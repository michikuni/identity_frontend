import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
import 'package:identity_frontend/domain/entities/attendance_entity.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'bloc/attendance_bloc.dart';
import 'bloc/attendance_event.dart';
import 'bloc/attendance_state.dart';

class TimesheetScreen extends StatefulWidget {
  const TimesheetScreen({super.key});

  @override
  State<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen> {
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
        title: Text(AppLocalizations.of(context)!.navTimesheet),
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
                return _buildContent(state.history);
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
              AppLocalizations.of(context)!.attendanceMonth(_month, _year),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
              onPressed: () => _changeMonth(1),
            ),
          ],
        ),
      );

  Widget _buildContent(List<AttendanceEntity> history) {
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final firstWeekday = DateTime(_year, _month, 1).weekday; // 1=Mon...7=Sun

    final attendanceMap = {for (final a in history) a.workDate: a};

    final present = history.where((a) => a.status == 'PRESENT').length;
    final late = history.where((a) => a.status == 'LATE').length;
    final absent = history.where((a) => a.status == 'ABSENT').length;
    final workdays = _countWorkdays(daysInMonth);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCards(present, late, absent, workdays),
        const SizedBox(height: 16),
        _buildCalendarGrid(daysInMonth, firstWeekday, attendanceMap),
        const SizedBox(height: 16),
        _buildLegend(),
        const SizedBox(height: 16),
        if (history.isNotEmpty) _buildDailyList(history),
      ],
    );
  }

  Widget _buildSummaryCards(int present, int late, int absent, int workdays) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _summaryCard(context, l10n.attendancePresent, present, AppColors.success, Icons.check_circle_outline_rounded),
        const SizedBox(width: 8),
        _summaryCard(context, l10n.attendanceLate, late, AppColors.warning, Icons.schedule_rounded),
        const SizedBox(width: 8),
        _summaryCard(context, l10n.attendanceAbsent, absent, AppColors.error, Icons.cancel_outlined),
        const SizedBox(width: 8),
        _summaryCard(context, l10n.attendanceWorkdays, workdays, AppColors.info, Icons.work_outline_rounded),
      ],
    );
  }

  Widget _summaryCard(BuildContext context, String label, int count, Color color, IconData icon) =>
      Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: context.r(10), horizontal: context.r(6)),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(context.r(12)),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: context.r(18)),
              const SizedBox(height: 4),
              Text('$count',
                  style: TextStyle(fontSize: context.r(18), fontWeight: FontWeight.w800, color: color)),
              Text(label,
                  style: TextStyle(fontSize: context.r(9), color: color),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );

  Widget _buildCalendarGrid(int daysInMonth, int firstWeekday, Map<String, AttendanceEntity> map) {
    final l10n = AppLocalizations.of(context)!;
    final headers = [l10n.weekdayMon, l10n.weekdayTue, l10n.weekdayWed, l10n.weekdayThu, l10n.weekdayFri, l10n.weekdaySat, l10n.weekdaySun];
    // firstWeekday: 1=Mon=index0, 7=Sun=index6
    final startOffset = firstWeekday - 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: headers
                .map((h) => Expanded(
                      child: Center(
                        child: Text(h,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (_, idx) {
              if (idx < startOffset) return const SizedBox.shrink();
              final day = idx - startOffset + 1;
              final dateStr = '$_year-${_month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
              final a = map[dateStr];
              final weekday = DateTime(_year, _month, day).weekday;
              final isWeekend = weekday >= 6;
              final isToday = DateTime.now().year == _year &&
                  DateTime.now().month == _month &&
                  DateTime.now().day == day;
              return _DayCell(
                day: day,
                attendance: a,
                isWeekend: isWeekend,
                isToday: isToday,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Builder(builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _legendItem(AppColors.success, l10n.attendancePresent),
              _legendItem(AppColors.warning, l10n.attendanceLate),
              _legendItem(AppColors.error, l10n.attendanceAbsent),
              _legendItem(AppColors.inactive, l10n.attendanceWeekend),
              _legendItem(AppColors.primary, l10n.attendanceToday),
            ],
          );
        }),
      );

  Widget _legendItem(Color color, String label) => Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      );

  Widget _buildDailyList(List<AttendanceEntity> history) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.attendanceDetail,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        ...history.map((a) => _DailyRow(attendance: a)),
      ],
    );
  }

  int _countWorkdays(int daysInMonth) {
    int count = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      final wd = DateTime(_year, _month, d).weekday;
      if (wd < 6) count++;
    }
    return count;
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final AttendanceEntity? attendance;
  final bool isWeekend;
  final bool isToday;

  const _DayCell({
    required this.day,
    required this.attendance,
    required this.isWeekend,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;

    if (isToday && attendance == null) {
      bg = AppColors.primary.withValues(alpha: 0.15);
      textColor = AppColors.primary;
    } else if (isWeekend) {
      bg = AppColors.surfaceVariant;
      textColor = AppColors.inactive;
    } else if (attendance == null) {
      bg = Colors.transparent;
      textColor = AppColors.textPrimary;
    } else {
      final color = _statusColor(attendance!.status);
      bg = color.withValues(alpha: 0.18);
      textColor = color;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: isToday ? Border.all(color: AppColors.primary, width: 1.5) : null,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$day',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                    color: textColor)),
            if (attendance != null)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: _statusColor(attendance!.status),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
        'PRESENT' => AppColors.success,
        'LATE' => AppColors.warning,
        'ABSENT' => AppColors.error,
        _ => AppColors.inactive,
      };
}

class _DailyRow extends StatelessWidget {
  final AttendanceEntity attendance;
  const _DailyRow({required this.attendance});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(attendance.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(
              _fmtDate(attendance.workDate),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${_fmt(attendance.checkInTime)} → ${_fmt(attendance.checkOutTime)}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(_statusLabel(context, attendance.status),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
        'PRESENT' => AppColors.success,
        'LATE' => AppColors.warning,
        'ABSENT' => AppColors.error,
        _ => AppColors.inactive,
      };

  String _statusLabel(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    return switch (status) {
      'PRESENT' => l10n.attendancePresent,
      'LATE' => l10n.attendanceLate,
      'ABSENT' => l10n.attendanceAbsent,
      _ => status,
    };
  }

  String _fmtDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  String _fmt(String? raw) {
    if (raw == null) return '--:--';
    try {
      final dt = DateTime.parse(raw).toUtc().add(const Duration(hours: 7));
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.length >= 16 ? raw.substring(11, 16) : raw;
    }
  }
}
