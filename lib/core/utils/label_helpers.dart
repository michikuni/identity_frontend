import 'package:identity_frontend/l10n/app_localizations.dart';

String workingTypeLabel(AppLocalizations l10n, String? value) =>
    switch (value) {
      'FULL_TIME' => l10n.statusFullTime,
      'PART_TIME' => l10n.statusPartTime,
      _ => value ?? '',
    };

String roleLabel(AppLocalizations l10n, String? value) => switch (value) {
      'ADMIN' => l10n.roleAdmin,
      'CHIEF' => l10n.roleChief,
      'MANAGER' => l10n.roleManager,
      _ => l10n.roleEmployee,
    };
