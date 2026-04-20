import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
import 'package:identity_frontend/domain/entities/profile_entity.dart';
import 'package:identity_frontend/domain/usecases/employee_usecase.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/features/profile/bloc/profile_bloc.dart';
import 'package:identity_frontend/presentation/widgets/app_card.dart';
import 'package:identity_frontend/presentation/widgets/app_input.dart';
import 'package:identity_frontend/presentation/widgets/info_row.dart';
import 'package:identity_frontend/presentation/widgets/status_badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(profileUseCase: sl())..add(const ProfileFetch()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const LoadingWidget(message: 'Loading profile...');
          }
          if (state.status == ProfileStatus.failure || state.profile == null) {
            return _NoProfileView(
              onCreated: () => context.read<ProfileBloc>().add(const ProfileFetch()),
            );
          }
          return _buildContent(context, l10n, state.profile!);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, ProfileEntity p) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.r(16)),
      child: Column(
        children: [
          GradientCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: context.r(30),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                    style: TextStyle(
                        fontSize: context.r(24),
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
                SizedBox(width: context.r(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: context.r(18),
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: context.r(4)),
                      Text(p.email,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: context.r(13))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.r(16)),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionHeader(title: l10n.profilePersonalInfo, icon: Icons.person_outline_rounded),
              InfoRow(label: l10n.profileName, value: p.name),
              InfoRow(label: l10n.profileGender, value: _genderLabel(p.gender, l10n)),
              InfoRow(label: l10n.profileDOB, value: p.dateOfBirth ?? '—'),
              InfoRow(label: l10n.profilePhone, value: p.phone),
              InfoRow(label: l10n.profileEmail, value: p.email, showDivider: false),
            ]),
          ),
          SizedBox(height: context.r(12)),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionHeader(title: l10n.profileIdentity, icon: Icons.badge_outlined),
              InfoRow(label: l10n.profileIdentityType, value: p.identityType),
              InfoRow(label: l10n.profileIdentityNumber, value: p.identityNumber),
              if (p.identityIssuePlace != null)
                InfoRow(
                    label: l10n.profileIdentityIssuePlace,
                    value: p.identityIssuePlace!,
                    showDivider: false),
            ]),
          ),
          SizedBox(height: context.r(12)),
          if (p.emergencyName != null || p.emergencyPhone != null) ...[
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SectionHeader(title: l10n.profileEmergency, icon: Icons.emergency_outlined),
                if (p.emergencyName != null)
                  InfoRow(label: l10n.profileEmergencyName, value: p.emergencyName!),
                if (p.emergencyPhone != null)
                  InfoRow(label: l10n.profileEmergencyPhone, value: p.emergencyPhone!),
                if (p.emergencyRelationship != null)
                  InfoRow(
                      label: l10n.profileEmergencyRelationship,
                      value: p.emergencyRelationship!,
                      showDivider: false),
              ]),
            ),
            SizedBox(height: context.r(12)),
          ],
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionHeader(title: l10n.profileResidence, icon: Icons.home_outlined),
              if (p.permanentResidence != null)
                InfoRow(label: l10n.profilePermanentResidence, value: p.permanentResidence!),
              InfoRow(
                  label: l10n.profileNowResidence,
                  value: p.nowResidence ?? '—',
                  showDivider: false),
            ]),
          ),
          SizedBox(height: context.r(12)),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionHeader(title: l10n.profileEducation, icon: Icons.school_outlined),
              if (p.educationLevel != null)
                InfoRow(label: l10n.profileEducationLevel, value: p.educationLevel!),
              if (p.major != null) InfoRow(label: l10n.profileMajor, value: p.major!),
              if (p.expYears != null) InfoRow(label: l10n.profileExpYears, value: '${p.expYears}'),
              if (p.skillSet != null && p.skillSet!.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.only(top: context.r(10)),
                  child: Text(l10n.profileSkills,
                      style: TextStyle(
                          fontSize: context.r(13), color: AppColors.textSecondary)),
                ),
                SizedBox(height: context.r(8)),
                Wrap(
                  spacing: context.r(8),
                  runSpacing: context.r(8),
                  children: p.skillSet!.map((s) => Chip(label: Text(s))).toList(),
                ),
              ],
            ]),
          ),
          SizedBox(height: context.r(24)),
        ],
      ),
    );
  }

  String _genderLabel(String gender, AppLocalizations l10n) {
    return switch (gender.toUpperCase()) {
      'MALE' => l10n.statusMale,
      'FEMALE' => l10n.statusFemale,
      _ => gender,
    };
  }
}

// ── No Profile State ─────────────────────────────────────────────────────────

class _NoProfileView extends StatelessWidget {
  final VoidCallback onCreated;
  const _NoProfileView({required this.onCreated});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.r(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(context.r(20)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_add_outlined,
                  size: context.r(48), color: AppColors.primary),
            ),
            SizedBox(height: context.r(20)),
            Text('Chưa có hồ sơ',
                style: TextStyle(
                    fontSize: context.r(18), fontWeight: FontWeight.w700)),
            SizedBox(height: context.r(8)),
            Text(
              'Thiết lập hồ sơ để sử dụng đầy đủ tính năng',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: context.r(14)),
            ),
            SizedBox(height: context.r(28)),
            ElevatedButton.icon(
              icon: Icon(Icons.edit_outlined, size: context.r(18)),
              label: const Text('Thiết lập hồ sơ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: context.r(28), vertical: context.r(14)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.r(12))),
              ),
              onPressed: () => _showSetupSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSetupSheet(BuildContext context) async {
    final profileBloc = context.read<ProfileBloc>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: profileBloc,
        child: _ProfileSetupSheet(onCreated: onCreated),
      ),
    );
  }
}

// ── Profile Setup Bottom Sheet ────────────────────────────────────────────────

class _ProfileSetupSheet extends StatefulWidget {
  final VoidCallback onCreated;
  const _ProfileSetupSheet({required this.onCreated});

  @override
  State<_ProfileSetupSheet> createState() => _ProfileSetupSheetState();
}

class _ProfileSetupSheetState extends State<_ProfileSetupSheet> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;
  bool _submittingWork = false;

  final _deptCtrl = TextEditingController();
  final _posCtrl = TextEditingController();
  String _workingType = 'FULL_TIME';

  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String _gender = 'MALE';
  String _identityType = 'CCCD';
  final _idNumCtrl = TextEditingController();
  final _idYearCtrl = TextEditingController();
  final _idPlaceCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _emergencyRelCtrl = TextEditingController();
  final _permResCtrl = TextEditingController();
  final _nowResCtrl = TextEditingController();
  final _healthCtrl = TextEditingController();
  String _married = 'SINGLE';
  final _eduCtrl = TextEditingController();
  final _majorCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();

  String _email = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    final email = await SecureStorage.getUserEmail() ?? '';
    final phone = await SecureStorage.getUserPhone() ?? '';
    if (mounted) {
      setState(() { _email = email; _phone = phone; });
    }
  }

  @override
  void dispose() {
    for (final c in [
      _deptCtrl, _posCtrl, _nameCtrl, _dobCtrl, _idNumCtrl, _idYearCtrl,
      _idPlaceCtrl, _emergencyNameCtrl, _emergencyPhoneCtrl, _emergencyRelCtrl,
      _permResCtrl, _nowResCtrl, _healthCtrl, _eduCtrl, _majorCtrl, _expCtrl, _skillsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submitWork() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _submittingWork = true);
    try {
      final email = await SecureStorage.getUserEmail() ?? '';
      await sl<EmployeeUseCase>().createEmployee({
        'department': _deptCtrl.text.trim(),
        'position': _posCtrl.text.trim(),
        'status': 'ACTIVE',
        'workingType': _workingType,
        'isActive': true,
        'createdBy': email,
      });
      if (mounted) setState(() { _step = 1; _submittingWork = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _submittingWork = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  void _submitProfile() {
    if (_formKey.currentState?.validate() != true) return;
    final skills = _skillsCtrl.text.trim().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    context.read<ProfileBloc>().add(ProfileCreate({
      'name': _nameCtrl.text.trim(),
      'gender': _gender,
      'dateOfBirth': _dobCtrl.text.trim(),
      'identityType': _identityType,
      'identityNumber': _idNumCtrl.text.trim(),
      'identityIssueDate': int.tryParse(_idYearCtrl.text.trim()) ?? 0,
      'identityIssuePlace': _idPlaceCtrl.text.trim(),
      'email': _email,
      'phone': _phone,
      'emergencyName': _emergencyNameCtrl.text.trim(),
      'emergencyPhone': _emergencyPhoneCtrl.text.trim(),
      'emergencyRelationship': _emergencyRelCtrl.text.trim(),
      'permanentResidence': _permResCtrl.text.trim(),
      'nowResidence': _nowResCtrl.text.trim(),
      'health': _healthCtrl.text.trim(),
      'married': _married,
      'educationLevel': _eduCtrl.text.trim(),
      'major': _majorCtrl.text.trim(),
      'expYears': int.tryParse(_expCtrl.text.trim()) ?? 0,
      'skillSet': skills,
    }));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.success) {
          Navigator.pop(context);
          widget.onCreated();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Hồ sơ đã được tạo thành công'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ));
        } else if (state.status == ProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage ?? 'Có lỗi xảy ra'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        maxChildSize: 0.97,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(context.r(20))),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: context.r(12), bottom: context.r(8)),
                width: context.r(40),
                height: context.r(4),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(context.r(2)),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    context.r(24), context.r(4), context.r(24), 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _step == 0
                          ? 'Bước 1/2 — Thông tin công việc'
                          : 'Bước 2/2 — Thông tin cá nhân',
                      style: TextStyle(
                          fontSize: context.r(16), fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: context.r(8)),
                    LinearProgressIndicator(
                      value: _step == 0 ? 0.5 : 1.0,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(context.r(4)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.r(8)),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.fromLTRB(
                      context.r(24), context.r(12), context.r(24), context.r(32)),
                  child: Form(
                    key: _formKey,
                    child: _step == 0 ? _buildWorkStep(context) : _buildProfileStep(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkStep(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppInput(
        label: 'Phòng ban *',
        hint: 'VD: Ban Giám đốc',
        controller: _deptCtrl,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.business_outlined,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(14)),
      AppInput(
        label: 'Chức vụ *',
        hint: 'VD: Giám đốc điều hành',
        controller: _posCtrl,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.badge_outlined,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(14)),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Loại hình làm việc',
            style: TextStyle(
                fontSize: context.r(13),
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary)),
        SizedBox(height: context.r(6)),
        DropdownButtonFormField<String>(
          initialValue: _workingType,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.schedule_outlined,
                size: context.r(20), color: AppColors.inactive),
          ),
          items: const [
            DropdownMenuItem(value: 'FULL_TIME', child: Text('Toàn thời gian')),
            DropdownMenuItem(value: 'PART_TIME', child: Text('Bán thời gian')),
          ],
          onChanged: (v) => setState(() => _workingType = v ?? 'FULL_TIME'),
        ),
      ]),
      SizedBox(height: context.r(28)),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: context.r(14)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.r(12))),
        ),
        onPressed: _submittingWork ? null : _submitWork,
        child: _submittingWork
            ? SizedBox(
                width: context.r(20),
                height: context.r(20),
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text('Tiếp theo',
                style: TextStyle(
                    fontSize: context.r(15), fontWeight: FontWeight.w600)),
      ),
    ]);
  }

  Widget _buildProfileStep(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _section(context, 'Thông tin cá nhân', Icons.person_outline_rounded),
      AppInput(
        label: 'Họ và tên *',
        hint: 'Nguyễn Văn A',
        controller: _nameCtrl,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.badge_outlined,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(12)),
      _dropdownField(context, 'Giới tính', _gender, ['MALE', 'FEMALE', 'OTHER'],
          (v) => switch (v) { 'MALE' => 'Nam', 'FEMALE' => 'Nữ', _ => 'Khác' },
          (v) => setState(() => _gender = v!)),
      SizedBox(height: context.r(12)),
      AppInput(
        label: 'Ngày sinh *',
        hint: 'VD: 1990-01-01',
        controller: _dobCtrl,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.cake_outlined,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(20)),
      _section(context, 'Giấy tờ tùy thân', Icons.badge_outlined),
      _dropdownField(context, 'Loại giấy tờ', _identityType,
          ['CCCD', 'CMND', 'PASSPORT'], (v) => v,
          (v) => setState(() => _identityType = v!)),
      SizedBox(height: context.r(12)),
      AppInput(
        label: 'Số giấy tờ *',
        hint: '0123456789',
        controller: _idNumCtrl,
        keyboardType: TextInputType.number,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.numbers_rounded,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(12)),
      AppInput(
        label: 'Năm cấp *',
        hint: '2020',
        controller: _idYearCtrl,
        keyboardType: TextInputType.number,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.calendar_today_outlined,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(12)),
      AppInput(
        label: 'Nơi cấp *',
        hint: 'Cục CSQLHC về TTXH',
        controller: _idPlaceCtrl,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.location_city_outlined,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(20)),
      _section(context, 'Liên hệ khẩn cấp', Icons.emergency_outlined),
      AppInput(
        label: 'Họ tên *',
        hint: 'Nguyễn Thị B',
        controller: _emergencyNameCtrl,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.person_outline_rounded,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(12)),
      AppInput(
        label: 'Số điện thoại *',
        hint: '0987654321',
        controller: _emergencyPhoneCtrl,
        keyboardType: TextInputType.phone,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.phone_outlined,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(12)),
      AppInput(
        label: 'Mối quan hệ *',
        hint: 'Cha/Mẹ, Vợ/Chồng',
        controller: _emergencyRelCtrl,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.group_outlined,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(20)),
      _section(context, 'Cư trú & Sức khỏe', Icons.home_outlined),
      AppInput(
        label: 'Địa chỉ thường trú *',
        hint: 'Số nhà, đường, phường, quận, tỉnh',
        controller: _permResCtrl,
        maxLines: 2,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.home_outlined,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(12)),
      AppInput(
        label: 'Địa chỉ hiện tại *',
        hint: 'Số nhà, đường, phường, quận, tỉnh',
        controller: _nowResCtrl,
        maxLines: 2,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.location_on_outlined,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(12)),
      AppInput(
        label: 'Tình trạng sức khỏe *',
        hint: 'VD: Tốt',
        controller: _healthCtrl,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.favorite_outline_rounded,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(12)),
      _dropdownField(context, 'Tình trạng hôn nhân', _married,
          ['SINGLE', 'MARRIED', 'DIVORCED'],
          (v) => switch (v) {
                'MARRIED' => 'Đã kết hôn',
                'DIVORCED' => 'Đã ly hôn',
                _ => 'Độc thân'
              },
          (v) => setState(() => _married = v!)),
      SizedBox(height: context.r(20)),
      _section(context, 'Học vấn & Kỹ năng', Icons.school_outlined),
      AppInput(
        label: 'Trình độ học vấn *',
        hint: 'Đại học',
        controller: _eduCtrl,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.school_outlined,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(12)),
      AppInput(
        label: 'Chuyên ngành *',
        hint: 'Công nghệ thông tin',
        controller: _majorCtrl,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.book_outlined,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(12)),
      AppInput(
        label: 'Số năm kinh nghiệm *',
        hint: '5',
        controller: _expCtrl,
        keyboardType: TextInputType.number,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.work_history_outlined,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(12)),
      AppInput(
        label: 'Kỹ năng *',
        hint: 'Flutter, Kotlin (cách nhau bởi dấu phẩy)',
        controller: _skillsCtrl,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        prefixIcon: Icon(Icons.psychology_outlined,
            size: context.r(20), color: AppColors.inactive),
      ),
      SizedBox(height: context.r(28)),
      BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: context.r(14)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.r(12))),
          ),
          onPressed: state.status == ProfileStatus.loading ? null : _submitProfile,
          child: state.status == ProfileStatus.loading
              ? SizedBox(
                  width: context.r(20),
                  height: context.r(20),
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text('Lưu hồ sơ',
                  style: TextStyle(
                      fontSize: context.r(15), fontWeight: FontWeight.w600)),
        ),
      ),
    ]);
  }

  Widget _section(BuildContext context, String title, IconData icon) => Padding(
        padding: EdgeInsets.only(bottom: context.r(12)),
        child: Row(children: [
          Icon(icon, size: context.r(16), color: AppColors.primary),
          SizedBox(width: context.r(6)),
          Text(title,
              style: TextStyle(
                  fontSize: context.r(13),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ]),
      );

  Widget _dropdownField(
    BuildContext context,
    String label,
    String value,
    List<String> items,
    String Function(String) labelFn,
    ValueChanged<String?> onChange,
  ) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                fontSize: context.r(13),
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary)),
        SizedBox(height: context.r(6)),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: const InputDecoration(),
          items: items
              .map((v) => DropdownMenuItem(value: v, child: Text(labelFn(v))))
              .toList(),
          onChanged: onChange,
        ),
      ]);
}
