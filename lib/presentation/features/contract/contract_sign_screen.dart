import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/core/wallet/wallet_service.dart';
import 'package:identity_frontend/l10n/l10n.dart';

/// ContractSignScreen — E-sign a contract using the employee's ECDSA P-256 key.
///
/// Demo flow (step 6 in the 8-step demo):
///   1. Screen loads contract details from the backend.
///   2. Employee taps "Sign with Biometric".
///   3. BiometricService prompts fingerprint/face.
///   4. WalletService.signDocument computes SHA-256(docBytes) + ECDSA P-256 sign.
///   5. POST /api/v1/contracts/{id}/sign → backend anchors on Fabric.
///   6. UI shows "SIGNED — anchored on blockchain" with on-chain timestamp.
///
/// For demo purposes docBytes is derived from the contract JSON payload.
/// In production, the manager uploads the PDF and this screen receives its URL.
class ContractSignScreen extends StatefulWidget {
  final int contractId;
  final String? contractType;
  final String? startDate;
  final String? endDate;

  const ContractSignScreen({
    super.key,
    required this.contractId,
    this.contractType,
    this.startDate,
    this.endDate,
  });

  @override
  State<ContractSignScreen> createState() => _ContractSignScreenState();
}

class _ContractSignScreenState extends State<ContractSignScreen> {
  _SignState _state = _SignState.idle;
  String? _errorMessage;
  Map<String, dynamic>? _anchorResult;
  List<Map<String, dynamic>> _signatures = [];

  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = Dio(BaseOptions(baseUrl: _baseUrl));
    _loadSignatures();
  }

  String get _baseUrl {
    // Android emulator: 10.0.2.2, physical device: your local IP
    return const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8080/api/v1');
  }

  Future<void> _loadSignatures() async {
    try {
      final token = await SecureStorage.getToken();
      final res = await _dio.get(
        '/contracts/${widget.contractId}/signatures',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (res.statusCode == 200 && mounted) {
        final data = (res.data['data'] as List? ?? []).cast<Map<String, dynamic>>();
        setState(() => _signatures = data);
      }
    } catch (_) {}
  }

  Future<void> _sign() async {
    setState(() {
      _state = _SignState.authenticating;
      _errorMessage = null;
    });

    try {
      // Build deterministic doc bytes from contract metadata (demo).
      // Production: fetch actual PDF bytes from /contracts/{id}/document.
      final docString = jsonEncode({
        'contractId': widget.contractId,
        'type': widget.contractType ?? 'FULL_TIME',
        'startDate': widget.startDate ?? '',
        'endDate': widget.endDate ?? '',
        'platform': 'TrustID',
      });
      final docBytes = Uint8List.fromList(utf8.encode(docString));

      setState(() => _state = _SignState.signing);

      final (:signatureBase64, :docHash) = await WalletService.signDocument(
        docBytes,
        biometricReason: 'Touch to sign contract #${widget.contractId}',
      );

      final signerDid = await SecureStorage.getDid() ??
          'did:fabric:trustid:${await SecureStorage.getEmployeeNumericId() ?? "unknown"}';

      setState(() => _state = _SignState.anchoring);

      final token = await SecureStorage.getToken();
      final res = await _dio.post(
        '/contracts/${widget.contractId}/sign',
        data: {
          'signatureBase64': signatureBase64,
          'docHash': docHash,
          'signerDid': signerDid,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (res.statusCode == 200 && mounted) {
        setState(() {
          _state = _SignState.done;
          _anchorResult = res.data['data'] as Map<String, dynamic>?;
        });
        await _loadSignatures();
      }
    } on WalletBiometricException {
      setState(() {
        _state = _SignState.idle;
        _errorMessage = context.l10n.contractBiometricCancelled;
      });
    } on WalletNotInitializedException {
      setState(() {
        _state = _SignState.idle;
        _errorMessage = context.l10n.contractWalletNotInit;
      });
    } on DioException catch (e) {
      setState(() {
        _state = _SignState.idle;
        _errorMessage = context.l10n.contractBackendError(e.response?.data?.toString() ?? e.message ?? '');
      });
    } catch (e) {
      setState(() {
        _state = _SignState.idle;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSigned = _state == _SignState.done ||
        _signatures.any((s) => s['signerDid']?.toString().contains(
              RegExp(r'trustid:'),
            ) ==
            true);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.contractSignTitle(widget.contractId.toString())),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Contract details card
            _InfoCard(
              title: context.l10n.contractDetails,
              icon: Icons.description_outlined,
              rows: [
                (context.l10n.contractContractId, '#${widget.contractId}'),
                (context.l10n.contractType, widget.contractType ?? '—'),
                (context.l10n.contractStart, widget.startDate ?? '—'),
                (context.l10n.contractEnd, widget.endDate ?? context.l10n.contractOpenEnded),
              ],
            ),
            const SizedBox(height: 16),

            // Signature status
            if (_signatures.isNotEmpty) ...[
              _SignatureListCard(signatures: _signatures),
              const SizedBox(height: 16),
            ],

            // Success banner
            if (_state == _SignState.done && _anchorResult != null)
              _SuccessBanner(result: _anchorResult!),

            // Error
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),

            // Sign button
            if (!isSigned) ...[
              const SizedBox(height: 8),
              _buildSignButton(theme),
            ],

            const SizedBox(height: 24),
            // Explainer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                context.l10n.contractExplainer,
                style: const TextStyle(fontSize: 12, color: Colors.indigo),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignButton(ThemeData theme) {
    final busy = _state == _SignState.authenticating ||
        _state == _SignState.signing ||
        _state == _SignState.anchoring;

    final l10n = context.l10n;
    String label;
    switch (_state) {
      case _SignState.authenticating:
        label = l10n.contractSignWaiting;
      case _SignState.signing:
        label = l10n.contractSignSigning;
      case _SignState.anchoring:
        label = l10n.contractSignAnchoring;
      default:
        label = l10n.contractSignBiometric;
    }

    return ElevatedButton.icon(
      onPressed: busy ? null : _sign,
      icon: busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.fingerprint),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

enum _SignState { idle, authenticating, signing, anchoring, done }

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<(String, String)> rows;

  const _InfoCard({required this.title, required this.icon, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            const Divider(height: 20),
            ...rows.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r.$1, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      Text(r.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _SignatureListCard extends StatelessWidget {
  final List<Map<String, dynamic>> signatures;
  const _SignatureListCard({required this.signatures});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.green.shade200),
      ),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.verified, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Text(context.l10n.contractOnChainSignatures, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
            ]),
            const Divider(height: 16),
            ...signatures.map((sig) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sig['signerDid'] ?? '—',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                      ),
                      Text(
                        '${context.l10n.contractSignedAt} ${sig['signedAt'] ?? '—'}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      Text(
                        '${context.l10n.contractDocHash} ${(sig['docHash'] as String? ?? '').substring(0, 16)}…',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final Map<String, dynamic> result;
  const _SuccessBanner({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(context.l10n.contractSignatureAnchored,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.green)),
            ]),
            const SizedBox(height: 8),
            _row('Contract', '#${result['contractId']}'),
            _row('Signer DID', result['signerDid'] ?? '—'),
            _row('Doc Hash', '${(result['docHash'] as String? ?? '').substring(0, 16)}…'),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
