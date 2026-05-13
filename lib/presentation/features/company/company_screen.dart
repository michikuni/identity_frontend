import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
import 'package:identity_frontend/domain/entities/company_entity.dart';
import 'package:identity_frontend/domain/usecases/company_usecase.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';

// ── BLoC (inline) ─────────────────────────────────────────────────────────────

class CompanyBloc extends Cubit<CompanyState> {
  final CompanyUseCase _useCase;
  CompanyBloc(this._useCase) : super(const CompanyState());

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      final company = await _useCase.getCompany();
      emit(state.copyWith(loading: false, company: company));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> save(Map<String, dynamic> data, {bool isNew = false}) async {
    emit(state.copyWith(saving: true));
    try {
      final company = await _useCase.saveCompany(data, isNew: isNew);
      emit(state.copyWith(saving: false, company: company, saved: true));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }
}

class CompanyState {
  final bool loading;
  final bool saving;
  final bool saved;
  final CompanyEntity? company;
  final String? error;
  const CompanyState({
    this.loading = false, this.saving = false, this.saved = false,
    this.company, this.error,
  });
  CompanyState copyWith({bool? loading, bool? saving, bool? saved, CompanyEntity? company, String? error}) =>
      CompanyState(
        loading: loading ?? this.loading, saving: saving ?? this.saving,
        saved: saved ?? false, company: company ?? this.company, error: error,
      );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class CompanyInfoScreen extends StatefulWidget {
  const CompanyInfoScreen({super.key});
  @override
  State<CompanyInfoScreen> createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends State<CompanyInfoScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CompanyBloc>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(l10n.companyTitle),
        elevation: 0,
      ),
      body: BlocBuilder<CompanyBloc, CompanyState>(
        builder: (context, state) {
          if (state.loading) return const Center(child: CircularProgressIndicator());
          if (state.company == null) {
            return _buildEmpty(context, l10n);
          }
          return _buildInfo(state.company!, l10n);
        },
      ),
    );
  }

  Widget _buildInfo(CompanyEntity c, AppLocalizations l10n) {
    final context = this.context;
    return ListView(
      padding: EdgeInsets.all(context.r(20)),
      children: [
        Container(
          padding: EdgeInsets.all(context.r(20)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(context.r(18)),
          ),
          child: Column(
            children: [
              Container(
                width: context.r(72),
                height: context.r(72),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3), width: 2),
                ),
                child: Icon(Icons.business_rounded,
                    color: Colors.white, size: context.r(36)),
              ),
              SizedBox(height: context.r(12)),
              Text(c.companyName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: context.r(18),
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center),
              SizedBox(height: context.r(4)),
              Text(l10n.companyTaxCode(c.taxCode),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: context.r(13))),
            ],
          ),
        ),
        SizedBox(height: context.r(20)),
        _infoCard(context, l10n.companyLegalInfo, Icons.gavel_rounded, [
          _row(context, l10n.companyLegalRep, c.legalRepName),
          _row(context, l10n.companyLegalRepTitle, c.legalRepTitle),
          _row(context, l10n.companyLegalRepId, c.legalRepIdNumber),
          _row(context, l10n.companyRegisteredAt, c.registeredAt),
        ]),
        SizedBox(height: context.r(14)),
        _infoCard(context, l10n.companyContact, Icons.contact_phone_rounded, [
          _row(context, l10n.companyPhone, c.phone),
          _row(context, l10n.companyEmail, c.email),
          _row(context, l10n.companyAddress, c.address, multiline: true),
        ]),
      ],
    );
  }

  Widget _infoCard(BuildContext context, String title, IconData icon,
          List<Widget> rows) =>
      Container(
        padding: EdgeInsets.all(context.r(16)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(context.r(14)),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: context.r(18), color: AppColors.primary),
              SizedBox(width: context.r(8)),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: context.r(14))),
            ]),
            SizedBox(height: context.r(12)),
            const Divider(height: 1),
            ...rows,
          ],
        ),
      );

  Widget _row(BuildContext context, String label, String value,
          {bool multiline = false}) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: context.r(10)),
        child: Row(
          crossAxisAlignment:
              multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: context.r(130),
              child: Text(label,
                  style: TextStyle(
                      fontSize: context.r(13),
                      color: AppColors.textSecondary)),
            ),
            Expanded(
                child: Text(value,
                    style: TextStyle(
                        fontSize: context.r(13),
                        fontWeight: FontWeight.w500))),
          ],
        ),
      );

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.business_outlined,
              size: context.r(64), color: AppColors.inactive),
          SizedBox(height: context.r(16)),
          Text(l10n.companyEmpty,
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: context.r(14))),
          SizedBox(height: context.r(8)),
          Text(l10n.companyEmptyHint,
              style: TextStyle(
                  fontSize: context.r(12), color: AppColors.textHint)),
        ]),
      );
}
