import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/locale/locale_cubit.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/date_format.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
import 'package:identity_frontend/core/utils/label_helpers.dart';
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
      create: (_) =>
          HomeBloc(employeeUseCase: sl())..add(const HomeFetchData()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, l10n, state),
              if (state.status == HomeStatus.loading)
                SliverFillRemaining(
                  child: LoadingWidget(message: l10n.homeLoadingProfile),
                )
              else if (state.status == HomeStatus.failure)
                SliverFillRemaining(
                  child: ErrorStateWidget(
                    message: state.errorMessage ?? l10n.homeLoadFailed,
                    onRetry: () =>
                        context.read<HomeBloc>().add(const HomeFetchData()),
                  ),
                )
              else if (state.employee != null)
                _buildContent(context, l10n, state.employee!, _role)
              else
                const SliverFillRemaining(child: LoadingWidget()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    HomeState state,
  ) {
    return SliverAppBar(
      expandedHeight: context.r(200),
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
          padding: EdgeInsets.fromLTRB(
            context.r(24),
            context.r(60),
            context.r(24),
            context.r(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: context.r(48),
                    height: context.r(48),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: context.r(26),
                    ),
                  ),
                  SizedBox(width: context.r(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeGreeting,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: context.r(13),
                          ),
                        ),
                        Text(
                          state.employee?.email ?? '—',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.r(17),
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  BlocBuilder<LocaleCubit, Locale>(
                    builder: (context, locale) {
                      final isVi = locale.languageCode == 'vi';
                      return GestureDetector(
                        onTap: () => context.read<LocaleCubit>().toggle(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.r(10),
                            vertical: context.r(5),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(context.r(20)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isVi ? '🇻🇳' : '🇺🇸',
                                style: TextStyle(fontSize: context.r(13)),
                              ),
                              SizedBox(width: context.r(4)),
                              Text(
                                isVi ? 'VI' : 'EN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.r(11),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: context.r(8)),
                  IconButton(
                    icon: Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: context.r(22),
                    ),
                    tooltip: l10n.logout,
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthLoggedOut());
                      context.go('/auth/sign-in');
                    },
                  ),
                ],
              ),
              SizedBox(height: context.r(12)),
              Text(
                l10n.homeSubtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: context.r(13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    EmployeeEntity emp,
    String role,
  ) {
    return SliverPadding(
      padding: EdgeInsets.all(context.r(16)),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.r(18),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: context.r(4)),
                          Text(
                            emp.department,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: context.r(14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge.fromStatus(emp.status),
                  ],
                ),
                SizedBox(height: context.r(20)),
                Row(
                  children: [
                    _statItem(
                      context,
                      Icons.work_outline_rounded,
                      l10n.homeWorkingType,
                      workingTypeLabel(l10n, emp.workingType),
                    ),
                    SizedBox(width: context.r(16)),
                    _statItem(
                      context,
                      Icons.badge_outlined,
                      l10n.homeEmployee,
                      roleLabel(l10n, emp.role),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.r(16)),
          Text(
            l10n.homeQuickAccess,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: context.r(12)),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: context.r(12),
            crossAxisSpacing: context.r(12),
            childAspectRatio: 1.6,
            children: [
              _quickCard(
                context,
                Icons.person_outlined,
                l10n.navProfile,
                '/app/profile',
                AppColors.info,
              ),
              _quickCard(
                context,
                Icons.description_outlined,
                l10n.navContract,
                '/app/contract',
                AppColors.success,
              ),
              _quickCard(
                context,
                Icons.payments_outlined,
                l10n.navPayroll,
                '/app/payroll',
                AppColors.accent,
              ),
              if (role == 'CHIEF') ...[
                _quickCard(
                  context,
                  Icons.how_to_reg_outlined,
                  l10n.homeApproveAccounts,
                  '/app/admin/pending-accounts',
                  AppColors.warning,
                ),
                _quickCard(
                  context,
                  Icons.manage_accounts_outlined,
                  l10n.homeStaff,
                  '/app/chief',
                  AppColors.primary,
                ),
              ],
            ],
          ),
          SizedBox(height: context.r(16)),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.r(7)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(context.r(8)),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: context.r(16),
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: context.r(10)),
                    Text(
                      l10n.homeEmployee,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                SizedBox(height: context.r(12)),
                const Divider(),
                _detailRow(context, l10n.homeDepartment, emp.department),
                _detailRow(context, l10n.homePosition, emp.position),
                _detailRow(
                  context,
                  l10n.homeWorkingType,
                  workingTypeLabel(l10n, emp.workingType),
                ),
                if (emp.createdAt != null)
                  _detailRow(
                    context,
                    l10n.homeJoinedDate,
                    formatDateOf(emp.createdAt!),
                  ),
                if (emp.note != null && emp.note!.isNotEmpty)
                  _detailRow(
                    context,
                    l10n.homeNote,
                    emp.note!,
                    showDivider: false,
                  ),
              ],
            ),
          ),
          SizedBox(height: context.r(24)),
        ]),
      ),
    );
  }

  Widget _statItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.7),
            size: context.r(16),
          ),
          SizedBox(width: context.r(6)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: context.r(11),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.r(13),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickCard(
    BuildContext context,
    IconData icon,
    String label,
    String route,
    Color color,
  ) {
    return AppCard(
      onTap: () => context.go(route),
      padding: EdgeInsets.all(context.r(14)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.r(8)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
            child: Icon(icon, color: color, size: context.r(20)),
          ),
          SizedBox(width: context.r(10)),
          Text(
            label,
            style: TextStyle(
              fontSize: context.r(13),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: context.r(10)),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: context.r(13),
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: context.r(13),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
