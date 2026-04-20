import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/wallet/vp_builder.dart';
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

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _did = await SecureStorage.getDid();
      _publicKeyJwk = await SecureStorage.getPublicKeyJwk();
      _employmentVc   = await SecureStorage.getEmploymentVC();
      _terminationVc  = await SecureStorage.getTerminationVC();
      _salaryRangeVc  = await SecureStorage.getSalaryRangeVC();
      _promotionVc    = await SecureStorage.getPromotionVC();

      final employeeId = await SecureStorage.getUserId();
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
                  ] else ...[
                    _PendingCard(
                      message: 'DID chưa được cấp. Chờ Admin phê duyệt tài khoản.',
                      icon: Icons.fingerprint_rounded,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── EmploymentVC Card ────────────────────────────────────
                  if (_vcParsed != null) ...[
                    _VCCard(
                      vc: _vcParsed!,
                      onShowQr: () => _showQrDialog(context, _employmentVc!),
                      onPresentVp: () => _showPresentVpDialog(context),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    _PendingCard(
                      message: 'EmploymentVC chưa được cấp. Tài khoản cần được Admin duyệt.',
                      icon: Icons.verified_outlined,
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

  Future<void> _showPresentVpDialog(BuildContext context) async {
    if (_employmentVc == null) return;

    // Available fields in the VC credentialSubject
    final allFields = ['employmentStatus', 'department', 'position', 'startDate'];
    final selected = <String>{...allFields}; // default: all selected

    // State + nonce from a new VP session
    String? sessionState;
    String? sessionNonce;

    // Step 1: create session on backend
    try {
      final res = await ApiClient.instance.post(
        ApiConstants.oidcVpRequest,
        data: {'requestedClaims': allFields},
      );
      final data = res.data['data'] as Map<String, dynamic>? ?? {};
      sessionState = data['state'] as String?;
      sessionNonce = data['nonce'] as String?;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Không thể tạo VP session'),
          behavior: SnackBarBehavior.floating,
        ));
      }
      return;
    }

    if (!context.mounted) return;

    // Step 2: show field-selector dialog
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: const Text('Present Verifiable Presentation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chọn thông tin muốn tiết lộ cho Verifier:',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ...allFields.map((field) => CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(field, style: const TextStyle(fontSize: 13)),
                    value: selected.contains(field),
                    onChanged: (val) => setLocalState(() {
                      val == true ? selected.add(field) : selected.remove(field);
                    }),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: selected.isEmpty
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      await _submitVp(
                        state: sessionState!,
                        nonce: sessionNonce!,
                        disclosedFields: selected.toList(),
                      );
                    },
              child: const Text('Gửi VP'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitVp({
    required String state,
    required String nonce,
    required List<String> disclosedFields,
  }) async {
    try {
      final result = await VpBuilder.submit(
        state: state,
        nonce: nonce,
        vcJson: _employmentVc!,
        disclosedFields: disclosedFields,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.valid
            ? 'VP được Verifier chấp nhận'
            : 'VP bị từ chối: ${result.reason}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: result.valid ? AppColors.success : AppColors.error,
        duration: const Duration(seconds: 4),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Gửi VP thất bại'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
      ));
    }
  }

  void _showQrDialog(BuildContext context, String vcJson,
      {String title = 'Employment VC'}) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cho Verifier quét để xác minh',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              QrImageView(
                data: vcJson,
                version: QrVersions.auto,
                size: 240,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
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
                  ready
                      ? 'Keypair + VC đã sẵn sàng'
                      : hasKeypair
                          ? 'Keypair OK — chờ VC'
                          : 'Chưa khởi tạo',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(
            ready ? Icons.verified_rounded : Icons.pending_rounded,
            color: Colors.white,
            size: 24,
          ),
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
  const _VCCard({required this.vc, required this.onShowQr, required this.onPresentVp});

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
                child: FilledButton.icon(
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Present VP'),
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
  const _PendingCard({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.warning, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
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
