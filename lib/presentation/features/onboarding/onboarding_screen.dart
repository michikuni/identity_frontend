import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/wallet/wallet_service.dart';
import 'package:identity_frontend/presentation/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:identity_frontend/presentation/widgets/app_input.dart';
import 'package:identity_frontend/presentation/widgets/primary_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(employeeUseCase: sl()),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _formKey = GlobalKey<FormState>();
  final _departmentCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _workingType = 'FULL_TIME';

  static const _workingTypes = ['FULL_TIME', 'PART_TIME'];

  @override
  void dispose() {
    _departmentCtrl.dispose();
    _positionCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    // Sinh keypair P-256 khi onboarding — idempotent nếu đã có
    final publicKeyJwk = await WalletService.generateAndSave();
    final email = await SecureStorage.getUserEmail() ?? '';
    if (!mounted) return;
    context.read<OnboardingBloc>().add(OnboardingSubmitted(
          department: _departmentCtrl.text.trim(),
          position: _positionCtrl.text.trim(),
          workingType: _workingType,
          createdBy: email,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          publicKeyJwk: publicKeyJwk,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.status == OnboardingStatus.success) {
          context.go('/auth/onboarding/profile');
        } else if (state.status == OnboardingStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage ?? 'Có lỗi xảy ra, vui lòng thử lại'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.work_outline_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Thiết lập hồ sơ công việc',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Điền thông tin để hoàn tất đăng ký tài khoản',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 36),

                  // ── Step indicator ────────────────────────────────────
                  _StepIndicator(current: 1, total: 2),
                  const SizedBox(height: 28),

                  // ── Fields ────────────────────────────────────────────
                  AppInput(
                    label: 'Phòng ban',
                    hint: 'VD: Phòng Kỹ thuật',
                    controller: _departmentCtrl,
                    prefixIcon: const Icon(Icons.business_outlined,
                        size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Chức vụ',
                    hint: 'VD: Kỹ sư phần mềm',
                    controller: _positionCtrl,
                    prefixIcon: const Icon(Icons.badge_outlined,
                        size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 16),

                  // ── Working type dropdown ─────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Loại hình làm việc',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _workingType,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.schedule_outlined,
                              size: 20, color: AppColors.inactive),
                        ),
                        items: _workingTypes
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(
                                    t == 'FULL_TIME' ? 'Toàn thời gian' : 'Bán thời gian',
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _workingType = v ?? 'FULL_TIME'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Ghi chú (tuỳ chọn)',
                    hint: 'Thông tin bổ sung...',
                    controller: _noteCtrl,
                    maxLines: 3,
                    prefixIcon: const Icon(Icons.notes_outlined,
                        size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 32),

                  // ── Submit ────────────────────────────────────────────
                  BlocBuilder<OnboardingBloc, OnboardingState>(
                    builder: (context, state) => PrimaryButton(
                      title: 'Hoàn tất đăng ký',
                      isLoading: state.status == OnboardingStatus.loading,
                      onPressed: _submit,
                      icon: Icons.check_circle_outline_rounded,
                    ),
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

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 1; i <= total; i++) ...[
          _StepDot(index: i, current: current),
          if (i < total)
            Expanded(
              child: Container(
                height: 2,
                color: i < current ? AppColors.primary : AppColors.border,
              ),
            ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final int current;
  const _StepDot({required this.index, required this.current});

  @override
  Widget build(BuildContext context) {
    final isDone = index < current;
    final isActive = index == current;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isDone || isActive) ? AppColors.primary : AppColors.border,
      ),
      child: Center(
        child: isDone
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : Text(
                '$index',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}
