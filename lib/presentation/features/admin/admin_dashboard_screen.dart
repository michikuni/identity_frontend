import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/features/auth/bloc/auth_bloc.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient.instance.get(ApiConstants.adminDashboard);
      if (!mounted) return;
      setState(() {
        _stats = res.data['data'] as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  int _int(String key) => ((_stats ?? {})[key] as num?)?.toInt() ?? 0;

  Future<void> _showIssueSalaryVcSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final idCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminIssueSalaryVcTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adminIssueSalaryVcDesc,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: idCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.adminEmployeeId,
                hintText: l10n.adminEmployeeIdHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final id = idCtrl.text.trim();
              if (id.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await ApiClient.instance.put('/admin/employees/$id/issue-salary-vc');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(l10n.adminSalaryVcIssued),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(l10n.adminErrorPrefix(e.toString())),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              }
            },
            child: Text(l10n.adminIssueVc),
          ),
        ],
      ),
    );
    idCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(l10n.adminDashboardTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
            tooltip: l10n.adminRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: l10n.logout,
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLoggedOut());
              context.go('/auth/sign-in');
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(l10n)
              : _buildContent(context, l10n),
    );
  }

  Widget _buildError(AppLocalizations l10n) => Center(
        child: Padding(
          padding: EdgeInsets.all(context.r(32)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline_rounded, size: context.r(52), color: AppColors.error),
            SizedBox(height: context.r(12)),
            Text(l10n.adminLoadFailed,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: context.r(8)),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            SizedBox(height: context.r(20)),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh_rounded, size: context.r(18)),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: _load,
            ),
          ]),
        ),
      );

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.r(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Header card
        Container(
          padding: EdgeInsets.all(context.r(18)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(context.r(16)),
          ),
          child: Row(children: [
            Container(
              padding: EdgeInsets.all(context.r(10)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(context.r(12)),
              ),
              child: Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.white, size: context.r(26)),
            ),
            SizedBox(width: context.r(14)),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.adminSystemOverview,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: context.r(17),
                      fontWeight: FontWeight.w700)),
              SizedBox(height: context.r(2)),
              Text(l10n.adminRealTimeData,
                  style: TextStyle(color: Colors.white70, fontSize: context.r(12))),
            ]),
          ]),
        ),
        SizedBox(height: context.r(16)),

        // Pending accounts banner
        if (_int('pendingAccounts') > 0) ...[
          GestureDetector(
            onTap: () => context.push('/app/admin/pending-accounts'),
            child: Container(
              padding: EdgeInsets.all(context.r(14)),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(context.r(14)),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                Icon(Icons.pending_actions_rounded, color: AppColors.warning, size: context.r(22)),
                SizedBox(width: context.r(10)),
                Expanded(
                  child: Text(
                    l10n.adminPendingAccountsBanner(_int('pendingAccounts')),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                        fontSize: context.r(14)),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.warning, size: context.r(14)),
              ]),
            ),
          ),
          SizedBox(height: context.r(16)),
        ],

        // Stats grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: context.r(14),
          crossAxisSpacing: context.r(14),
          childAspectRatio: 1.45,
          children: [
            _statCard(context, l10n.adminStatTotalEmployees, _int('totalEmployees'),
                Icons.group_rounded, AppColors.primary),
            _statCard(context, l10n.adminStatActiveEmployees, _int('activeEmployees'),
                Icons.how_to_reg_rounded, AppColors.success),
            _statCard(context, l10n.adminStatTodayAttendance, _int('todayAttendance'),
                Icons.login_rounded, AppColors.info),
            _statCard(context, l10n.adminStatPendingRequests, _int('pendingRequests'),
                Icons.pending_actions_rounded, AppColors.warning),
          ],
        ),
        SizedBox(height: context.r(20)),

        // Quick links row 1
        Row(children: [
          Expanded(
            child: _quickCard(
              context,
              icon: Icons.people_alt_rounded,
              label: l10n.adminManageStaff,
              color: AppColors.primary,
              onTap: () => context.go('/app/chief'),
            ),
          ),
          SizedBox(width: context.r(12)),
          Expanded(
            child: _quickCard(
              context,
              icon: Icons.manage_accounts_rounded,
              label: l10n.homeApproveAccounts,
              color: AppColors.warning,
              onTap: () => context.push('/app/admin/pending-accounts'),
            ),
          ),
        ]),
        SizedBox(height: context.r(12)),

        // Quick links row 2
        Row(children: [
          Expanded(
            child: _quickCard(
              context,
              icon: Icons.attach_money_rounded,
              label: l10n.adminIssueSalaryVc,
              color: AppColors.accent,
              onTap: () => _showIssueSalaryVcSheet(context),
            ),
          ),
          SizedBox(width: context.r(12)),
          Expanded(
            child: _quickCard(
              context,
              icon: Icons.qr_code_scanner_rounded,
              label: l10n.adminVerifierScanner,
              color: AppColors.info,
              onTap: () => context.push('/app/verifier'),
            ),
          ),
        ]),
        SizedBox(height: context.r(24)),
      ]),
    );
  }

  Widget _statCard(BuildContext context, String label, int value, IconData icon, Color color) =>
      Container(
        padding: EdgeInsets.all(context.r(16)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: context.r(10),
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(context.r(8)),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.r(8))),
              child: Icon(icon, color: color, size: context.r(18)),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$value',
                  style: TextStyle(
                      fontSize: context.r(26), fontWeight: FontWeight.w900, color: color)),
              Text(label,
                  style: TextStyle(
                      fontSize: context.r(11), color: AppColors.textSecondary)),
            ]),
          ],
        ),
      );

  Widget _quickCard(BuildContext context,
          {required IconData icon,
          required String label,
          required Color color,
          required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(context.r(16)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(context.r(14)),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.06),
                  blurRadius: context.r(8),
                  offset: const Offset(0, 3))
            ],
          ),
          child: Row(children: [
            Icon(icon, color: color, size: context.r(22)),
            SizedBox(width: context.r(10)),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: context.r(13), fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      );
}
