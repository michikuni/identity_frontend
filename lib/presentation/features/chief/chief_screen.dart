import 'package:flutter/material.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';

class ChiefScreen extends StatefulWidget {
  const ChiefScreen({super.key});
  @override
  State<ChiefScreen> createState() => _ChiefScreenState();
}

class _ChiefScreenState extends State<ChiefScreen> {
  List<Map<String, dynamic>> _employees = [];
  bool _loading = true;
  String _search = '';

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

  List<Map<String, dynamic>> get _filtered => _search.isEmpty
      ? _employees
      : _employees.where((e) {
          final q = _search.toLowerCase();
          return (e['name'] ?? '').toString().toLowerCase().contains(q) ||
              (e['department'] ?? '').toString().toLowerCase().contains(q);
        }).toList();

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
      body: Column(
        children: [
          _buildSearch(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, idx) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _ChiefEmployeeCard(
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

  Widget _buildSearch() => Container(
        color: AppColors.primary,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: TextField(
          onChanged: (v) => setState(() => _search = v),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tìm nhân viên...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.7), size: 20),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      );
}

class _ChiefEmployeeCard extends StatelessWidget {
  final Map<String, dynamic> emp;
  final VoidCallback onChanged;
  const _ChiefEmployeeCard({required this.emp, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isActive = emp['isActive'] == true;
    final roleColor = _roleColor(emp['role'] ?? 'EMPLOYEE');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isActive ? AppColors.border : AppColors.error.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isActive ? AppColors.primary.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
            child: Text(
              _initials(emp['name'] ?? emp['email'] ?? '?'),
              style: TextStyle(fontWeight: FontWeight.w800, color: isActive ? AppColors.primary : AppColors.error, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(emp['name'] ?? emp['email'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 2),
              Text('${emp['position'] ?? ''} • ${emp['department'] ?? ''}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Row(children: [
                _badge(_roleLabel(emp['role'] ?? ''), roleColor),
                if (!isActive) ...[const SizedBox(width: 6), _badge('Đã nghỉ', AppColors.error)],
              ]),
            ]),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.inactive),
            onSelected: (v) => _onAction(context, v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'manager', child: Text('Bổ nhiệm quản lý')),
              const PopupMenuItem(value: 'employee', child: Text('Hạ nhân viên')),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'terminate',
                child: Text('Chấm dứt HĐ', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onAction(BuildContext context, String action) async {
    final id = emp['id'];
    if (id == null) return;
    try {
      if (action == 'terminate') {
        final ctrl = TextEditingController();
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Chấm dứt hợp đồng'),
            content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Lý do...')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        if (confirm != true) return;
        await ApiClient.instance.put('${ApiConstants.chiefEmployees}/$id/terminate', data: {'reason': ctrl.text});
      } else {
        final role = action == 'manager' ? 'MANAGER' : 'EMPLOYEE';
        await ApiClient.instance.put('${ApiConstants.chiefEmployees}/$id/role', data: {'role': role});
      }
      onChanged();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
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

  String _roleLabel(String r) => switch (r) {
        'ADMIN' => 'Admin',
        'CHIEF' => 'Giám đốc',
        'MANAGER' => 'Quản lý',
        _ => 'Nhân viên',
      };
}
