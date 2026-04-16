import 'package:flutter/material.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đã duyệt tài khoản'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
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
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối tài khoản'),
        content: Text('Từ chối tài khoản "$email"?\nTài khoản này sẽ không thể đăng nhập.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _processingIds.add(id));
    try {
      await ApiClient.instance.put(ApiConstants.adminRejectAccount(id));
      setState(() => _accounts.removeWhere((a) => a['id'] == id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đã từ chối tài khoản'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Duyệt tài khoản'),
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
          : _accounts.isEmpty
              ? _buildEmpty()
              : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 56, color: AppColors.success.withValues(alpha: 0.7)),
          const SizedBox(height: 12),
          const Text('Không có tài khoản nào chờ duyệt',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        // Summary bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.warningLight,
          child: Row(
            children: [
              const Icon(Icons.pending_actions_rounded,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                '${_accounts.length} tài khoản đang chờ duyệt',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _accounts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
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
    final email = account['email'] as String? ?? '';
    final phone = account['phone'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              email.isNotEmpty ? email[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(phone,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          // Actions
          if (isProcessing)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Approve
                IconButton(
                  icon: const Icon(Icons.check_circle_rounded,
                      color: AppColors.success),
                  tooltip: 'Duyệt',
                  onPressed: onApprove,
                ),
                // Reject
                IconButton(
                  icon: const Icon(Icons.cancel_rounded,
                      color: AppColors.error),
                  tooltip: 'Từ chối',
                  onPressed: onReject,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
