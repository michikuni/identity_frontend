import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/qr/vc_qr_payload_codec.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
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
  List<String> _modeBClaims = ['employmentStatus', 'position'];

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

    // Short-token path: QR chứa vcid:<id> thay vì toàn bộ VC JSON
    if (VcQrPayloadCodec.isVcIdToken(raw)) {
      final vcId = VcQrPayloadCodec.extractVcId(raw)!;
      _modeAScanning = false;
      _scannerCtrl.stop().ignore();
      await _verifyByVcId(vcId);
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

  Future<void> _verifyByVcId(String vcId) async {
    try {
      final res = await ApiClient.instance.get(ApiConstants.verifyVCById(vcId));
      final data = res.data['data'] as Map<String, dynamic>? ?? {};
      final subject = data['credentialSubject'] as Map<String, dynamic>?;
      final vcType = data['type'] as List<dynamic>?;
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

  Future<void> _createVpRequest() async {
    setState(() {
      _modeBLoading = true;
      _modeBState = null;
      _modeBQrData = null;
      _modeBStatus = _PollStatus.idle;
    });

    try {
      final res = await ApiClient.instance.post(
        ApiConstants.oidcVpRequest,
        data: {'requestedClaims': _modeBClaims},
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
          content: Text('Tạo VP Request thất bại: $e'),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Employee chưa quét QR hoặc chưa xác nhận chia sẻ'),
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
              rejected ? 'VP bị từ chối' : 'Thông tin được chia sẻ',
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
                reason.isNotEmpty ? reason : 'VP không hợp lệ hoặc bị từ chối',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              )
            : disclosed.isEmpty
                ? const Text(
                    'Employee đã xác nhận nhưng không có trường nào được chia sẻ.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Employee đã xác nhận và chia sẻ các thông tin sau:',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                                            e.key,
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
            child: const Text('Đóng'),
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
        title: const Text('Verifier'),
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
                tabs: const [
                  Tab(
                    icon: Icon(Icons.qr_code_scanner_rounded, size: 18),
                    text: 'Xác minh VC',
                    iconMargin: EdgeInsets.only(bottom: 2),
                  ),
                  Tab(
                    icon: Icon(Icons.rule_rounded, size: 18),
                    text: 'Yêu cầu VP',
                    iconMargin: EdgeInsets.only(bottom: 2),
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
          child: const Column(
            children: [
              Icon(Icons.qr_code_scanner_rounded,
                  color: AppColors.primary, size: 28),
              SizedBox(height: 8),
              Text(
                'Hướng camera vào QR Code trên app của Employee',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              SizedBox(height: 6),
              Text(
                'Chấp nhận 2 loại QR:\n'
                '• QR từ nút "Xuất QR" — xác minh VC trực tiếp\n'
                '• QR từ nút "Present VP" — xác minh VP Token đã được Employee ký',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Mode B UI ────────────────────────────────────────────────────────────

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
                  children: const [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Cách hoạt động',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Chọn thông tin bạn muốn Employee cung cấp\n'
                  '2. Nhấn "Tạo VP Request QR" → QR được tạo\n'
                  '3. Cho Employee quét QR này bằng app của họ\n'
                  '4. Employee xem xét và gửi Verifiable Presentation\n'
                  '5. Nhấn "Kiểm tra kết quả" để xem thông tin Employee đã chia sẻ',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Claim selector
          _SectionCard(
            title: 'Thông tin muốn yêu cầu Employee cung cấp',
            child: Column(
              children: [
                for (final claim in [
                  'employmentStatus',
                  'department',
                  'position',
                  'startDate',
                ])
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(claim,
                        style: const TextStyle(fontSize: 13)),
                    value: _modeBClaims.contains(claim),
                    onChanged: _modeBStatus == _PollStatus.pending
                        ? null
                        : (val) => setState(() {
                              val == true
                                  ? _modeBClaims.add(claim)
                                  : _modeBClaims.remove(claim);
                            }),
                  ),
              ],
            ),
          ),
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
              label: const Text('Bước 2 — Tạo QR cho Employee quét'),
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
              title: 'Bước 3 — Cho Employee quét QR này',
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
                label: const Text('Bước 5 — Kiểm tra kết quả'),
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
  const _VerifyResult({required this.valid, required this.reason, this.subject, this.vcType});

  String get credentialLabel {
    if (vcType == null) return 'Verifiable Credential';
    if (vcType!.contains('PromotionCredential')) return 'Promotion Credential';
    if (vcType!.contains('TerminationCredential')) return 'Termination Credential';
    if (vcType!.contains('SalaryRangeCredential')) return 'Salary Range Credential';
    if (vcType!.contains('EmploymentCredential')) return 'Employment Credential';
    return 'Verifiable Credential';
  }
}

class _VerifyResultCard extends StatelessWidget {
  final _VerifyResult result;
  final VoidCallback onReset;
  const _VerifyResultCard({required this.result, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final color = result.valid ? AppColors.success : AppColors.error;
    final bgColor = result.valid ? AppColors.successLight : AppColors.errorLight;
    final icon = result.valid ? Icons.verified_rounded : Icons.cancel_rounded;
    final label = result.valid ? 'HỢP LỆ' : 'KHÔNG HỢP LỆ';

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

          // Disclosed subject fields
          if (result.subject != null && result.subject!.isNotEmpty) ...[
            _SectionCard(
              title: 'Thông tin được tiết lộ',
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
                                child: Text(e.key,
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
            label: const Text('Quét lại'),
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
    final (icon, label, color, bg) = switch (status) {
      _PollStatus.idle     => (Icons.hourglass_empty_rounded, 'Chưa có yêu cầu nào', AppColors.inactive, AppColors.surfaceVariant),
      _PollStatus.pending  => (Icons.hourglass_top_rounded, 'Chờ Employee quét QR và gửi VP...', AppColors.warning, AppColors.warningLight),
      _PollStatus.accepted => (Icons.verified_rounded, 'Employee đã gửi VP — Đã xác minh hợp lệ', AppColors.success, AppColors.successLight),
      _PollStatus.rejected => (Icons.cancel_rounded, 'VP không hợp lệ hoặc bị từ chối', AppColors.error, AppColors.errorLight),
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
            const Text(
              'Thông tin Employee đã chia sẻ',
              style: TextStyle(
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
                          e.key,
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
