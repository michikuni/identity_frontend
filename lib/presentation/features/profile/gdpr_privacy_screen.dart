import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/l10n/l10n.dart';

/// GDPR Privacy Screen — Art.20 Data Export + Art.17 Right to be Forgotten.
///
/// GET    /api/v1/me/export-data  → JSON dump of all personal data
/// DELETE /api/v1/me/data         → soft-delete + revoke VC + RevokeDID
class GdprPrivacyScreen extends StatefulWidget {
  const GdprPrivacyScreen({super.key});

  @override
  State<GdprPrivacyScreen> createState() => _GdprPrivacyScreenState();
}

class _GdprPrivacyScreenState extends State<GdprPrivacyScreen> {
  bool _exporting = false;
  bool _deleting  = false;
  String? _exportedJson;
  String? _error;

  Future<void> _exportData() async {
    setState(() { _exporting = true; _error = null; });
    try {
      final res = await ApiClient.instance.get(ApiConstants.gdprExport);
      final pretty = const JsonEncoder.withIndent('  ')
          .convert(res.data['data'] ?? res.data);
      setState(() { _exportedJson = pretty; _exporting = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _exporting = false; });
    }
  }

  Future<void> _deleteData() async {
    // Step 1: inform
    final l10n = context.l10n;
    final step1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.gdprDeleteTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.error)),
        content: Text(l10n.gdprDeleteWarning),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.gdprIUnderstandContinue),
          ),
        ],
      ),
    );
    if (step1 != true || !mounted) return;

    // Step 2: type confirmation
    final ctrl = TextEditingController();
    final step2 = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(l10n.gdprFinalConfirmTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.gdprTypeDeleteHint,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                onChanged: (_) => setLocal(() {}),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  hintText: 'DELETE',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: ctrl.text == 'DELETE' ? () => Navigator.pop(ctx, true) : null,
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(l10n.gdprDeleteAllData),
            ),
          ],
        ),
      ),
    );
    if (step2 != true || !mounted) return;

    setState(() { _deleting = true; _error = null; });
    try {
      await ApiClient.instance.delete(ApiConstants.gdprDelete);
      await SecureStorage.clearAll();
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.gdprDataDeleted),
            content: Text(l10n.gdprDataDeletedMsg),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
        // Navigate to sign-in
        if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/auth/sign-in', (_) => false);
      }
    } catch (e) {
      setState(() { _error = e.toString(); _deleting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(l10n.gdprTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(
            icon: Icons.privacy_tip_outlined,
            title: l10n.gdprDataRightsTitle,
            body: l10n.gdprDataRightsBody,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),

          // Export section
          _SectionCard(
            icon: Icons.download_outlined,
            title: l10n.gdprExportTitle,
            subtitle: l10n.gdprExportSubtitle,
            color: AppColors.info,
            action: _exporting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : FilledButton.icon(
                    icon: const Icon(Icons.download_outlined, size: 16),
                    label: Text(l10n.gdprExportBtn),
                    onPressed: _exportData,
                    style: FilledButton.styleFrom(backgroundColor: AppColors.info),
                  ),
          ),

          if (_exportedJson != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(l10n.gdprExportedData,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.copy_outlined, size: 14),
                        label: Text(l10n.walletCopy, style: const TextStyle(fontSize: 12)),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _exportedJson!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.copiedToClipboard),
                                behavior: SnackBarBehavior.floating),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _exportedJson!,
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Delete section
          _SectionCard(
            icon: Icons.delete_forever_outlined,
            title: l10n.gdprDeleteTitle,
            subtitle: l10n.gdprDeleteCardSubtitle,
            color: AppColors.error,
            action: _deleting
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error))
                : OutlinedButton.icon(
                    icon: const Icon(Icons.delete_forever_outlined, size: 16, color: AppColors.error),
                    label: Text(l10n.gdprDeleteAllData,
                        style: const TextStyle(color: AppColors.error)),
                    onPressed: _deleteData,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12)),
          ],

          const SizedBox(height: 32),
          const _LegalNote(),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 4),
                Text(body,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget action;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          action,
        ],
      ),
    );
  }
}

class _LegalNote extends StatelessWidget {
  const _LegalNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        context.l10n.gdprLegalNote,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}
