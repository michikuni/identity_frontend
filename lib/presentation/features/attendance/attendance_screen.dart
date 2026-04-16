import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/domain/entities/attendance_entity.dart';
import 'bloc/attendance_bloc.dart';
import 'bloc/attendance_event.dart';
import 'bloc/attendance_state.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state.status == AttendanceStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildCheckCard(context, state),
                      const SizedBox(height: 20),
                      _buildTodayInfo(context, state.today),
                      const SizedBox(height: 20),
                      _buildQuickActions(context),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) => SliverAppBar(
        expandedHeight: 140,
        pinned: true,
        backgroundColor: AppColors.primary,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Chấm Công',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                Text(_today(), style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
              ],
            ),
          ),
        ),
      );

  Widget _buildCheckCard(BuildContext context, AttendanceState state) {
    final today = state.today;
    final isLoading = state.status == AttendanceStatus.loading;
    final hasCheckedIn = today?.hasCheckedIn ?? false;
    final hasCheckedOut = today?.hasCheckedOut ?? false;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context2, snap) => Text(
              _currentTime(),
              style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w300, letterSpacing: 2),
            ),
          ),
          const SizedBox(height: 4),
          Text(_today(), style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
          const SizedBox(height: 24),
          if (!hasCheckedIn)
            _actionButton(
              context,
              label: 'Check In',
              icon: Icons.login_rounded,
              color: Colors.white,
              textColor: AppColors.primary,
              isLoading: isLoading,
              onTap: () => context.read<AttendanceBloc>().add(const AttendanceCheckIn()),
            )
          else if (!hasCheckedOut)
            _actionButton(
              context,
              label: 'Check Out',
              icon: Icons.logout_rounded,
              color: Colors.white.withValues(alpha: 0.2),
              textColor: Colors.white,
              isLoading: isLoading,
              onTap: () => context.read<AttendanceBloc>().add(const AttendanceCheckOut()),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Text('Đã hoàn thành hôm nay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required bool isLoading,
    required VoidCallback onTap,
  }) =>
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          icon: isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Icon(icon),
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          onPressed: isLoading ? null : onTap,
        ),
      );

  Widget _buildTodayInfo(BuildContext context, AttendanceEntity? today) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hôm nay', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _timeCell('Giờ vào', today?.checkInTime, Icons.login_rounded, AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: _timeCell('Giờ ra', today?.checkOutTime, Icons.logout_rounded, AppColors.error)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeCell(String label, String? time, IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(
                    time != null ? _formatTime(time) : '--:--',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: time != null ? color : AppColors.inactive),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildQuickActions(BuildContext context) => Row(
        children: [
          Expanded(
            child: _quickBtn(
              context,
              icon: Icons.calendar_month_rounded,
              label: 'Lịch sử',
              color: AppColors.info,
              onTap: () => context.go('/app/attendance/history'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _quickBtn(
              context,
              icon: Icons.table_chart_outlined,
              label: 'Bảng công',
              color: AppColors.accent,
              onTap: () => context.go('/app/attendance/timesheet'),
            ),
          ),
        ],
      );

  Widget _quickBtn(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      );

  String _today() {
    final now = DateTime.now();
    const days = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
    return '${days[now.weekday % 7]}, ${now.day}/${now.month}/${now.year}';
  }

  String _currentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  String _formatTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.length > 5 ? raw.substring(11, 16) : raw;
    }
  }
}
