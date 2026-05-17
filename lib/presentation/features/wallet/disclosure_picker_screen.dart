import 'package:flutter/material.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/security/biometric_service.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/wallet/sd_jwt_holder.dart';
import 'package:identity_frontend/core/wallet/vc_schemas.dart';
import 'package:identity_frontend/l10n/l10n.dart';

/// Disclosure Picker — Holder side of SD-JWT Selective Disclosure.
///
/// Flow:
///   1. Verifier requests credential type + required claims (via QR / deeplink extra).
///   2. This screen loads the SD-JWT from wallet, pre-ticks required claims.
///   3. Holder can tick additional claims optionally.
///   4. "Sign & Present" → biometric gate → build presentation → POST to /sd-jwt/present.
///   5. Returns presentation string to caller via Navigator.pop().
class DisclosurePickerScreen extends StatefulWidget {
  final String sdJwt;
  final String credentialType;
  final List<String> requiredClaims;

  const DisclosurePickerScreen({
    super.key,
    required this.sdJwt,
    required this.credentialType,
    this.requiredClaims = const [],
  });

  @override
  State<DisclosurePickerScreen> createState() => _DisclosurePickerScreenState();
}

class _DisclosurePickerScreenState extends State<DisclosurePickerScreen> {
  late SdJwtCredential _credential;
  bool _signing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _credential = SdJwtCredential.parse(widget.sdJwt);
    _credential.selectByNames(widget.requiredClaims);
  }

  Future<void> _signAndPresent() async {
    setState(() {
      _signing = true;
      _error = null;
    });
    try {
      final authed = await BiometricService.authenticateNow(
        reason: 'Touch to sign your credential presentation',
      );
      if (!authed) {
        setState(() {
          _error = context.l10n.disclosureBiometricCancelled;
          _signing = false;
        });
        return;
      }

      final revealNames = _credential.disclosures
          .where((d) => d.selected)
          .map((d) => d.claimName)
          .toList();

      // Option A (demo): backend builds presentation
      final res = await ApiClient.instance.post(ApiConstants.sdJwtPresent, data: {
        'sdJwt': widget.sdJwt,
        'reveal': revealNames,
      });
      final presentation =
          (res.data['data'] as Map<String, dynamic>)['presentation'] as String;

      if (mounted) Navigator.of(context).pop(presentation);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _signing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final required = widget.requiredClaims.toSet();
    final requiredDisclosures =
        _credential.disclosures.where((d) => required.contains(d.claimName)).toList();
    final optionalDisclosures =
        _credential.disclosures.where((d) => !required.contains(d.claimName)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.disclosureShareTitle(humanizeVcType(widget.credentialType)),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            if (widget.requiredClaims.isNotEmpty)
              Text(context.l10n.disclosureClaimsRequested(widget.requiredClaims.length),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: _signing
          ? _buildSigning()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildInfoBanner(),
                      const SizedBox(height: 16),
                      if (requiredDisclosures.isNotEmpty) ...[
                        _sectionHeader(context.l10n.disclosureVerifierWants,
                            Icons.verified_outlined, AppColors.primary),
                        const SizedBox(height: 8),
                        ...requiredDisclosures.map(_buildDisclosureRow),
                        const SizedBox(height: 16),
                      ],
                      if (optionalDisclosures.isNotEmpty) ...[
                        _sectionHeader(context.l10n.disclosureOptional,
                            Icons.visibility_outlined, AppColors.textSecondary),
                        const SizedBox(height: 8),
                        ...optionalDisclosures.map(_buildDisclosureRow),
                        const SizedBox(height: 16),
                      ],
                      _buildPrivacyNote(),
                    ],
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(_error!,
                        style: const TextStyle(color: AppColors.error, fontSize: 12)),
                  ),
                _buildSignButton(),
              ],
            ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha:0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.disclosureInfoBanner,
              style: TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(title,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _buildDisclosureRow(SdJwtDisclosure d) {
    final isRequired = widget.requiredClaims.contains(d.claimName);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: d.selected ? AppColors.primary.withValues(alpha:0.4) : AppColors.border,
        ),
      ),
      child: CheckboxListTile(
        value: d.selected,
        onChanged: (v) => setState(() => d.selected = v ?? false),
        title: Text(humanizeFieldKey(d.claimName),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(_formatValue(d.claimValue),
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        secondary: isRequired
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(context.l10n.disclosureRequired,
                    style: TextStyle(fontSize: 10, color: AppColors.primary)),
              )
            : null,
        activeColor: AppColors.primary,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha:0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.disclosurePrivacyNote,
              style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignButton() {
    final anySelected = _credential.disclosures.any((d) => d.selected);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: anySelected ? _signAndPresent : null,
            icon: const Icon(Icons.fingerprint, size: 22),
            label: Text(context.l10n.disclosureSignBiometric,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.border,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSigning() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(context.l10n.disclosureSigningBiometric, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  String _formatValue(dynamic v) {
    if (v is String) return v;
    return v.toString();
  }
}
