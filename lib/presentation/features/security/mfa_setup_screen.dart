import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/l10n/l10n.dart';

/// MFA Setup Screen — TOTP 2FA for Admin / Chief.
///
/// Flow:
///   1. POST /mfa/setup → nhận qrDataUri (base64 PNG) + secret
///   2. User scan QR vào Google Authenticator / Authy
///   3. Nhập 6-digit code → POST /mfa/verify-setup → nhận backup codes
///   4. Hiển thị backup codes một lần (không xem lại được)
class MfaSetupScreen extends StatefulWidget {
  const MfaSetupScreen({super.key});

  @override
  State<MfaSetupScreen> createState() => _MfaSetupScreenState();
}

class _MfaSetupScreenState extends State<MfaSetupScreen> {
  _MfaStep _step = _MfaStep.loading;
  String? _qrDataUri;
  String? _secret;
  List<String> _backupCodes = [];
  String? _error;
  bool _submitting = false;

  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startSetup();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _startSetup() async {
    setState(() {
      _step = _MfaStep.loading;
      _error = null;
    });
    try {
      final userId = await SecureStorage.getUserId();
      final res = await ApiClient.instance.post(ApiConstants.mfaSetup, data: {'userId': userId});
      final data = res.data['data'] as Map<String, dynamic>;
      setState(() {
        _qrDataUri = data['qrDataUri'] as String?;
        _secret = data['secret'] as String?;
        _step = _MfaStep.scanQr;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _step = _MfaStep.error;
      });
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final userId = await SecureStorage.getUserId();
      final res = await ApiClient.instance.post(ApiConstants.mfaVerifySetup, data: {
        'userId': userId,
        'code': code,
      });
      final data = res.data['data'] as Map<String, dynamic>;
      final codes = (data['backupCodes'] as List<dynamic>).cast<String>();
      setState(() {
        _backupCodes = codes;
        _step = _MfaStep.showBackupCodes;
        _submitting = false;
      });
    } catch (e) {
      setState(() {
        _error = context.l10n.mfaInvalidCode;
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(context.l10n.mfaSetupTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: switch (_step) {
        _MfaStep.loading => const Center(child: CircularProgressIndicator()),
        _MfaStep.error   => _buildError(),
        _MfaStep.scanQr  => _buildScanQr(),
        _MfaStep.showBackupCodes => _buildBackupCodes(),
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(_error ?? context.l10n.error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            FilledButton(onPressed: _startSetup, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }

  Widget _buildScanQr() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _StepIndicator(current: 1, total: 2),
          const SizedBox(height: 24),
          Text(context.l10n.mfaScanQrInstruction,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(context.l10n.mfaScanQrHint,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),

          // QR Code
          if (_qrDataUri != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: _QrImage(dataUri: _qrDataUri!),
            )
          else
            const CircularProgressIndicator(),

          const SizedBox(height: 16),

          // Manual entry fallback
          if (_secret != null)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: _secret!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.mfaSecretCopied), behavior: SnackBarBehavior.floating),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.copy_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(_secret!, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          Text(context.l10n.mfaEnterCodeHint,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 8),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: '000000',
            ),
            onChanged: (v) => setState(() {}),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: (_codeCtrl.text.length == 6 && !_submitting) ? _verifyCode : null,
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(context.l10n.mfaVerifyBtn, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCodes() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepIndicator(current: 2, total: 2),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
              const SizedBox(width: 10),
              Text(context.l10n.mfaEnabled,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.mfaBackupCodesWarning,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(context.l10n.mfaBackupCodesTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: _backupCodes.map((code) => Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(code,
                  style: const TextStyle(fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
            )).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.copy_outlined),
              label: Text(context.l10n.mfaCopyAllCodes),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _backupCodes.join('\n')));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.mfaBackupCodesCopied), behavior: SnackBarBehavior.floating),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.done, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MfaStep { loading, scanQr, showBackupCodes, error }

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: i + 1 == current ? 28 : 10,
        height: 8,
        decoration: BoxDecoration(
          color: i + 1 == current ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(4),
        ),
      )),
    );
  }
}

class _QrImage extends StatelessWidget {
  final String dataUri;
  const _QrImage({required this.dataUri});

  @override
  Widget build(BuildContext context) {
    try {
      final comma = dataUri.indexOf(',');
      final base64Str = comma >= 0 ? dataUri.substring(comma + 1) : dataUri;
      final bytes = base64Decode(base64Str);
      return Image.memory(Uint8List.fromList(bytes), width: 200, height: 200);
    } catch (_) {
      return SizedBox(
        width: 200,
        height: 200,
        child: Center(
          child: Text(context.l10n.mfaQrUnavailable,
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
  }
}
