import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/presentation/features/profile/bloc/profile_bloc.dart';
import 'package:identity_frontend/presentation/widgets/app_input.dart';
import 'package:identity_frontend/presentation/widgets/primary_button.dart';

class ProfileOnboardingScreen extends StatelessWidget {
  const ProfileOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(profileUseCase: sl()),
      child: const _ProfileOnboardingView(),
    );
  }
}

class _ProfileOnboardingView extends StatefulWidget {
  const _ProfileOnboardingView();

  @override
  State<_ProfileOnboardingView> createState() => _ProfileOnboardingViewState();
}

class _ProfileOnboardingViewState extends State<_ProfileOnboardingView> {
  final _formKey = GlobalKey<FormState>();

  // Personal
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String _gender = 'MALE';

  // Identity
  String _identityType = 'CCCD';
  final _identityNumberCtrl = TextEditingController();
  final _identityIssueDateCtrl = TextEditingController();
  final _identityIssuePlaceCtrl = TextEditingController();

  // Emergency
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _emergencyRelCtrl = TextEditingController();

  // Residence & Health
  final _permanentResCtrl = TextEditingController();
  final _nowResCtrl = TextEditingController();
  final _healthCtrl = TextEditingController();
  String _married = 'SINGLE';

  // Education
  final _educationCtrl = TextEditingController();
  final _majorCtrl = TextEditingController();
  final _expYearsCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _certCtrl = TextEditingController();

  // Pre-filled
  String _email = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final email = await SecureStorage.getUserEmail() ?? '';
    final phone = await SecureStorage.getUserPhone() ?? '';
    if (mounted) setState(() { _email = email; _phone = phone; });
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _dobCtrl, _identityNumberCtrl, _identityIssueDateCtrl,
      _identityIssuePlaceCtrl, _emergencyNameCtrl, _emergencyPhoneCtrl,
      _emergencyRelCtrl, _permanentResCtrl, _nowResCtrl, _healthCtrl,
      _educationCtrl, _majorCtrl, _expYearsCtrl, _skillsCtrl, _certCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final skills = _skillsCtrl.text.trim().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final certs = _certCtrl.text.trim().isEmpty
        ? null
        : _certCtrl.text.trim().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    context.read<ProfileBloc>().add(ProfileCreate({
      'name': _nameCtrl.text.trim(),
      'gender': _gender,
      'dateOfBirth': _dobCtrl.text.trim(),
      'identityType': _identityType,
      'identityNumber': _identityNumberCtrl.text.trim(),
      'identityIssueDate': int.tryParse(_identityIssueDateCtrl.text.trim()) ?? 0,
      'identityIssuePlace': _identityIssuePlaceCtrl.text.trim(),
      'email': _email,
      'phone': _phone,
      'emergencyName': _emergencyNameCtrl.text.trim(),
      'emergencyPhone': _emergencyPhoneCtrl.text.trim(),
      'emergencyRelationship': _emergencyRelCtrl.text.trim(),
      'permanentResidence': _permanentResCtrl.text.trim(),
      'nowResidence': _nowResCtrl.text.trim(),
      'health': _healthCtrl.text.trim(),
      'married': _married,
      'educationLevel': _educationCtrl.text.trim(),
      'major': _majorCtrl.text.trim(),
      'expYears': int.tryParse(_expYearsCtrl.text.trim()) ?? 0,
      'skillSet': skills,
      'certificate': certs,
    }));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.success) {
          context.go('/app/home');
        } else if (state.status == ProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage ?? 'Có lỗi xảy ra'),
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ───────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text('Thông tin cá nhân', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  const Text('Hoàn tất hồ sơ để quản trị viên duyệt tài khoản',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  _StepIndicator(current: 2, total: 2),
                  const SizedBox(height: 28),

                  // ── Personal ─────────────────────────────────────────
                  _sectionHeader('Thông tin cá nhân', Icons.person_outline_rounded),
                  AppInput(
                    label: 'Họ và tên *',
                    hint: 'Nguyễn Văn A',
                    controller: _nameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 12),
                  _dropdown('Giới tính *', _gender, ['MALE', 'FEMALE', 'OTHER'],
                      _genderLabel, (v) => setState(() => _gender = v!)),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Ngày sinh *',
                    hint: 'VD: 1999-12-31',
                    controller: _dobCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập ngày sinh' : null,
                    prefixIcon: const Icon(Icons.cake_outlined, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 24),

                  // ── Identity ─────────────────────────────────────────
                  _sectionHeader('Giấy tờ tùy thân', Icons.badge_outlined),
                  _dropdown('Loại giấy tờ *', _identityType, ['CCCD', 'CMND', 'PASSPORT'],
                      (v) => v, (v) => setState(() => _identityType = v!)),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Số giấy tờ *',
                    hint: '0123456789',
                    controller: _identityNumberCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập số giấy tờ' : null,
                    prefixIcon: const Icon(Icons.numbers_rounded, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Năm cấp *',
                    hint: 'VD: 2020',
                    controller: _identityIssueDateCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập năm cấp' : null,
                    prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Nơi cấp *',
                    hint: 'VD: Cục CSQLHC về TTXH',
                    controller: _identityIssuePlaceCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập nơi cấp' : null,
                    prefixIcon: const Icon(Icons.location_city_outlined, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 24),

                  // ── Emergency ────────────────────────────────────────
                  _sectionHeader('Liên hệ khẩn cấp', Icons.emergency_outlined),
                  AppInput(
                    label: 'Họ tên *',
                    hint: 'Nguyễn Thị B',
                    controller: _emergencyNameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
                    prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Số điện thoại *',
                    hint: '0987654321',
                    controller: _emergencyPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập số điện thoại' : null,
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Mối quan hệ *',
                    hint: 'VD: Cha/Mẹ, Vợ/Chồng',
                    controller: _emergencyRelCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập mối quan hệ' : null,
                    prefixIcon: const Icon(Icons.group_outlined, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 24),

                  // ── Residence & Health ────────────────────────────────
                  _sectionHeader('Cư trú & Sức khỏe', Icons.home_outlined),
                  AppInput(
                    label: 'Địa chỉ thường trú *',
                    hint: 'Số nhà, đường, phường/xã, quận/huyện, tỉnh/TP',
                    controller: _permanentResCtrl,
                    maxLines: 2,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập địa chỉ thường trú' : null,
                    prefixIcon: const Icon(Icons.home_outlined, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Địa chỉ hiện tại *',
                    hint: 'Số nhà, đường, phường/xã, quận/huyện, tỉnh/TP',
                    controller: _nowResCtrl,
                    maxLines: 2,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập địa chỉ hiện tại' : null,
                    prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Tình trạng sức khỏe *',
                    hint: 'VD: Tốt, Bình thường',
                    controller: _healthCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tình trạng sức khỏe' : null,
                    prefixIcon: const Icon(Icons.favorite_outline_rounded, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 12),
                  _dropdown('Tình trạng hôn nhân *', _married, ['SINGLE', 'MARRIED', 'DIVORCED'],
                      _marriedLabel, (v) => setState(() => _married = v!)),
                  const SizedBox(height: 24),

                  // ── Education ────────────────────────────────────────
                  _sectionHeader('Học vấn & Kỹ năng', Icons.school_outlined),
                  AppInput(
                    label: 'Trình độ học vấn *',
                    hint: 'VD: Đại học, Cao đẳng',
                    controller: _educationCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập trình độ học vấn' : null,
                    prefixIcon: const Icon(Icons.school_outlined, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Chuyên ngành *',
                    hint: 'VD: Công nghệ thông tin',
                    controller: _majorCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập chuyên ngành' : null,
                    prefixIcon: const Icon(Icons.book_outlined, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Số năm kinh nghiệm *',
                    hint: 'VD: 3',
                    controller: _expYearsCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập số năm kinh nghiệm' : null,
                    prefixIcon: const Icon(Icons.work_history_outlined, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Kỹ năng *',
                    hint: 'VD: Flutter, Kotlin, Spring Boot (cách nhau bởi dấu phẩy)',
                    controller: _skillsCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập ít nhất 1 kỹ năng' : null,
                    prefixIcon: const Icon(Icons.psychology_outlined, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Chứng chỉ (tùy chọn)',
                    hint: 'VD: AWS, PMP (cách nhau bởi dấu phẩy)',
                    controller: _certCtrl,
                    prefixIcon: const Icon(Icons.card_membership_outlined, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 32),

                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) => PrimaryButton(
                      title: 'Hoàn tất đăng ký',
                      isLoading: state.status == ProfileStatus.loading,
                      onPressed: _submit,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/app/home'),
                    child: const Text('Bỏ qua, hoàn thành sau',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ]),
      );

  Widget _dropdown(String label, String value, List<String> items, String Function(String) labelFn,
          ValueChanged<String?> onChanged) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: const InputDecoration(),
          items: items.map((v) => DropdownMenuItem(value: v, child: Text(labelFn(v)))).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 0),
      ]);

  String _genderLabel(String v) => switch (v) {
        'MALE' => 'Nam',
        'FEMALE' => 'Nữ',
        _ => 'Khác',
      };

  String _marriedLabel(String v) => switch (v) {
        'MARRIED' => 'Đã kết hôn',
        'DIVORCED' => 'Đã ly hôn',
        _ => 'Độc thân',
      };
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
              child: Container(height: 2, color: i < current ? AppColors.primary : AppColors.border),
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
            : Text('$index',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                )),
      ),
    );
  }
}
