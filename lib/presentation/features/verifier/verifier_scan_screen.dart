import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
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
  final MobileScannerController _scannerCtrl = MobileScannerController();

  // ── Mode A state ─────────────────────────────────────────────────────────
  bool _modeAScanning = true;
  _VerifyResult? _modeAResult;

  // ── Mode B state ─────────────────────────────────────────────────────────
  bool _modeBLoading = false;
  String? _modeBState;
  String? _modeBQrData;      // JSON of the authorizationRequest to show as QR
  _PollStatus _modeBStatus = _PollStatus.idle;
  String _modeBReason = '';
  List<String> _modeBClaims = ['employmentStatus', 'position'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scannerCtrl.dispose();
    super.dispose();
  }

  // ── Mode A: scan employee VC QR ──────────────────────────────────────────

  Future<void> _onQrDetected(BarcodeCapture capture) async {
    if (!_modeAScanning) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _modeAScanning = false);
    await _scannerCtrl.stop();

    // Try verify as VC JSON directly
    try {
      final res = await ApiClient.instance.post(
        ApiConstants.verifyVC,
        data: {'vc': raw},
      );
      final data = res.data['data'] as Map<String, dynamic>? ?? {};
      final valid = data['valid'] as bool? ?? false;
      final reason = data['reason'] as String? ?? '';

      // Also try to parse VC subject for display
      Map<String, dynamic>? subject;
      try {
        final vc = jsonDecode(raw) as Map<String, dynamic>;
        subject = vc['credentialSubject'] as Map<String, dynamic>?;
      } catch (_) {}

      setState(() => _modeAResult = _VerifyResult(
            valid: valid,
            reason: reason,
            subject: subject,
          ));
    } catch (e) {
      setState(() => _modeAResult = _VerifyResult(
            valid: false,
            reason: 'Network error: $e',
          ));
    }
  }

  void _resetModeA() {
    setState(() {
      _modeAScanning = true;
      _modeAResult = null;
    });
    _scannerCtrl.start();
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
      setState(() {
        _modeBReason = reason;
        _modeBStatus = status == 'ACCEPTED'
            ? _PollStatus.accepted
            : status == 'REJECTED'
                ? _PollStatus.rejected
                : _PollStatus.pending;
      });
    } catch (_) {}
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verifier — Xác minh VC'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(height: 1, color: AppColors.border),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Quét QR của Employee'),
                  Tab(text: 'Tạo VP Request'),
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
          padding: const EdgeInsets.all(20),
          child: const Column(
            children: [
              Icon(Icons.qr_code_scanner_rounded,
                  color: AppColors.primary, size: 32),
              SizedBox(height: 8),
              Text(
                'Hướng camera vào QR Code trên app của Employee',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              SizedBox(height: 4),
              Text(
                'Hỗ trợ: EmploymentVC, TerminationVC, VP Token',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 11, color: AppColors.inactive),
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
          // Claim selector
          _SectionCard(
            title: 'Yêu cầu thông tin',
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
              label: const Text('Tạo VP Request QR'),
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
              title: 'Cho Employee quét QR này',
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
            _PollStatusCard(status: _modeBStatus, reason: _modeBReason),
            const SizedBox(height: 12),

            if (_modeBStatus == _PollStatus.pending)
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Kiểm tra kết quả'),
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
  const _VerifyResult({required this.valid, required this.reason, this.subject});
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
  const _PollStatusCard({required this.status, required this.reason});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color, bg) = switch (status) {
      _PollStatus.idle     => (Icons.hourglass_empty_rounded, 'Chờ Employee quét QR', AppColors.inactive, AppColors.surfaceVariant),
      _PollStatus.pending  => (Icons.hourglass_top_rounded, 'Đang chờ Employee gửi VP...', AppColors.warning, AppColors.warningLight),
      _PollStatus.accepted => (Icons.verified_rounded, 'VP được chấp nhận', AppColors.success, AppColors.successLight),
      _PollStatus.rejected => (Icons.cancel_rounded, 'VP bị từ chối', AppColors.error, AppColors.errorLight),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
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
