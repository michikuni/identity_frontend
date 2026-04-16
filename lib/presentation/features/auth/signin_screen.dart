import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:identity_frontend/presentation/widgets/app_input.dart';
import 'package:identity_frontend/presentation/widgets/primary_button.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        signInUseCase: sl(),
        signUpUseCase: sl(),
      ),
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
    context.read<AuthBloc>().add(SignInSubmitted(
          username: _userCtrl.text.trim(),
          password: _passCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.success) {
          context.go('/app/home');
        } else if (state.status == AuthStatus.failure) {
          final msg = state.errorMessage ?? '';
          final isPending = msg.contains('pending approval');
          final isRejected = msg.contains('rejected');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isPending
                    ? 'Tài khoản đang chờ Admin duyệt. Vui lòng thử lại sau.'
                    : isRejected
                        ? 'Tài khoản đã bị từ chối. Vui lòng liên hệ Admin.'
                        : 'Đăng nhập thất bại. Kiểm tra lại thông tin.',
              ),
              backgroundColor: isPending ? AppColors.warning : AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                // ── Header gradient banner ──────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(28, 48, 28, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.signinWelcomeBack,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.signinSubtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Form ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
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
                          prefixIcon: const Icon(Icons.mail_outline_rounded,
                              size: 20, color: AppColors.inactive),
                        ),
                        const SizedBox(height: 16),
                        AppInput(
                          hint: l10n.passwordHint,
                          label: l10n.password,
                          controller: _passCtrl,
                          isPassword: true,
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              size: 20, color: AppColors.inactive),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(l10n.forgotPassword),
                          ),
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) => PrimaryButton(
                            title: l10n.signIn,
                            isLoading: state.status == AuthStatus.loading,
                            onPressed: _submit,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.noAccount,
                                style: const TextStyle(
                                    color: AppColors.textSecondary)),
                            TextButton(
                              onPressed: () =>
                                  context.go('/auth/sign-up'),
                              child: Text(l10n.signUp),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            l10n.appVersion,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textHint),
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
