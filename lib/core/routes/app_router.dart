import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/firebase/analytics_route_observer.dart';
import 'package:identity_frontend/core/firebase/repositories/i_analytics_service.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/domain/usecases/attendance_usecase.dart';
import 'package:identity_frontend/domain/usecases/company_usecase.dart';
import 'package:identity_frontend/domain/usecases/directory_usecase.dart';
import 'package:identity_frontend/domain/usecases/request_usecase.dart';
import 'package:identity_frontend/presentation/features/admin/admin_dashboard_screen.dart';
import 'package:identity_frontend/presentation/features/admin/audit_log_screen.dart';
import 'package:identity_frontend/presentation/features/admin/issue_sd_jwt_screen.dart';
import 'package:identity_frontend/presentation/features/attendance/attendance_history_screen.dart';
import 'package:identity_frontend/presentation/features/contract/contract_sign_screen.dart';
import 'package:identity_frontend/presentation/features/profile/gdpr_privacy_screen.dart';
import 'package:identity_frontend/presentation/features/security/mfa_setup_screen.dart';
import 'package:identity_frontend/presentation/features/security/sessions_screen.dart';
import 'package:identity_frontend/presentation/features/attendance/attendance_screen.dart';
import 'package:identity_frontend/presentation/features/attendance/timesheet_screen.dart';
import 'package:identity_frontend/presentation/features/manager/manager_timesheet_screen.dart';
import 'package:identity_frontend/presentation/features/attendance/bloc/attendance_bloc.dart';
import 'package:identity_frontend/presentation/features/attendance/bloc/attendance_event.dart';
import 'package:identity_frontend/presentation/features/admin/pending_accounts_screen.dart';
import 'package:identity_frontend/presentation/features/auth/signin_screen.dart';
import 'package:identity_frontend/presentation/features/auth/signup_screen.dart';
import 'package:identity_frontend/presentation/features/cccd/cccd_scan_screen.dart';
import 'package:identity_frontend/presentation/features/onboarding/onboarding_screen.dart';
import 'package:identity_frontend/presentation/features/onboarding/profile_onboarding_screen.dart';
import 'package:identity_frontend/presentation/features/chief/chief_screen.dart';
import 'package:identity_frontend/presentation/features/company/company_screen.dart';
import 'package:identity_frontend/presentation/features/contract/contract_screen.dart';
import 'package:identity_frontend/presentation/features/directory/directory_screen.dart';
import 'package:identity_frontend/presentation/features/home/home_screen.dart';
import 'package:identity_frontend/presentation/features/ledger/ledger_screen.dart';
import 'package:identity_frontend/presentation/features/manager/manager_requests_screen.dart';
import 'package:identity_frontend/presentation/features/payroll/payroll_screen.dart';
import 'package:identity_frontend/presentation/features/profile/profile_screen.dart';
import 'package:identity_frontend/presentation/features/requests/bloc/request_bloc.dart';
import 'package:identity_frontend/presentation/features/requests/bloc/request_event.dart';
import 'package:identity_frontend/presentation/features/requests/create_request_screen.dart';
import 'package:identity_frontend/presentation/features/requests/request_list_screen.dart';
import 'package:identity_frontend/presentation/features/splash/splash_screen.dart';
import 'package:identity_frontend/presentation/features/wallet/wallet_screen.dart';
import 'package:identity_frontend/presentation/features/verifier/verifier_scan_screen.dart';
import 'package:identity_frontend/presentation/features/workplace/workplace_screen.dart';

GoRouter? appRouter;

GoRouter createAppRouter(IAnalyticsService analytics) {
  appRouter = GoRouter(
  initialLocation: '/',
  observers: [AnalyticsRouteObserver(analytics)],
  redirect: (context, state) async {
    final isLoggedIn = await SecureStorage.isLoggedIn();
    final loc = state.matchedLocation;
    final isAuthRoute = loc.startsWith('/auth');
    final isSplash = loc == '/';

    if (!isLoggedIn && !isAuthRoute && !isSplash) return '/auth/sign-in';

    // Role guards
    if (isLoggedIn && !isSplash && !isAuthRoute) {
      final role = await SecureStorage.getUserRole() ?? 'EMPLOYEE';
      if (loc.startsWith('/app/chief') && role != 'CHIEF' && role != 'ADMIN') {
        return '/app/home';
      }
      if (loc.startsWith('/app/admin') && role != 'ADMIN' && role != 'CHIEF') {
        return '/app/home';
      }
      if (loc.startsWith('/app/manager') && role == 'EMPLOYEE') {
        return '/app/home';
      }
      if (loc.startsWith('/app/ledger') && role == 'EMPLOYEE') {
        return '/app/home';
      }
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/auth/sign-in', builder: (_, _) => const SignInScreen()),
    GoRoute(path: '/auth/sign-up', builder: (_, _) => const SignUpScreen()),
    GoRoute(path: '/auth/onboarding', builder: (_, _) => const OnboardingScreen()),
    GoRoute(
      path: '/auth/onboarding/cccd-scan',
      builder: (context, state) => CccdScanScreen(
        onScanned: (data) => context.go('/auth/onboarding/profile', extra: data),
        onSkip: () => context.go('/auth/onboarding/profile'),
      ),
    ),
    GoRoute(
      path: '/auth/onboarding/profile',
      builder: (_, state) => ProfileOnboardingScreen(cccdData: state.extra as CccdData?),
    ),

    // Standalone routes (pushed on top of shell)
    GoRoute(
      path: '/app/requests/create',
      builder: (context, _) => BlocProvider(
        create: (_) => RequestBloc(useCase: sl<RequestUseCase>()),
        child: const CreateRequestScreen(),
      ),
    ),

    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(path: '/app/home', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/app/profile', builder: (_, _) => const ProfileScreen()),
        GoRoute(path: '/app/contract', builder: (_, _) => const ContractScreen()),
        GoRoute(path: '/app/payroll', builder: (_, _) => const PayrollScreen()),

        // Attendance
        GoRoute(
          path: '/app/attendance',
          builder: (context, _) => BlocProvider(
            create: (_) => AttendanceBloc(useCase: sl<AttendanceUseCase>())
              ..add(const AttendanceFetchToday()),
            child: const AttendanceScreen(),
          ),
        ),
        GoRoute(
          path: '/app/attendance/history',
          builder: (context, _) => BlocProvider(
            create: (_) => AttendanceBloc(useCase: sl<AttendanceUseCase>()),
            child: const AttendanceHistoryScreen(),
          ),
        ),
        GoRoute(
          path: '/app/attendance/timesheet',
          builder: (context, _) => BlocProvider(
            create: (_) => AttendanceBloc(useCase: sl<AttendanceUseCase>()),
            child: const TimesheetScreen(),
          ),
        ),

        // Manager timesheet
        GoRoute(
          path: '/app/manager/timesheet',
          builder: (_, _) => const ManagerTimesheetScreen(),
        ),

        // Requests
        GoRoute(
          path: '/app/requests',
          builder: (context, _) => BlocProvider(
            create: (_) => RequestBloc(useCase: sl<RequestUseCase>())
              ..add(const RequestFetchMine()),
            child: const RequestListScreen(),
          ),
        ),

        // Directory
        GoRoute(
          path: '/app/directory',
          builder: (context, _) => BlocProvider(
            create: (_) => DirectoryBloc(sl<DirectoryUseCase>()),
            child: const DirectoryScreen(),
          ),
        ),

        // Company
        GoRoute(
          path: '/app/company',
          builder: (context, _) => BlocProvider(
            create: (_) => CompanyBloc(sl<CompanyUseCase>()),
            child: const CompanyInfoScreen(),
          ),
        ),

        // Ledger (CHIEF + ADMIN)
        GoRoute(path: '/app/ledger', builder: (_, _) => const LedgerScreen()),
        GoRoute(path: '/app/admin/ledger', builder: (_, _) => const LedgerScreen()),

        // Manager
        GoRoute(
          path: '/app/manager/requests',
          builder: (context, _) => BlocProvider(
            create: (_) => RequestBloc(useCase: sl<RequestUseCase>()),
            child: const ManagerRequestsScreen(),
          ),
        ),

        // Chief
        GoRoute(path: '/app/chief', builder: (_, _) => const ChiefScreen()),

        // Admin
        GoRoute(path: '/app/admin', builder: (_, _) => const AdminDashboardScreen()),
        GoRoute(path: '/app/admin/pending-accounts', builder: (_, _) => const PendingAccountsScreen()),

        // Wallet (all roles)
        GoRoute(path: '/app/wallet', builder: (_, _) => const WalletScreen()),

        // Verifier QR scanner (all roles)
        GoRoute(path: '/app/verifier', builder: (_, _) => const VerifierScanScreen()),

        // Workplace hub — HRMS use-cases grouped under one entry
        GoRoute(path: '/app/workplace', builder: (_, _) => const WorkplaceScreen()),

        // Contract e-sign (Phase 1 / 4.7)
        GoRoute(
          path: '/app/contract/:id/sign',
          builder: (context, state) {
            final contractId = int.parse(state.pathParameters['id']!);
            final extra = state.extra as Map<String, dynamic>?;
            return ContractSignScreen(
              contractId: contractId,
              contractType: extra?['contractType'] as String?,
              startDate: extra?['startDate'] as String?,
              endDate: extra?['endDate'] as String?,
            );
          },
        ),

        // Issue SD-JWT (Admin / Chief)
        GoRoute(
          path: '/app/admin/issue-sd-jwt/:employeeId',
          builder: (context, state) {
            final employeeId = state.pathParameters['employeeId']!;
            final extra = state.extra as Map<String, dynamic>?;
            return IssueSdJwtScreen(
              employeeId: employeeId,
              employeeName: extra?['employeeName'] as String?,
            );
          },
        ),

        // Audit Log (Admin / Chief)
        GoRoute(
          path: '/app/admin/audit/:employeeId',
          builder: (context, state) {
            final employeeId = state.pathParameters['employeeId']!;
            final extra = state.extra as Map<String, dynamic>?;
            return AuditLogScreen(
              employeeId: employeeId,
              employeeName: extra?['employeeName'] as String?,
            );
          },
        ),

        // MFA Setup (Admin / Chief)
        GoRoute(
          path: '/app/security/mfa-setup',
          builder: (_, _) => const MfaSetupScreen(),
        ),

        // Active Sessions
        GoRoute(
          path: '/app/security/sessions',
          builder: (_, _) => const SessionsScreen(),
        ),

        // GDPR Privacy
        GoRoute(
          path: '/app/privacy',
          builder: (_, _) => const GdprPrivacyScreen(),
        ),
      ],
    ),
  ],
);
  return appRouter!;
}

// ── Role-aware Shell ──────────────────────────────────────────────────────────

class _AppShell extends StatefulWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  String _role = 'EMPLOYEE';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await SecureStorage.getUserRole() ?? 'EMPLOYEE';
    if (mounted) setState(() => _role = role);
  }

  List<_NavItem> _navItems(AppLocalizations l10n) {
    // SSI-first navigation. HRMS use-cases (attendance/requests/directory/...)
    // are collapsed under /app/workplace to reposition the app as an SSI
    // platform instead of an HRMS-with-blockchain.
    if (_role == 'MANAGER') {
      return [
        _NavItem('/app/wallet', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, l10n.navWallet),
        _NavItem('/app/verifier', Icons.qr_code_scanner_rounded, Icons.qr_code_scanner_rounded, l10n.navVerifier),
        _NavItem('/app/workplace', Icons.work_outline_rounded, Icons.work_rounded, l10n.navWorkplace),
        _NavItem('/app/home', Icons.home_outlined, Icons.home_rounded, l10n.navHome),
        _NavItem('/app/profile', Icons.person_outline_rounded, Icons.person_rounded, l10n.navProfile),
      ];
    }

    if (_role == 'CHIEF') {
      return [
        _NavItem('/app/wallet', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, l10n.navWallet),
        _NavItem('/app/verifier', Icons.qr_code_scanner_rounded, Icons.qr_code_scanner_rounded, l10n.navVerifier),
        _NavItem('/app/chief', Icons.manage_accounts_outlined, Icons.manage_accounts_rounded, l10n.ssiCredentialSubjects),
        _NavItem('/app/workplace', Icons.work_outline_rounded, Icons.work_rounded, l10n.navWorkplace),
        _NavItem('/app/profile', Icons.person_outline_rounded, Icons.person_rounded, l10n.navProfile),
      ];
    }

    if (_role == 'ADMIN') {
      return [
        _NavItem('/app/admin', Icons.workspace_premium_outlined, Icons.workspace_premium_rounded, l10n.navIssuer),
        _NavItem('/app/verifier', Icons.qr_code_scanner_rounded, Icons.qr_code_scanner_rounded, l10n.navVerifier),
        _NavItem('/app/profile', Icons.person_outline_rounded, Icons.person_rounded, l10n.navProfile),
      ];
    }

    // EMPLOYEE
    return [
      _NavItem('/app/wallet', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, l10n.navWallet),
      _NavItem('/app/verifier', Icons.qr_code_scanner_rounded, Icons.qr_code_scanner_rounded, l10n.navVerifier),
      _NavItem('/app/workplace', Icons.work_outline_rounded, Icons.work_rounded, l10n.navWorkplace),
      _NavItem('/app/home', Icons.home_outlined, Icons.home_rounded, l10n.navHome),
      _NavItem('/app/profile', Icons.person_outline_rounded, Icons.person_rounded, l10n.navProfile),
    ];
  }

  int _currentIndex(List<_NavItem> items, String loc) {
    for (int i = 0; i < items.length; i++) {
      if (loc.startsWith(items[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loc = GoRouterState.of(context).matchedLocation;
    final items = _navItems(l10n);
    final currentIndex = _currentIndex(items, loc);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 16, offset: Offset(0, -4))],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex.clamp(0, items.length - 1),
          onTap: (i) => context.go(items[i].path),
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.inactive,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: items
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.activeIcon),
                    label: item.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.path, this.icon, this.activeIcon, this.label);
}
