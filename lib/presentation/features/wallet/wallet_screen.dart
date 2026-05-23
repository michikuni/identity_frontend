import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/qr/vc_qr_payload_codec.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/date_format.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/core/security/biometric_service.dart';
import 'package:identity_frontend/core/wallet/vc_schemas.dart';
import 'package:identity_frontend/presentation/features/wallet/disclosure_picker_screen.dart';
import 'package:identity_frontend/core/wallet/vp_builder.dart';
import 'package:identity_frontend/core/wallet/wallet_service.dart';
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

  // SD-JWT credentials (Phase 1 / 4.2)
  String? _skillSdJwt;
  String? _educationSdJwt;

  // Status badge cache: vcId → 'ACTIVE' | 'REVOKED' | 'UNKNOWN'
  final Map<String, String> _statusCache = {};

  // Biometric lock toggle
  bool _biometricLockEnabled = false;

  // True while the wallet is locked behind biometric — hides VC content
  // until the user authenticates.
  bool _biometricLocked = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// Load preferences first, then either prompt for biometric (lock enabled)
  /// or load the wallet contents directly.
  Future<void> _bootstrap() async {
    final enabled = await BiometricService.isBiometricLockEnabled();
    if (!mounted) return;
    setState(() {
      _biometricLockEnabled = enabled;
      _biometricLocked = enabled;
    });
    if (enabled) {
      await _promptUnlock();
    } else {
      await _load();
    }
  }

  /// Asks the OS for biometric auth. On success unlocks the wallet and
  /// fetches data; on failure leaves the lock overlay visible so the user
  /// can retry.
  Future<void> _promptUnlock() async {
    final ok = await BiometricService.authenticateNow(
      reason: AppLocalizations.of(context)!.biometricUnlockReason,
    );
    if (!mounted) return;
    if (ok) {
      setState(() => _biometricLocked = false);
      await _load();
    }
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
      _employmentVc = await SecureStorage.getEmploymentVC();
      _terminationVc = await SecureStorage.getTerminationVC();
      _salaryRangeVc = await SecureStorage.getSalaryRangeVC();
      _promotionVc = await SecureStorage.getPromotionVC();

      // Nếu chưa có keypair local, thử regenerate — trường hợp reinstall app
      if (_publicKeyJwk == null || _publicKeyJwk!.isEmpty) {
        try {
          final newJwk = await WalletService.generateAndSave();
          setState(() => _publicKeyJwk = newJwk);
        } catch (_) {}
      }

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

        await _fetchSdJwts(employeeId);
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
      final res = await ApiClient.instance.get(
        ApiConstants.getEmploymentVC(employeeId),
      );
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
      final res = await ApiClient.instance.get(
        ApiConstants.getTerminationVC(employeeId),
      );
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
      final res = await ApiClient.instance.get(
        ApiConstants.getSalaryRangeVC(employeeId),
      );
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
      setState(
        () => _salaryRangeVcParsed = jsonDecode(vcJson) as Map<String, dynamic>,
      );
    } catch (_) {}
  }

  Future<void> _tryFetchPromotionVC(String employeeId) async {
    try {
      final res = await ApiClient.instance.get(
        ApiConstants.getPromotionVC(employeeId),
      );
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
      setState(
        () => _promotionVcParsed = jsonDecode(vcJson) as Map<String, dynamic>,
      );
    } catch (_) {}
  }

  // ── SD-JWT fetch (Phase 1 / 4.2) ────────────────────────────────────────────

  Future<void> _fetchSdJwts(String employeeId) async {
    await Future.wait([
      _tryFetchSkillSdJwt(employeeId),
      _tryFetchEducationSdJwt(employeeId),
    ]);
  }

  Future<void> _tryFetchSkillSdJwt(String employeeId) async {
    try {
      final res = await ApiClient.instance.get(ApiConstants.sdJwtGetSkill(employeeId));
      final jwt = res.data['data']?['sdJwt'] as String?;
      if (jwt != null && jwt.isNotEmpty) {
        setState(() => _skillSdJwt = jwt);
      }
    } catch (_) {}
  }

  Future<void> _tryFetchEducationSdJwt(String employeeId) async {
    try {
      final res = await ApiClient.instance.get(ApiConstants.sdJwtGetEducation(employeeId));
      final jwt = res.data['data']?['sdJwt'] as String?;
      if (jwt != null && jwt.isNotEmpty) {
        setState(() => _educationSdJwt = jwt);
      }
    } catch (_) {}
  }

  // ── Status List badge (Phase 1 / 4.1) ────────────────────────────────────────

  /// Returns 'ACTIVE', 'REVOKED', or 'UNKNOWN'.
  Future<String> _fetchStatusBadge(Map<String, dynamic> vc) async {
    try {
      final cs = vc['credentialStatus'] as Map<String, dynamic>?;
      if (cs == null || cs['type'] != 'StatusList2021Entry') return 'UNKNOWN';
      final listCredUrl = cs['statusListCredential'] as String? ?? '';
      final listId = listCredUrl.split('/').last;
      final index = cs['statusListIndex']?.toString() ?? '';
      if (listId.isEmpty || index.isEmpty) return 'UNKNOWN';

      final cacheKey = '$listId#$index';
      if (_statusCache.containsKey(cacheKey)) return _statusCache[cacheKey]!;

      final res = await ApiClient.instance.get(
        ApiConstants.statusListEntry(listId),
        queryParameters: {'index': index},
      );
      final revoked = res.data['revoked'] == true;
      final status = revoked ? 'REVOKED' : 'ACTIVE';
      _statusCache[cacheKey] = status;
      return status;
    } catch (_) {
      return 'UNKNOWN';
    }
  }

  List<Widget> _employmentRows(Map<String, dynamic> vc) => _credentialRows(
    vc,
    kVcSchemas['EmploymentCredential']?.fields ?? const [],
  );

  List<Widget> _salaryRows(Map<String, dynamic> vc) => _credentialRows(
    vc,
    kVcSchemas['SalaryRangeCredential']?.fields ?? const [],
  );

  List<Widget> _promotionRows(Map<String, dynamic> vc) => _credentialRows(
    vc,
    kVcSchemas['PromotionCredential']?.fields ?? const [],
  );

  List<Widget> _terminationRows(Map<String, dynamic> vc) => _credentialRows(
    vc,
    kVcSchemas['TerminationCredential']?.fields ?? const [],
  );

  List<Widget> _credentialRows(
    Map<String, dynamic> vc,
    List<String> preferredFields,
  ) {
    final subject = vc['credentialSubject'] as Map<String, dynamic>? ?? {};
    final entries = <MapEntry<String, String>>[];

    void add(String label, Object? value) {
      final text = _formatVcValue(value);
      if (text.isNotEmpty) entries.add(MapEntry(label, text));
    }

    for (final field in preferredFields) {
      final raw = subject[field];
      if (field == 'salaryBand') {
        add(humanizeFieldKey(field), humanizeSalaryBandValue(raw?.toString() ?? ''));
      } else {
        add(humanizeFieldKey(field), raw);
      }
    }
    for (final entry in subject.entries) {
      if (entry.key == 'id' || preferredFields.contains(entry.key)) continue;
      if (entry.key == 'salaryBand') {
        add(humanizeFieldKey(entry.key), humanizeSalaryBandValue(entry.value?.toString() ?? ''));
      } else {
        add(humanizeFieldKey(entry.key), entry.value);
      }
    }
    add(AppLocalizations.of(context)!.vcFieldIssued, formatDateTime(vc['issuanceDate']?.toString()));
    add(AppLocalizations.of(context)!.vcFieldExpires, formatDateTime(vc['expirationDate']?.toString()));
    add(AppLocalizations.of(context)!.vcFieldId, vc['id']);

    if (entries.isEmpty) {
      return [
        Text(
          AppLocalizations.of(context)!.vcNoFields,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ];
    }

    final rows = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      rows.add(
        _InfoRow(
          label: entry.key,
          value: entry.value,
          copyable: entry.key == 'VC ID',
        ),
      );
      if (i < entries.length - 1) rows.add(const SizedBox(height: 6));
    }
    return rows;
  }

  String _formatVcValue(Object? value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is num || value is bool) return value.toString();
    return jsonEncode(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.walletTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _biometricLocked ? null : _load,
            tooltip: AppLocalizations.of(context)!.walletRefresh,
          ),
        ],
      ),
      body: _biometricLocked
          ? _LockedOverlay(onUnlock: _promptUnlock)
          : _loading
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
                  ] else if (_vcParsed != null) ...[
                    // Đã có VC (đã được duyệt) nhưng DID resolve fail — không show pending
                  ] else if (_publicKeyJwk != null) ...[
                    _PendingCard(
                      message: AppLocalizations.of(context)!.walletDidPending,
                      icon: Icons.hourglass_top_rounded,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    _PendingCard(
                      message: AppLocalizations.of(context)!.walletDidNotInit,
                      icon: Icons.info_outline_rounded,
                      color: AppColors.info,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── EmploymentVC Card ────────────────────────────────────
                  if (_vcParsed != null) ...[
                    _VCCard(
                      vc: _vcParsed!,
                      vcJson: _employmentVc!,
                      vcType: 'EmploymentCredential',
                      title: humanizeVcType('EmploymentCredential'),
                      icon: Icons.verified_rounded,
                      color: AppColors.primary,
                      detailRows: _employmentRows(_vcParsed!),
                      fetchStatus: _fetchStatusBadge,
                      onCreateVcQr: () => _showCreateVcQrDialog(
                        context,
                        _employmentVc!,
                        'EmploymentCredential',
                      ),
                      onScanVpRequest: () => _showScanVpRequestDialog(
                        context,
                        _employmentVc!,
                        'EmploymentCredential',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (_publicKeyJwk != null) ...[
                    _PendingCard(
                      message: AppLocalizations.of(context)!.walletVcPending,
                      icon: Icons.verified_outlined,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── SalaryRangeVC Card ───────────────────────────────────
                  if (_salaryRangeVcParsed != null) ...[
                    _VCCard(
                      vc: _salaryRangeVcParsed!,
                      vcJson: _salaryRangeVc!,
                      vcType: 'SalaryRangeCredential',
                      title: humanizeVcType('SalaryRangeCredential'),
                      icon: Icons.attach_money_rounded,
                      color: AppColors.accent,
                      detailRows: _salaryRows(_salaryRangeVcParsed!),
                      fetchStatus: _fetchStatusBadge,
                      onCreateVcQr: () => _showCreateVcQrDialog(
                        context,
                        _salaryRangeVc!,
                        'SalaryRangeCredential',
                      ),
                      onScanVpRequest: () => _showScanVpRequestDialog(
                        context,
                        _salaryRangeVc!,
                        'SalaryRangeCredential',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── PromotionVC Card ─────────────────────────────────────
                  if (_promotionVcParsed != null) ...[
                    _VCCard(
                      vc: _promotionVcParsed!,
                      vcJson: _promotionVc!,
                      vcType: 'PromotionCredential',
                      title: humanizeVcType('PromotionCredential'),
                      icon: Icons.trending_up_rounded,
                      color: AppColors.info,
                      detailRows: _promotionRows(_promotionVcParsed!),
                      fetchStatus: _fetchStatusBadge,
                      onCreateVcQr: () => _showCreateVcQrDialog(
                        context,
                        _promotionVc!,
                        'PromotionCredential',
                      ),
                      onScanVpRequest: () => _showScanVpRequestDialog(
                        context,
                        _promotionVc!,
                        'PromotionCredential',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── TerminationVC Card ───────────────────────────────────
                  if (_terminationVcParsed != null) ...[
                    _VCCard(
                      vc: _terminationVcParsed!,
                      vcJson: _terminationVc!,
                      vcType: 'TerminationCredential',
                      title: humanizeVcType('TerminationCredential'),
                      icon: Icons.cancel_rounded,
                      color: AppColors.error,
                      detailRows: _terminationRows(_terminationVcParsed!),
                      fetchStatus: _fetchStatusBadge,
                      onCreateVcQr: () => _showCreateVcQrDialog(
                        context,
                        _terminationVc!,
                        'TerminationCredential',
                      ),
                      onScanVpRequest: () => _showScanVpRequestDialog(
                        context,
                        _terminationVc!,
                        'TerminationCredential',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Skill SD-JWT Card (Phase 1 / 4.2) ────────────────────
                  if (_skillSdJwt != null) ...[
                    _SdJwtCard(
                      sdJwt: _skillSdJwt!,
                      credentialType: 'SkillCredential',
                      title: humanizeVcType('SkillCredential'),
                      subtitle: AppLocalizations.of(context)!.sdJwtSelectiveSubtitle,
                      icon: Icons.psychology_outlined,
                      color: const Color(0xFF7C3AED),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Education SD-JWT Card (Phase 1 / 4.2) ────────────────
                  if (_educationSdJwt != null) ...[
                    _SdJwtCard(
                      sdJwt: _educationSdJwt!,
                      credentialType: 'EducationCredential',
                      title: humanizeVcType('EducationCredential'),
                      subtitle: AppLocalizations.of(context)!.sdJwtSelectiveSubtitle,
                      icon: Icons.school_outlined,
                      color: const Color(0xFF0891B2),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Biometric Lock Toggle ────────────────────────────────
                  _BiometricLockTile(
                    enabled: _biometricLockEnabled,
                    onChanged: (v) async {
                      if (v) {
                        final ok = await BiometricService.authenticateNow(
                          reason: AppLocalizations.of(context)!.biometricEnableReason,
                        );
                        if (!ok) return;
                      }
                      await BiometricService.setBiometricLockEnabled(v);
                      if (!mounted) return;
                      setState(() => _biometricLockEnabled = v);
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Public Key Card ──────────────────────────────────────
                  if (_publicKeyJwk != null)
                    _PublicKeyCard(jwk: _publicKeyJwk!),
                ],
              ),
            ),
    );
  }

  // ── Present VP: Employee chủ động chọn field → tạo VP QR cho Verifier quét ──

  // ignore: unused_element
  Future<void> _showPresentVpDialog(BuildContext context) async {
    if (_employmentVc == null) return;

    // Lấy tất cả fields thực tế từ VC (trừ 'id')
    final subject =
        _vcParsed?['credentialSubject'] as Map<String, dynamic>? ?? {};
    final allFields = subject.keys.where((k) => k != 'id').toList();
    if (allFields.isEmpty) return;
    final selected = <String>{...allFields};

    final confirmed = await showDialog<Set<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.walletShareInfo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
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
                child: Text(
                  AppLocalizations.of(context)!.walletShareInfoHint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...allFields.map(
                (f) => CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(f, style: const TextStyle(fontSize: 13)),
                  value: selected.contains(f),
                  onChanged: (v) => setLocal(
                    () => v == true ? selected.add(f) : selected.remove(f),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.walletQrCancel),
            ),
            FilledButton(
              onPressed: selected.isEmpty
                  ? null
                  : () => Navigator.pop(ctx, Set<String>.from(selected)),
              child: Text(AppLocalizations.of(context)!.walletQrCreate),
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
        sessionNonce =
            (d['authorizationRequest'] as Map<String, dynamic>?)?['nonce']
                as String? ??
            d['nonce'] as String?;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.walletVpSessionFailed(e.toString())),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }
    if (sessionState == null || sessionNonce == null || !context.mounted) {
      return;
    }

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
          ? (AppLocalizations.of(context)!.walletVpSentSuccess, AppColors.success)
          : (AppLocalizations.of(context)!.walletVpRejected(result.reason), AppColors.error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.walletVpSendFailed(e.toString())),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ── Scan VP Request: Employee quét QR từ Verifier → gửi VP đáp lại ──────────

  Future<void> _showScanVpRequestDialog(
    BuildContext context,
    String vcJson,
    String vcType,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => _VpRequestScanDialog(vcJson: vcJson, vcType: vcType),
    );
  }

  Future<void> _showCreateVcQrDialog(
    BuildContext context,
    String vcJson,
    String vcType,
  ) async {
    Map<String, dynamic> vc;
    try {
      vc = jsonDecode(vcJson) as Map<String, dynamic>;
    } catch (_) {
      _showQrDialog(context, vcJson, title: vcType);
      return;
    }

    final schema = kVcSchemas[vcType];
    final title = schema?.label ?? vcType;
    final vcId = vc['id']?.toString();
    final subject = vc['credentialSubject'] as Map<String, dynamic>? ?? {};
    final schemaFields = schema?.fields ?? subject.keys.where((k) => k != 'id');
    final fields = schemaFields
        .where((field) => subject.containsKey(field))
        .toList(growable: false);

    if (vcId == null || vcId.isEmpty || fields.isEmpty) {
      _showQrDialog(context, vcJson, title: title);
      return;
    }

    final selected = <String>{...fields};
    final disclosedFields = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.walletQrSelectFields,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              ...fields.map(
                (field) => CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(humanizeFieldKey(field), style: const TextStyle(fontSize: 13)),
                  value: selected.contains(field),
                  onChanged: (value) => setLocal(() {
                    if (value == true) {
                      selected.add(field);
                    } else {
                      selected.remove(field);
                    }
                  }),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.walletQrCancel),
            ),
            FilledButton(
              onPressed: selected.isEmpty
                  ? null
                  : () => Navigator.pop(ctx, selected.toList()),
              child: Text(AppLocalizations.of(context)!.walletQrCreate),
            ),
          ],
        ),
      ),
    );

    if (disclosedFields == null ||
        disclosedFields.isEmpty ||
        !context.mounted) {
      return;
    }

    final qrData = VcQrPayloadCodec.buildVcIdToken(
      vcId,
      fields: disclosedFields,
    );
    _showQrDialog(context, vcJson, title: title, qrData: qrData);
  }

  void _showQrDialog(
    BuildContext context,
    String vcJson, {
    String title = 'Employment VC',
    String? qrData,
  }) {
    final effectiveQrData = qrData ?? VcQrPayloadCodec.encode(vcJson);
    final isShortToken = VcQrPayloadCodec.isVcIdToken(effectiveQrData);
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
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.walletQrForVerifier,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: QrImageView(
                  data: effectiveQrData,
                  version: QrVersions.auto,
                  size: qrSize,
                  errorCorrectionLevel: QrErrorCorrectLevel.L,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isShortToken
                    ? AppLocalizations.of(context)!.walletQrCharsShort(effectiveQrData.length)
                    : AppLocalizations.of(context)!.walletQrChars(effectiveQrData.length),
                style: const TextStyle(fontSize: 10, color: AppColors.inactive),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: Text(AppLocalizations.of(context)!.walletCopyVcJson),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: vcJson));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.walletCopied),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
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
    final l10n = AppLocalizations.of(context)!;
    final (statusText, statusIcon) = ready
        ? (l10n.walletVerifiedReady, Icons.verified_rounded)
        : hasKeypair
        ? (l10n.walletKeypairPending, Icons.hourglass_top_rounded)
        : (l10n.walletNotInitialized, Icons.warning_amber_rounded);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.75),
          ],
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
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.walletTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
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

    final l10n = AppLocalizations.of(context)!;
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
            title: l10n.walletDidCardTitle,
            badge: status,
            badgeColor: isActive ? AppColors.success : AppColors.error,
          ),
          const SizedBox(height: 12),
          _InfoRow(label: l10n.walletDidLabel, value: did, copyable: true),
          const SizedBox(height: 6),
          _InfoRow(label: l10n.walletControllerLabel, value: controller),
          const SizedBox(height: 6),
          _InfoRow(
            label: l10n.walletIssuedAtLabel,
            value: formatDateTime(createdAt).isNotEmpty ? formatDateTime(createdAt) : '-',
          ),
        ],
      ),
    );
  }
}

/// Card chung cho tất cả 4 loại VC. Mỗi card có 2 nút:
///   - "Tạo VC QR" — popup chọn field → QR `vcid:<id>?fields=...`
///   - "Quét QR VP Request" — mở camera, chỉ chấp nhận VP Request đúng vcType
class _VCCard extends StatelessWidget {
  final Map<String, dynamic> vc;
  final String vcJson;
  final String vcType;
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> detailRows;
  final VoidCallback onCreateVcQr;
  final VoidCallback onScanVpRequest;
  final Future<String> Function(Map<String, dynamic>)? fetchStatus;

  const _VCCard({
    required this.vc,
    required this.vcJson,
    required this.vcType,
    required this.title,
    required this.icon,
    required this.color,
    required this.detailRows,
    required this.onCreateVcQr,
    required this.onScanVpRequest,
    this.fetchStatus,
  });

  @override
  Widget build(BuildContext context) {
    final expirationDate = vc['expirationDate'] as String? ?? '';
    final isExpired =
        expirationDate.isNotEmpty &&
        DateTime.tryParse(expirationDate)?.isBefore(DateTime.now()) == true;

    return _Card(
      borderColor: isExpired
          ? AppColors.error.withValues(alpha: 0.4)
          : color.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: icon,
            iconColor: isExpired ? AppColors.error : color,
            title: title,
            badge: isExpired ? 'EXPIRED' : 'VALID',
            badgeColor: isExpired ? AppColors.error : AppColors.success,
          ),
          const SizedBox(height: 12),
          if (fetchStatus != null) ...[
            _StatusBadge(vc: vc, fetchStatus: fetchStatus!),
            const SizedBox(height: 10),
          ],
          ...detailRows,
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.qr_code_rounded, size: 16),
                  label: Text(AppLocalizations.of(context)!.walletCreateVcQr),
                  onPressed: onCreateVcQr,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                  label: Text(AppLocalizations.of(context)!.walletScanVpRequest),
                  onPressed: onScanVpRequest,
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  final VoidCallback onUnlock;
  const _LockedOverlay({required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fingerprint,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.walletBiometricLock,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.biometricLockedHint,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onUnlock,
              icon: const Icon(Icons.lock_open_rounded, size: 18),
              label: Text(l10n.biometricUnlock),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(180, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
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
            title: AppLocalizations.of(context)!.walletPublicKeyTitle,
            trailing: IconButton(
              icon: const Icon(
                Icons.copy_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              tooltip: AppLocalizations.of(context)!.walletCopy,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jwk));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.walletCopiedPublicKey),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
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

  String _trunc(String s) => s.length > 20
      ? '${s.substring(0, 12)}...${s.substring(s.length - 8)}'
      : s;
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
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
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
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badgeColor ?? AppColors.primary,
              ),
            ),
          ),
        ?trailing,
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
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: copyable
                ? () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.walletCopiedSnack),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
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
  final String vcJson;
  final String vcType;
  const _VpRequestScanDialog({required this.vcJson, required this.vcType});

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

    final requestedVcType = _extractVcType(authReq);
    if (requestedVcType != null && requestedVcType != widget.vcType) {
      _scanning = false;
      _ctrl.stop().ignore();
      if (!mounted) return;
      setState(
        () => _errorMsg = AppLocalizations.of(context)!
            .walletQrScanWrongCredential(
              humanizeVcType(requestedVcType),
              humanizeVcType(widget.vcType),
            ),
      );
      return;
    }

    _scanning = false;
    _ctrl.stop().ignore();

    final state = authReq['state'] as String?;
    final nonce = authReq['nonce'] as String?;
    if (state == null || nonce == null) {
      if (!mounted) return;
      setState(() => _errorMsg = AppLocalizations.of(context)!.walletQrInvalidMissingStateNonce);
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
        vcJson: widget.vcJson,
        disclosedFields: requestedFields,
      );
      if (!mounted) return;
      Navigator.pop(context);
      final l10n = AppLocalizations.of(context)!;
      final errorMsg = result.valid
          ? l10n.walletVpAccepted
          : l10n.walletVpRejected(result.reason);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: result.valid ? AppColors.success : AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() {
        _submitting = false;
        _errorMsg = AppLocalizations.of(context)!.walletVpSendFailed(e.toString());
      });
    }
  }

  Future<bool?> _showConfirmDialog(List<String> requestedFields) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.walletRequestShareInfo,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.walletVerifierRequestHint,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.walletRequestedFields,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...requestedFields.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      humanizeFieldKey(f),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppLocalizations.of(context)!.walletReject,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.check_rounded, size: 16),
            label: Text(AppLocalizations.of(context)!.walletConfirmShare),
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
        final p = path.first
            .toString(); // e.g. "$.credentialSubject.department"
        return p.split('.').last;
      }).toList();
    } catch (_) {
      return kVcSchemas[widget.vcType]?.fields ??
          ['employmentStatus', 'department', 'position', 'startDate'];
    }
  }

  String? _extractVcType(Map<String, dynamic> authReq) {
    try {
      final pd = authReq['presentation_definition'] as Map<String, dynamic>;
      final descriptors = pd['input_descriptors'] as List<dynamic>;
      final first = descriptors.first as Map<String, dynamic>;
      final schema = first['schema'] as Map<String, dynamic>;
      return schema['vcType'] as String?;
    } catch (_) {
      return null;
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
            Text(
              AppLocalizations.of(context)!.walletVerifierScanTitle,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.walletVerifierScanSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                child: Text(
                  _errorMsg!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
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
                            border: Border.all(
                              color: AppColors.accent,
                              width: 2.5,
                            ),
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
              child: Text(AppLocalizations.of(context)!.walletClose),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _StatusBadge ───────────────────────────────────────────────────────────────

class _StatusBadge extends StatefulWidget {
  final Map<String, dynamic> vc;
  final Future<String> Function(Map<String, dynamic>) fetchStatus;

  const _StatusBadge({required this.vc, required this.fetchStatus});

  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge> {
  String _status = 'LOADING';

  @override
  void initState() {
    super.initState();
    widget.fetchStatus(widget.vc).then((s) {
      if (mounted) setState(() => _status = s);
    });
  }

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (_status) {
      'ACTIVE'  => ('● ACTIVE',  const Color(0xFF16A34A)),
      'REVOKED' => ('✕ REVOKED', AppColors.error),
      'LOADING' => ('…',         AppColors.textSecondary),
      _         => ('UNKNOWN',   AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

// ── _SdJwtCard ─────────────────────────────────────────────────────────────────

class _SdJwtCard extends StatelessWidget {
  final String sdJwt;
  final String credentialType;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SdJwtCard({
    required this.sdJwt,
    required this.credentialType,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Parse to show claim count
    int claimCount = 0;
    try {
      final parts = sdJwt.split('~');
      claimCount = parts.skip(1).where((s) => s.isNotEmpty).length;
    } catch (_) {}

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(subtitle,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(AppLocalizations.of(context)!.walletSdJwtBadge,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: color),
                    const SizedBox(width: 6),
                    Text(AppLocalizations.of(context)!.walletSelectiveClaims(claimCount),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const Spacer(),
                    Icon(Icons.visibility_off_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.of(context)!.walletZeroKnowledge,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => DisclosurePickerScreen(
                        sdJwt: sdJwt,
                        credentialType: credentialType,
                      ),
                    ));
                  },
                  icon: Icon(Icons.share_outlined, size: 16, color: color),
                  label: Text(AppLocalizations.of(context)!.walletPresentSelective,
                      style: TextStyle(fontSize: 13, color: color)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── _BiometricLockTile ─────────────────────────────────────────────────────────

class _BiometricLockTile extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _BiometricLockTile({required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        value: enabled,
        onChanged: onChanged,
        secondary: Icon(
          enabled ? Icons.fingerprint : Icons.lock_open_outlined,
          color: enabled ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(AppLocalizations.of(context)!.walletBiometricLock,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(
          enabled
              ? AppLocalizations.of(context)!.walletBiometricLockOnSubtitle
              : AppLocalizations.of(context)!.walletBiometricLockOffSubtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
