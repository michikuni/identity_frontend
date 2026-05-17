import 'package:flutter/material.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/l10n/l10n.dart';

/// Audit Log Screen — timeline of on-chain record history for an employee.
///
/// GET /api/v1/audit/employees/{employeeId}/history → all record types
/// GET /api/v1/audit/employees/{employeeId}/history/{type} → single type
class AuditLogScreen extends StatefulWidget {
  final String employeeId;
  final String? employeeName;

  const AuditLogScreen({
    super.key,
    required this.employeeId,
    this.employeeName,
  });

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _entries = [];
  String? _error;
  String _filterType = 'ALL';

  static const _recordTypes = [
    'ALL', 'PROFILE', 'CONTRACT', 'PAYROLL', 'ATTENDANCE',
    'DID', 'STATUS_LIST', 'CONTRACT_SIGNATURE',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final path = _filterType == 'ALL'
          ? ApiConstants.auditEmployeeAll(widget.employeeId)
          : ApiConstants.auditEmployeeHistory(widget.employeeId, _filterType);
      final res = await ApiClient.instance.get(path);
      final list = (res.data['data'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      setState(() {
        _entries = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.auditLogTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            if (widget.employeeName != null)
              Text(widget.employeeName!,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError()
                    : _entries.isEmpty
                        ? _buildEmpty()
                        : _buildTimeline(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 44,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _recordTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final type = _recordTypes[i];
          final selected = _filterType == type;
          return GestureDetector(
            onTap: () {
              setState(() => _filterType = type);
              _load();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _entries.length,
      itemBuilder: (_, i) {
        final entry = _entries[i];
        final isLast = i == _entries.length - 1;
        return _TimelineEntry(entry: entry, isLast: isLast);
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_outlined, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(context.l10n.auditNoRecords,
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final Map<String, dynamic> entry;
  final bool isLast;

  const _TimelineEntry({required this.entry, required this.isLast});

  static const _actionColors = {
    'CREATE': Color(0xFF2563EB),
    'UPDATE': Color(0xFFD97706),
    'DELETE': Color(0xFFDC2626),
    'REVOKE': Color(0xFF7C2D12),
    'ACTIVATE': Color(0xFF16A34A),
  };

  static const _actionIcons = {
    'CREATE':   Icons.add_circle_outline,
    'UPDATE':   Icons.edit_outlined,
    'DELETE':   Icons.delete_outline,
    'REVOKE':   Icons.block_outlined,
    'ACTIVATE': Icons.check_circle_outline,
  };

  Color get _color =>
      _actionColors[entry['action']?.toString().toUpperCase()] ?? AppColors.primary;

  IconData get _icon =>
      _actionIcons[entry['action']?.toString().toUpperCase()] ?? Icons.circle_outlined;

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final action = entry['action']?.toString() ?? 'UNKNOWN';
    final recordType = entry['recordType']?.toString() ?? '';
    final updatedBy = entry['updatedBy']?.toString() ?? '';
    final timestamp = _formatDate(entry['timestamp']?.toString());
    final keyFields = entry['keyFields']?.toString();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: _color.withValues(alpha: 0.4)),
                  ),
                  child: Icon(_icon, size: 14, color: _color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
              child: _AuditCard(
                action: action,
                recordType: recordType,
                updatedBy: updatedBy,
                timestamp: timestamp,
                keyFields: keyFields,
                color: _color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditCard extends StatefulWidget {
  final String action;
  final String recordType;
  final String updatedBy;
  final String timestamp;
  final String? keyFields;
  final Color color;

  const _AuditCard({
    required this.action,
    required this.recordType,
    required this.updatedBy,
    required this.timestamp,
    required this.keyFields,
    required this.color,
  });

  @override
  State<_AuditCard> createState() => _AuditCardState();
}

class _AuditCardState extends State<_AuditCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: widget.color.withValues(alpha: 0.3)),
                  ),
                  child: Text(widget.action,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: widget.color)),
                ),
                const SizedBox(width: 8),
                Text(widget.recordType,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const Spacer(),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(widget.timestamp,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            if (widget.updatedBy.isNotEmpty)
              Text(context.l10n.auditUpdatedBy(widget.updatedBy),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            if (_expanded && widget.keyFields != null) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(widget.keyFields!,
                  style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: AppColors.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}
