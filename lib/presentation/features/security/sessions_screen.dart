import 'package:flutter/material.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/l10n/l10n.dart';

/// Sessions Screen — quản lý active devices / sessions.
///
/// GET  /api/v1/sessions            → danh sách active sessions
/// DELETE /api/v1/sessions/{deviceId} → logout 1 device
/// DELETE /api/v1/sessions?keepCurrent=true → logout tất cả trừ thiết bị này
class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _sessions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.get(ApiConstants.sessions);
      final list = (res.data['data'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      setState(() {
        _sessions = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _logoutDevice(String deviceId) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.sessionsLogoutDeviceTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(l10n.sessionsLogoutDeviceContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.sessionsLogoutBtn),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiClient.instance.delete(ApiConstants.sessionsDevice(deviceId));
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.sessionsFailed(e.toString())),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _logoutAllOthers() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.sessionsLogoutAllTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(l10n.sessionsLogoutAllContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.sessionsLogoutAllBtn),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiClient.instance.delete(
        ApiConstants.sessions,
        queryParameters: {'keepCurrent': 'true'},
      );
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.sessionsFailed(e.toString())),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(context.l10n.sessionsTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _sessions.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.devices_outlined, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(context.l10n.sessionsNoActive, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._sessions.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SessionTile(
              session: s,
              isCurrent: i == 0,
              onLogout: () => _logoutDevice(s['deviceId']?.toString() ?? ''),
            ),
          );
        }),
        const SizedBox(height: 8),
        if (_sessions.length > 1)
          OutlinedButton.icon(
            icon: const Icon(Icons.logout, size: 18, color: AppColors.error),
            label: Text(context.l10n.sessionsLogoutAllTitle,
                style: const TextStyle(color: AppColors.error)),
            onPressed: _logoutAllOthers,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Map<String, dynamic> session;
  final bool isCurrent;
  final VoidCallback onLogout;

  const _SessionTile({
    required this.session,
    required this.isCurrent,
    required this.onLogout,
  });

  IconData _platformIcon(String? platform) {
    return switch (platform?.toLowerCase()) {
      'ios'     => Icons.phone_iphone_rounded,
      'android' => Icons.phone_android_rounded,
      'web'     => Icons.web_rounded,
      _         => Icons.devices_rounded,
    };
  }

  String _relativeTime(String? iso) {
    if (iso == null) return 'Unknown';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final platform = session['devicePlatform'] as String?;
    final deviceName = session['deviceName'] as String? ?? 'Unknown Device';
    final lastSeen = session['lastSeen'] as String?;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(_platformIcon(platform),
                color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(deviceName,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    if (isCurrent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(context.l10n.sessionsThisDevice,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(context.l10n.sessionsLastSeen(_relativeTime(lastSeen)),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (!isCurrent)
            TextButton(
              onPressed: onLogout,
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(context.l10n.sessionsLogoutBtn, style: const TextStyle(fontSize: 13)),
            ),
        ],
      ),
    );
  }
}
