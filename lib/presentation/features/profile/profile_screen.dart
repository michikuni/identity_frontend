import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/core/utils/extensions.dart';
import 'package:identity_frontend/domain/entities/profile_entity.dart';
import 'package:identity_frontend/domain/usecases/employee_usecase.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/features/cccd/cccd_scan_screen.dart';
import 'package:identity_frontend/presentation/features/onboarding/profile_onboarding_screen.dart';
import 'package:identity_frontend/presentation/features/profile/bloc/profile_bloc.dart';
import 'package:identity_frontend/presentation/widgets/app_card.dart';
import 'package:identity_frontend/presentation/widgets/app_input.dart';
import 'package:identity_frontend/presentation/widgets/info_row.dart';
import 'package:identity_frontend/presentation/widgets/status_badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(profileUseCase: sl())..add(const ProfileFetch()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return LoadingWidget(message: l10n.profileLoading);
          }
          if (state.status == ProfileStatus.failure || state.profile == null) {
            return _NoProfileView(
              onCreated: () => context.read<ProfileBloc>().add(const ProfileFetch()),
            );
          }
          return _buildContent(context, l10n, state.profile!);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, ProfileEntity p) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.r(16)),
      child: Column(
        children: [
          GradientCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: context.r(30),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                    style: TextStyle(
                        fontSize: context.r(24),
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
                SizedBox(width: context.r(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: context.r(18),
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: context.r(4)),
                      Text(p.email,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: context.r(13))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.r(16)),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionHeader(title: l10n.profilePersonalInfo, icon: Icons.person_outline_rounded),
              InfoRow(label: l10n.profileName, value: p.name),
              InfoRow(label: l10n.profileGender, value: _genderLabel(p.gender, l10n)),
              InfoRow(label: l10n.profileDOB, value: p.dateOfBirth ?? '—'),
              InfoRow(label: l10n.profilePhone, value: p.phone),
              InfoRow(label: l10n.profileEmail, value: p.email, showDivider: false),
            ]),
          ),
          SizedBox(height: context.r(12)),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionHeader(title: l10n.profileIdentity, icon: Icons.badge_outlined),
              InfoRow(label: l10n.profileIdentityType, value: p.identityType),
              InfoRow(label: l10n.profileIdentityNumber, value: p.identityNumber),
              if (p.identityIssuePlace != null)
                InfoRow(
                    label: l10n.profileIdentityIssuePlace,
                    value: p.identityIssuePlace!,
                    showDivider: false),
            ]),
          ),
          SizedBox(height: context.r(12)),
          if (p.emergencyName != null || p.emergencyPhone != null) ...[
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SectionHeader(title: l10n.profileEmergency, icon: Icons.emergency_outlined),
                if (p.emergencyName != null)
                  InfoRow(label: l10n.profileEmergencyName, value: p.emergencyName!),
                if (p.emergencyPhone != null)
                  InfoRow(label: l10n.profileEmergencyPhone, value: p.emergencyPhone!),
                if (p.emergencyRelationship != null)
                  InfoRow(
                      label: l10n.profileEmergencyRelationship,
                      value: p.emergencyRelationship!,
                      showDivider: false),
              ]),
            ),
            SizedBox(height: context.r(12)),
          ],
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionHeader(title: l10n.profileResidence, icon: Icons.home_outlined),
              if (p.permanentResidence != null)
                InfoRow(label: l10n.profilePermanentResidence, value: p.permanentResidence!),
              InfoRow(
                  label: l10n.profileNowResidence,
                  value: p.nowResidence ?? '—',
                  showDivider: false),
            ]),
          ),
          SizedBox(height: context.r(12)),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionHeader(title: l10n.profileEducation, icon: Icons.school_outlined),
              if (p.educationLevel != null)
                InfoRow(label: l10n.profileEducationLevel, value: p.educationLevel!),
              if (p.major != null) InfoRow(label: l10n.profileMajor, value: p.major!),
              if (p.expYears != null) InfoRow(label: l10n.profileExpYears, value: '${p.expYears}'),
              if (p.skillSet != null && p.skillSet!.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.only(top: context.r(10)),
                  child: Text(l10n.profileSkills,
                      style: TextStyle(
                          fontSize: context.r(13), color: AppColors.textSecondary)),
                ),
                SizedBox(height: context.r(8)),
                Wrap(
                  spacing: context.r(8),
                  runSpacing: context.r(8),
                  children: p.skillSet!.map((s) => Chip(label: Text(s))).toList(),
                ),
              ],
            ]),
          ),
          SizedBox(height: context.r(24)),
        ],
      ),
    );
  }

  String _genderLabel(String gender, AppLocalizations l10n) {
    return switch (gender.toUpperCase()) {
      'MALE' => l10n.statusMale,
      'FEMALE' => l10n.statusFemale,
      _ => gender,
    };
  }
}

// ── No Profile State ─────────────────────────────────────────────────────────

class _NoProfileView extends StatelessWidget {
  final VoidCallback onCreated;
  const _NoProfileView({required this.onCreated});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.r(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(context.r(20)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_add_outlined,
                  size: context.r(48), color: AppColors.primary),
            ),
            SizedBox(height: context.r(20)),
            Text(AppLocalizations.of(context)!.profileNoData,
                style: TextStyle(
                    fontSize: context.r(18), fontWeight: FontWeight.w700)),
            SizedBox(height: context.r(8)),
            Text(
              AppLocalizations.of(context)!.profileSetupHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: context.r(14)),
            ),
            SizedBox(height: context.r(28)),
            ElevatedButton.icon(
              icon: Icon(Icons.edit_outlined, size: context.r(18)),
              label: Text(AppLocalizations.of(context)!.profileSetup),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: context.r(28), vertical: context.r(14)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.r(12))),
              ),
              onPressed: () => _showSetupSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSetupSheet(BuildContext context) async {
    bool workDone = false;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSetupSheet(onWorkDone: () => workDone = true),
    );
    if (!context.mounted || !workDone) return;

    // Bước 2: quét QR CCCD
    final cccdData = await Navigator.push<CccdData?>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (routeCtx) => CccdScanScreen(
          onScanned: (data) => Navigator.of(routeCtx).pop(data),
          onSkip: () => Navigator.of(routeCtx).pop(null),
        ),
      ),
    );
    if (!context.mounted) return;

    // Bước 3: nhập thông tin cá nhân (giống luồng onboarding)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileOnboardingScreen(
          cccdData: cccdData,
          onSuccess: onCreated,
        ),
      ),
    );
  }
}

// ── Profile Setup Bottom Sheet ────────────────────────────────────────────────

class _ProfileSetupSheet extends StatefulWidget {
  final VoidCallback onWorkDone;
  const _ProfileSetupSheet({required this.onWorkDone});

  @override
  State<_ProfileSetupSheet> createState() => _ProfileSetupSheetState();
}

class _ProfileSetupSheetState extends State<_ProfileSetupSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _submittingWork = false;
  bool _employeeExists = false;
  bool _loadingEmployee = true;

  final _deptCtrl = TextEditingController();
  final _posCtrl = TextEditingController();
  String _workingType = 'FULL_TIME';

  @override
  void initState() {
    super.initState();
    _loadExistingEmployee();
  }

  Future<void> _loadExistingEmployee() async {
    try {
      final employee = await sl<EmployeeUseCase>().getEmployee();
      if (mounted) {
        setState(() {
          _employeeExists = true;
          _deptCtrl.text = employee.department;
          _posCtrl.text = employee.position;
          _workingType = employee.workingType;
          _loadingEmployee = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingEmployee = false);
    }
  }

  @override
  void dispose() {
    _deptCtrl.dispose();
    _posCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitWork() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _submittingWork = true);
    try {
      final email = await SecureStorage.getUserEmail() ?? '';
      if (_employeeExists) {
        await sl<EmployeeUseCase>().updateEmployee({
          'department': _deptCtrl.text.trim(),
          'position': _posCtrl.text.trim(),
          'status': 'ACTIVE',
          'workingType': _workingType,
          'isActive': true,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        await sl<EmployeeUseCase>().createEmployee({
          'department': _deptCtrl.text.trim(),
          'position': _posCtrl.text.trim(),
          'status': 'ACTIVE',
          'workingType': _workingType,
          'isActive': true,
          'createdBy': email,
        });
      }
      if (mounted) {
        Navigator.pop(context);
        widget.onWorkDone();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submittingWork = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(context.r(20))),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: context.r(12), bottom: context.r(8)),
              width: context.r(40),
              height: context.r(4),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(context.r(2)),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(context.r(24), context.r(4), context.r(24), 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.profileStep1,
                    style: TextStyle(fontSize: context.r(16), fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: context.r(8)),
                  LinearProgressIndicator(
                    value: 0.33,
                    backgroundColor: AppColors.border,
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(context.r(4)),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.r(8)),
            Expanded(
              child: _loadingEmployee
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      controller: scrollCtrl,
                      padding: EdgeInsets.fromLTRB(
                          context.r(24), context.r(12), context.r(24), context.r(32)),
                      child: Form(
                        key: _formKey,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          AppInput(
                            label: AppLocalizations.of(context)!.profileDepartmentLabel,
                            hint: AppLocalizations.of(context)!.profileDepartmentHint,
                            controller: _deptCtrl,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? AppLocalizations.of(context)!.profileRequired
                                : null,
                            prefixIcon: Icon(Icons.business_outlined,
                                size: context.r(20), color: AppColors.inactive),
                          ),
                          SizedBox(height: context.r(14)),
                          AppInput(
                            label: AppLocalizations.of(context)!.profilePositionLabel,
                            hint: AppLocalizations.of(context)!.profilePositionHint,
                            controller: _posCtrl,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? AppLocalizations.of(context)!.profileRequired
                                : null,
                            prefixIcon: Icon(Icons.badge_outlined,
                                size: context.r(20), color: AppColors.inactive),
                          ),
                          SizedBox(height: context.r(14)),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(AppLocalizations.of(context)!.profileWorkingTypeLabel,
                                style: TextStyle(
                                    fontSize: context.r(13),
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary)),
                            SizedBox(height: context.r(6)),
                            DropdownButtonFormField<String>(
                              initialValue: _workingType,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.schedule_outlined,
                                    size: context.r(20), color: AppColors.inactive),
                              ),
                              items: [
                                DropdownMenuItem(
                                    value: 'FULL_TIME',
                                    child: Text(AppLocalizations.of(context)!.chiefFullTime)),
                                DropdownMenuItem(
                                    value: 'PART_TIME',
                                    child: Text(AppLocalizations.of(context)!.chiefPartTime)),
                              ],
                              onChanged: (v) => setState(() => _workingType = v ?? 'FULL_TIME'),
                            ),
                          ]),
                          SizedBox(height: context.r(28)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: context.r(14)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(context.r(12))),
                            ),
                            onPressed: _submittingWork ? null : _submitWork,
                            child: _submittingWork
                                ? SizedBox(
                                    width: context.r(20),
                                    height: context.r(20),
                                    child: const CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : Text(AppLocalizations.of(context)!.profileNext,
                                    style: TextStyle(
                                        fontSize: context.r(15), fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
