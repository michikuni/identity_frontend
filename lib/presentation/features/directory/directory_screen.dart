import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/domain/entities/directory_entity.dart';
import 'package:identity_frontend/domain/usecases/directory_usecase.dart';

// ── BLoC (inline, nhỏ gọn) ───────────────────────────────────────────────────

class DirectoryBloc extends Cubit<DirectoryState> {
  final DirectoryUseCase _useCase;
  List<DirectoryEntity> _all = [];

  DirectoryBloc(this._useCase) : super(const DirectoryState());

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      _all = await _useCase.getAll();
      emit(state.copyWith(loading: false, items: _all));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void search(String query) {
    final q = query.toLowerCase();
    final filtered = q.isEmpty
        ? _all
        : _all.where((e) =>
            e.name.toLowerCase().contains(q) ||
            e.department.toLowerCase().contains(q) ||
            e.position.toLowerCase().contains(q)).toList();
    emit(state.copyWith(items: filtered));
  }
}

class DirectoryState {
  final bool loading;
  final List<DirectoryEntity> items;
  final String? error;
  const DirectoryState({this.loading = false, this.items = const [], this.error});
  DirectoryState copyWith({bool? loading, List<DirectoryEntity>? items, String? error}) =>
      DirectoryState(loading: loading ?? this.loading, items: items ?? this.items, error: error);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});
  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DirectoryBloc>().load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Danh sách nhân viên'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) => context.read<DirectoryBloc>().search(q),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm tên, phòng ban, chức vụ...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.7), size: 20),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<DirectoryBloc, DirectoryState>(
        builder: (context, state) {
          if (state.loading) return const Center(child: CircularProgressIndicator());
          if (state.items.isEmpty) {
            return const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.group_off_rounded, size: 56, color: AppColors.inactive),
                SizedBox(height: 12),
                Text('Không tìm thấy', style: TextStyle(color: AppColors.textSecondary)),
              ]),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<DirectoryBloc>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, idx) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _EmployeeCard(item: state.items[i]),
            ),
          );
        },
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final DirectoryEntity item;
  const _EmployeeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(item.role);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              item.initials,
              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(item.position, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(children: [
                  _chip(Icons.corporate_fare_rounded, item.department, AppColors.info),
                  const SizedBox(width: 6),
                  _chip(Icons.shield_outlined, _roleLabel(item.role), roleColor),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ]),
      );

  Color _roleColor(String role) => switch (role) {
        'ADMIN' => AppColors.error,
        'CHIEF' => AppColors.accent,
        'MANAGER' => AppColors.info,
        _ => AppColors.success,
      };

  String _roleLabel(String role) => switch (role) {
        'ADMIN' => 'Admin',
        'CHIEF' => 'Giám đốc',
        'MANAGER' => 'Quản lý',
        _ => 'Nhân viên',
      };
}
