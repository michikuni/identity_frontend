import 'package:flutter/material.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';

class PendingAccountsScreen extends StatefulWidget {
  const PendingAccountsScreen({super.key});

  @override
  State<PendingAccountsScreen> createState() => _PendingAccountsScreenState();
}

class _PendingAccountsScreenState extends State<PendingAccountsScreen> {
  List<Map<String, dynamic>> _accounts = [];
  bool _loading = true;
  final Set<String> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get(ApiConstants.adminPendingAccounts);
      final data = res.data['data'] as List<dynamic>? ?? [];
      setState(() {
        _accounts = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _approve(String id) async {
    setState(() => _processingIds.add(id));
    try {
      await ApiClient.instance.put(ApiConstants.adminApproveAccount(id));
      setState(() => _accounts.removeWhere((a) => a['id'] == id));
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.pendingApproved),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.adminErrorPrefix(e.toString())),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      setState(() => _processingIds.remove(id));
    }
  }

  Future<void> _reject(String id, String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final ctxL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(ctxL10n.pendingRejectTitle),
          content: Text(ctxL10n.pendingRejectConfirm(email)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ctxL10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(ctxL10n.pendingReject),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    setState(() => _processingIds.add(id));
    try {
      await ApiClient.instance.put(ApiConstants.adminRejectAccount(id));
      setState(() => _accounts.removeWhere((a) => a['id'] == id));
      if (mounted) {
        final mountedL10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(mountedL10n.pendingRejected),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        final mountedL10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(mountedL10n.adminErrorPrefix(e.toString())),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      setState(() => _processingIds.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.homeApproveAccounts),
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
            tooltip: l10n.adminRefresh,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? _buildEmpty(context)
              : _buildList(context),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: context.r(56),
              color: AppColors.success.withValues(alpha: 0.7)),
          SizedBox(height: context.r(12)),
          Text(l10n.pendingEmpty,
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: context.r(16), vertical: context.r(10)),
          color: AppColors.warningLight,
          child: Row(
            children: [
              Icon(Icons.pending_actions_rounded,
                  size: context.r(18), color: AppColors.warning),
              SizedBox(width: context.r(8)),
              Text(
                l10n.adminPendingAccountsBanner(_accounts.length),
                style: TextStyle(
                    fontSize: context.r(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(context.r(16)),
            itemCount: _accounts.length,
            separatorBuilder: (_, _) => SizedBox(height: context.r(10)),
            itemBuilder: (_, i) => _AccountCard(
              account: _accounts[i],
              isProcessing: _processingIds.contains(_accounts[i]['id']),
              onApprove: () => _approve(_accounts[i]['id'] as String),
              onReject: () => _reject(
                _accounts[i]['id'] as String,
                _accounts[i]['email'] as String,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Map<String, dynamic> account;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _AccountCard({
    required this.account,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final email = account['email'] as String? ?? '';
    final phone = account['phone'] as String? ?? '';

    return Container(
      padding: EdgeInsets.all(context.r(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: context.r(22),
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              email.isNotEmpty ? email[0].toUpperCase() : '?',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: context.r(14)),
            ),
          ),
          SizedBox(width: context.r(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: context.r(14),
                        color: AppColors.textPrimary)),
                SizedBox(height: context.r(2)),
                Text(phone,
                    style: TextStyle(
                        fontSize: context.r(13), color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (isProcessing)
            SizedBox(
              width: context.r(24),
              height: context.r(24),
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: context.r(24)),
                  tooltip: l10n.pendingApprove,
                  onPressed: onApprove,
                ),
                IconButton(
                  icon: Icon(Icons.cancel_rounded,
                      color: AppColors.error, size: context.r(24)),
                  tooltip: l10n.pendingReject,
                  onPressed: onReject,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
