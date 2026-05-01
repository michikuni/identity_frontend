import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/domain/entities/contract_entity.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/features/contract/bloc/contract_bloc.dart';
import 'package:identity_frontend/presentation/widgets/app_card.dart';
import 'package:identity_frontend/presentation/widgets/info_row.dart';
import 'package:identity_frontend/presentation/widgets/status_badge.dart';

class ContractScreen extends StatelessWidget {
  const ContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContractBloc(contractUseCase: sl())..add(const ContractFetch()),
      child: const _ContractView(),
    );
  }
}

class _ContractView extends StatelessWidget {
  const _ContractView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.contractTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border)),
      ),
      body: BlocBuilder<ContractBloc, ContractState>(
        builder: (context, state) {
          if (state.status == ContractStatus.loading) {
            return const LoadingWidget(message: 'Loading contract...');
          }
          if (state.status == ContractStatus.failure || state.contract == null) {
            return _EmptyOrErrorWidget(
              icon: Icons.description_outlined,
              message: 'Không có dữ liệu hợp đồng.\nVui lòng thử lại.',
              onRetry: () => context.read<ContractBloc>().add(const ContractFetch()),
            );
          }
          return _buildContent(context, l10n, state.contract!);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, ContractEntity c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Contract Header card ────────────────────────────────────────
          GradientCard(
            gradient: const [Color(0xFF059669), Color(0xFF10B981)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_outlined, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        c.typeContract,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                    StatusBadge.fromStatus(c.typeContract),
                  ],
                ),
                if (c.startDate != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.contractStart}: ${_fmtDate(c.startDate)}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Dates ──────────────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'Contract Dates', icon: Icons.calendar_today_outlined),
                InfoRow(label: l10n.contractStart, value: _fmtDate(c.startDate)),
                if (c.endDate != null)
                  InfoRow(label: l10n.contractEnd, value: _fmtDate(c.endDate)),
                if (c.contractExpire != null)
                  InfoRow(label: l10n.contractExpire, value: _fmtDate(c.contractExpire)),
                if (c.probationStartDate != null)
                  InfoRow(label: l10n.contractProbationStart, value: _fmtDate(c.probationStartDate)),
                if (c.probationEndDate != null)
                  InfoRow(
                      label: l10n.contractProbationEnd,
                      value: _fmtDate(c.probationEndDate),
                      showDivider: false),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Insurance & Tax ────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'Insurance & Tax', icon: Icons.security_outlined),
                if (c.taxCode != null)
                  InfoRow(label: l10n.contractTaxCode, value: c.taxCode!),
                if (c.socialInsuranceNumber != null)
                  InfoRow(label: l10n.contractSocialInsurance, value: c.socialInsuranceNumber!),
                if (c.healthInsuranceNumber != null)
                  InfoRow(
                      label: l10n.contractHealthInsurance,
                      value: c.healthInsuranceNumber!,
                      showDivider: false),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

class _EmptyOrErrorWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  const _EmptyOrErrorWidget({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.inactive),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Thử lại'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
