import 'package:flutter/material.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';

enum BadgeType { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const StatusBadge({super.key, required this.label, required this.type});

  factory StatusBadge.fromStatus(String status) {
    final type = switch (status.toUpperCase()) {
      'ACTIVE' || 'SUCCESS' || 'VERIFIED' || 'PERMANENT' => BadgeType.success,
      'INACTIVE' || 'DELETED' || 'FAILED' => BadgeType.error,
      'PENDING' || 'PROBATION' => BadgeType.warning,
      'PART_TIME' || 'FIXED_TERM' => BadgeType.info,
      _ => BadgeType.neutral,
    };
    return StatusBadge(label: status.titleCase, type: type);
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      BadgeType.success => (AppColors.successLight, AppColors.success),
      BadgeType.warning => (AppColors.warningLight, AppColors.warning),
      BadgeType.error   => (AppColors.errorLight, AppColors.error),
      BadgeType.info    => (AppColors.infoLight, AppColors.info),
      BadgeType.neutral => (AppColors.surfaceVariant, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: AppColors.error, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension _StringExt on String {
  String get titleCase => split('_').map((w) {
        if (w.isEmpty) return w;
        return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
      }).join(' ');
}
