import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/themes/theme_cubit.dart';
import 'package:identity_frontend/l10n/l10n.dart';

class ThemeSettingScreen extends StatelessWidget {
  const ThemeSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.themeTitle)),
      body: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, current) {
          final l10n = context.l10n;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ThemeOption(
                label: l10n.themeLight,
                icon: Icons.light_mode_outlined,
                selected: current == ThemeMode.light,
                onTap: () => context.read<ThemeCubit>().setMode(ThemeMode.light),
              ),
              const SizedBox(height: 12),
              _ThemeOption(
                label: l10n.themeDark,
                icon: Icons.dark_mode_outlined,
                selected: current == ThemeMode.dark,
                onTap: () => context.read<ThemeCubit>().setMode(ThemeMode.dark),
              ),
              const SizedBox(height: 12),
              _ThemeOption(
                label: l10n.themeSystem,
                icon: Icons.brightness_auto_outlined,
                selected: current == ThemeMode.system,
                onTap: () => context.read<ThemeCubit>().setMode(ThemeMode.system),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? cs.primary : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
          color: selected ? cs.primary.withValues(alpha: 0.08) : cs.surface,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: selected ? cs.primary : null,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: cs.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
