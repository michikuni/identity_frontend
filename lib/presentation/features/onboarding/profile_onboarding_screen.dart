import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/presentation/features/cccd/cccd_scan_screen.dart';
import 'package:identity_frontend/presentation/features/profile/bloc/profile_bloc.dart';
import 'package:identity_frontend/presentation/widgets/app_input.dart';
import 'package:identity_frontend/presentation/widgets/primary_button.dart';

// ── Province API models ────────────────────────────────────────────────────────

class _Province {
  final String code;
  final String name;
  _Province({required this.code, required this.name});
  factory _Province.fromJson(Map<String, dynamic> j) =>
      _Province(code: j['code'].toString(), name: j['name'] as String);
}

class _District {
  final String code;
  final String name;
  _District({required this.code, required this.name});
  factory _District.fromJson(Map<String, dynamic> j) =>
      _District(code: j['code'].toString(), name: j['name'] as String);
}

class _Ward {
  final String code;
  final String name;
  _Ward({required this.code, required this.name});
  factory _Ward.fromJson(Map<String, dynamic> j) =>
      _Ward(code: j['code'].toString(), name: j['name'] as String);
}

// ── Address picker widget ──────────────────────────────────────────────────────

class _AddressPicker extends StatefulWidget {
  final String label;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String> onChanged;

  const _AddressPicker({
    required this.label,
    required this.onChanged,
    this.validator,
  });

  @override
  State<_AddressPicker> createState() => _AddressPickerState();
}

class _AddressPickerState extends State<_AddressPicker> {
  List<_Province> _provinces = [];
  List<_District> _districts = [];
  List<_Ward> _wards = [];

  _Province? _selectedProvince;
  _District? _selectedDistrict;
  _Ward? _selectedWard;

  bool _loadingProvinces = false;
  bool _loadingDistricts = false;
  bool _loadingWards = false;

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  String get _fullAddress {
    final parts = [
      if (_selectedWard != null) _selectedWard!.name,
      if (_selectedDistrict != null) _selectedDistrict!.name,
      if (_selectedProvince != null) _selectedProvince!.name,
    ];
    return parts.join(', ');
  }

  final _dio = Dio();

  Future<void> _fetchProvinces() async {
    setState(() => _loadingProvinces = true);
    try {
      final res = await _dio.get<List<dynamic>>('https://provinces.open-api.vn/api/p/');
      if (res.statusCode == 200 && res.data != null) {
        final list = res.data!
            .map((e) => _Province.fromJson(e as Map<String, dynamic>))
            .toList();
        if (mounted) setState(() => _provinces = list);
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingProvinces = false);
  }

  Future<void> _fetchDistricts(String provinceCode) async {
    setState(() {
      _loadingDistricts = true;
      _districts = [];
      _wards = [];
      _selectedDistrict = null;
      _selectedWard = null;
    });
    try {
      final res = await _dio.get<Map<String, dynamic>>(
          'https://provinces.open-api.vn/api/p/$provinceCode?depth=2');
      if (res.statusCode == 200 && res.data != null) {
        final list = (res.data!['districts'] as List)
            .map((e) => _District.fromJson(e as Map<String, dynamic>))
            .toList();
        if (mounted) setState(() => _districts = list);
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingDistricts = false);
  }

  Future<void> _fetchWards(String districtCode) async {
    setState(() {
      _loadingWards = true;
      _wards = [];
      _selectedWard = null;
    });
    try {
      final res = await _dio.get<Map<String, dynamic>>(
          'https://provinces.open-api.vn/api/d/$districtCode?depth=2');
      if (res.statusCode == 200 && res.data != null) {
        final list = (res.data!['wards'] as List)
            .map((e) => _Ward.fromJson(e as Map<String, dynamic>))
            .toList();
        if (mounted) setState(() => _wards = list);
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingWards = false);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.validator != null
          ? (_) => widget.validator!(_fullAddress.isEmpty ? null : _fullAddress)
          : null,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          // Province
          _buildDropdown<_Province>(
            hint: 'Tỉnh / Thành phố',
            value: _selectedProvince,
            items: _provinces,
            loading: _loadingProvinces,
            labelFn: (p) => p.name,
            hasError: field.hasError,
            onChanged: (p) {
              setState(() => _selectedProvince = p);
              if (p != null) {
                _fetchDistricts(p.code);
                widget.onChanged(_fullAddress);
              }
            },
          ),
          const SizedBox(height: 8),
          // District
          _buildDropdown<_District>(
            hint: 'Quận / Huyện',
            value: _selectedDistrict,
            items: _districts,
            loading: _loadingDistricts,
            labelFn: (d) => d.name,
            hasError: field.hasError,
            enabled: _selectedProvince != null,
            onChanged: (d) {
              setState(() => _selectedDistrict = d);
              if (d != null) {
                _fetchWards(d.code);
                widget.onChanged(_fullAddress);
              }
            },
          ),
          const SizedBox(height: 8),
          // Ward
          _buildDropdown<_Ward>(
            hint: 'Phường / Xã',
            value: _selectedWard,
            items: _wards,
            loading: _loadingWards,
            labelFn: (w) => w.name,
            hasError: field.hasError,
            enabled: _selectedDistrict != null,
            onChanged: (w) {
              setState(() => _selectedWard = w);
              widget.onChanged(_fullAddress);
              field.didChange(_fullAddress);
            },
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(field.errorText!,
                  style: const TextStyle(fontSize: 12, color: AppColors.error)),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required bool loading,
    required String Function(T) labelFn,
    required ValueChanged<T?> onChanged,
    bool enabled = true,
    bool hasError = false,
  }) {
    return IgnorePointer(
      ignoring: !enabled || loading,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: DropdownButtonFormField<T>(
          initialValue: value,
          hint: Text(hint, style: const TextStyle(color: AppColors.inactive)),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: hasError ? AppColors.error : AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: hasError ? AppColors.error : AppColors.border),
            ),
            filled: true,
            fillColor: AppColors.surface,
            suffixIcon: loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                : null,
          ),
          items: items
              .map((item) => DropdownMenuItem<T>(value: item, child: Text(labelFn(item))))
              .toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}

// ── Main screen ───────────────────────────────────────────────────────────────

class ProfileOnboardingScreen extends StatelessWidget {
  final CccdData? cccdData;
  const ProfileOnboardingScreen({super.key, this.cccdData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(profileUseCase: sl()),
      child: _ProfileOnboardingView(cccdData: cccdData),
    );
  }
}

class _ProfileOnboardingView extends StatefulWidget {
  final CccdData? cccdData;
  const _ProfileOnboardingView({this.cccdData});

  @override
  State<_ProfileOnboardingView> createState() => _ProfileOnboardingViewState();
}

class _ProfileOnboardingViewState extends State<_ProfileOnboardingView> {
  final _formKey = GlobalKey<FormState>();

  // Personal
  final _nameCtrl = TextEditingController();
  DateTime? _selectedDob;
  String _gender = 'MALE';

  // Identity
  String _identityType = 'CCCD';
  final _identityNumberCtrl = TextEditingController();
  int? _identityIssueYear;
  String _identityIssuePlace = '';

  // Emergency
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  String _emergencyRelationship = 'Bố';

  // Residence
  String _permanentAddress = '';
  String _nowAddress = '';

  // Health & Married
  String _health = 'Tốt';
  String _married = 'SINGLE';

  // Education
  String _educationLevel = 'Đại học';
  final _majorCtrl = TextEditingController();
  final _expYearsCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _certCtrl = TextEditingController();

  // Pre-filled
  String _email = '';
  String _phone = '';

  bool get _cccdFilled => widget.cccdData != null;

  static const List<String> _issuePlaceOptions = [
    'Bộ công an',
    'Công an tỉnh',
    'Cục cảnh sát quản lý hành chính về trật tự xã hội',
  ];

  static const List<String> _relationshipOptions = [
    'Bố', 'Mẹ', 'Anh', 'Chị', 'Em', 'Con', 'Cháu',
    'Ông', 'Bà', 'Chú', 'Bác', 'Thím', 'Cô', 'Cậu', 'Mợ', 'Dì',
    'Vợ', 'Chồng', 'Con dâu', 'Con rể',
  ];

  static const List<String> _healthOptions = ['Tốt', 'Bình thường', 'Yếu'];

  static const List<String> _marriedOptions = [
    'SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED', 'SEPARATED', 'ENGAGED', 'REMARRIED',
  ];

  static const List<String> _educationOptions = [
    'Mầm non', 'Tiểu học', 'Trung học cơ sở', 'Trung học phổ thông',
    'Cao đẳng', 'Đại học', 'Thạc sĩ', 'Tiến sĩ', 'Phó giáo sư', 'Giáo sư',
  ];

  @override
  void initState() {
    super.initState();
    _loadStoredData();
    _prefillCccd();
  }

  void _prefillCccd() {
    final d = widget.cccdData;
    if (d == null) return;
    _nameCtrl.text = d.name;
    _gender = d.gender;
    _identityType = 'CCCD';
    _identityNumberCtrl.text = d.cccdNumber;

    // Parse issue year from issueDate string
    final issueParts = d.issueDate.split('-');
    if (issueParts.isNotEmpty) {
      _identityIssueYear = int.tryParse(issueParts[0]);
    }

    final parts = d.dateOfBirth.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (y != null && m != null && day != null) {
        _selectedDob = DateTime(y, m, day);
      }
    }
  }

  Future<void> _loadStoredData() async {
    final email = await SecureStorage.getUserEmail() ?? '';
    final phone = await SecureStorage.getUserPhone() ?? '';
    if (mounted) setState(() { _email = email; _phone = phone; });
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _identityNumberCtrl, _emergencyNameCtrl, _emergencyPhoneCtrl,
      _majorCtrl, _expYearsCtrl, _skillsCtrl, _certCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _pickIssueYear() async {
    final now = DateTime.now();
    int tempYear = _identityIssueYear ?? now.year;

    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) => _YearPickerDialog(
        initialYear: tempYear,
        firstYear: 1990,
        lastYear: now.year,
      ),
    );
    if (picked != null) setState(() => _identityIssueYear = picked);
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
      'dateOfBirth': _selectedDob != null
          ? '${_selectedDob!.year.toString().padLeft(4, '0')}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}'
          : '',
      'identityType': _identityType,
      'identityNumber': _identityNumberCtrl.text.trim(),
      'identityIssueDate': _identityIssueYear ?? 0,
      'identityIssuePlace': _identityIssuePlace,
      'email': _email,
      'phone': _phone,
      'emergencyName': _emergencyNameCtrl.text.trim(),
      'emergencyPhone': _emergencyPhoneCtrl.text.trim(),
      'emergencyRelationship': _emergencyRelationship,
      'permanentResidence': _permanentAddress,
      'nowResidence': _nowAddress,
      'health': _health,
      'married': _married,
      'educationLevel': _educationLevel,
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
                    readOnly: _cccdFilled,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppColors.inactive),
                    suffixIcon: _cccdFilled ? const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.inactive) : null,
                  ),
                  const SizedBox(height: 12),
                  _dropdown('Giới tính *', _gender, ['MALE', 'FEMALE', 'OTHER'],
                      _genderLabel, _cccdFilled ? null : (v) => setState(() => _gender = v!)),
                  const SizedBox(height: 12),
                  _DatePickerField(
                    label: 'Ngày sinh *',
                    selectedDate: _selectedDob,
                    locked: _cccdFilled,
                    onDateSelected: (date) => setState(() => _selectedDob = date),
                    validator: (_) => _selectedDob == null ? 'Vui lòng chọn ngày sinh' : null,
                  ),
                  const SizedBox(height: 24),

                  // ── Identity ─────────────────────────────────────────
                  _sectionHeader('Giấy tờ tùy thân', Icons.badge_outlined),
                  _dropdown('Loại giấy tờ *', _identityType, ['CCCD', 'CMND', 'PASSPORT'],
                      (v) => v, _cccdFilled ? null : (v) => setState(() => _identityType = v!)),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Số giấy tờ *',
                    hint: '0123456789',
                    controller: _identityNumberCtrl,
                    keyboardType: TextInputType.number,
                    readOnly: _cccdFilled,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập số giấy tờ' : null,
                    prefixIcon: const Icon(Icons.numbers_rounded, size: 20, color: AppColors.inactive),
                    suffixIcon: _cccdFilled ? const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.inactive) : null,
                  ),
                  const SizedBox(height: 12),
                  // Năm cấp – chọn qua dialog
                  _YearPickerFormField(
                    label: 'Năm cấp *',
                    selectedYear: _identityIssueYear,
                    locked: _cccdFilled && _identityIssueYear != null,
                    onTap: _pickIssueYear,
                    validator: (_) => _identityIssueYear == null ? 'Vui lòng chọn năm cấp' : null,
                  ),
                  const SizedBox(height: 12),
                  // Nơi cấp – dropdown 3 lựa chọn
                  _dropdown(
                    'Nơi cấp *',
                    _identityIssuePlace.isEmpty ? _issuePlaceOptions.first : _identityIssuePlace,
                    _issuePlaceOptions,
                    (v) => v,
                    (v) => setState(() => _identityIssuePlace = v!),
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
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
                      final phone = v.trim();
                      if (!RegExp(r'^(0|\+84)[0-9]{9}$').hasMatch(phone)) {
                        return 'Số điện thoại không hợp lệ';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.inactive),
                  ),
                  const SizedBox(height: 12),
                  // Mối quan hệ – dropdown
                  _dropdown(
                    'Mối quan hệ *',
                    _emergencyRelationship,
                    _relationshipOptions,
                    (v) => v,
                    (v) => setState(() => _emergencyRelationship = v!),
                  ),
                  const SizedBox(height: 24),

                  // ── Residence ────────────────────────────────────────
                  _sectionHeader('Cư trú & Sức khỏe', Icons.home_outlined),
                  _AddressPicker(
                    label: 'Địa chỉ thường trú *',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng chọn địa chỉ thường trú' : null,
                    onChanged: (addr) => _permanentAddress = addr,
                  ),
                  const SizedBox(height: 16),
                  _AddressPicker(
                    label: 'Địa chỉ hiện tại *',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng chọn địa chỉ hiện tại' : null,
                    onChanged: (addr) => _nowAddress = addr,
                  ),
                  const SizedBox(height: 12),
                  // Tình trạng sức khỏe – dropdown
                  _dropdown(
                    'Tình trạng sức khỏe *',
                    _health,
                    _healthOptions,
                    (v) => v,
                    (v) => setState(() => _health = v!),
                  ),
                  const SizedBox(height: 12),
                  // Tình trạng hôn nhân – dropdown
                  _dropdown(
                    'Tình trạng hôn nhân *',
                    _married,
                    _marriedOptions,
                    _marriedLabel,
                    (v) => setState(() => _married = v!),
                  ),
                  const SizedBox(height: 24),

                  // ── Education ────────────────────────────────────────
                  _sectionHeader('Học vấn & Kỹ năng', Icons.school_outlined),
                  // Trình độ học vấn – dropdown
                  _dropdown(
                    'Trình độ học vấn *',
                    _educationLevel,
                    _educationOptions,
                    (v) => v,
                    (v) => setState(() => _educationLevel = v!),
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
          ValueChanged<String?>? onChanged) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : items.first,
          decoration: InputDecoration(
            suffixIcon: onChanged == null ? const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.inactive) : null,
          ),
          items: items.map((v) => DropdownMenuItem(value: v, child: Text(labelFn(v)))).toList(),
          onChanged: onChanged,
        ),
      ]);

  String _genderLabel(String v) => switch (v) {
        'MALE' => 'Nam',
        'FEMALE' => 'Nữ',
        _ => 'Khác',
      };

  String _marriedLabel(String v) => switch (v) {
        'MARRIED' => 'Đã kết hôn',
        'DIVORCED' => 'Đã ly hôn',
        'WIDOWED' => 'Góa',
        'SEPARATED' => 'Ly thân',
        'ENGAGED' => 'Đính hôn',
        'REMARRIED' => 'Tái hôn',
        _ => 'Độc thân',
      };
}

// ── Year picker form field ────────────────────────────────────────────────────

class _YearPickerFormField extends StatelessWidget {
  final String label;
  final int? selectedYear;
  final bool locked;
  final VoidCallback onTap;
  final FormFieldValidator<String>? validator;

  const _YearPickerFormField({
    required this.label,
    required this.selectedYear,
    required this.onTap,
    this.validator,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: locked ? null : onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                    color: field.hasError ? AppColors.error : AppColors.border),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.surface,
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.inactive),
                const SizedBox(width: 10),
                Text(
                  selectedYear != null ? '$selectedYear' : 'Chọn năm cấp',
                  style: TextStyle(
                    fontSize: 15,
                    color: selectedYear == null ? AppColors.inactive : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                locked
                    ? const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.inactive)
                    : const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.inactive),
              ]),
            ),
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(field.errorText!,
                  style: const TextStyle(fontSize: 12, color: AppColors.error)),
            ),
        ],
      ),
    );
  }
}

// ── Year picker dialog ────────────────────────────────────────────────────────

class _YearPickerDialog extends StatefulWidget {
  final int initialYear;
  final int firstYear;
  final int lastYear;

  const _YearPickerDialog({
    required this.initialYear,
    required this.firstYear,
    required this.lastYear,
  });

  @override
  State<_YearPickerDialog> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<_YearPickerDialog> {
  late int _selectedYear;
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    final years = List.generate(widget.lastYear - widget.firstYear + 1, (i) => widget.firstYear + i);
    final idx = years.indexOf(_selectedYear);
    _scrollCtrl = ScrollController(
      initialScrollOffset: idx >= 0 ? (idx * 48.0 - 96) : 0,
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(
        widget.lastYear - widget.firstYear + 1, (i) => widget.lastYear - i);

    return AlertDialog(
      title: const Text('Chọn năm cấp'),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: 200,
        height: 300,
        child: ListView.builder(
          controller: _scrollCtrl,
          itemCount: years.length,
          itemExtent: 48,
          itemBuilder: (ctx, i) {
            final year = years[i];
            final isSelected = year == _selectedYear;
            return InkWell(
              onTap: () => setState(() => _selectedYear = year),
              child: Container(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : null,
                alignment: Alignment.center,
                child: Text(
                  '$year',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontSize: isSelected ? 17 : 15,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy')),
        TextButton(
            onPressed: () => Navigator.pop(context, _selectedYear),
            child: const Text('Xác nhận')),
      ],
    );
  }
}

// ── Date picker field ─────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final FormFieldValidator<String>? validator;
  final bool locked;

  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.validator,
    this.locked = false,
  });

  String get _displayText => selectedDate == null
      ? 'Chọn ngày sinh'
      : '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}';

  Future<void> _pickDate(BuildContext context) async {
    if (locked) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(now.year - 25, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 16, now.month, now.day),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                    color: field.hasError ? AppColors.error : AppColors.border),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.surface,
              ),
              child: Row(children: [
                const Icon(Icons.cake_outlined, size: 20, color: AppColors.inactive),
                const SizedBox(width: 10),
                Text(
                  _displayText,
                  style: TextStyle(
                    fontSize: 15,
                    color: selectedDate == null ? AppColors.inactive : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                locked
                    ? const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.inactive)
                    : const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.inactive),
              ]),
            ),
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(field.errorText!,
                  style: const TextStyle(fontSize: 12, color: AppColors.error)),
            ),
        ],
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

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
