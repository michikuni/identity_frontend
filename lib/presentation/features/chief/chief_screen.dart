import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/widgets/app_input.dart';

class ChiefScreen extends StatefulWidget {
  const ChiefScreen({super.key});
  @override
  State<ChiefScreen> createState() => _ChiefScreenState();
}

class _ChiefScreenState extends State<ChiefScreen> {
  List<Map<String, dynamic>> _employees = [];
  int _pendingAccounts = 0;
  bool _loading = true;
  String _search = '';
  String _filterRole = 'ALL';

  List<(String, String)> _filters(AppLocalizations l10n) => [
    ('ALL', l10n.chiefFilterAll),
    ('EMPLOYEE', l10n.chiefFilterEmployee),
    ('MANAGER', l10n.chiefFilterManager),
    ('CHIEF', l10n.chiefFilterChief),
    ('ADMIN', l10n.chiefFilterAdmin),
    ('TERMINATED', l10n.chiefFilterTerminated),
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
    _loadPendingCount();
  }

  Future<void> _loadPendingCount() async {
    try {
      final res = await ApiClient.instance.get(ApiConstants.adminPendingAccounts);
      final list = res.data['data'] as List? ?? [];
      if (mounted) setState(() => _pendingAccounts = list.length);
    } catch (_) {}
  }

  List<Map<String, dynamic>> get _filtered {
    return _employees.where((e) {
      final isTerminated = e['isActive'] == false;
      final role = (e['role'] ?? '').toString();
      if (_filterRole == 'TERMINATED') {
        if (!isTerminated) return false;
      } else if (_filterRole == 'ALL') {
        // Tab tất cả không hiển thị nhân sự đã nghỉ
        if (isTerminated) return false;
      } else {
        if (isTerminated || role != _filterRole) return false;
      }

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(l10n.chiefTitle),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.how_to_reg_rounded),
            tooltip: l10n.chiefApproveAccounts,
            onPressed: () => context.push('/app/admin/pending-accounts').then((_) => _load()),
          ),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: Text(l10n.chiefAddStaff),
        onPressed: () => _showCreateSheet(context),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(context),
          if (_pendingAccounts > 0) _buildPendingBanner(context),
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

  Widget _buildSearchAndFilter(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
        color: AppColors.primary,
        child: Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(context.r(16), 0, context.r(16), context.r(8)),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n.chiefSearchHint,
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
              children: _filters(l10n).map((f) {
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
  }

  Widget _buildPendingBanner(BuildContext context) => GestureDetector(
        onTap: () => context.push('/app/admin/pending-accounts').then((_) => _load()),
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(context.r(16), context.r(12), context.r(16), 0),
          padding: EdgeInsets.all(context.r(12)),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(context.r(12)),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
          ),
          child: Row(children: [
            Icon(Icons.pending_actions_rounded,
                color: AppColors.warning, size: context.r(20)),
            SizedBox(width: context.r(10)),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.chiefPendingBanner(_pendingAccounts),
                style: TextStyle(
                    fontSize: context.r(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.warning, size: context.r(14)),
          ]),
        ),
      );

  Widget _buildEmpty(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.group_off_rounded, size: context.r(56), color: AppColors.inactive),
        SizedBox(height: context.r(12)),
        Text(l10n.chiefNoEmployees, style: const TextStyle(color: AppColors.textSecondary)),
        SizedBox(height: context.r(16)),
        ElevatedButton.icon(
          icon: Icon(Icons.person_add_rounded, size: context.r(18)),
          label: Text(l10n.chiefAddStaff),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          onPressed: () => _showCreateSheet(context),
        ),
      ]),
    );
  }

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
              _badge(context, _roleLabel(context, role), roleColor),
              if (!isActive) ...[
                SizedBox(width: context.r(6)),
                _badge(context, AppLocalizations.of(context)!.chiefTerminated, AppColors.error),
              ],
            ]),
          ]),
        ),
        if (isActive)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: AppColors.inactive, size: context.r(22)),
            onSelected: (v) => _onAction(context, v),
            itemBuilder: (_) {
              final l10n = AppLocalizations.of(context)!;
              return [
                PopupMenuItem(value: 'ADMIN', child: Text(l10n.chiefPromoteAdmin)),
                PopupMenuItem(value: 'CHIEF', child: Text(l10n.chiefPromoteChief)),
                PopupMenuItem(value: 'MANAGER', child: Text(l10n.chiefPromoteManager)),
                PopupMenuItem(value: 'EMPLOYEE', child: Text(l10n.chiefDemoteEmployee)),
                const PopupMenuDivider(),
                PopupMenuItem(value: 'assign_manager', child: Text(l10n.chiefAssignManager)),
                const PopupMenuDivider(),
                PopupMenuItem(value: 'contract', child: Text(l10n.chiefCreateContract)),
                PopupMenuItem(value: 'payroll', child: Text(l10n.chiefCreatePayroll)),
                const PopupMenuDivider(),
                PopupMenuItem(value: 'salary_vc', child: Text(l10n.chiefIssueSalaryVc)),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'terminate',
                  child: Text(l10n.chiefTerminateContract, style: const TextStyle(color: AppColors.error)),
                ),
              ];
            },
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
      if (action == 'assign_manager') {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _AssignManagerSheet(
            employeeId: id,
            currentManagerId: emp['managerId']?.toString(),
            currentManagerName: emp['managerName']?.toString(),
            onSaved: onChanged,
          ),
        );
        return;

      } else if (action == 'terminate') {
        final ctrl = TextEditingController();
        final l10n = AppLocalizations.of(context)!;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.chiefTerminateTitle),
            content: TextField(
                controller: ctrl,
                decoration: InputDecoration(hintText: l10n.chiefTerminateReasonHint)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.cancel)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.confirm, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        if (confirm != true || !context.mounted) return;
        await ApiClient.instance
            .put(ApiConstants.chiefTerminate(id), data: {'reason': ctrl.text});

      } else if (action == 'contract') {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _ContractSheet(employeeId: id, onSaved: onChanged),
        );
        return;

      } else if (action == 'payroll') {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _PayrollSheet(employeeId: id, onSaved: onChanged),
        );
        return;

      } else if (action == 'salary_vc') {
        // Issue SalaryRangeVC — requires payroll to be assigned first
        final l10nSvc = AppLocalizations.of(context)!;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10nSvc.chiefIssueSalaryVcTitle),
            content: Text(l10nSvc.chiefIssueSalaryVcContent(emp['name'] ?? emp['email'] ?? '')),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10nSvc.cancel)),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10nSvc.adminIssueVc),
              ),
            ],
          ),
        );
        if (confirm != true || !context.mounted) return;
        await ApiClient.instance
            .put(ApiConstants.adminIssueSalaryVC(id));

      } else {
        // Role change — ask for new position to trigger PromotionVC correctly
        final posCtrl = TextEditingController(
            text: emp['position']?.toString() ?? '');
        final l10nRole = AppLocalizations.of(context)!;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10nRole.chiefChangeRoleTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10nRole.chiefNewRoleLabel(_roleLabel(context, action))),
                const SizedBox(height: 12),
                TextField(
                  controller: posCtrl,
                  decoration: InputDecoration(
                    labelText: l10nRole.chiefNewPositionLabel,
                    hintText: l10nRole.chiefNewPositionHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10nRole.chiefPromotionVcNote,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10nRole.cancel)),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10nRole.confirm)),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.chiefUpdateSuccess),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        String msg = e.toString();
        if (e is DioException) {
          final data = e.response?.data;
          if (data is Map) {
            msg = data['message']?.toString() ?? data['error']?.toString() ?? msg;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  String _roleLabel(BuildContext context, String r) {
    final l10n = AppLocalizations.of(context)!;
    return switch (r) {
      'ADMIN' => l10n.roleAdmin,
      'CHIEF' => l10n.roleChief,
      'MANAGER' => l10n.roleManager,
      _ => l10n.roleEmployee,
    };
  }

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.chiefCreateSuccess),
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
              child: Text(AppLocalizations.of(context)!.chiefCreateStaffTitle,
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
                child: Builder(builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  _sectionLabel(context, l10n.chiefSectionAccount),
                  AppInput(
                    label: l10n.chiefEmailLabel,
                    hint: l10n.chiefEmailHint,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.profileRequired : null,
                    prefixIcon: Icon(Icons.mail_outline_rounded,
                        size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(12)),
                  AppInput(
                    label: l10n.chiefPhoneLabel,
                    hint: '0912345678',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.profileRequired : null,
                    prefixIcon: Icon(Icons.phone_outlined,
                        size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(12)),
                  AppInput(
                    label: l10n.chiefPasswordLabel,
                    hint: l10n.chiefPasswordHint,
                    controller: _passwordCtrl,
                    isPassword: true,
                    validator: (v) =>
                        (v == null || v.length < 6) ? l10n.chiefPasswordHint : null,
                    prefixIcon: Icon(Icons.lock_outline_rounded,
                        size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(20)),
                  _sectionLabel(context, l10n.chiefSectionWork),
                  AppInput(
                    label: l10n.chiefDepartmentLabel,
                    hint: l10n.chiefDepartmentHint,
                    controller: _deptCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.profileRequired : null,
                    prefixIcon: Icon(Icons.business_outlined,
                        size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(12)),
                  AppInput(
                    label: l10n.chiefPositionLabel,
                    hint: l10n.chiefPositionHint,
                    controller: _posCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.profileRequired : null,
                    prefixIcon: Icon(Icons.badge_outlined,
                        size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(12)),
                  _dropdownField(
                    context,
                    l10n.chiefRoleLabel,
                    _role,
                    ['EMPLOYEE', 'MANAGER', 'CHIEF', 'ADMIN'],
                    (v) => switch (v) {
                      'ADMIN' => l10n.roleAdmin,
                      'CHIEF' => l10n.roleChief,
                      'MANAGER' => l10n.roleManager,
                      _ => l10n.roleEmployee,
                    },
                    (v) => setState(() => _role = v!),
                  ),
                  SizedBox(height: context.r(12)),
                  _dropdownField(
                    context,
                    l10n.chiefWorkingTypeLabel,
                    _workingType,
                    ['FULL_TIME', 'PART_TIME'],
                    (v) => v == 'FULL_TIME' ? l10n.chiefFullTime : l10n.chiefPartTime,
                    (v) => setState(() => _workingType = v!),
                  ),
                  SizedBox(height: context.r(12)),
                  AppInput(
                    label: l10n.chiefNoteLabel,
                    hint: l10n.chiefNoteHint,
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
                        : Text(l10n.chiefCreateBtn,
                            style: TextStyle(
                                fontSize: context.r(15), fontWeight: FontWeight.w600)),
                  ),
                ]);
                }),
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

// ── Contract Sheet ────────────────────────────────────────────────────────────

class _ContractSheet extends StatefulWidget {
  final String employeeId;
  final VoidCallback onSaved;
  const _ContractSheet({required this.employeeId, required this.onSaved});

  @override
  State<_ContractSheet> createState() => _ContractSheetState();
}

class _ContractSheetState extends State<_ContractSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;

  String _typeContract = 'FULL_TIME';
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _probationStart;
  DateTime? _probationEnd;
  final _taxCtrl = TextEditingController();
  final _socialCtrl = TextEditingController();
  final _healthCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    try {
      final res = await ApiClient.instance.get(
        ApiConstants.adminEmployeeContract(widget.employeeId),
      );
      final data = res.data['data'] as Map<String, dynamic>?;
      if (data != null) {
        setState(() {
          _typeContract = data['typeContract'] as String? ?? 'FULL_TIME';
          _startDate = _parseDate(data['startDate']);
          _endDate = _parseDate(data['endDate']);
          _probationStart = _parseDate(data['probationStartDate']);
          _probationEnd = _parseDate(data['probationEndDate']);
          _taxCtrl.text = data['taxCode'] as String? ?? '';
          _socialCtrl.text = data['socialInsuranceNumber'] as String? ?? '';
          _healthCtrl.text = data['healthInsuranceNumber'] as String? ?? '';
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try { return DateTime.parse(v as String); } catch (_) { return null; }
  }

  @override
  void dispose() {
    _taxCtrl.dispose();
    _socialCtrl.dispose();
    _healthCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, DateTime? current, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  String _fmtDate(DateTime? dt, AppLocalizations l10n) {
    if (dt == null) return l10n.chiefPickDate;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.chiefContractStartRequired),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _loading = true);
    try {
      final payload = {
        'typeContract': _typeContract,
        'startDate': _startDate!.toIso8601String(),
        if (_endDate != null) 'endDate': _endDate!.toIso8601String(),
        if (_probationStart != null) 'probationStartDate': _probationStart!.toIso8601String(),
        if (_probationEnd != null) 'probationEndDate': _probationEnd!.toIso8601String(),
        if (_taxCtrl.text.trim().isNotEmpty) 'taxCode': _taxCtrl.text.trim(),
        if (_socialCtrl.text.trim().isNotEmpty) 'socialInsuranceNumber': _socialCtrl.text.trim(),
        if (_healthCtrl.text.trim().isNotEmpty) 'healthInsuranceNumber': _healthCtrl.text.trim(),
      };
      await ApiClient.instance.put(
        ApiConstants.adminEmployeeContract(widget.employeeId),
        data: payload,
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.chiefContractSaved),
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
      initialChildSize: 0.9,
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
              child: Text(AppLocalizations.of(context)!.chiefContractTitle,
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
                child: Builder(builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(l10n.chiefContractType,
                      style: TextStyle(fontSize: context.r(13), fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary)),
                  SizedBox(height: context.r(6)),
                  DropdownButtonFormField<String>(
                    initialValue: _typeContract,
                    decoration: const InputDecoration(),
                    items: [
                      DropdownMenuItem(value: 'FULL_TIME', child: Text(l10n.chiefContractFullTime)),
                      DropdownMenuItem(value: 'PART_TIME', child: Text(l10n.chiefContractPartTime)),
                      DropdownMenuItem(value: 'PROBATION', child: Text(l10n.chiefContractProbation)),
                      DropdownMenuItem(value: 'INTERNSHIP', child: Text(l10n.chiefContractInternship)),
                    ],
                    onChanged: (v) => setState(() => _typeContract = v!),
                  ),
                  SizedBox(height: context.r(16)),
                  _DateRow(
                    label: l10n.chiefContractStartDate,
                    value: _fmtDate(_startDate, l10n),
                    onTap: () => _pickDate(context, _startDate, (d) => setState(() => _startDate = d)),
                  ),
                  SizedBox(height: context.r(10)),
                  _DateRow(
                    label: l10n.chiefContractEndDate,
                    value: _fmtDate(_endDate, l10n),
                    onTap: () => _pickDate(context, _endDate, (d) => setState(() => _endDate = d)),
                  ),
                  SizedBox(height: context.r(10)),
                  _DateRow(
                    label: l10n.chiefContractProbationStart,
                    value: _fmtDate(_probationStart, l10n),
                    onTap: () => _pickDate(context, _probationStart, (d) => setState(() => _probationStart = d)),
                  ),
                  SizedBox(height: context.r(10)),
                  _DateRow(
                    label: l10n.chiefContractProbationEnd,
                    value: _fmtDate(_probationEnd, l10n),
                    onTap: () => _pickDate(context, _probationEnd, (d) => setState(() => _probationEnd = d)),
                  ),
                  SizedBox(height: context.r(16)),
                  AppInput(
                    label: l10n.chiefContractTaxCode,
                    hint: 'VD: 0123456789',
                    controller: _taxCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.receipt_outlined, size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(10)),
                  AppInput(
                    label: l10n.chiefContractSocialInsurance,
                    hint: l10n.chiefContractSocialInsurance,
                    controller: _socialCtrl,
                    prefixIcon: Icon(Icons.security_outlined, size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(10)),
                  AppInput(
                    label: l10n.chiefContractHealthInsurance,
                    hint: l10n.chiefContractHealthInsurance,
                    controller: _healthCtrl,
                    prefixIcon: Icon(Icons.health_and_safety_outlined, size: context.r(20), color: AppColors.inactive),
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
                            width: context.r(20), height: context.r(20),
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.chiefContractSaveBtn,
                            style: TextStyle(fontSize: context.r(15), fontWeight: FontWeight.w600)),
                  ),
                ]);
                }),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Payroll Sheet ─────────────────────────────────────────────────────────────

class _PayrollSheet extends StatefulWidget {
  final String employeeId;
  final VoidCallback onSaved;
  const _PayrollSheet({required this.employeeId, required this.onSaved});

  @override
  State<_PayrollSheet> createState() => _PayrollSheetState();
}

class _PayrollSheetState extends State<_PayrollSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;

  String _salaryType = 'MONTHLY';
  String _currency = 'VND';
  final _baseCtrl = TextEditingController();
  final _bonusCtrl = TextEditingController();
  final _otCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _bankAccNumCtrl = TextEditingController();
  final _bankAccNameCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _bankBranchCtrl = TextEditingController();
  DateTime? _payDay;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    try {
      final res = await ApiClient.instance.get(
        '/admin/employees/${widget.employeeId}/payroll',
      );
      final data = res.data['data'] as Map<String, dynamic>?;
      if (data != null) {
        setState(() {
          _salaryType = data['salaryType'] as String? ?? 'MONTHLY';
          _currency = data['currency'] as String? ?? 'VND';
          _baseCtrl.text = (data['baseSalary'] as num?)?.toString() ?? '';
          _totalCtrl.text = (data['totalIncome'] as num?)?.toString() ?? '';
          _bonusCtrl.text = (data['bonusSalary'] as num?)?.toString() ?? '';
          _otCtrl.text = (data['overTimeRate'] as num?)?.toString() ?? '';
          _bankNameCtrl.text = data['bankName'] as String? ?? '';
          _bankAccNumCtrl.text = data['bankAccountNumber'] as String? ?? '';
          _bankAccNameCtrl.text = data['bankAccountName'] as String? ?? '';
          _bankBranchCtrl.text = data['bankBranch'] as String? ?? '';
          final pd = data['payDay'];
          if (pd != null) {
            try { _payDay = DateTime.parse(pd as String); } catch (_) {}
          }
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    for (final c in [_baseCtrl, _bonusCtrl, _otCtrl, _totalCtrl, _bankAccNumCtrl,
                     _bankAccNameCtrl, _bankNameCtrl, _bankBranchCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  String _fmtDate(DateTime? dt, AppLocalizations l10n) {
    if (dt == null) return l10n.chiefPickDate;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _loading = true);
    try {
      final payload = {
        'employeeId': widget.employeeId,
        'salaryType': _salaryType,
        'baseSalary': double.tryParse(_baseCtrl.text.trim()) ?? 0,
        'totalIncome': double.tryParse(_totalCtrl.text.trim()) ??
            double.tryParse(_baseCtrl.text.trim()) ?? 0,
        'currency': _currency,
        if (_bonusCtrl.text.trim().isNotEmpty)
          'bonusSalary': double.tryParse(_bonusCtrl.text.trim()),
        if (_otCtrl.text.trim().isNotEmpty)
          'overTimeRate': double.tryParse(_otCtrl.text.trim()),
        if (_payDay != null) 'payDay': _payDay!.toIso8601String(),
        if (_bankAccNumCtrl.text.trim().isNotEmpty)
          'bankAccountNumber': _bankAccNumCtrl.text.trim(),
        if (_bankAccNameCtrl.text.trim().isNotEmpty)
          'bankAccountName': _bankAccNameCtrl.text.trim(),
        if (_bankNameCtrl.text.trim().isNotEmpty)
          'bankName': _bankNameCtrl.text.trim(),
        if (_bankBranchCtrl.text.trim().isNotEmpty)
          'bankBranch': _bankBranchCtrl.text.trim(),
      };
      await ApiClient.instance.post(
        '/admin/employees/${widget.employeeId}/payroll',
        data: payload,
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.chiefPayrollSaved),
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
      initialChildSize: 0.9,
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
              child: Text(AppLocalizations.of(context)!.chiefPayrollTitle,
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
                child: Builder(builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(l10n.chiefPayrollSalaryType,
                      style: TextStyle(fontSize: context.r(13), fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary)),
                  SizedBox(height: context.r(6)),
                  DropdownButtonFormField<String>(
                    initialValue: _salaryType,
                    decoration: const InputDecoration(),
                    items: [
                      DropdownMenuItem(value: 'MONTHLY', child: Text(l10n.chiefPayrollMonthly)),
                      DropdownMenuItem(value: 'HOURLY', child: Text(l10n.chiefPayrollHourly)),
                      DropdownMenuItem(value: 'CONTRACT', child: Text(l10n.chiefPayrollByContract)),
                    ],
                    onChanged: (v) => setState(() => _salaryType = v!),
                  ),
                  SizedBox(height: context.r(12)),
                  Text(l10n.chiefPayrollCurrency,
                      style: TextStyle(fontSize: context.r(13), fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary)),
                  SizedBox(height: context.r(6)),
                  DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: const InputDecoration(),
                    items: const [
                      DropdownMenuItem(value: 'VND', child: Text('VND')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                    ],
                    onChanged: (v) => setState(() => _currency = v!),
                  ),
                  SizedBox(height: context.r(12)),
                  AppInput(
                    label: l10n.chiefPayrollBaseSalary,
                    hint: 'VD: 15000000',
                    controller: _baseCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return l10n.profileRequired;
                      if (double.tryParse(v.trim()) == null) return l10n.profileRequired;
                      return null;
                    },
                    prefixIcon: Icon(Icons.payments_outlined, size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(10)),
                  AppInput(
                    label: l10n.chiefPayrollTotalIncome,
                    hint: l10n.chiefPayrollTotalHint,
                    controller: _totalCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(10)),
                  AppInput(
                    label: l10n.chiefPayrollBonus,
                    hint: 'VD: 2000000',
                    controller: _bonusCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.card_giftcard_outlined, size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(10)),
                  AppInput(
                    label: l10n.chiefPayrollOtRate,
                    hint: 'VD: 100000',
                    controller: _otCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.more_time_outlined, size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(10)),
                  _DateRow(
                    label: l10n.chiefPayrollPayDay,
                    value: _fmtDate(_payDay, l10n),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _payDay ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _payDay = picked);
                    },
                  ),
                  SizedBox(height: context.r(16)),
                  Text(l10n.chiefPayrollBankSection,
                      style: TextStyle(fontSize: context.r(13), fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  SizedBox(height: context.r(10)),
                  AppInput(
                    label: l10n.chiefPayrollBankName,
                    hint: 'VD: Vietcombank',
                    controller: _bankNameCtrl,
                    prefixIcon: Icon(Icons.account_balance_outlined, size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(10)),
                  AppInput(
                    label: l10n.chiefPayrollBankAccNum,
                    hint: 'VD: 0123456789',
                    controller: _bankAccNumCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.credit_card_outlined, size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(10)),
                  AppInput(
                    label: l10n.chiefPayrollBankAccName,
                    hint: 'VD: NGUYEN VAN A',
                    controller: _bankAccNameCtrl,
                    prefixIcon: Icon(Icons.person_outline_rounded, size: context.r(20), color: AppColors.inactive),
                  ),
                  SizedBox(height: context.r(10)),
                  AppInput(
                    label: l10n.chiefPayrollBankBranch,
                    hint: 'VD: Hà Nội',
                    controller: _bankBranchCtrl,
                    prefixIcon: Icon(Icons.location_on_outlined, size: context.r(20), color: AppColors.inactive),
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
                            width: context.r(20), height: context.r(20),
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.chiefPayrollSaveBtn,
                            style: TextStyle(fontSize: context.r(15), fontWeight: FontWeight.w600)),
                  ),
                ]);
                }),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Date row helper ───────────────────────────────────────────────────────────

class _DateRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateRow({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(8)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.r(12), vertical: context.r(12)),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(context.r(8)),
        ),
        child: Row(children: [
          Icon(Icons.calendar_today_outlined, size: context.r(18), color: AppColors.inactive),
          SizedBox(width: context.r(10)),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(fontSize: context.r(11), color: AppColors.textSecondary)),
              SizedBox(height: context.r(2)),
              Text(value,
                  style: TextStyle(
                      fontSize: context.r(13),
                      fontWeight: FontWeight.w500,
                      color: value == 'Chọn ngày' ? AppColors.inactive : AppColors.textPrimary)),
            ]),
          ),
          Icon(Icons.arrow_drop_down_rounded, color: AppColors.inactive, size: context.r(20)),
        ]),
      ),
    );
  }
}

// ── Assign Manager Sheet ──────────────────────────────────────────────────────

class _AssignManagerSheet extends StatefulWidget {
  final String employeeId;
  final String? currentManagerId;
  final String? currentManagerName;
  final VoidCallback onSaved;
  const _AssignManagerSheet({
    required this.employeeId,
    this.currentManagerId,
    this.currentManagerName,
    required this.onSaved,
  });

  @override
  State<_AssignManagerSheet> createState() => _AssignManagerSheetState();
}

class _AssignManagerSheetState extends State<_AssignManagerSheet> {
  List<Map<String, dynamic>> _managers = [];
  bool _loading = true;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.currentManagerId;
    _loadManagers();
  }

  Future<void> _loadManagers() async {
    try {
      final res = await ApiClient.instance.get(ApiConstants.chiefEmployees);
      final list = (res.data['data'] as List? ?? []).cast<Map<String, dynamic>>();
      setState(() {
        _managers = list.where((e) {
          final role = e['role'] as String? ?? '';
          return (role == 'MANAGER' || role == 'CHIEF') && e['isActive'] == true;
        }).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    try {
      await ApiClient.instance.put(
        ApiConstants.chiefAssignManager(widget.employeeId),
        data: {'managerId': _selectedId == null ? null : int.tryParse(_selectedId!)},
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.chiefAssignSuccess),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
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
              child: Text(AppLocalizations.of(context)!.chiefAssignManagerTitle,
                  style: TextStyle(fontSize: context.r(17), fontWeight: FontWeight.w700)),
            ),
          ),
          if (widget.currentManagerName != null)
            Padding(
              padding: EdgeInsets.fromLTRB(context.r(24), 0, context.r(24), context.r(4)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.chiefCurrentManager(widget.currentManagerName!),
                    style: TextStyle(fontSize: context.r(12), color: AppColors.textSecondary)),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    controller: scrollCtrl,
                    children: [
                      RadioListTile<String?>(
                        value: null,
                        groupValue: _selectedId,
                        title: Text(AppLocalizations.of(context)!.chiefNoManager, style: const TextStyle(color: AppColors.textSecondary)),
                        onChanged: (v) => setState(() { _selectedId = null; }),
                      ),
                      if (_managers.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(context.r(24)),
                          child: Column(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: context.r(40), color: AppColors.warning),
                              SizedBox(height: context.r(8)),
                              Text(
                                AppLocalizations.of(context)!.chiefNoManagerAvailable,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: context.r(12),
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._managers.map((m) {
                          final mId = m['id']?.toString();
                          final mName = (m['name'] ?? m['email'] ?? '').toString();
                          final mRole = m['role'] as String? ?? '';
                          return RadioListTile<String?>(
                            value: mId,
                            groupValue: _selectedId,
                            title: Text(mName),
                            subtitle: Text('${_roleLabel(context, mRole)} • ${m['department'] ?? ''}',
                                style: TextStyle(fontSize: context.r(11))),
                            onChanged: (v) => setState(() { _selectedId = v; }),
                          );
                        }),
                    ],
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(context.r(24), context.r(8), context.r(24), context.r(24)),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, context.r(48)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(12))),
              ),
              onPressed: _submit,
              child: Text(AppLocalizations.of(context)!.chiefSaveAssign, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  String _roleLabel(BuildContext context, String r) {
    final l10n = AppLocalizations.of(context)!;
    return switch (r) {
      'CHIEF' => l10n.roleChief,
      'MANAGER' => l10n.roleManager,
      _ => r,
    };
  }
}
