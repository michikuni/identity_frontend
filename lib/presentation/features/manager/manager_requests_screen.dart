import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
import 'package:identity_frontend/domain/entities/request_entity.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/features/requests/bloc/request_bloc.dart';
import 'package:identity_frontend/presentation/features/requests/bloc/request_event.dart';
import 'package:identity_frontend/presentation/features/requests/bloc/request_state.dart';

class ManagerRequestsScreen extends StatefulWidget {
  const ManagerRequestsScreen({super.key});

  @override
  State<ManagerRequestsScreen> createState() => _ManagerRequestsScreenState();
}

class _ManagerRequestsScreenState extends State<ManagerRequestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RequestBloc>().add(const RequestFetchSubordinate());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Text(AppLocalizations.of(context)!.navApproveRequests),
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.requestTabPending),
              Tab(text: AppLocalizations.of(context)!.requestTabDone),
            ],
          ),
        ),
        body: BlocConsumer<RequestBloc, RequestState>(
          listener: (context, state) {
            if (state.actionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.managerRequestProcessed),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (context, state) {
            final pending = state.subordinateRequests.where((r) => r.isPending).toList();
            final done = state.subordinateRequests.where((r) => !r.isPending).toList();
            return TabBarView(children: [
              _buildList(context, pending, showActions: true),
              _buildList(context, done, showActions: false),
            ]);
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<RequestEntity> items, {required bool showActions}) {
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.task_alt_rounded, size: context.r(56), color: AppColors.inactive),
          SizedBox(height: context.r(12)),
          Text(AppLocalizations.of(context)!.managerRequestEmpty,
              style: TextStyle(color: AppColors.textSecondary, fontSize: context.r(14))),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context.read<RequestBloc>().add(const RequestFetchSubordinate()),
      child: ListView.separated(
        padding: EdgeInsets.all(context.r(16)),
        itemCount: items.length,
        separatorBuilder: (_, idx) => SizedBox(height: context.r(12)),
        itemBuilder: (_, i) => _ApprovalCard(item: items[i], showActions: showActions),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final RequestEntity item;
  final bool showActions;
  const _ApprovalCard({required this.item, required this.showActions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: context.r(8),
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(context.r(14)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(context.r(14))),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: context.r(18),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  (item.approverName ?? '?')[0].toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontSize: context.r(13)),
                ),
              ),
              SizedBox(width: context.r(10)),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_typeLabel(context, item.requestType),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: context.r(13))),
                      Text('${item.startDate} → ${item.endDate}',
                          style: TextStyle(
                              fontSize: context.r(11),
                              color: AppColors.textSecondary)),
                    ]),
              ),
              _StatusBadge(status: item.status),
            ]),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(context.r(14)),
            child: Text(item.reason,
                style: TextStyle(
                    fontSize: context.r(13), color: AppColors.textSecondary)),
          ),
          if (showActions) ...[
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(context.r(12)),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.close_rounded, size: context.r(16)),
                    label: Text(AppLocalizations.of(context)!.pendingReject),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    onPressed: () => _showRejectDialog(context, item.id!),
                  ),
                ),
                SizedBox(width: context.r(10)),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.check_rounded, size: context.r(16)),
                    label: Text(AppLocalizations.of(context)!.pendingApprove),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () =>
                        context.read<RequestBloc>().add(RequestApprove(item.id!)),
                  ),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, int id) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.managerRejectReasonTitle),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: InputDecoration(hintText: AppLocalizations.of(ctx)!.requestReasonHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<RequestBloc>().add(RequestReject(id, ctrl.text));
            },
            child: Text(AppLocalizations.of(ctx)!.confirm, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _typeLabel(BuildContext context, String t) {
    final l10n = AppLocalizations.of(context)!;
    return switch (t) {
      'LEAVE' => l10n.managerRequestTypeLeave,
      'WFH' => l10n.requestTypeWfh,
      'BUSINESS_TRIP' => l10n.requestTypeBusinessTrip,
      'ATTENDANCE_CORRECTION' => l10n.requestTypeAttendanceCorrection,
      _ => t,
    };
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = switch (status) {
      'APPROVED' => AppColors.success,
      'REJECTED' => AppColors.error,
      _ => AppColors.warning,
    };
    final label = switch (status) {
      'APPROVED' => l10n.requestStatusApproved,
      'REJECTED' => l10n.requestStatusRejected,
      _ => l10n.requestStatusPending,
    };
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: context.r(10), vertical: context.r(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: context.r(11),
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}
