import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/domain/entities/attendance_entity.dart';
import 'bloc/attendance_bloc.dart';
import 'bloc/attendance_event.dart';
import 'bloc/attendance_state.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    context.read<AttendanceBloc>().add(AttendanceFetchHistory(year: _year, month: _month));
  }

  void _changeMonth(int delta) {
    setState(() {
      _month += delta;
      if (_month > 12) { _month = 1; _year++; }
      if (_month < 1) { _month = 12; _year--; }
    });
    context.read<AttendanceBloc>().add(AttendanceFetchHistory(year: _year, month: _month));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lịch sử chấm công'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          Expanded(
            child: BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                if (state.status == AttendanceStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.history.isEmpty) {
                  return _buildEmpty();
                }
                return _buildSummaryAndList(state.history);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() => Container(
        color: AppColors.primary,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
              onPressed: () => _changeMonth(-1),
            ),
            Text(
              'Tháng $_month/$_year',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
              onPressed: () => _changeMonth(1),
            ),
          ],
        ),
      );

  Widget _buildSummaryAndList(List<AttendanceEntity> list) {
    final present = list.where((a) => a.status == 'PRESENT').length;
    final late = list.where((a) => a.status == 'LATE').length;
    final absent = list.where((a) => a.status == 'ABSENT').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryRow(present, late, absent),
        const SizedBox(height: 16),
        ...list.map((a) => _buildItem(a)),
      ],
    );
  }

  Widget _buildSummaryRow(int present, int late, int absent) => Row(
        children: [
          _summaryChip('Có mặt', present, AppColors.success),
          const SizedBox(width: 8),
          _summaryChip('Muộn', late, AppColors.warning),
          const SizedBox(width: 8),
          _summaryChip('Vắng', absent, AppColors.error),
        ],
      );

  Widget _summaryChip(String label, int count, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
        ),
      );

  Widget _buildItem(AttendanceEntity a) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _statusColor(a.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_statusIcon(a.status), color: _statusColor(a.status), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.workDate, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    '${_fmt(a.checkInTime)} → ${_fmt(a.checkOutTime)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(a.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusLabel(a.status),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(a.status)),
              ),
            ),
          ],
        ),
      );

  Widget _buildEmpty() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded, size: 56, color: AppColors.inactive),
            SizedBox(height: 12),
            Text('Không có dữ liệu tháng này', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );

  Color _statusColor(String status) => switch (status) {
        'PRESENT' => AppColors.success,
        'LATE' => AppColors.warning,
        'ABSENT' => AppColors.error,
        _ => AppColors.inactive,
      };

  IconData _statusIcon(String status) => switch (status) {
        'PRESENT' => Icons.check_circle_rounded,
        'LATE' => Icons.schedule_rounded,
        'ABSENT' => Icons.cancel_rounded,
        _ => Icons.help_outline_rounded,
      };

  String _statusLabel(String status) => switch (status) {
        'PRESENT' => 'Có mặt',
        'LATE' => 'Muộn',
        'ABSENT' => 'Vắng',
        _ => status,
      };

  String _fmt(String? raw) {
    if (raw == null) return '--:--';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.length >= 16 ? raw.substring(11, 16) : raw;
    }
  }
}
