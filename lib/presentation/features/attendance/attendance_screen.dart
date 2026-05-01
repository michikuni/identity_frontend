import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
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
                  padding: EdgeInsets.all(context.r(20)),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildCheckCard(context, state),
                      SizedBox(height: context.r(20)),
                      _buildTodayInfo(context, state.today),
                      SizedBox(height: context.r(20)),
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
        expandedHeight: context.r(140),
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
            padding: EdgeInsets.fromLTRB(
                context.r(24), context.r(60), context.r(24), context.r(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Chấm Công',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: context.r(24),
                        fontWeight: FontWeight.w700)),
                Text(_today(),
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: context.r(13))),
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
        borderRadius: BorderRadius.circular(context.r(20)),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: context.r(20),
              offset: const Offset(0, 8))
        ],
      ),
      padding: EdgeInsets.all(context.r(24)),
      child: Column(
        children: [
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context2, snap) => Text(
              _currentTime(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: context.r(42),
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2),
            ),
          ),
          SizedBox(height: context.r(4)),
          Text(_today(),
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: context.r(13))),
          SizedBox(height: context.r(24)),
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
              padding: EdgeInsets.symmetric(
                  horizontal: context.r(20), vertical: context.r(12)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(context.r(12)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: Colors.white, size: context.r(18)),
                  SizedBox(width: context.r(8)),
                  Text('Đã hoàn thành hôm nay',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: context.r(14))),
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
            padding: EdgeInsets.symmetric(vertical: context.r(14)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.r(12))),
            elevation: 0,
          ),
          icon: isLoading
              ? SizedBox(
                  width: context.r(18),
                  height: context.r(18),
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Icon(icon),
          label: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: context.r(15))),
          onPressed: isLoading ? null : onTap,
        ),
      );

  Widget _buildTodayInfo(BuildContext context, AttendanceEntity? today) {
    return Container(
      padding: EdgeInsets.all(context.r(16)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hôm nay', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: context.r(12)),
          Row(
            children: [
              Expanded(
                  child: _timeCell(context, 'Giờ vào', today?.checkInTime,
                      Icons.login_rounded, AppColors.success)),
              SizedBox(width: context.r(12)),
              Expanded(
                  child: _timeCell(context, 'Giờ ra', today?.checkOutTime,
                      Icons.logout_rounded, AppColors.error)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeCell(BuildContext context, String label, String? time,
      IconData icon, Color color) =>
      Container(
        padding: EdgeInsets.all(context.r(12)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(context.r(10)),
        ),
        child: Row(
          children: [
            Icon(icon, size: context.r(18), color: color),
            SizedBox(width: context.r(8)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: context.r(11),
                          color: AppColors.textSecondary)),
                  Text(
                    time != null ? _formatTime(time) : '--:--',
                    style: TextStyle(
                        fontSize: context.r(15),
                        fontWeight: FontWeight.w700,
                        color: time != null ? color : AppColors.inactive),
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
            child: _quickBtn(context,
                icon: Icons.calendar_month_rounded,
                label: 'Lịch sử',
                color: AppColors.info,
                onTap: () => context.go('/app/attendance/history')),
          ),
          SizedBox(width: context.r(12)),
          Expanded(
            child: _quickBtn(context,
                icon: Icons.table_chart_outlined,
                label: 'Bảng công',
                color: AppColors.accent,
                onTap: () => context.go('/app/attendance/timesheet')),
          ),
        ],
      );

  Widget _quickBtn(BuildContext context,
          {required IconData icon,
          required String label,
          required Color color,
          required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(context.r(16)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(context.r(14)),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.r(8)),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.r(8))),
                child: Icon(icon, color: color, size: context.r(18)),
              ),
              SizedBox(width: context.r(10)),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: context.r(13))),
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
      final dt = DateTime.parse(raw).toUtc().add(const Duration(hours: 7));
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.length > 5 ? raw.substring(11, 16) : raw;
    }
  }
}
