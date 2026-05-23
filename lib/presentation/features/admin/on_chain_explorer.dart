import 'package:flutter/material.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/date_format.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/l10n/l10n.dart';

/// On-Chain Explorer — shows the current state of ALL records on the
/// Hyperledger Fabric ledger across every employee.
///
/// GET /api/v1/audit/records → GetAllRecords() chaincode
class OnChainExplorer extends StatefulWidget {
  const OnChainExplorer({super.key});

  @override
  State<OnChainExplorer> createState() => _OnChainExplorerState();
}

class _OnChainExplorerState extends State<OnChainExplorer> {
  bool _loading = true;
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  String? _error;
  String _filterType = 'ALL';
  final _searchCtrl = TextEditingController();

  static const _recordTypes = [
    'ALL',
    'PROFILE',
    'CONTRACT',
    'PAYROLL',
  ];

  String _recordTypeLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case 'ALL': return l10n.auditFilterAll;
      case 'PROFILE': return l10n.auditFilterProfile;
      case 'CONTRACT': return l10n.auditFilterContract;
      case 'PAYROLL': return l10n.auditFilterPayroll;
      case 'ATTENDANCE': return l10n.auditFilterAttendance;
      case 'DID': return l10n.auditFilterDid;
      case 'STATUS_LIST': return l10n.auditFilterStatusList;
      case 'CONTRACT_SIGNATURE': return l10n.auditFilterContractSignature;
      case 'COMPANY': return l10n.auditFilterCompany;
      default: return type;
    }
  }

  static const _actionColors = {
    'CREATE':   Color(0xFF2563EB),
    'UPDATE':   Color(0xFFD97706),
    'DELETE':   Color(0xFFDC2626),
    'REVOKE':   Color(0xFF7C2D12),
    'ACTIVATE': Color(0xFF16A34A),
  };

  static const _actionIcons = {
    'CREATE':   Icons.add_circle_outline,
    'UPDATE':   Icons.edit_outlined,
    'DELETE':   Icons.delete_outline,
    'REVOKE':   Icons.block_outlined,
    'ACTIVATE': Icons.check_circle_outline,
  };

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilter);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient.instance.get(ApiConstants.auditRecords);
      final list = (res.data['data'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _all = list;
        _loading = false;
        _applyFilter();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _applyFilter() {
    final query = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = _all.where((r) {
        final typeMatch = _filterType == 'ALL' || r['recordType'] == _filterType;
        final searchMatch = query.isEmpty ||
            (r['employeeId']?.toString().toLowerCase().contains(query) ?? false) ||
            (r['updatedBy']?.toString().toLowerCase().contains(query) ?? false);
        return typeMatch && searchMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterBar(),
        if (!_loading && _error == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  context.l10n.auditRecordCount(_filtered.length),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Spacer(),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: Text(context.l10n.adminRefresh, style: const TextStyle(fontSize: 12)),
                  onPressed: _load,
                ),
              ],
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError()
                  : _filtered.isEmpty
                      ? _buildEmpty()
                      : _buildList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: context.l10n.auditSearchHint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search_rounded, size: 18),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  onPressed: () {
                    _searchCtrl.clear();
                    _applyFilter();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final l10n = context.l10n;
    return Container(
      height: 40,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        itemCount: _recordTypes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final type = _recordTypes[i];
          final selected = _filterType == type;
          return GestureDetector(
            onTap: () {
              setState(() => _filterType = type);
              _applyFilter();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _recordTypeLabel(l10n, type),
                style: TextStyle(
                  fontSize: 11,
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

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _OnChainRecordCard(
        record: _filtered[i],
        actionColors: _actionColors,
        actionIcons: _actionIcons,
      ),
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
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_tree_outlined, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            _filterType == 'ALL'
                ? l10n.auditNoRecords
                : l10n.auditNoTypeRecords(_recordTypeLabel(l10n, _filterType)),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _OnChainRecordCard extends StatefulWidget {
  final Map<String, dynamic> record;
  final Map<String, Color> actionColors;
  final Map<String, IconData> actionIcons;

  const _OnChainRecordCard({
    required this.record,
    required this.actionColors,
    required this.actionIcons,
  });

  @override
  State<_OnChainRecordCard> createState() => _OnChainRecordCardState();
}

class _OnChainRecordCardState extends State<_OnChainRecordCard> {
  bool _expanded = false;

  Color get _color {
    final action = widget.record['action']?.toString().toUpperCase() ?? '';
    return widget.actionColors[action] ?? AppColors.primary;
  }

  IconData get _icon {
    final action = widget.record['action']?.toString().toUpperCase() ?? '';
    return widget.actionIcons[action] ?? Icons.circle_outlined;
  }

  String _humanRecordType(AppLocalizations l10n, String type) {
    switch (type) {
      case 'PROFILE': return l10n.auditFilterProfile;
      case 'CONTRACT': return l10n.auditFilterContract;
      case 'PAYROLL': return l10n.auditFilterPayroll;
      case 'ATTENDANCE': return l10n.auditFilterAttendance;
      case 'DID': return l10n.auditFilterDid;
      case 'STATUS_LIST': return l10n.auditFilterStatusList;
      case 'CONTRACT_SIGNATURE': return l10n.auditFilterContractSignature;
      case 'COMPANY': return l10n.auditFilterCompany;
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final r = widget.record;
    final action = r['action']?.toString() ?? 'UNKNOWN';
    final recordType = r['recordType']?.toString() ?? '';
    final employeeId = r['employeeId']?.toString() ?? '';
    final status = r['status']?.toString() ?? '';
    final updatedBy = r['updatedBy']?.toString() ?? '';
    final timestamp = formatDateTime(r['timestamp']?.toString());
    final keyFields = r['keyFields']?.toString();
    final dataHash = r['dataHash']?.toString();

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: _color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(_icon, size: 13, color: _color),
                ),
                const SizedBox(width: 8),
                // Action badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: _color.withValues(alpha: 0.3)),
                  ),
                  child: Text(action,
                      style: TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w700, color: _color)),
                ),
                const SizedBox(width: 6),
                Text(_humanRecordType(l10n, recordType),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const Spacer(),
                // Status chip
                if (status.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: status == 'ACTIVE'
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.textSecondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(status,
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: status == 'ACTIVE'
                                ? AppColors.success
                                : AppColors.textSecondary)),
                  ),
                const SizedBox(width: 4),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Employee ID
            if (employeeId.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.badge_outlined, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(context.l10n.auditEmployeeLabel(employeeId),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),

            // Timestamp + updatedBy
            const SizedBox(height: 2),
            if (timestamp.isNotEmpty)
              Text(timestamp,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            if (updatedBy.isNotEmpty)
              Text(context.l10n.auditUpdatedBy(updatedBy),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),

            // Expanded details
            if (_expanded) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              if (keyFields != null && keyFields.isNotEmpty) ...[
                Text(context.l10n.auditKeyFields,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(keyFields,
                      style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 8),
              ],
              if (dataHash != null && dataHash.isNotEmpty) ...[
                Text(context.l10n.auditDataHash,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    dataHash,
                    style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: AppColors.textSecondary),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
