import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/date_format.dart';
import 'package:identity_frontend/domain/entities/payroll_entity.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/features/payroll/bloc/payroll_bloc.dart';
import 'package:identity_frontend/presentation/widgets/app_card.dart';
import 'package:identity_frontend/presentation/widgets/info_row.dart';
import 'package:identity_frontend/presentation/widgets/status_badge.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PayrollBloc(payrollUseCase: sl())..add(const PayrollFetch()),
      child: const _PayrollView(),
    );
  }
}

class _PayrollView extends StatelessWidget {
  const _PayrollView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.payrollTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border)),
      ),
      body: BlocBuilder<PayrollBloc, PayrollState>(
        builder: (context, state) {
          if (state.status == PayrollStatus.loading) {
            return LoadingWidget(message: l10n.payrollLoading);
          }
          if (state.status == PayrollStatus.failure || state.payroll == null) {
            return _EmptyOrErrorWidget(
              icon: Icons.payments_outlined,
              message: l10n.payrollNoDataRetry,
              onRetry: () => context.read<PayrollBloc>().add(const PayrollFetch()),
            );
          }
          return _buildContent(l10n, state.payroll!);
        },
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, PayrollEntity p) {
    final currency = p.currency ?? 'VND';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Total Income card ──────────────────────────────────────────
          GradientCard(
            gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.payrollTotal,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                    StatusBadge.fromStatus(p.salaryType),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _fmtCurrency(p.totalIncome ?? p.baseSalary, currency),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                ),
                if (p.payDay != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.payrollPayDay}: ${_fmtDate(p.payDay)}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Salary Breakdown ───────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: l10n.payrollBreakdown, icon: Icons.account_balance_outlined),
                InfoRow(label: l10n.payrollSalaryType, value: p.salaryType),
                InfoRow(label: l10n.payrollBaseSalary, value: _fmtCurrency(p.baseSalary, currency)),
                if (p.bonusSalary != null && p.bonusSalary! > 0)
                  InfoRow(label: l10n.payrollBonus, value: _fmtCurrency(p.bonusSalary!, currency)),
                if (p.overTimeRate != null && p.overTimeRate! > 0)
                  InfoRow(
                      label: l10n.payrollOvertime,
                      value: _fmtCurrency(p.overTimeRate!, currency),
                      showDivider: false),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Bank Info ──────────────────────────────────────────────────
          if (p.bankAccountNumber != null)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: l10n.payrollBank, icon: Icons.credit_card_outlined),
                  if (p.bankName != null)
                    InfoRow(label: l10n.payrollBankNameInst, value: p.bankName!),
                  if (p.bankAccountName != null)
                    InfoRow(label: l10n.payrollBankName_label, value: p.bankAccountName!),
                  InfoRow(
                      label: l10n.payrollBankAccount,
                      value: p.bankAccountNumber!,
                      showDivider: false),
                  if (p.bankBranch != null)
                    InfoRow(
                        label: l10n.payrollBankBranch,
                        value: p.bankBranch!,
                        showDivider: false),
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _fmtCurrency(double amount, String currency) {
    final parts = amount.toStringAsFixed(0).split('');
    final buf = StringBuffer();
    int count = 0;
    for (int i = parts.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(',');
      buf.write(parts[i]);
      count++;
    }
    return '${buf.toString().split('').reversed.join()} $currency';
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    return formatDateOf(dt);
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
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
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
              label: Text(l10n.retry),
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
