import 'dart:convert';

import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';

/// Builds and submits a W3C Verifiable Presentation (VP) Token.
///
/// OID4VP flow (Holder side):
///   1. Scan QR → get state + nonce + requestedClaims
///   2. User picks which extra fields to include (selective disclosure)
///   3. [build] creates VP with only disclosed fields
///   4. [submit] POSTs VP Token to /oidc/vp/submit
class VpBuilder {
  VpBuilder._();

  /// Build a VP Token from [vcJson] disclosing only [disclosedFields].
  ///
  /// [nonce]  — from Authorization Request (replay-protection)
  /// [vcJson] — full VC JSON stored in SecureStorage
  /// [disclosedFields] — subset of credentialSubject keys to include
  static Map<String, dynamic> build({
    required String nonce,
    required String vcJson,
    required List<String> disclosedFields,
  }) {
    final vc = jsonDecode(vcJson) as Map<String, dynamic>;
    final fullSubject =
        vc['credentialSubject'] as Map<String, dynamic>? ?? {};

    // Selective disclosure — keep only fields the user chose + mandatory 'id'
    final disclosedSubject = <String, dynamic>{
      'id': fullSubject['id'],
    };
    for (final field in disclosedFields) {
      if (fullSubject.containsKey(field)) {
        disclosedSubject[field] = fullSubject[field];
      }
    }

    // Rebuild VC with only disclosed subject (proof stays intact — Verifier
    // verifies the original VC proof separately)
    final disclosedVc = Map<String, dynamic>.from(vc)
      ..['credentialSubject'] = disclosedSubject;

    return {
      '@context': ['https://www.w3.org/2018/credentials/v1'],
      'type': ['VerifiablePresentation'],
      'verifiableCredential': [disclosedVc],
      'proof': {
        'type': 'HMAC-SHA256',
        'nonce': nonce,
        'created': DateTime.now().toUtc().toIso8601String(),
        'verificationMethod': 'did:fabric:trustid:org1#key-1',
        // Holder proof is the nonce itself for PoC — production uses Ed25519
        'proofValue': nonce,
      },
    };
  }

  /// Submit VP Token to the backend and return the result.
  static Future<VpSubmitResult> submit({
    required String state,
    required String nonce,
    required String vcJson,
    required List<String> disclosedFields,
  }) async {
    final vp = build(nonce: nonce, vcJson: vcJson, disclosedFields: disclosedFields);
    final vpJson = jsonEncode(vp);

    final res = await ApiClient.instance.post(
      ApiConstants.oidcVpSubmit,
      data: {'state': state, 'vpToken': vpJson},
    );

    final data = res.data['data'] as Map<String, dynamic>? ?? {};
    return VpSubmitResult(
      valid: data['valid'] as bool? ?? false,
      reason: data['reason'] as String? ?? '',
    );
  }

  /// Fetch the current result of a VP session (for Verifier polling).
  static Future<Map<String, dynamic>> pollResult(String state) async {
    final res = await ApiClient.instance.get(ApiConstants.oidcVpResult(state));
    return res.data['data'] as Map<String, dynamic>? ?? {};
  }
}

class VpSubmitResult {
  final bool valid;
  final String reason;
  const VpSubmitResult({required this.valid, required this.reason});
}
