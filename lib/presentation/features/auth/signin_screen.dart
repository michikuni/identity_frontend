import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/locale/locale_cubit.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:identity_frontend/presentation/widgets/app_input.dart';
import 'package:identity_frontend/presentation/widgets/primary_button.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(signInUseCase: sl(), signUpUseCase: sl()),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatefulWidget {
  const _SignInView();

  @override
  State<_SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<_SignInView> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
      SignInSubmitted(
        username: _userCtrl.text.trim(),
        password: _passCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.success) {
          final role = state.auth?.role ?? 'EMPLOYEE';
          if (role == 'ADMIN') {
            context.go('/app/admin');
          } else if (role == 'CHIEF') {
            context.go('/app/chief');
          } else {
            context.go('/app/home');
          }
        } else if (state.status == AuthStatus.failure) {
          final msg = state.errorMessage ?? '';
          final isPending = msg.contains('pending approval');
          final isRejected = msg.contains('rejected');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isPending
                    ? AppLocalizations.of(context)!.signinPendingApproval
                    : isRejected
                    ? AppLocalizations.of(context)!.signinRejected
                    : AppLocalizations.of(context)!.signinFailed,
              ),
              backgroundColor: isPending ? AppColors.warning : AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.r(10)),
              ),
              duration: Duration(seconds: isPending ? 4 : 3),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(context.r(32)),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    context.r(28),
                    context.r(48),
                    context.r(28),
                    context.r(40),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(context.r(10)),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                context.r(14),
                              ),
                            ),
                            child: Icon(
                              Icons.verified_user_rounded,
                              color: Colors.white,
                              size: context.r(28),
                            ),
                          ),
                          const Spacer(),
                          _LangToggleButton(),
                        ],
                      ),
                      SizedBox(height: context.r(20)),
                      Text(
                        l10n.signinWelcomeBack,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.r(28),
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: context.r(6)),
                      Text(
                        l10n.signinSubtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: context.r(14),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.r(24),
                    context.r(32),
                    context.r(24),
                    context.r(24),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppInput(
                          hint: l10n.emailHint,
                          label: l10n.email,
                          controller: _userCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            size: context.r(20),
                            color: AppColors.inactive,
                          ),
                        ),
                        SizedBox(height: context.r(16)),
                        AppInput(
                          hint: l10n.passwordHint,
                          label: l10n.password,
                          controller: _passCtrl,
                          isPassword: true,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            size: context.r(20),
                            color: AppColors.inactive,
                          ),
                        ),
                        SizedBox(height: context.r(8)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(l10n.forgotPassword),
                          ),
                        ),
                        SizedBox(height: context.r(8)),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) => PrimaryButton(
                            title: l10n.signIn,
                            isLoading: state.status == AuthStatus.loading,
                            onPressed: _submit,
                          ),
                        ),
                        SizedBox(height: context.r(32)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.noAccount,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/auth/sign-up'),
                              child: Text(l10n.signUp),
                            ),
                          ],
                        ),
                        SizedBox(height: context.r(16)),
                        Center(
                          child: Text(
                            l10n.appVersion,
                            style: TextStyle(
                              fontSize: context.r(12),
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final isVi = locale.languageCode == 'vi';
        return GestureDetector(
          onTap: () => context.read<LocaleCubit>().toggle(),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.r(10),
              vertical: context.r(6),
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
                  style: TextStyle(fontSize: context.r(14)),
                ),
                SizedBox(width: context.r(4)),
                Text(
                  isVi ? 'VI' : 'EN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.r(12),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
