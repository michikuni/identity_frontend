import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/domain/entities/request_entity.dart';
import 'bloc/request_bloc.dart';
import 'bloc/request_event.dart';
import 'bloc/request_state.dart';

class RequestListScreen extends StatelessWidget {
  const RequestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('Đơn từ'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              tooltip: 'Tạo đơn',
              onPressed: () => context.push('/app/requests/create'),
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Chờ duyệt'),
              Tab(text: 'Đã xử lý'),
            ],
          ),
        ),
        body: BlocBuilder<RequestBloc, RequestState>(
          builder: (context, state) {
            if (state.status == RequestStatus.loading && state.requests.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = state.requests;
            final pending = all.where((r) => r.isPending).toList();
            final done = all.where((r) => !r.isPending).toList();
            return TabBarView(
              children: [
                _RequestTab(items: all),
                _RequestTab(items: pending),
                _RequestTab(items: done),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RequestTab extends StatelessWidget {
  final List<RequestEntity> items;
  const _RequestTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: AppColors.inactive),
            SizedBox(height: 12),
            Text('Không có đơn', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context.read<RequestBloc>().add(const RequestFetchMine()),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, idx) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _RequestCard(item: items[i]),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestEntity item;
  const _RequestCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(_typeIcon(item.requestType), size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_typeLabel(item.requestType),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_statusLabel(item.status),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.calendar_today_rounded, '${item.startDate} → ${item.endDate}'),
                if (item.session != null) _infoRow(Icons.wb_sunny_outlined, _sessionLabel(item.session!)),
                _infoRow(Icons.notes_rounded, item.reason),
                if (item.approverName != null) _infoRow(Icons.person_outline_rounded, 'Người duyệt: ${item.approverName}'),
                if (item.rejectedReason != null)
                  _infoRow(Icons.error_outline_rounded, 'Lý do từ chối: ${item.rejectedReason}', color: AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {Color? color}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: color ?? AppColors.textSecondary))),
          ],
        ),
      );

  Color _statusColor(String s) => switch (s) {
        'APPROVED' => AppColors.success,
        'REJECTED' => AppColors.error,
        _ => AppColors.warning,
      };

  String _statusLabel(String s) => switch (s) {
        'APPROVED' => 'Đã duyệt',
        'REJECTED' => 'Từ chối',
        _ => 'Chờ duyệt',
      };

  IconData _typeIcon(String t) => switch (t) {
        'LEAVE' => Icons.beach_access_rounded,
        'WFH' => Icons.home_work_rounded,
        'BUSINESS_TRIP' => Icons.flight_rounded,
        _ => Icons.edit_calendar_rounded,
      };

  String _typeLabel(String t) => switch (t) {
        'LEAVE' => 'Đơn xin nghỉ phép',
        'WFH' => 'Làm việc tại nhà',
        'BUSINESS_TRIP' => 'Công tác',
        'ATTENDANCE_CORRECTION' => 'Sửa chấm công',
        _ => t,
      };

  String _sessionLabel(String s) => switch (s) {
        'MORNING' => 'Buổi sáng',
        'AFTERNOON' => 'Buổi chiều',
        _ => 'Cả ngày',
      };
}
