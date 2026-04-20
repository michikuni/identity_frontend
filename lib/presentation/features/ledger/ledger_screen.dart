import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
import 'package:identity_frontend/domain/entities/ledger_entity.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/features/ledger/bloc/ledger_bloc.dart';
import 'package:identity_frontend/presentation/widgets/app_card.dart';
import 'package:identity_frontend/presentation/widgets/status_badge.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LedgerBloc(ledgerUseCase: sl()),
      child: const _LedgerView(),
    );
  }
}

class _LedgerView extends StatefulWidget {
  const _LedgerView();

  @override
  State<_LedgerView> createState() => _LedgerViewState();
}

class _LedgerViewState extends State<_LedgerView> {
  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    if (!mounted) return;
    final role = await SecureStorage.getUserRole() ?? 'EMPLOYEE';
    if (!mounted) return;
    if (role == 'ADMIN' || role == 'CHIEF') {
      context.read<LedgerBloc>().add(const LedgerFetchAll());
    } else {
      final empId = await SecureStorage.getUserId();
      if (!mounted) return;
      if (empId != null && empId.isNotEmpty) {
        context.read<LedgerBloc>().add(LedgerFetchForEmployee(empId));
      } else {
        context.read<LedgerBloc>().add(const LedgerFetchAll());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.ledgerTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadRecords,
          ),
        ],
      ),
      body: BlocBuilder<LedgerBloc, LedgerState>(
        builder: (context, state) {
          if (state.status == LedgerStatus.loading) {
            return const LoadingWidget(message: 'Fetching ledger records...');
          }
          if (state.status == LedgerStatus.failure) {
            return ErrorStateWidget(
              message: state.errorMessage ?? 'Failed to fetch ledger',
              onRetry: _loadRecords,
            );
          }
          if (state.records.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(context.r(16)),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.link_off_rounded,
                        size: context.r(40), color: AppColors.primary),
                  ),
                  SizedBox(height: context.r(16)),
                  Text(l10n.ledgerNoData,
                      style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return _buildList(context, l10n, state.records);
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, AppLocalizations l10n,
      List<LedgerRecordEntity> records) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(context.r(16)),
            child: GradientCard(
              gradient: const [Color(0xFF1A237E), Color(0xFF4A148C)],
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(context.r(10)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(context.r(12)),
                    ),
                    child: Icon(Icons.link_rounded,
                        color: Colors.white, size: context.r(24)),
                  ),
                  SizedBox(width: context.r(14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hyperledger Fabric',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: context.r(15))),
                        Text(
                          '${records.length} ${l10n.ledgerRecords}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: context.r(12)),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(label: l10n.ledgerActive, type: BadgeType.success),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
              context.r(16), 0, context.r(16), context.r(24)),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: EdgeInsets.only(bottom: context.r(10)),
                child: _RecordCard(record: records[index], l10n: l10n),
              ),
              childCount: records.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  final LedgerRecordEntity record;
  final AppLocalizations l10n;

  const _RecordCard({required this.record, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isActive = record.status.toUpperCase() == 'ACTIVE';
    final actionColor = switch (record.action.toUpperCase()) {
      'CREATE' => AppColors.success,
      'UPDATE' => AppColors.info,
      'DELETE' => AppColors.error,
      _ => AppColors.inactive,
    };

    return AppCard(
      padding: EdgeInsets.all(context.r(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: context.r(10), vertical: context.r(5)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.r(8)),
                ),
                child: Text(
                  record.recordType,
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: context.r(12),
                      fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: context.r(8), vertical: context.r(4)),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.r(6)),
                ),
                child: Text(record.action,
                    style: TextStyle(
                        color: actionColor,
                        fontSize: context.r(11),
                        fontWeight: FontWeight.w600)),
              ),
              SizedBox(width: context.r(6)),
              StatusBadge(
                label: isActive ? l10n.ledgerActive : l10n.ledgerDeleted,
                type: isActive ? BadgeType.success : BadgeType.error,
              ),
            ],
          ),
          SizedBox(height: context.r(12)),
          if (record.timestamp != null)
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: context.r(13), color: AppColors.inactive),
                SizedBox(width: context.r(4)),
                Text(record.timestamp!,
                    style: TextStyle(
                        fontSize: context.r(12), color: AppColors.textSecondary)),
              ],
            ),
          if (record.dataHash != null) ...[
            SizedBox(height: context.r(8)),
            Row(
              children: [
                Icon(Icons.fingerprint_rounded,
                    size: context.r(13), color: AppColors.inactive),
                SizedBox(width: context.r(4)),
                Expanded(
                  child: Text(
                    record.dataHash!,
                    style: TextStyle(
                        fontSize: context.r(11),
                        color: AppColors.textHint,
                        fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
