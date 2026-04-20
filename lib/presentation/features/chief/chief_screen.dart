import 'package:flutter/material.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
import 'package:identity_frontend/presentation/widgets/app_input.dart';

class ChiefScreen extends StatefulWidget {
  const ChiefScreen({super.key});
  @override
  State<ChiefScreen> createState() => _ChiefScreenState();
}

class _ChiefScreenState extends State<ChiefScreen> {
  List<Map<String, dynamic>> _employees = [];
  bool _loading = true;
  String _search = '';
  String _filterRole = 'ALL';

  static const _filters = [
    ('ALL', 'Tất cả'),
    ('EMPLOYEE', 'Nhân viên'),
    ('MANAGER', 'Quản lý'),
    ('CHIEF', 'Giám đốc'),
    ('ADMIN', 'Admin'),
    ('TERMINATED', 'Đã nghỉ'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get(ApiConstants.chiefEmployees);
      final list = res.data['data'] as List? ?? [];
      setState(() {
        _employees = list.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    return _employees.where((e) {
      final isTerminated = e['isActive'] == false;
      final role = (e['role'] ?? '').toString();
      if (_filterRole == 'TERMINATED' && !isTerminated) { return false; }
      if (_filterRole != 'ALL' && _filterRole != 'TERMINATED' &&
          (isTerminated || role != _filterRole)) { return false; }

      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        return (e['name'] ?? '').toString().toLowerCase().contains(q) ||
            (e['department'] ?? '').toString().toLowerCase().contains(q) ||
            (e['email'] ?? '').toString().toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Quản lý nhân sự'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Thêm nhân sự'),
        onPressed: () => _showCreateSheet(context),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(context),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? _buildEmpty(context)
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                              context.r(16), context.r(12), context.r(16), context.r(88)),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, _) => SizedBox(height: context.r(10)),
                          itemBuilder: (_, i) => _EmployeeCard(
                            emp: _filtered[i],
                            onChanged: _load,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) => Container(
        color: AppColors.primary,
        child: Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(context.r(16), 0, context.r(16), context.r(8)),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm nhân viên...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                prefixIcon: Icon(Icons.search_rounded,
                    color: Colors.white.withValues(alpha: 0.7), size: context.r(20)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.r(10)),
                    borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(vertical: context.r(10)),
              ),
            ),
          ),
          SizedBox(
            height: context.r(36),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(context.r(16), 0, context.r(16), context.r(8)),
              children: _filters.map((f) {
                final (value, label) = f;
                final selected = _filterRole == value;
                return Padding(
                  padding: EdgeInsets.only(right: context.r(8)),
                  child: GestureDetector(
                    onTap: () => setState(() => _filterRole = value),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.r(12), vertical: context.r(4)),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(context.r(20)),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: context.r(12),
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColors.primary : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ]),
      );

  Widget _buildEmpty(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.group_off_rounded, size: context.r(56), color: AppColors.inactive),
          SizedBox(height: context.r(12)),
          const Text('Không có nhân viên nào',
              style: TextStyle(color: AppColors.textSecondary)),
          SizedBox(height: context.r(16)),
          ElevatedButton.icon(
            icon: Icon(Icons.person_add_rounded, size: context.r(18)),
            label: const Text('Thêm nhân sự'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () => _showCreateSheet(context),
          ),
        ]),
      );

  Future<void> _showCreateSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateEmployeeSheet(onCreated: _load),
    );
  }
}

// ── Employee Card ─────────────────────────────────────────────────────────────

class _EmployeeCard extends StatelessWidget {
  final Map<String, dynamic> emp;
  final VoidCallback onChanged;
  const _EmployeeCard({required this.emp, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isActive = emp['isActive'] == true;
    final role = emp['role'] as String? ?? 'EMPLOYEE';
    final roleColor = _roleColor(role);

    return Container(
      padding: EdgeInsets.all(context.r(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(
            color: isActive ? AppColors.border : AppColors.error.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: AppColors.shadowLight, blurRadius: context.r(6), offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: context.r(22),
          backgroundColor: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.error.withValues(alpha: 0.1),
          child: Text(
            _initials(emp['name'] ?? emp['email'] ?? '?'),
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isActive ? AppColors.primary : AppColors.error,
                fontSize: context.r(14)),
          ),
        ),
        SizedBox(width: context.r(12)),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(emp['name'] ?? emp['email'] ?? '',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: context.r(13))),
            SizedBox(height: context.r(2)),
            Text('${emp['position'] ?? ''} • ${emp['department'] ?? ''}',
                style: TextStyle(fontSize: context.r(11), color: AppColors.textSecondary)),
            SizedBox(height: context.r(4)),
            Row(children: [
              _badge(context, _roleLabel(role), roleColor),
              if (!isActive) ...[
                SizedBox(width: context.r(6)),
                _badge(context, 'Đã nghỉ', AppColors.error),
              ],
            ]),
          ]),
        ),
        if (isActive)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: AppColors.inactive, size: context.r(22)),
            onSelected: (v) => _onAction(context, v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'ADMIN', child: Text('Bổ nhiệm Admin')),
              const PopupMenuItem(value: 'CHIEF', child: Text('Bổ nhiệm Giám đốc')),
              const PopupMenuItem(value: 'MANAGER', child: Text('Bổ nhiệm Quản lý')),
              const PopupMenuItem(value: 'EMPLOYEE', child: Text('Hạ nhân viên')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'salary_vc', child: Text('Issue Salary VC')),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'terminate',
                child: Text('Chấm dứt HĐ',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          )
        else
          SizedBox(width: context.r(48)),
      ]),
    );
  }

  Future<void> _onAction(BuildContext context, String action) async {
    final id = emp['id']?.toString();
    if (id == null) return;
    try {
      if (action == 'terminate') {
        final ctrl = TextEditingController();
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Chấm dứt hợp đồng'),
            content: TextField(
                controller: ctrl,
                decoration: const InputDecoration(hintText: 'Lý do...')),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Huỷ')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        if (confirm != true || !context.mounted) return;
        await ApiClient.instance
            .put(ApiConstants.chiefTerminate(id), data: {'reason': ctrl.text});

      } else if (action == 'salary_vc') {
        // Issue SalaryRangeVC — requires payroll to be assigned first
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Issue Salary Range VC'),
            content: Text(
                'Phát hành SalaryRangeVC cho ${emp['name'] ?? emp['email']}?\n\nYêu cầu nhân viên đã có payroll được gán.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Huỷ')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Issue VC'),
              ),
            ],
          ),
        );
        if (confirm != true || !context.mounted) return;
        await ApiClient.instance
            .put('/admin/employees/$id/issue-salary-vc');

      } else {
        // Role change — ask for new position to trigger PromotionVC correctly
        final posCtrl = TextEditingController(
            text: emp['position']?.toString() ?? '');
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Đổi chức danh'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chức danh mới: ${_roleLabel(action)}'),
                const SizedBox(height: 12),
                TextField(
                  controller: posCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Chức vụ mới (tuỳ chọn)',
                    hintText: 'VD: Senior Engineer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nếu nhập chức vụ mới, hệ thống sẽ tự phát hành PromotionVC.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Huỷ')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Xác nhận')),
            ],
          ),
        );
        if (confirm != true || !context.mounted) return;
        await ApiClient.instance.put(
          ApiConstants.chiefChangeRole(id),
          data: {
            'role': action,
            if (posCtrl.text.trim().isNotEmpty) 'position': posCtrl.text.trim(),
          },
        );
      }

      onChanged();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cập nhật thành công'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  String _roleLabel(String r) => switch (r) {
        'ADMIN' => 'Admin',
        'CHIEF' => 'Giám đốc',
        'MANAGER' => 'Quản lý',
        _ => 'Nhân viên',
      };

  Widget _badge(BuildContext context, String label, Color color) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: context.r(7), vertical: context.r(2)),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.r(6))),
        child: Text(label,
            style: TextStyle(
                fontSize: context.r(10), fontWeight: FontWeight.w700, color: color)),
      );

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _roleColor(String r) => switch (r) {
        'ADMIN' => AppColors.error,
        'CHIEF' => AppColors.accent,
        'MANAGER' => AppColors.info,
        _ => AppColors.success,
      };

}

// ── Create Employee Sheet ─────────────────────────────────────────────────────

class _CreateEmployeeSheet extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreateEmployeeSheet({required this.onCreated});

  @override
  State<_CreateEmployeeSheet> createState() => _CreateEmployeeSheetState();
}

class _CreateEmployeeSheetState extends State<_CreateEmployeeSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _posCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _role = 'EMPLOYEE';
  String _workingType = 'FULL_TIME';

  @override
  void dispose() {
    for (final c in [_emailCtrl, _phoneCtrl, _passwordCtrl, _deptCtrl, _posCtrl, _noteCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _loading = true);
    try {
      await ApiClient.instance.post(ApiConstants.chiefEmployees, data: {
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'password': _passwordCtrl.text,
        'role': _role,
        'department': _deptCtrl.text.trim(),
        'position': _posCtrl.text.trim(),
        'workingType': _workingType,
        if (_noteCtrl.text.trim().isNotEmpty) 'note': _noteCtrl.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      widget.onCreated();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Đã tạo nhân sự thành công'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(context.r(20))),
        ),
        child: Column(children: [
          Container(
            margin: EdgeInsets.only(top: context.r(12), bottom: context.r(4)),
            width: context.r(40),
            height: context.r(4),
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(context.r(2))),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(context.r(24), context.r(8), context.r(24), context.r(4)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Thêm nhân sự mới',
                  style: TextStyle(fontSize: context.r(17), fontWeight: FontWeight.w700)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollCtrl,
              padding: EdgeInsets.fromLTRB(
                  context.r(24), context.r(12), context.r(24), context.r(32)),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  _sectionLabel(context, 'Tài khoản'),
                  AppInput(
                    label: 'Email *',
                    hint: 'nhanvien@company.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                    prefixIcon: Icon(Icons.mail_outline_rounded,
                        size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(12)),
                  AppInput(
                    label: 'Số điện thoại *',
                    hint: '0912345678',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                    prefixIcon: Icon(Icons.phone_outlined,
                        size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(12)),
                  AppInput(
                    label: 'Mật khẩu *',
                    hint: 'Tối thiểu 6 ký tự',
                    controller: _passwordCtrl,
                    isPassword: true,
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Tối thiểu 6 ký tự' : null,
                    prefixIcon: Icon(Icons.lock_outline_rounded,
                        size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(20)),
                  _sectionLabel(context, 'Công việc'),
                  AppInput(
                    label: 'Phòng ban *',
                    hint: 'VD: Phòng Kỹ thuật',
                    controller: _deptCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                    prefixIcon: Icon(Icons.business_outlined,
                        size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(12)),
                  AppInput(
                    label: 'Chức vụ *',
                    hint: 'VD: Kỹ sư phần mềm',
                    controller: _posCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                    prefixIcon: Icon(Icons.badge_outlined,
                        size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(12)),
                  _dropdownField(
                    context,
                    'Chức danh',
                    _role,
                    ['EMPLOYEE', 'MANAGER', 'CHIEF', 'ADMIN'],
                    (v) => switch (v) {
                      'ADMIN' => 'Admin',
                      'CHIEF' => 'Giám đốc',
                      'MANAGER' => 'Quản lý',
                      _ => 'Nhân viên',
                    },
                    (v) => setState(() => _role = v!),
                  ),
                  SizedBox(height: context.r(12)),
                  _dropdownField(
                    context,
                    'Loại hình',
                    _workingType,
                    ['FULL_TIME', 'PART_TIME'],
                    (v) => v == 'FULL_TIME' ? 'Toàn thời gian' : 'Bán thời gian',
                    (v) => setState(() => _workingType = v!),
                  ),
                  SizedBox(height: context.r(12)),
                  AppInput(
                    label: 'Ghi chú (tuỳ chọn)',
                    hint: 'Thông tin bổ sung...',
                    controller: _noteCtrl,
                    maxLines: 2,
                    prefixIcon: Icon(Icons.notes_outlined,
                        size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(28)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: context.r(14)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.r(12))),
                    ),
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? SizedBox(
                            width: context.r(20),
                            height: context.r(20),
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('Tạo nhân sự',
                            style: TextStyle(
                                fontSize: context.r(15), fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String title) => Padding(
        padding: EdgeInsets.only(bottom: context.r(10)),
        child: Text(title,
            style: TextStyle(
                fontSize: context.r(13),
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
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
