import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/domain/entities/employee_entity.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:identity_frontend/presentation/features/home/bloc/home_bloc.dart';
import 'package:identity_frontend/presentation/widgets/app_card.dart';
import 'package:identity_frontend/presentation/widgets/status_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(employeeUseCase: sl())..add(const HomeFetchData()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, l10n, state),
              if (state.status == HomeStatus.loading)
                const SliverFillRemaining(
                  child: LoadingWidget(message: 'Loading your profile...'),
                )
              else if (state.status == HomeStatus.failure)
                SliverFillRemaining(
                  child: ErrorStateWidget(
                    message: state.errorMessage ?? 'Failed to load data',
                    onRetry: () => context.read<HomeBloc>().add(const HomeFetchData()),
                  ),
                )
              else if (state.employee != null)
                _buildContent(context, l10n, state.employee!)
              else
                const SliverFillRemaining(child: LoadingWidget()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations l10n, HomeState state) {
    return SliverAppBar(
      expandedHeight: 200,
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
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeGreeting,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          state.employee?.email ?? '—',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                    tooltip: l10n.logout,
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthLoggedOut());
                      context.go('/auth/sign-in');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.homeSubtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, EmployeeEntity emp) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // ── Employee Card ──────────────────────────────────────────────
          GradientCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            emp.position,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            emp.department,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge.fromStatus(emp.status),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _statItem(Icons.work_outline_rounded, l10n.homeWorkingType, emp.workingType),
                    const SizedBox(width: 16),
                    _statItem(Icons.badge_outlined, l10n.homeEmployee, emp.role),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ── Quick Access ───────────────────────────────────────────────
          Text(l10n.homeQuickAccess, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _quickCard(context, Icons.person_outlined, l10n.navProfile, '/app/profile', AppColors.info),
              _quickCard(context, Icons.description_outlined, l10n.navContract, '/app/contract', AppColors.success),
              _quickCard(context, Icons.payments_outlined, l10n.navPayroll, '/app/payroll', AppColors.accent),
              _quickCard(context, Icons.link_rounded, l10n.navLedger, '/app/ledger', AppColors.primaryLight),
            ],
          ),
          const SizedBox(height: 16),
          // ── Details ────────────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Text(l10n.homeEmployee, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                _detailRow(l10n.homeDepartment, emp.department),
                _detailRow(l10n.homePosition, emp.position),
                _detailRow(l10n.homeWorkingType, emp.workingType),
                if (emp.createdAt != null)
                  _detailRow(l10n.homeJoinedDate, '${emp.createdAt!.day}/${emp.createdAt!.month}/${emp.createdAt!.year}'),
                if (emp.note != null && emp.note!.isNotEmpty)
                  _detailRow(l10n.homeNote, emp.note!, showDivider: false),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                ),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickCard(BuildContext context, IconData icon, String label, String route, Color color) {
    return AppCard(
      onTap: () => context.go(route),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(label,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ),
              Expanded(
                flex: 6,
                child: Text(value,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
