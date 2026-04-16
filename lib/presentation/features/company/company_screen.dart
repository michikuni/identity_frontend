import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/domain/entities/company_entity.dart';
import 'package:identity_frontend/domain/usecases/company_usecase.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Thông tin công ty'),
        elevation: 0,
      ),
      body: BlocBuilder<CompanyBloc, CompanyState>(
        builder: (context, state) {
          if (state.loading) return const Center(child: CircularProgressIndicator());
          if (state.company == null) {
            return _buildEmpty(context);
          }
          return _buildInfo(state.company!);
        },
      ),
    );
  }

  Widget _buildInfo(CompanyEntity c) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Hero banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Icon(Icons.business_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 12),
                Text(c.companyName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text('MST: ${c.taxCode}', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _infoCard('Thông tin pháp nhân', Icons.gavel_rounded, [
            _row('Người đại diện', c.legalRepName),
            _row('Chức danh', c.legalRepTitle),
            _row('CCCD/CMND', c.legalRepIdNumber),
            _row('Ngày đăng ký', c.registeredAt),
          ]),
          const SizedBox(height: 14),

          _infoCard('Liên hệ', Icons.contact_phone_rounded, [
            _row('Điện thoại', c.phone),
            _row('Email', c.email),
            _row('Địa chỉ', c.address, multiline: true),
          ]),
        ],
      );

  Widget _infoCard(String title, IconData icon, List<Widget> rows) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ]),
            const SizedBox(height: 12),
            const Divider(height: 1),
            ...rows,
          ],
        ),
      );

  Widget _row(String label, String value, {bool multiline = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          ],
        ),
      );

  Widget _buildEmpty(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.business_outlined, size: 64, color: AppColors.inactive),
          const SizedBox(height: 16),
          const Text('Chưa có thông tin công ty', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('Giám đốc có thể đăng ký pháp nhân', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
        ]),
      );
}
