import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get(ApiConstants.adminDashboard);
      setState(() {
        _stats = res.data['data'] as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildPendingAccountsBanner(context),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildLedgerBanner(context),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() => SliverAppBar(
        expandedHeight: 160,
        pinned: true,
        backgroundColor: AppColors.primary,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Bảng điều hành', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    Text('Tổng quan hệ thống', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                  ]),
                ]),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _load,
          ),
        ],
      );

  Widget _buildStatsGrid() {
    final s = _stats ?? {};
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.5,
      children: [
        _statCard('Tổng NV', '${s['totalEmployees'] ?? 0}', Icons.group_rounded, AppColors.primary),
        _statCard('Đang làm', '${s['activeEmployees'] ?? 0}', Icons.how_to_reg_rounded, AppColors.success),
        _statCard('Vào hôm nay', '${s['todayAttendance'] ?? 0}', Icons.login_rounded, AppColors.info),
        _statCard('Đơn chờ', '${s['pendingRequests'] ?? 0}', Icons.pending_actions_rounded, AppColors.warning),
      ],
    );
  }

  Widget _buildPendingAccountsBanner(BuildContext context) {
    final count = (_stats ?? {})['pendingAccounts'] as int? ?? 0;
    if (count == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => context.push('/app/admin/pending-accounts'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.pending_actions_rounded, color: AppColors.warning, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$count tài khoản đang chờ duyệt',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.warning, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      );

  Widget _buildLedgerBanner(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_tree_rounded, color: Color(0xFF34D399), size: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Blockchain Ledger', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('Xem toàn bộ audit trail', style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34D399),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: () => context.go('/app/admin/ledger'),
              child: const Text('Xem', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ],
        ),
      );
}
