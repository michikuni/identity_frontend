import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show Either, left, right;
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:identity_frontend/presentation/widgets/app_input.dart';
import 'package:identity_frontend/presentation/widgets/primary_button.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(signInUseCase: sl(), signUpUseCase: sl()),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _phoneRegex = RegExp(r'^\+?[0-9]+$');

  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_updateFormValidity);
    _phoneCtrl.addListener(_updateFormValidity);
    _passCtrl.addListener(_updateFormValidity);
    _confirmCtrl.addListener(_updateFormValidity);
  }

  @override
  void dispose() {
    _emailCtrl.removeListener(_updateFormValidity);
    _phoneCtrl.removeListener(_updateFormValidity);
    _passCtrl.removeListener(_updateFormValidity);
    _confirmCtrl.removeListener(_updateFormValidity);
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _validateEmailValue(_emailCtrl.text).match((_) => false, (_) => true) &&
      _validatePhoneValue(_phoneCtrl.text).match((_) => false, (_) => true) &&
      _validatePasswordValue(_passCtrl.text).match((_) => false, (_) => true) &&
      _validateConfirmPasswordValue(
        _confirmCtrl.text,
      ).match((_) => false, (_) => true);

  void _updateFormValidity() {
    final nextIsValid = _canSubmit;
    if (nextIsValid == _isFormValid) return;
    setState(() => _isFormValid = nextIsValid);
  }

  String _message({required String vi, required String en}) {
    return Localizations.localeOf(context).languageCode == 'vi' ? vi : en;
  }

  Either<String, String> _validateEmailValue(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return left(
        _message(vi: 'Vui lòng nhập email', en: 'Please enter your email'),
      );
    }
    if (!_emailRegex.hasMatch(email)) {
      return left(
        _message(vi: 'Email không hợp lệ', en: 'Invalid email address'),
      );
    }
    return right(email);
  }

  String? _validateEmail(String? value) {
    return _validateEmailValue(value).match((error) => error, (_) => null);
  }

  Either<String, String> _validatePhoneValue(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return left(
        _message(
          vi: 'Vui lòng nhập số điện thoại',
          en: 'Please enter your phone number',
        ),
      );
    }
    if (phone.length < 6) {
      return left(
        _message(
          vi: 'Số điện thoại phải từ 6 ký tự trở lên',
          en: 'Phone number must be at least 6 characters',
        ),
      );
    }
    if (!_phoneRegex.hasMatch(phone)) {
      return left(
        _message(vi: 'Số điện thoại không hợp lệ', en: 'Invalid phone number'),
      );
    }
    return right(phone);
  }

  String? _validatePhone(String? value) {
    return _validatePhoneValue(value).match((error) => error, (_) => null);
  }

  Either<String, String> _validatePasswordValue(String? value) {
    if ((value ?? '').isEmpty) {
      return left(
        _message(
          vi: 'Vui lòng nhập mật khẩu',
          en: 'Please enter your password',
        ),
      );
    }
    if ((value ?? '').length < 6) {
      return left(
        _message(
          vi: 'Mật khẩu phải từ 6 ký tự trở lên',
          en: 'Password must be at least 6 characters',
        ),
      );
    }
    return right(value!);
  }

  String? _validatePassword(String? value) {
    return _validatePasswordValue(value).match((error) => error, (_) => null);
  }

  Either<String, String> _validateConfirmPasswordValue(String? value) {
    if ((value ?? '').isEmpty) {
      return left(
        _message(
          vi: 'Vui lòng xác nhận mật khẩu',
          en: 'Please confirm your password',
        ),
      );
    }
    if (value != _passCtrl.text) {
      return left(
        _message(
          vi: 'Xác nhận mật khẩu không khớp',
          en: 'Passwords do not match',
        ),
      );
    }
    return right(value!);
  }

  String? _validateConfirmPassword(String? value) {
    return _validateConfirmPasswordValue(
      value,
    ).match((error) => error, (_) => null);
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
      SignUpSubmitted(
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        password: _passCtrl.text,
      ),
    );
  }

  void _goBackToSignIn() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/auth/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.signedUp) {
          context.go('/auth/onboarding');
        } else if (state.status == AuthStatus.failure) {
          final errorMsg = state.errorMessage;
          final String msg;
          if (errorMsg == 'SERVER_ERROR') {
            msg = l10n.authSignUpServerError;
          } else if (errorMsg == null || errorMsg == 'SIGN_UP_FAILED') {
            msg = l10n.authSignUpFailed;
          } else {
            msg = errorMsg;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: _goBackToSignIn,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_add_outlined,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.signupGetStarted,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.signupSubtitle,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  // ── Fields ──────────────────────────────────────────
                  AppInput(
                    hint: l10n.emailHint,
                    label: l10n.email,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    prefixIcon: const Icon(
                      Icons.mail_outline_rounded,
                      size: 20,
                      color: AppColors.inactive,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    hint: l10n.phoneHint,
                    label: l10n.phone,
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      size: 20,
                      color: AppColors.inactive,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    hint: l10n.passwordHint,
                    label: l10n.password,
                    controller: _passCtrl,
                    isPassword: true,
                    validator: _validatePassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      size: 20,
                      color: AppColors.inactive,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    hint: l10n.confirmPasswordHint,
                    label: l10n.confirmPassword,
                    controller: _confirmCtrl,
                    isPassword: true,
                    validator: _validateConfirmPassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      size: 20,
                      color: AppColors.inactive,
                    ),
                  ),
                  const SizedBox(height: 28),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => PrimaryButton(
                      title: l10n.signUp,
                      isLoading: state.status == AuthStatus.loading,
                      onPressed: _isFormValid ? _submit : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.hasAccount,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: _goBackToSignIn,
                        child: Text(l10n.signIn),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
