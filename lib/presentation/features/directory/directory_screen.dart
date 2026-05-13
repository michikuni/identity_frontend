import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
import 'package:identity_frontend/domain/entities/directory_entity.dart';
import 'package:identity_frontend/domain/usecases/directory_usecase.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';

// ── BLoC (inline, nhỏ gọn) ───────────────────────────────────────────────────

class DirectoryBloc extends Cubit<DirectoryState> {
  final DirectoryUseCase _useCase;
  List<DirectoryEntity> _all = [];

  DirectoryBloc(this._useCase) : super(const DirectoryState());

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      final all = await _useCase.getAll();
      // Chỉ hiển thị nhân sự đang làm việc (status ACTIVE)
      _all = all.where((e) => e.status == 'ACTIVE').toList();
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(l10n.directoryTitle),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(context.r(56)),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                context.r(16), 0, context.r(16), context.r(10)),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) => context.read<DirectoryBloc>().search(q),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n.directorySearchHint,
                hintStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                prefixIcon: Icon(Icons.search_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: context.r(20)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.r(10)),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: context.r(10)),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<DirectoryBloc, DirectoryState>(
        builder: (context, state) {
          if (state.loading) return const Center(child: CircularProgressIndicator());
          if (state.items.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.group_off_rounded,
                    size: context.r(56), color: AppColors.inactive),
                SizedBox(height: context.r(12)),
                Text(l10n.directoryNotFound,
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.r(14))),
              ]),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<DirectoryBloc>().load(),
            child: ListView.separated(
              padding: EdgeInsets.all(context.r(16)),
              itemCount: state.items.length,
              separatorBuilder: (_, idx) => SizedBox(height: context.r(10)),
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
    final l10n = AppLocalizations.of(context)!;
    final roleColor = _roleColor(item.role);
    return Container(
      padding: EdgeInsets.all(context.r(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: context.r(6),
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: context.r(24),
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              item.initials,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontSize: context.r(16)),
            ),
          ),
          SizedBox(width: context.r(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: context.r(14))),
                SizedBox(height: context.r(2)),
                Text(item.position,
                    style: TextStyle(
                        fontSize: context.r(12),
                        color: AppColors.textSecondary)),
                SizedBox(height: context.r(4)),
                Row(children: [
                  _chip(context, Icons.corporate_fare_rounded,
                      item.department, AppColors.info),
                  SizedBox(width: context.r(6)),
                  _chip(context, Icons.shield_outlined,
                      _roleLabel(item.role, l10n), roleColor),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, IconData icon, String label, Color color) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: context.r(7), vertical: context.r(3)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(context.r(6)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: context.r(11), color: color),
          SizedBox(width: context.r(4)),
          Text(label,
              style: TextStyle(
                  fontSize: context.r(10),
                  fontWeight: FontWeight.w600,
                  color: color)),
        ]),
      );

  Color _roleColor(String role) => switch (role) {
        'ADMIN' => AppColors.error,
        'CHIEF' => AppColors.accent,
        'MANAGER' => AppColors.info,
        _ => AppColors.success,
      };

  String _roleLabel(String role, AppLocalizations l10n) => switch (role) {
        'ADMIN' => l10n.roleAdmin,
        'CHIEF' => l10n.roleChief,
        'MANAGER' => l10n.roleManager,
        _ => l10n.roleEmployee,
      };
}
