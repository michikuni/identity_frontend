import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/domain/entities/profile_entity.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/features/profile/bloc/profile_bloc.dart';
import 'package:identity_frontend/presentation/widgets/app_card.dart';
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
            return const LoadingWidget(message: 'Loading profile...');
          }
          if (state.status == ProfileStatus.failure) {
            return ErrorStateWidget(
              message: state.errorMessage ?? 'Failed to load profile',
              onRetry: () => context.read<ProfileBloc>().add(const ProfileFetch()),
            );
          }
          if (state.profile == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_off_outlined, size: 56, color: AppColors.inactive),
                  const SizedBox(height: 12),
                  Text(l10n.profileNoData,
                      style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return _buildContent(context, l10n, state.profile!);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, ProfileEntity p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Avatar header ──────────────────────────────────────────────
          GradientCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(p.email,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Personal Info ──────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: l10n.profilePersonalInfo, icon: Icons.person_outline_rounded),
                InfoRow(label: l10n.profileName, value: p.name),
                InfoRow(label: l10n.profileGender, value: _genderLabel(p.gender, l10n)),
                InfoRow(label: l10n.profileDOB, value: p.dateOfBirth ?? '—'),
                InfoRow(label: l10n.profilePhone, value: p.phone),
                InfoRow(label: l10n.profileEmail, value: p.email, showDivider: false),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Identity ──────────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: l10n.profileIdentity, icon: Icons.badge_outlined),
                InfoRow(label: l10n.profileIdentityType, value: p.identityType),
                InfoRow(label: l10n.profileIdentityNumber, value: p.identityNumber),
                if (p.identityIssuePlace != null)
                  InfoRow(label: l10n.profileIdentityIssuePlace, value: p.identityIssuePlace!, showDivider: false),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Emergency Contact ─────────────────────────────────────────
          if (p.emergencyName != null || p.emergencyPhone != null)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: l10n.profileEmergency, icon: Icons.emergency_outlined),
                  if (p.emergencyName != null)
                    InfoRow(label: l10n.profileEmergencyName, value: p.emergencyName!),
                  if (p.emergencyPhone != null)
                    InfoRow(label: l10n.profileEmergencyPhone, value: p.emergencyPhone!),
                  if (p.emergencyRelationship != null)
                    InfoRow(label: l10n.profileEmergencyRelationship, value: p.emergencyRelationship!, showDivider: false),
                ],
              ),
            ),
          if (p.emergencyName != null) const SizedBox(height: 12),

          // ── Residence ─────────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: l10n.profileResidence, icon: Icons.home_outlined),
                if (p.permanentResidence != null)
                  InfoRow(label: l10n.profilePermanentResidence, value: p.permanentResidence!),
                if (p.nowResidence != null)
                  InfoRow(label: l10n.profileNowResidence, value: p.nowResidence!, showDivider: false)
                else
                  InfoRow(label: l10n.profileNowResidence, value: '—', showDivider: false),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Education & Skills ────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: l10n.profileEducation, icon: Icons.school_outlined),
                if (p.educationLevel != null)
                  InfoRow(label: l10n.profileEducationLevel, value: p.educationLevel!),
                if (p.major != null)
                  InfoRow(label: l10n.profileMajor, value: p.major!),
                if (p.expYears != null)
                  InfoRow(label: l10n.profileExpYears, value: '${p.expYears}'),
                if (p.skillSet != null && p.skillSet!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(l10n.profileSkills,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.skillSet!
                        .map((s) => Chip(label: Text(s)))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
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
