import 'package:flutter/material.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';

class ManagerTimesheetScreen extends StatefulWidget {
  const ManagerTimesheetScreen({super.key});

  @override
  State<ManagerTimesheetScreen> createState() => _ManagerTimesheetScreenState();
}

class _ManagerTimesheetScreenState extends State<ManagerTimesheetScreen> {
  late int _year;
  late int _month;
  List<_EmployeeTimesheet> _data = [];
  bool _loading = true;
  String? _selectedEmployeeId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance
          .get('${ApiConstants.attendanceTeam}?year=$_year&month=$_month');
      final list = res.data['data'] as List? ?? [];
      setState(() {
        _data = list
            .map((e) => _EmployeeTimesheet.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
        if (_selectedEmployeeId == null && _data.isNotEmpty) {
          _selectedEmployeeId = _data.first.employeeId.toString();
        }
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _month += delta;
      if (_month > 12) { _month = 1; _year++; }
      if (_month < 1) { _month = 12; _year--; }
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Bảng công nhân viên'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          if (!_loading && _data.isNotEmpty) _buildEmployeePicker(context),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _data.isEmpty
                    ? _buildEmpty(context)
                    : _buildTimesheetForSelected(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() => Container(
        color: AppColors.primary,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
              onPressed: () => _changeMonth(-1),
            ),
            Text('Tháng $_month/$_year',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
              onPressed: () => _changeMonth(1),
            ),
          ],
        ),
      );

  Widget _buildEmployeePicker(BuildContext context) => Container(
        color: AppColors.primary,
        padding: EdgeInsets.fromLTRB(context.r(16), 0, context.r(16), context.r(12)),
        child: SizedBox(
          height: context.r(34),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _data.length,
            separatorBuilder: (_, _) => SizedBox(width: context.r(8)),
            itemBuilder: (_, i) {
              final emp = _data[i];
              final selected = _selectedEmployeeId == emp.employeeId.toString();
              return GestureDetector(
                onTap: () => setState(() => _selectedEmployeeId = emp.employeeId.toString()),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: context.r(12), vertical: context.r(4)),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(context.r(20)),
                  ),
                  child: Text(
                    emp.employeeName,
                    style: TextStyle(
                      fontSize: context.r(12),
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.primary : Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

  Widget _buildTimesheetForSelected(BuildContext context) {
    final emp = _data.firstWhere(
      (e) => e.employeeId.toString() == _selectedEmployeeId,
      orElse: () => _data.first,
    );
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final firstWeekday = DateTime(_year, _month, 1).weekday;
    final attendanceMap = {for (final r in emp.records) r.workDate: r};

    final present = emp.records.where((r) => r.status == 'PRESENT').length;
    final late = emp.records.where((r) => r.status == 'LATE').length;
    final absent = emp.records.where((r) => r.status == 'ABSENT').length;

    return ListView(
      padding: EdgeInsets.all(context.r(16)),
      children: [
        _buildEmployeeHeader(context, emp),
        SizedBox(height: context.r(12)),
        _buildSummaryRow(context, present, late, absent),
        SizedBox(height: context.r(16)),
        _buildCalendar(context, daysInMonth, firstWeekday, attendanceMap),
        SizedBox(height: context.r(16)),
        _buildLegend(context),
        if (emp.records.isNotEmpty) ...[
          SizedBox(height: context.r(16)),
          _buildDetailList(context, emp.records),
        ],
      ],
    );
  }

  Widget _buildEmployeeHeader(BuildContext context, _EmployeeTimesheet emp) => Container(
        padding: EdgeInsets.all(context.r(14)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(context.r(14)),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: context.r(20),
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              emp.employeeName.isNotEmpty ? emp.employeeName[0].toUpperCase() : '?',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontSize: context.r(15)),
            ),
          ),
          SizedBox(width: context.r(12)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(emp.employeeName,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: context.r(14))),
            Text(emp.department,
                style: TextStyle(fontSize: context.r(12), color: AppColors.textSecondary)),
          ]),
        ]),
      );

  Widget _buildSummaryRow(BuildContext context, int present, int late, int absent) => Row(
        children: [
          _chip(context, 'Có mặt', present, AppColors.success),
          SizedBox(width: context.r(8)),
          _chip(context, 'Muộn', late, AppColors.warning),
          SizedBox(width: context.r(8)),
          _chip(context, 'Vắng', absent, AppColors.error),
        ],
      );

  Widget _chip(BuildContext context, String label, int count, Color color) => Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: context.r(10)),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.r(10)),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text('$count',
                  style: TextStyle(
                      fontSize: context.r(20), fontWeight: FontWeight.w800, color: color)),
              Text(label,
                  style: TextStyle(fontSize: context.r(11), color: color)),
            ],
          ),
        ),
      );

  Widget _buildCalendar(BuildContext context, int daysInMonth, int firstWeekday,
      Map<String, _AttendanceRecord> map) {
    const headers = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final startOffset = firstWeekday - 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: AppColors.border),
      ),
      padding: EdgeInsets.all(context.r(12)),
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
          SizedBox(height: context.r(8)),
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
              final dateStr =
                  '$_year-${_month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
              final rec = map[dateStr];
              final weekday = DateTime(_year, _month, day).weekday;
              final isWeekend = weekday >= 6;
              return _CalendarCell(day: day, record: rec, isWeekend: isWeekend);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) => Container(
        padding: EdgeInsets.all(context.r(12)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(context.r(12)),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _legendDot(AppColors.success, 'Có mặt'),
            _legendDot(AppColors.warning, 'Muộn'),
            _legendDot(AppColors.error, 'Vắng'),
            _legendDot(AppColors.inactive, 'Cuối tuần'),
          ],
        ),
      );

  Widget _legendDot(Color color, String label) => Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      );

  Widget _buildDetailList(BuildContext context, List<_AttendanceRecord> records) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chi tiết',
              style: TextStyle(
                  fontSize: context.r(14),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          SizedBox(height: context.r(8)),
          ...records.map((r) => _DetailRow(record: r)),
        ],
      );

  Widget _buildEmpty(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.event_busy_rounded, size: context.r(56), color: AppColors.inactive),
          SizedBox(height: context.r(12)),
          const Text('Không có nhân viên cấp dưới',
              style: TextStyle(color: AppColors.textSecondary)),
        ]),
      );
}

class _CalendarCell extends StatelessWidget {
  final int day;
  final _AttendanceRecord? record;
  final bool isWeekend;
  const _CalendarCell({required this.day, required this.record, required this.isWeekend});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;

    if (isWeekend) {
      bg = AppColors.surfaceVariant;
      textColor = AppColors.inactive;
    } else if (record == null) {
      bg = Colors.transparent;
      textColor = AppColors.textPrimary;
    } else {
      final color = _statusColor(record!.status);
      bg = color.withValues(alpha: 0.18);
      textColor = color;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$day',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textColor)),
            if (record != null)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: _statusColor(record!.status),
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

class _DetailRow extends StatelessWidget {
  final _AttendanceRecord record;
  const _DetailRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(record.status);
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
            child: Text(_fmtDate(record.workDate),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Text(
            '${_fmt(record.checkInTime)} → ${_fmt(record.checkOutTime)}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(_statusLabel(record.status),
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

  String _statusLabel(String status) => switch (status) {
        'PRESENT' => 'Có mặt',
        'LATE' => 'Muộn',
        'ABSENT' => 'Vắng',
        _ => status,
      };

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

// ── Data classes ──────────────────────────────────────────────────────────────

class _EmployeeTimesheet {
  final int employeeId;
  final String employeeName;
  final String department;
  final List<_AttendanceRecord> records;

  _EmployeeTimesheet({
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.records,
  });

  factory _EmployeeTimesheet.fromJson(Map<String, dynamic> json) {
    final rawRecords = json['records'] as List? ?? [];
    return _EmployeeTimesheet(
      employeeId: (json['employeeId'] as num).toInt(),
      employeeName: json['employeeName'] as String? ?? '',
      department: json['department'] as String? ?? '',
      records: rawRecords
          .map((r) => _AttendanceRecord.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class _AttendanceRecord {
  final String workDate;
  final String? checkInTime;
  final String? checkOutTime;
  final String status;

  _AttendanceRecord({
    required this.workDate,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
  });

  factory _AttendanceRecord.fromJson(Map<String, dynamic> json) => _AttendanceRecord(
        workDate: json['workDate']?.toString() ?? '',
        checkInTime: json['checkInTime']?.toString(),
        checkOutTime: json['checkOutTime']?.toString(),
        status: json['status'] as String? ?? 'ABSENT',
      );
}
