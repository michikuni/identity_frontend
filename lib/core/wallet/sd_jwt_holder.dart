import 'dart:convert';

/// Parses a compact SD-JWT string and provides selective-disclosure presentation builder.
///
/// Wire format: `<header>.<payload>.<signature>~<disclosure_1>~<disclosure_2>~...~`
///
/// Each disclosure is base64url-encoded JSON array: [salt, claim_name, claim_value]
class SdJwtDisclosure {
  final String raw;
  final String claimName;
  final dynamic claimValue;
  bool selected;

  SdJwtDisclosure({
    required this.raw,
    required this.claimName,
    required this.claimValue,
    this.selected = false,
  });
}

class SdJwtCredential {
  final String jwtPart; // header.payload.signature
  final Map<String, dynamic> alwaysVisibleClaims; // non-SD claims from payload
  final List<SdJwtDisclosure> disclosures;

  SdJwtCredential({
    required this.jwtPart,
    required this.alwaysVisibleClaims,
    required this.disclosures,
  });

  static SdJwtCredential parse(String sdJwt) {
    final parts = sdJwt.split('~');
    final jwtPart = parts.first;

    // Decode payload to extract always-visible claims
    Map<String, dynamic> alwaysVisible = {};
    try {
      final segments = jwtPart.split('.');
      if (segments.length >= 2) {
        final padded = _base64Pad(segments[1]);
        final decoded = utf8.decode(base64Url.decode(padded));
        final payload = jsonDecode(decoded) as Map<String, dynamic>;
        // Remove SD machinery fields; keep human-readable claims
        alwaysVisible = Map.from(payload)
          ..remove('_sd')
          ..remove('_sd_alg')
          ..remove('status')
          ..remove('iss')
          ..remove('sub')
          ..remove('iat')
          ..remove('exp');
      }
    } catch (_) {}

    final rawDisclosures = parts.skip(1).where((s) => s.isNotEmpty).toList();
    final disclosures = <SdJwtDisclosure>[];

    for (final raw in rawDisclosures) {
      try {
        final padded = _base64Pad(raw);
        final decoded = utf8.decode(base64Url.decode(padded));
        final arr = jsonDecode(decoded) as List<dynamic>;
        if (arr.length >= 3) {
          disclosures.add(SdJwtDisclosure(
            raw: raw,
            claimName: arr[1].toString(),
            claimValue: arr[2],
          ));
        }
      } catch (_) {}
    }

    return SdJwtCredential(
      jwtPart: jwtPart,
      alwaysVisibleClaims: alwaysVisible,
      disclosures: disclosures,
    );
  }

  /// Builds a presentation by including only selected disclosures.
  String buildPresentation() {
    final selected = disclosures.where((d) => d.selected).map((d) => d.raw);
    return '$jwtPart~${selected.join('~')}~';
  }

  /// Selects disclosures for the given claim names (used by Verifier request pre-fill).
  void selectByNames(List<String> names) {
    for (final d in disclosures) {
      d.selected = names.contains(d.claimName);
    }
  }

  static String _base64Pad(String s) {
    final mod = s.length % 4;
    if (mod == 0) return s;
    return s + ('=' * (4 - mod));
  }
}
