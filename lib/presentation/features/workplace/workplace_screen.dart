import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';

class WorkplaceScreen extends StatefulWidget {
  const WorkplaceScreen({super.key});

  @override
  State<WorkplaceScreen> createState() => _WorkplaceScreenState();
}

class _WorkplaceScreenState extends State<WorkplaceScreen> {
  String _role = 'EMPLOYEE';

  @override
  void initState() {
    super.initState();
    SecureStorage.getUserRole().then((r) {
      if (mounted) setState(() => _role = r ?? 'EMPLOYEE');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChief = _role == 'CHIEF';
    final isManager = _role == 'MANAGER';
    final tiles = <_WorkplaceTile>[
      if (!isChief && !isManager) ...[
        _WorkplaceTile(
          icon: Icons.fingerprint_rounded,
          label: l10n.workplaceAttendance,
          color: AppColors.info,
          route: '/app/attendance',
        ),
        _WorkplaceTile(
          icon: Icons.description_rounded,
          label: l10n.workplaceRequests,
          color: AppColors.accent,
          route: '/app/requests',
        ),
      ],
      _WorkplaceTile(
        icon: Icons.group_rounded,
        label: l10n.workplaceDirectory,
        color: AppColors.primary,
        route: '/app/directory',
      ),
      if (!isChief && !isManager)
        _WorkplaceTile(
          icon: Icons.business_rounded,
          label: l10n.workplaceCompany,
          color: AppColors.primaryLight,
          route: '/app/company',
        ),
      _WorkplaceTile(
        icon: Icons.attach_money_rounded,
        label: l10n.workplacePayroll,
        color: AppColors.success,
        route: '/app/payroll',
      ),
      _WorkplaceTile(
        icon: Icons.assignment_rounded,
        label: l10n.workplaceContract,
        color: AppColors.warning,
        route: '/app/contract',
      ),
      if (_role == 'MANAGER' || isChief || _role == 'ADMIN')
        _WorkplaceTile(
          icon: Icons.approval_rounded,
          label: l10n.workplaceManagerRequests,
          color: AppColors.warning,
          route: '/app/manager/requests',
        ),
      if (_role == 'MANAGER' || _role == 'ADMIN')
        _WorkplaceTile(
          icon: Icons.table_chart_rounded,
          label: l10n.workplaceManagerTimesheet,
          color: AppColors.info,
          route: '/app/manager/timesheet',
        ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l10n.workplaceTitle,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.r(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                child: Icon(Icons.work_outline_rounded,
                    color: Colors.white, size: context.r(26)),
              ),
              SizedBox(width: context.r(14)),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.workplaceTitle,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: context.r(17),
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: context.r(2)),
                  Text(l10n.workplaceSubtitle,
                      style: TextStyle(
                          color: Colors.white70, fontSize: context.r(12))),
                ]),
              ),
            ]),
          ),
          SizedBox(height: context.r(20)),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: context.r(12),
            crossAxisSpacing: context.r(12),
            childAspectRatio: 1.3,
            children: tiles
                .map((t) => _tileCard(context, t))
                .toList(growable: false),
          ),
        ]),
      ),
    );
  }

  Widget _tileCard(BuildContext context, _WorkplaceTile t) => GestureDetector(
        onTap: () => context.push(t.route),
        child: Container(
          padding: EdgeInsets.all(context.r(14)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(context.r(14)),
            border: Border.all(color: t.color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                  color: t.color.withValues(alpha: 0.06),
                  blurRadius: context.r(8),
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(context.r(8)),
                  decoration: BoxDecoration(
                      color: t.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(context.r(10))),
                  child: Icon(t.icon, color: t.color, size: context.r(22)),
                ),
                Text(t.label,
                    style: TextStyle(
                        fontSize: context.r(13), fontWeight: FontWeight.w600)),
              ]),
        ),
      );
}

class _WorkplaceTile {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  _WorkplaceTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}
