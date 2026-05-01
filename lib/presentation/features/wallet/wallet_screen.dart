import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/qr/vc_qr_payload_codec.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/wallet/vp_builder.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _loading = true;
  String? _did;
  String? _publicKeyJwk;
  Map<String, dynamic>? _didDocument;
  String? _employmentVc;
  Map<String, dynamic>? _vcParsed;
  String? _terminationVc;
  Map<String, dynamic>? _terminationVcParsed;
  String? _salaryRangeVc;
  Map<String, dynamic>? _salaryRangeVcParsed;
  String? _promotionVc;
  Map<String, dynamic>? _promotionVcParsed;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<String?> _resolveEmployeeNumericId() async {
    // Try cached value first
    final cached = await SecureStorage.getEmployeeNumericId();
    if (cached != null && cached.isNotEmpty) return cached;

    // Fetch from /employee endpoint — id is wrapped as {"value": "42"}
    try {
      final res = await ApiClient.instance.get(ApiConstants.employee);
      final body = res.data as Map<String, dynamic>? ?? {};
      final data = body['data'] as Map<String, dynamic>? ?? body;
      final idField = data['id'];
      String? numericId;
      if (idField is Map) {
        numericId = idField['value']?.toString();
      } else {
        numericId = idField?.toString();
      }
      if (numericId != null && numericId.isNotEmpty) {
        await SecureStorage.saveEmployeeNumericId(numericId);
        return numericId;
      }
    } catch (_) {}
    return null;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _did = await SecureStorage.getDid();
      _publicKeyJwk = await SecureStorage.getPublicKeyJwk();
      _employmentVc   = await SecureStorage.getEmploymentVC();
      _terminationVc  = await SecureStorage.getTerminationVC();
      _salaryRangeVc  = await SecureStorage.getSalaryRangeVC();
      _promotionVc    = await SecureStorage.getPromotionVC();

      final employeeId = await _resolveEmployeeNumericId();
      if (employeeId != null) {
        final did = _did ?? 'did:fabric:trustid:$employeeId';
        await _tryResolveDid(did);

        if (_employmentVc == null || _employmentVc!.isEmpty) {
          await _tryFetchVC(employeeId);
        } else {
          _parseVc(_employmentVc!);
        }

        if (_terminationVc == null || _terminationVc!.isEmpty) {
          await _tryFetchTerminationVC(employeeId);
        } else {
          _parseTerminationVc(_terminationVc!);
        }

        if (_salaryRangeVc == null || _salaryRangeVc!.isEmpty) {
          await _tryFetchSalaryRangeVC(employeeId);
        } else {
          _parseSalaryRangeVc(_salaryRangeVc!);
        }

        if (_promotionVc == null || _promotionVc!.isEmpty) {
          await _tryFetchPromotionVC(employeeId);
        } else {
          _parsePromotionVc(_promotionVc!);
        }
      }
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _tryResolveDid(String did) async {
    try {
      final res = await ApiClient.instance.get(ApiConstants.resolveDid(did));
      final doc = res.data['data'] as Map<String, dynamic>?;
      if (doc != null) {
        setState(() {
          _did = did;
          _didDocument = doc;
        });
        await SecureStorage.saveDid(did);
      }
    } catch (_) {}
  }

  Future<void> _tryFetchVC(String employeeId) async {
    try {
      final res = await ApiClient.instance
          .get(ApiConstants.getEmploymentVC(employeeId));
      final vcJson = res.data['data']?['vc'] as String?;
      if (vcJson != null && vcJson.isNotEmpty) {
        await SecureStorage.saveEmploymentVC(vcJson);
        setState(() => _employmentVc = vcJson);
        _parseVc(vcJson);
      }
    } catch (_) {}
  }

  void _parseVc(String vcJson) {
    try {
      final parsed = jsonDecode(vcJson) as Map<String, dynamic>;
      setState(() => _vcParsed = parsed);
    } catch (_) {}
  }

  Future<void> _tryFetchTerminationVC(String employeeId) async {
    try {
      final res = await ApiClient.instance
          .get(ApiConstants.getTerminationVC(employeeId));
      final vcJson = res.data['data']?['vc'] as String?;
      if (vcJson != null && vcJson.isNotEmpty) {
        await SecureStorage.saveTerminationVC(vcJson);
        setState(() => _terminationVc = vcJson);
        _parseTerminationVc(vcJson);
      }
    } catch (_) {}
  }

  void _parseTerminationVc(String vcJson) {
    try {
      final parsed = jsonDecode(vcJson) as Map<String, dynamic>;
      setState(() => _terminationVcParsed = parsed);
    } catch (_) {}
  }

  Future<void> _tryFetchSalaryRangeVC(String employeeId) async {
    try {
      final res = await ApiClient.instance.get(ApiConstants.getSalaryRangeVC(employeeId));
      final vcJson = res.data['data']?['vc'] as String?;
      if (vcJson != null && vcJson.isNotEmpty) {
        await SecureStorage.saveSalaryRangeVC(vcJson);
        setState(() => _salaryRangeVc = vcJson);
        _parseSalaryRangeVc(vcJson);
      }
    } catch (_) {}
  }

  void _parseSalaryRangeVc(String vcJson) {
    try {
      setState(() => _salaryRangeVcParsed = jsonDecode(vcJson) as Map<String, dynamic>);
    } catch (_) {}
  }

  Future<void> _tryFetchPromotionVC(String employeeId) async {
    try {
      final res = await ApiClient.instance.get(ApiConstants.getPromotionVC(employeeId));
      final vcJson = res.data['data']?['vc'] as String?;
      if (vcJson != null && vcJson.isNotEmpty) {
        await SecureStorage.savePromotionVC(vcJson);
        setState(() => _promotionVc = vcJson);
        _parsePromotionVc(vcJson);
      }
    } catch (_) {}
  }

  void _parsePromotionVc(String vcJson) {
    try {
      setState(() => _promotionVcParsed = jsonDecode(vcJson) as Map<String, dynamic>);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Identity Wallet'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WalletHeader(
                    hasKeypair: _publicKeyJwk != null,
                    hasVC: _vcParsed != null,
                  ),
                  const SizedBox(height: 20),

                  // ── DID Card ────────────────────────────────────────────
                  if (_didDocument != null) ...[
                    _DIDCard(doc: _didDocument!),
                    const SizedBox(height: 16),
                  ] else if (_publicKeyJwk != null) ...[
                    _PendingCard(
                      message: 'DID đang chờ Admin phê duyệt.\n\nAdmin vào màn "Duyệt tài khoản" → nhấn ✓ để duyệt. Sau khi duyệt, DID và Employment VC sẽ tự động được cấp.',
                      icon: Icons.hourglass_top_rounded,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    _PendingCard(
                      message: 'DID Wallet chưa được khởi tạo.\n\n'
                          'Nguyên nhân thường gặp:\n'
                          '• Bạn chưa hoàn tất bước Onboarding (đăng ký phòng ban + chức vụ)\n'
                          '• Tài khoản chưa được Admin duyệt\n\n'
                          'Cách khắc phục:\n'
                          '1. Đảm bảo bạn đã điền đầy đủ thông tin phòng ban và chức vụ trong bước Onboarding\n'
                          '2. Liên hệ Admin để được duyệt tài khoản\n'
                          '3. Sau khi Admin duyệt, Wallet và Employment VC sẽ tự động được tạo\n'
                          '4. Nhấn nút Tải lại (↺) để kiểm tra lại',
                      icon: Icons.info_outline_rounded,
                      color: AppColors.info,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── EmploymentVC Card ────────────────────────────────────
                  if (_vcParsed != null) ...[
                    _VCCard(
                      vc: _vcParsed!,
                      onShowQr: () => _showQrDialog(context, _employmentVc!),
                      onPresentVp: () => _showPresentVpDialog(context),
                      onScanVpRequest: () => _showScanVpRequestDialog(context),
                    ),
                    const SizedBox(height: 16),
                  ] else if (_publicKeyJwk != null) ...[
                    _PendingCard(
                      message: 'Employment VC chưa được cấp — sẽ tự động xuất hiện sau khi Admin duyệt tài khoản.',
                      icon: Icons.verified_outlined,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── SalaryRangeVC Card ───────────────────────────────────
                  if (_salaryRangeVcParsed != null) ...[
                    _SalaryRangeVCCard(
                      vc: _salaryRangeVcParsed!,
                      onShowQr: () => _showQrDialog(
                        context, _salaryRangeVc!, title: 'Salary Range VC'),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── PromotionVC Card ─────────────────────────────────────
                  if (_promotionVcParsed != null) ...[
                    _PromotionVCCard(
                      vc: _promotionVcParsed!,
                      onShowQr: () => _showQrDialog(
                        context, _promotionVc!, title: 'Promotion VC'),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── TerminationVC Card ───────────────────────────────────
                  if (_terminationVcParsed != null) ...[
                    _TerminationVCCard(
                      vc: _terminationVcParsed!,
                      onShowQr: () => _showQrDialog(
                        context, _terminationVc!, title: 'Termination VC'),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Public Key Card ──────────────────────────────────────
                  if (_publicKeyJwk != null) _PublicKeyCard(jwk: _publicKeyJwk!),
                ],
              ),
            ),
    );
  }

  // ── Present VP: Employee chủ động chọn field → tạo VP QR cho Verifier quét ──

  Future<void> _showPresentVpDialog(BuildContext context) async {
    if (_employmentVc == null) return;

    // Lấy tất cả fields thực tế từ VC (trừ 'id')
    final subject = _vcParsed?['credentialSubject'] as Map<String, dynamic>? ?? {};
    final allFields = subject.keys.where((k) => k != 'id').toList();
    if (allFields.isEmpty) return;
    final selected = <String>{...allFields};

    final confirmed = await showDialog<Set<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Chọn thông tin chia sẻ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Bạn đang chủ động chia sẻ VP với Verifier.\nChọn các trường muốn tiết lộ — Verifier sẽ quét QR này.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                ),
              ),
              const SizedBox(height: 12),
              ...allFields.map((f) => CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(f, style: const TextStyle(fontSize: 13)),
                    value: selected.contains(f),
                    onChanged: (v) => setLocal(() => v == true ? selected.add(f) : selected.remove(f)),
                  )),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
            FilledButton(
              onPressed: selected.isEmpty ? null : () => Navigator.pop(ctx, Set<String>.from(selected)),
              child: const Text('Tạo VP QR'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == null || confirmed.isEmpty || !context.mounted) return;
    await _buildAndShowVpQr(context, disclosedFields: confirmed.toList());
  }

  Future<void> _buildAndShowVpQr(
    BuildContext context, {
    required List<String> disclosedFields,
    String? state,
    String? nonce,
  }) async {
    // If no session provided, create one (self-initiated Present VP)
    String? sessionState = state;
    String? sessionNonce = nonce;
    if (sessionState == null || sessionNonce == null) {
      try {
        final res = await ApiClient.instance.post(
          ApiConstants.oidcVpRequest,
          data: {'requestedClaims': disclosedFields},
        );
        final d = res.data['data'] as Map<String, dynamic>? ?? {};
        sessionState = d['state'] as String?;
        sessionNonce = (d['authorizationRequest'] as Map<String, dynamic>?)?['nonce'] as String?
            ?? d['nonce'] as String?;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Không thể tạo VP session: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ));
        }
        return;
      }
    }
    if (sessionState == null || sessionNonce == null || !context.mounted) return;

    // Submit VP directly to backend — Verifier polls the result
    try {
      final result = await VpBuilder.submit(
        state: sessionState,
        nonce: sessionNonce,
        vcJson: _employmentVc!,
        disclosedFields: disclosedFields,
      );
      if (!context.mounted) return;
      final (msg, bg) = result.valid
          ? ('VP đã gửi thành công — Verifier có thể xem kết quả ✓', AppColors.success)
          : ('VP bị từ chối: ${result.reason}', AppColors.error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
        duration: const Duration(seconds: 5),
      ));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gửi VP thất bại: $e'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
      ));
    }
  }

  // ── Scan VP Request: Employee quét QR từ Verifier → gửi VP đáp lại ──────────

  Future<void> _showScanVpRequestDialog(BuildContext context) async {
    if (_employmentVc == null) return;
    await showDialog(
      context: context,
      builder: (ctx) => _VpRequestScanDialog(
        employmentVcJson: _employmentVc!,
      ),
    );
  }

  void _showQrDialog(BuildContext context, String vcJson,
      {String title = 'Employment VC'}) {
    final qrData = VcQrPayloadCodec.encode(vcJson);
    final isShortToken = VcQrPayloadCodec.isVcIdToken(qrData);
    final screenW = MediaQuery.of(context).size.width;
    final qrSize = (screenW - 80).clamp(200.0, 320.0);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Cho Verifier quét để xác minh',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: qrSize,
                  errorCorrectionLevel: QrErrorCorrectLevel.L,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isShortToken
                    ? '${qrData.length} ký tự (short token)'
                    : '${qrData.length} ký tự',
                style: const TextStyle(fontSize: 10, color: AppColors.inactive),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Sao chép VC JSON'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: vcJson));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Đã sao chép VC JSON'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────────────────────

class _WalletHeader extends StatelessWidget {
  final bool hasKeypair;
  final bool hasVC;
  const _WalletHeader({required this.hasKeypair, required this.hasVC});

  @override
  Widget build(BuildContext context) {
    final ready = hasKeypair && hasVC;
    final (statusText, statusIcon) = ready
        ? ('Đã xác minh — sẵn sàng dùng', Icons.verified_rounded)
        : hasKeypair
            ? ('Keypair đã tạo — chờ Admin duyệt', Icons.hourglass_top_rounded)
            : ('Chưa khởi tạo Wallet', Icons.warning_amber_rounded);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DID Wallet',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(statusIcon, color: Colors.white, size: 24),
        ],
      ),
    );
  }
}

class _DIDCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _DIDCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final did = doc['did'] as String? ?? '';
    final status = doc['status'] as String? ?? '';
    final controller = doc['controller'] as String? ?? '';
    final createdAt = doc['createdAt'] as String? ?? '';
    final isActive = status == 'ACTIVE';

    return _Card(
      borderColor: isActive
          ? AppColors.success.withValues(alpha: 0.4)
          : AppColors.error.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.fingerprint_rounded,
            iconColor: isActive ? AppColors.success : AppColors.error,
            title: 'Decentralized Identifier',
            badge: status,
            badgeColor: isActive ? AppColors.success : AppColors.error,
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'DID', value: did, copyable: true),
          const SizedBox(height: 6),
          _InfoRow(label: 'Controller', value: controller),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Cấp lúc',
            value: createdAt.length >= 19
                ? createdAt.substring(0, 19).replaceAll('T', ' ')
                : '-',
          ),
        ],
      ),
    );
  }
}

class _VCCard extends StatelessWidget {
  final Map<String, dynamic> vc;
  final VoidCallback onShowQr;
  final VoidCallback onPresentVp;
  final VoidCallback onScanVpRequest;
  const _VCCard({
    required this.vc,
    required this.onShowQr,
    required this.onPresentVp,
    required this.onScanVpRequest,
  });

  @override
  Widget build(BuildContext context) {
    final subject = vc['credentialSubject'] as Map<String, dynamic>? ?? {};
    final issuanceDate = vc['issuanceDate'] as String? ?? '';
    final expirationDate = vc['expirationDate'] as String? ?? '';
    final isExpired = expirationDate.isNotEmpty &&
        DateTime.tryParse(expirationDate)?.isBefore(DateTime.now()) == true;

    return _Card(
      borderColor: isExpired
          ? AppColors.error.withValues(alpha: 0.4)
          : AppColors.primary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.verified_rounded,
            iconColor: isExpired ? AppColors.error : AppColors.primary,
            title: 'Employment Credential',
            badge: isExpired ? 'EXPIRED' : 'VALID',
            badgeColor: isExpired ? AppColors.error : AppColors.success,
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Phòng ban', value: subject['department']?.toString() ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(label: 'Chức vụ', value: subject['position']?.toString() ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Cấp lúc',
            value: issuanceDate.length >= 10 ? issuanceDate.substring(0, 10) : '-',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Hết hạn',
            value: expirationDate.length >= 10 ? expirationDate.substring(0, 10) : '-',
          ),
          const SizedBox(height: 14),
          // Row 1: Xuất QR + Quét VP Request
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.qr_code_rounded, size: 16),
                  label: const Text('Xuất QR'),
                  onPressed: onShowQr,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                  label: const Text('Quét VP Request'),
                  onPressed: onScanVpRequest,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Present VP (chủ động chọn field chia sẻ)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.share_rounded, size: 16),
              label: const Text('Present VP — tự chọn field chia sẻ'),
              onPressed: onPresentVp,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalaryRangeVCCard extends StatelessWidget {
  final Map<String, dynamic> vc;
  final VoidCallback onShowQr;
  const _SalaryRangeVCCard({required this.vc, required this.onShowQr});

  @override
  Widget build(BuildContext context) {
    final subject = vc['credentialSubject'] as Map<String, dynamic>? ?? {};
    final issuanceDate = vc['issuanceDate'] as String? ?? '';
    final expirationDate = vc['expirationDate'] as String? ?? '';
    final isExpired = expirationDate.isNotEmpty &&
        DateTime.tryParse(expirationDate)?.isBefore(DateTime.now()) == true;

    return _Card(
      borderColor: AppColors.accent.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.attach_money_rounded,
            iconColor: AppColors.accent,
            title: 'Salary Range Credential',
            badge: isExpired ? 'EXPIRED' : 'VALID',
            badgeColor: isExpired ? AppColors.error : AppColors.success,
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Salary Band', value: subject['salaryBand']?.toString() ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(label: 'Currency', value: subject['currency']?.toString() ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(label: 'Chức vụ', value: subject['position']?.toString() ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Cấp lúc',
            value: issuanceDate.length >= 10 ? issuanceDate.substring(0, 10) : '-',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Hết hạn',
            value: expirationDate.length >= 10 ? expirationDate.substring(0, 10) : '-',
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.qr_code_rounded, size: 18),
              label: const Text('Xuất QR để Verifier quét'),
              onPressed: onShowQr,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromotionVCCard extends StatelessWidget {
  final Map<String, dynamic> vc;
  final VoidCallback onShowQr;
  const _PromotionVCCard({required this.vc, required this.onShowQr});

  @override
  Widget build(BuildContext context) {
    final subject = vc['credentialSubject'] as Map<String, dynamic>? ?? {};
    final issuanceDate = vc['issuanceDate'] as String? ?? '';

    return _Card(
      borderColor: AppColors.info.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.trending_up_rounded,
            iconColor: AppColors.info,
            title: 'Promotion Credential',
            badge: 'PROMOTED',
            badgeColor: AppColors.info,
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Phòng ban', value: subject['department']?.toString() ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(label: 'Vị trí cũ', value: subject['oldPosition']?.toString() ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(label: 'Vị trí mới', value: subject['newPosition']?.toString() ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Ngày thăng',
            value: issuanceDate.length >= 10 ? issuanceDate.substring(0, 10) : '-',
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.qr_code_rounded, size: 18),
              label: const Text('Xuất QR để Verifier quét'),
              onPressed: onShowQr,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.info,
                side: const BorderSide(color: AppColors.info),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TerminationVCCard extends StatelessWidget {
  final Map<String, dynamic> vc;
  final VoidCallback onShowQr;
  const _TerminationVCCard({required this.vc, required this.onShowQr});

  @override
  Widget build(BuildContext context) {
    final subject = vc['credentialSubject'] as Map<String, dynamic>? ?? {};
    final issuanceDate = vc['issuanceDate'] as String? ?? '';

    return _Card(
      borderColor: AppColors.error.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.cancel_rounded,
            iconColor: AppColors.error,
            title: 'Termination Credential',
            badge: 'TERMINATED',
            badgeColor: AppColors.error,
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Phòng ban', value: subject['department']?.toString() ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(label: 'Chức vụ', value: subject['position']?.toString() ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Ngày chấm dứt',
            value: issuanceDate.length >= 10 ? issuanceDate.substring(0, 10) : '-',
          ),
          const SizedBox(height: 6),
          _InfoRow(label: 'Lý do', value: subject['terminationReason']?.toString() ?? '-'),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.qr_code_rounded, size: 18),
              label: const Text('Xuất QR để Verifier quét'),
              onPressed: onShowQr,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;
  const _PendingCard({required this.message, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _PublicKeyCard extends StatelessWidget {
  final String jwk;
  const _PublicKeyCard({required this.jwk});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> parsed = {};
    try {
      parsed = jsonDecode(jwk) as Map<String, dynamic>;
    } catch (_) {}

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.key_rounded,
            iconColor: AppColors.primary,
            title: 'Public Key (JWK)',
            trailing: IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18,
                  color: AppColors.textSecondary),
              tooltip: 'Sao chép',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jwk));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Đã sao chép public key'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ));
              },
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'kty', value: parsed['kty']?.toString() ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(label: 'crv', value: parsed['crv']?.toString() ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(label: 'x', value: _trunc(parsed['x']?.toString() ?? '-')),
          const SizedBox(height: 6),
          _InfoRow(label: 'y', value: _trunc(parsed['y']?.toString() ?? '-')),
        ],
      ),
    );
  }

  String _trunc(String s) =>
      s.length > 20 ? '${s.substring(0, 12)}...${s.substring(s.length - 8)}' : s;
}

// ── Shared primitives ──────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  const _Card({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? badge;
  final Color? badgeColor;
  final Widget? trailing;

  const _CardHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.badge,
    this.badgeColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge!,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeColor ?? AppColors.primary)),
          ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;

  const _InfoRow({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: GestureDetector(
            onTap: copyable
                ? () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Đã sao chép'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ));
                  }
                : null,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: copyable ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                decoration: copyable ? TextDecoration.underline : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── VP Request Scanner dialog ─────────────────────────────────────────────────
// Employee quét QR từ màn Verifier (Mode B) → parse authorizationRequest
// → chọn field được yêu cầu → gửi VP Token đáp lại.

class _VpRequestScanDialog extends StatefulWidget {
  final String employmentVcJson;
  const _VpRequestScanDialog({required this.employmentVcJson});

  @override
  State<_VpRequestScanDialog> createState() => _VpRequestScanDialogState();
}

class _VpRequestScanDialogState extends State<_VpRequestScanDialog> {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _scanning = true;
  bool _submitting = false;
  String? _errorMsg;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    // Parse authorizationRequest JSON
    Map<String, dynamic> authReq;
    try {
      authReq = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      final decoded = VcQrPayloadCodec.decode(raw);
      if (decoded == null) return;
      try {
        authReq = jsonDecode(decoded) as Map<String, dynamic>;
      } catch (_) {
        return;
      }
    }

    // Must be a VP Request (has response_type or presentation_definition)
    if (!authReq.containsKey('response_type') &&
        !authReq.containsKey('presentation_definition')) {
      return;
    }

    _scanning = false;
    _ctrl.stop().ignore();

    final state = authReq['state'] as String?;
    final nonce = authReq['nonce'] as String?;
    if (state == null || nonce == null) {
      setState(() => _errorMsg = 'QR không hợp lệ: thiếu state/nonce');
      return;
    }

    final List<String> requestedFields = _extractFields(authReq);

    // Hiển thị popup xác nhận TRƯỚC khi gửi VP
    if (!mounted) return;
    final confirmed = await _showConfirmDialog(requestedFields);
    if (!mounted) return;
    if (confirmed != true) {
      // Employee từ chối — cho phép quét lại
      setState(() {
        _scanning = true;
        _errorMsg = null;
      });
      _ctrl.start().ignore();
      return;
    }

    setState(() => _submitting = true);

    try {
      final result = await VpBuilder.submit(
        state: state,
        nonce: nonce,
        vcJson: widget.employmentVcJson,
        disclosedFields: requestedFields,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.valid
            ? 'VP được Verifier chấp nhận ✓'
            : 'VP bị từ chối: ${result.reason}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: result.valid ? AppColors.success : AppColors.error,
        duration: const Duration(seconds: 4),
      ));
    } catch (e) {
      setState(() {
        _submitting = false;
        _errorMsg = 'Gửi VP thất bại: $e';
      });
    }
  }

  Future<bool?> _showConfirmDialog(List<String> requestedFields) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'Yêu cầu chia sẻ thông tin',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Verifier đang yêu cầu bạn chia sẻ thông tin sau. Chỉ xác nhận nếu bạn tin tưởng bên yêu cầu.',
                      style: TextStyle(fontSize: 11, color: AppColors.warning, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Thông tin được yêu cầu:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            ...requestedFields.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        f,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Từ chối', style: TextStyle(color: AppColors.error)),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Xác nhận chia sẻ'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
  }

  List<String> _extractFields(Map<String, dynamic> authReq) {
    try {
      final pd = authReq['presentation_definition'] as Map<String, dynamic>;
      final descriptors = pd['input_descriptors'] as List<dynamic>;
      final first = descriptors.first as Map<String, dynamic>;
      final constraints = first['constraints'] as Map<String, dynamic>;
      final fields = constraints['fields'] as List<dynamic>;
      return fields.map((f) {
        final path = (f as Map)['path'] as List<dynamic>;
        final p = path.first.toString(); // e.g. "$.credentialSubject.department"
        return p.split('.').last;
      }).toList();
    } catch (_) {
      return ['employmentStatus', 'department', 'position', 'startDate'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Quét VP Request QR',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            const Text(
              'Hướng camera vào QR trên màn Verifier\n(tab "Tạo VP Request")',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            if (_submitting)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
            else if (_errorMsg != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_errorMsg!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error, fontSize: 13)),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 260,
                  child: Stack(
                    children: [
                      MobileScanner(controller: _ctrl, onDetect: _onDetect),
                      Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.accent, width: 2.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }
}
