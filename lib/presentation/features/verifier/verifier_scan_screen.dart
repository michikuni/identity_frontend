import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/qr/vc_qr_payload_codec.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/core/wallet/vc_schemas.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// VerifierScanScreen — Verifier-side QR scanner for OID4VP flow.
///
/// Two modes:
///   [Mode A] Scan employee's VC/VP QR → verify inline via POST /identity/vc/verify
///   [Mode B] Generate VP Request QR → employee scans it → Verifier polls result
class VerifierScanScreen extends StatefulWidget {
  const VerifierScanScreen({super.key});

  @override
  State<VerifierScanScreen> createState() => _VerifierScanScreenState();
}

class _VerifierScanScreenState extends State<VerifierScanScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final MobileScannerController _scannerCtrl;

  // ── Mode A state ─────────────────────────────────────────────────────────
  bool _modeAScanning = true;
  _VerifyResult? _modeAResult;

  // ── Mode B state ─────────────────────────────────────────────────────────
  bool _modeBLoading = false;
  String? _modeBState;
  String? _modeBQrData;
  _PollStatus _modeBStatus = _PollStatus.idle;
  String _modeBReason = '';
  Map<String, dynamic> _modeBDisclosedFields = {};
  // vcType -> set field đã chọn. Mỗi lần tạo VP Request chỉ chọn được field
  // trong CÙNG 1 VC — các nhóm còn lại bị disable.
  final Map<String, Set<String>> _modeBSelected = {
    for (final t in kVcSchemas.keys) t: <String>{},
  };

  @override
  void initState() {
    super.initState();
    _scannerCtrl = MobileScannerController();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    setState(() {});
    if (_tabController.index == 0 && _modeAResult == null) {
      _modeAScanning = true;
      _scannerCtrl.start().ignore();
    } else {
      _scannerCtrl.stop().ignore();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scannerCtrl.dispose();
    super.dispose();
  }

  // ── Mode A: scan employee VC QR ──────────────────────────────────────────

  Future<void> _onQrDetected(BarcodeCapture capture) async {
    if (!_modeAScanning) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    // Short-token path: QR chứa vcid:<id> (có thể kèm ?fields=a,b,c để selective disclosure)
    if (VcQrPayloadCodec.isVcIdToken(raw)) {
      final vcId = VcQrPayloadCodec.extractVcId(raw)!;
      final disclosed = VcQrPayloadCodec.extractDisclosedFields(raw);
      _modeAScanning = false;
      _scannerCtrl.stop().ignore();
      await _verifyByVcId(vcId, disclosedFields: disclosed);
      return;
    }

    String? decodedPayload = VcQrPayloadCodec.decode(raw);
    if (decodedPayload == null) return;

    // Bỏ qua nếu là VP Request QR (Mode B) chứ không phải VC
    try {
      final parsed = jsonDecode(decodedPayload) as Map<String, dynamic>;
      if (parsed.containsKey('response_type') ||
          parsed.containsKey('presentation_definition')) return;
    } catch (_) {}

    _modeAScanning = false;
    _scannerCtrl.stop().ignore();

    Map<String, dynamic>? subject;
    try {
      final parsed = jsonDecode(decodedPayload) as Map<String, dynamic>;
      subject = parsed['credentialSubject'] as Map<String, dynamic>?;
    } catch (_) {}

    try {
      final res = await ApiClient.instance.post(
        ApiConstants.verifyVC,
        data: {'vc': decodedPayload},
      );
      final data = res.data['data'] as Map<String, dynamic>? ?? {};
      setState(() => _modeAResult = _VerifyResult(
            valid: data['valid'] as bool? ?? false,
            reason: data['reason'] as String? ?? '',
            subject: subject,
            vcType: data['type'] as List<dynamic>?,
          ));
    } catch (e) {
      setState(() => _modeAResult = _VerifyResult(
            valid: false,
            reason: 'Network error: $e',
            subject: subject,
          ));
    }
  }

  Future<void> _verifyByVcId(String vcId, {List<String>? disclosedFields}) async {
    try {
      final res = await ApiClient.instance.get(ApiConstants.verifyVCById(vcId));
      final data = res.data['data'] as Map<String, dynamic>? ?? {};
      var subject = data['credentialSubject'] as Map<String, dynamic>?;
      final vcType = data['type'] as List<dynamic>?;

      // Selective disclosure (Hướng A) — backend trả full VC, ta filter UI
      // theo danh sách field trong QR. Luôn giữ lại 'id' để hiển thị DID nếu có.
      if (subject != null && disclosedFields != null) {
        final allowed = {...disclosedFields, 'id'};
        subject = Map<String, dynamic>.fromEntries(
          subject.entries.where((e) => allowed.contains(e.key)),
        );
      }

      setState(() => _modeAResult = _VerifyResult(
            valid: data['valid'] as bool? ?? false,
            reason: data['reason'] as String? ?? '',
            subject: subject,
            vcType: vcType,
          ));
    } catch (e) {
      setState(() => _modeAResult = _VerifyResult(
            valid: false,
            reason: 'Network error: $e',
          ));
    }
  }

  void _resetModeA() {
    _modeAScanning = true;
    setState(() => _modeAResult = null);
    _scannerCtrl.start().ignore();
  }

  // ── Mode B: generate VP Request QR ──────────────────────────────────────

  /// Trả về vcType đang được chọn (có ít nhất 1 field tick) hoặc null nếu chưa chọn gì.
  String? get _activeVcType {
    for (final entry in _modeBSelected.entries) {
      if (entry.value.isNotEmpty) return entry.key;
    }
    return null;
  }

  Future<void> _createVpRequest() async {
    final activeType = _activeVcType;
    final claims = activeType != null
        ? _modeBSelected[activeType]!.toList()
        : <String>[];
    if (activeType == null || claims.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.verifierSelectAtLeastOne),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.warning,
      ));
      return;
    }

    setState(() {
      _modeBLoading = true;
      _modeBState = null;
      _modeBQrData = null;
      _modeBStatus = _PollStatus.idle;
    });

    try {
      final res = await ApiClient.instance.post(
        ApiConstants.oidcVpRequest,
        data: {
          'vcType': activeType,
          'requestedClaims': claims,
        },
      );
      final data = res.data['data'] as Map<String, dynamic>? ?? {};
      final state = data['state'] as String?;
      final authReq = data['authorizationRequest'];

      setState(() {
        _modeBState = state;
        _modeBQrData = jsonEncode(authReq);
        _modeBStatus = _PollStatus.pending;
        _modeBLoading = false;
      });
    } catch (e) {
      setState(() => _modeBLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.verifierCreateVpRequestFailed(e.toString())),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  Future<void> _pollResult() async {
    if (_modeBState == null) return;
    try {
      final res =
          await ApiClient.instance.get(ApiConstants.oidcVpResult(_modeBState!));
      final data = res.data['data'] as Map<String, dynamic>? ?? {};
      final status = data['status'] as String? ?? 'PENDING';
      final reason = data['reason'] as String? ?? '';
      final disclosed = data['disclosedFields'] as Map<String, dynamic>? ?? {};

      final newStatus = status == 'ACCEPTED'
          ? _PollStatus.accepted
          : status == 'REJECTED'
              ? _PollStatus.rejected
              : _PollStatus.pending;

      setState(() {
        _modeBReason = reason;
        _modeBDisclosedFields = disclosed;
        _modeBStatus = newStatus;
      });

      // Hiển thị popup kết quả khi đã có phản hồi từ Employee
      if (newStatus == _PollStatus.accepted && mounted) {
        _showResultPopup(disclosed);
      } else if (newStatus == _PollStatus.rejected && mounted) {
        _showResultPopup({}, reason: reason, rejected: true);
      } else if (newStatus == _PollStatus.pending && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.verifierPollStillPending),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.warning,
        ));
      }
    } catch (_) {}
  }

  void _showResultPopup(
    Map<String, dynamic> disclosed, {
    String reason = '',
    bool rejected = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              rejected ? Icons.cancel_rounded : Icons.verified_rounded,
              color: rejected ? AppColors.error : AppColors.success,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              rejected ? AppLocalizations.of(context)!.verifierVpRejectedTitle : AppLocalizations.of(context)!.verifierVpSharedTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: rejected ? AppColors.error : AppColors.success,
              ),
            ),
          ],
        ),
        content: rejected
            ? Text(
                reason.isNotEmpty ? reason : AppLocalizations.of(context)!.verifierVpInvalidDefault,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              )
            : disclosed.isEmpty
                ? Text(
                    AppLocalizations.of(context)!.verifierEmployeeConfirmedNoFields,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.verifierEmployeeSharedInfo,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: disclosed.entries
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 120,
                                          child: Text(
                                            humanizeFieldKey(e.key),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${e.value}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: rejected ? AppColors.error : AppColors.success,
            ),
            child: Text(AppLocalizations.of(context)!.verifierClose),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.verifierTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: Column(
            children: [
              Container(height: 1, color: AppColors.border),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                    text: AppLocalizations.of(context)!.verifierVerifyVc,
                    iconMargin: const EdgeInsets.only(bottom: 2),
                  ),
                  Tab(
                    icon: const Icon(Icons.rule_rounded, size: 18),
                    text: AppLocalizations.of(context)!.verifierRequestVp,
                    iconMargin: const EdgeInsets.only(bottom: 2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildModeA(),
          _buildModeB(),
        ],
      ),
    );
  }

  // ── Mode A UI ────────────────────────────────────────────────────────────

  Widget _buildModeA() {
    if (_modeAResult != null) {
      return _VerifyResultCard(
        result: _modeAResult!,
        onReset: _resetModeA,
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              MobileScanner(
                controller: _scannerCtrl,
                onDetect: _onQrDetected,
              ),
              // Viewfinder overlay
              Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 2.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              const Icon(Icons.qr_code_scanner_rounded,
                  color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.verifierScanInstruction,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context)!.verifierScanDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Mode B UI ────────────────────────────────────────────────────────────

  /// Render 4 nhóm field (1 nhóm / VC). Khi user tick field đầu tiên ở 1 nhóm,
  /// các nhóm khác bị disable (xám) để đảm bảo mỗi VP Request chỉ request 1 VC.
  List<Widget> _buildModeBVcGroups() {
    final activeType = _activeVcType;
    final pollLocked = _modeBStatus == _PollStatus.pending;
    final widgets = <Widget>[];
    final entries = kVcSchemas.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final type = entries[i].key;
      final schema = entries[i].value;
      final selected = _modeBSelected[type]!;
      final groupDisabled = pollLocked || (activeType != null && activeType != type);

      widgets.add(_SectionCard(
        title: schema.label,
        child: Opacity(
          opacity: groupDisabled ? 0.45 : 1.0,
          child: Column(
            children: [
              for (final field in schema.fields)
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(humanizeFieldKey(field), style: const TextStyle(fontSize: 13)),
                  value: selected.contains(field),
                  onChanged: groupDisabled
                      ? null
                      : (val) => setState(() {
                            if (val == true) {
                              selected.add(field);
                            } else {
                              selected.remove(field);
                            }
                          }),
                ),
            ],
          ),
        ),
      ));
      if (i < entries.length - 1) widgets.add(const SizedBox(height: 12));
    }
    return widgets;
  }

  Widget _buildModeB() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // How-it-works banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.verifierHowItWorks,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.verifierHowItWorksSteps,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Claim selector — gom theo VC, mỗi lần chỉ chọn được 1 VC
          ..._buildModeBVcGroups(),
          const SizedBox(height: 16),

          // Create request button
          if (_modeBStatus == _PollStatus.idle ||
              _modeBStatus == _PollStatus.accepted ||
              _modeBStatus == _PollStatus.rejected) ...[
            FilledButton.icon(
              icon: _modeBLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.qr_code_2_rounded),
              label: Text(AppLocalizations.of(context)!.verifierCreateQrBtn),
              onPressed: _modeBLoading ? null : _createVpRequest,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // QR display + poll
          if (_modeBQrData != null) ...[
            _SectionCard(
              title: AppLocalizations.of(context)!.verifierQrTitle,
              child: Column(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Image.network(
                        'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${Uri.encodeComponent(_modeBQrData!)}',
                        width: 200,
                        height: 200,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_rounded,
                            size: 80,
                            color: AppColors.inactive),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'State: ${_modeBState ?? "-"}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Poll status
            _PollStatusCard(
              status: _modeBStatus,
              reason: _modeBReason,
              disclosedFields: _modeBDisclosedFields,
            ),
            const SizedBox(height: 12),

            if (_modeBStatus == _PollStatus.pending)
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(AppLocalizations.of(context)!.verifierCheckResult),
                onPressed: _pollResult,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ── Result card ────────────────────────────────────────────────────────────────

class _VerifyResult {
  final bool valid;
  final String reason;
  final Map<String, dynamic>? subject;
  final List<dynamic>? vcType;
  final Map<String, dynamic>? disclosedClaims; // SD-JWT only

  const _VerifyResult({
    required this.valid,
    required this.reason,
    this.subject,
    this.vcType,
    this.disclosedClaims,
  });

  bool get isRevoked => !valid && reason.toLowerCase().contains('revoked');
  bool get isSdJwt => disclosedClaims != null;

  String get credentialLabel {
    if (vcType == null) return humanizeVcType(null);
    for (final t in ['PromotionCredential', 'TerminationCredential', 'SalaryRangeCredential', 'EmploymentCredential']) {
      if (vcType!.contains(t)) return humanizeVcType(t);
    }
    return humanizeVcType(null);
  }
}

class _VerifyResultCard extends StatelessWidget {
  final _VerifyResult result;
  final VoidCallback onReset;
  const _VerifyResultCard({required this.result, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final color = result.valid
        ? AppColors.success
        : result.isRevoked
            ? const Color(0xFFB91C1C)
            : AppColors.error;
    final bgColor = result.valid
        ? AppColors.successLight
        : result.isRevoked
            ? const Color(0xFFFEF2F2)
            : AppColors.errorLight;
    final icon = result.valid
        ? Icons.verified_rounded
        : result.isRevoked
            ? Icons.block_rounded
            : Icons.cancel_rounded;
    final l10n = AppLocalizations.of(context)!;
    final label = result.valid
        ? l10n.verifierResultValid
        : result.isRevoked
            ? l10n.vcCredentialRevoked
            : l10n.verifierResultInvalid;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 56),
                const SizedBox(height: 12),
                Text(label,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: color)),
                const SizedBox(height: 4),
                Text(result.credentialLabel,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color.withValues(alpha: 0.8))),
                const SizedBox(height: 6),
                Text(result.reason,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // SD-JWT disclosed claims section
          if (result.isSdJwt && result.disclosedClaims != null && result.disclosedClaims!.isNotEmpty) ...[
            _SectionCard(
              title: AppLocalizations.of(context)!.vcSelectiveDisclosedClaims,
              child: Column(
                children: result.disclosedClaims!.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.visibility_outlined, size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 110,
                        child: Text(humanizeFieldKey(e.key),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        child: Text(e.value.toString(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Disclosed subject fields
          if (!result.isSdJwt && result.subject != null && result.subject!.isNotEmpty) ...[
            _SectionCard(
              title: AppLocalizations.of(context)!.verifierDisclosedInfo,
              child: Column(
                children: result.subject!.entries
                    .where((e) => e.key != 'id')
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(humanizeFieldKey(e.key),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Expanded(
                                child: Text(e.value.toString(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary)),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          OutlinedButton.icon(
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
            label: Text(AppLocalizations.of(context)!.verifierScanAgain),
            onPressed: onReset,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Poll status card ───────────────────────────────────────────────────────────

enum _PollStatus { idle, pending, accepted, rejected }

class _PollStatusCard extends StatelessWidget {
  final _PollStatus status;
  final String reason;
  final Map<String, dynamic> disclosedFields;
  const _PollStatusCard({
    required this.status,
    required this.reason,
    this.disclosedFields = const {},
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (icon, label, color, bg) = switch (status) {
      _PollStatus.idle     => (Icons.hourglass_empty_rounded, l10n.verifierPollIdle, AppColors.inactive, AppColors.surfaceVariant),
      _PollStatus.pending  => (Icons.hourglass_top_rounded, l10n.verifierPollPending, AppColors.warning, AppColors.warningLight),
      _PollStatus.accepted => (Icons.verified_rounded, l10n.verifierPollAccepted, AppColors.success, AppColors.successLight),
      _PollStatus.rejected => (Icons.cancel_rounded, l10n.verifierPollRejected, AppColors.error, AppColors.errorLight),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color)),
                    if (reason.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(reason,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (status == _PollStatus.accepted && disclosedFields.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.verifierSharedInfo,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            ...disclosedFields.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          humanizeFieldKey(e.key),
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${e.value}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// ── Shared section card ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
