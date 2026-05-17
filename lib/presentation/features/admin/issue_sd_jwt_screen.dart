import 'package:flutter/material.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/l10n/l10n.dart';

/// Issue SD-JWT Screen — Admin issues Skill or Education SD-JWT for an employee.
///
/// POST /api/v1/sd-jwt/issue/skill/{employeeId}
/// POST /api/v1/sd-jwt/issue/education/{employeeId}
class IssueSdJwtScreen extends StatefulWidget {
  final String employeeId;
  final String? employeeName;

  const IssueSdJwtScreen({
    super.key,
    required this.employeeId,
    this.employeeName,
  });

  @override
  State<IssueSdJwtScreen> createState() => _IssueSdJwtScreenState();
}

class _IssueSdJwtScreenState extends State<IssueSdJwtScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _submitting = false;
  String? _issuedJwt;
  String? _error;

  // Skill tab
  final List<_SkillRow> _skills = [_SkillRow()];

  // Education tab
  final _degreeCtrl      = TextEditingController();
  final _majorCtrl       = TextEditingController();
  final _universityCtrl  = TextEditingController();
  final _gradYearCtrl    = TextEditingController();
  final _gpaCtrl         = TextEditingController();
  final _honorsCtrl      = TextEditingController();

  static const _levels = ['ADVANCED', 'INTERMEDIATE', 'BEGINNER'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    _degreeCtrl.dispose();
    _majorCtrl.dispose();
    _universityCtrl.dispose();
    _gradYearCtrl.dispose();
    _gpaCtrl.dispose();
    _honorsCtrl.dispose();
    super.dispose();
  }

  Future<void> _issueSkill() async {
    final skills = <String, String>{};
    for (final row in _skills) {
      final name = row.nameCtrl.text.trim();
      if (name.isNotEmpty) skills[name] = row.level;
    }
    if (skills.isEmpty) return;

    setState(() { _submitting = true; _error = null; _issuedJwt = null; });
    try {
      final res = await ApiClient.instance.post(
        ApiConstants.sdJwtIssueSkill(widget.employeeId),
        data: {'skills': skills},
      );
      final jwt = res.data['data']?['sdJwt'] as String?;
      setState(() { _issuedJwt = jwt; _submitting = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _submitting = false; });
    }
  }

  Future<void> _issueEducation() async {
    setState(() { _submitting = true; _error = null; _issuedJwt = null; });
    try {
      final res = await ApiClient.instance.post(
        ApiConstants.sdJwtIssueEducation(widget.employeeId),
        data: {
          'degree':         _degreeCtrl.text.trim(),
          'major':          _majorCtrl.text.trim(),
          'university':     _universityCtrl.text.trim(),
          'graduationYear': _gradYearCtrl.text.trim(),
          'gpa':            _gpaCtrl.text.trim(),
          'honors':         _honorsCtrl.text.trim(),
        },
      );
      final jwt = res.data['data']?['sdJwt'] as String?;
      setState(() { _issuedJwt = jwt; _submitting = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _submitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.sdJwtIssueTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            if (widget.employeeName != null)
              Text(widget.employeeName!,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(icon: const Icon(Icons.psychology_outlined), text: context.l10n.sdJwtSkillTab),
            Tab(icon: const Icon(Icons.school_outlined), text: context.l10n.sdJwtEducationTab),
          ],
        ),
      ),
      body: _issuedJwt != null
          ? _buildSuccess()
          : TabBarView(
              controller: _tab,
              children: [_buildSkillTab(), _buildEducationTab()],
            ),
    );
  }

  Widget _buildSkillTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SdJwtInfoBanner(
          title: context.l10n.sdJwtSkillBannerTitle,
          subtitle: context.l10n.sdJwtSkillBannerSubtitle,
          color: const Color(0xFF7C3AED),
        ),
        const SizedBox(height: 16),
        ..._skills.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SkillInputRow(
              row: row,
              levels: _levels,
              canRemove: _skills.length > 1,
              onRemove: () => setState(() => _skills.removeAt(i)),
            ),
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: Text(context.l10n.sdJwtAddSkill),
          onPressed: () => setState(() => _skills.add(_SkillRow())),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
        ],
        const SizedBox(height: 16),
        _IssueButton(
          label: context.l10n.sdJwtIssueSkillBtn,
          loading: _submitting,
          onPressed: _issueSkill,
          color: const Color(0xFF7C3AED),
        ),
      ],
    );
  }

  Widget _buildEducationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SdJwtInfoBanner(
          title: context.l10n.sdJwtEducBannerTitle,
          subtitle: context.l10n.sdJwtEducBannerSubtitle,
          color: const Color(0xFF0891B2),
        ),
        const SizedBox(height: 16),
        _field('Degree', _degreeCtrl, hint: 'Bachelor of Science'),
        _field('Major', _majorCtrl, hint: 'Computer Science'),
        _field('University', _universityCtrl, hint: 'Hanoi University of Science'),
        _field('Graduation Year', _gradYearCtrl,
            hint: '2024', keyboard: TextInputType.number),
        _field('GPA', _gpaCtrl, hint: '3.8/4.0'),
        _field('Honors', _honorsCtrl, hint: 'Magna Cum Laude'),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
        ],
        const SizedBox(height: 16),
        _IssueButton(
          label: context.l10n.sdJwtIssueEducBtn,
          loading: _submitting,
          onPressed: _issueEducation,
          color: const Color(0xFF0891B2),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String? hint, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
          const SizedBox(height: 16),
          Text(context.l10n.sdJwtIssued,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.success)),
          const SizedBox(height: 8),
          Text(context.l10n.sdJwtIssuedMsg,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: SelectableText(
              _issuedJwt!.length > 120
                  ? '${_issuedJwt!.substring(0, 120)}…'
                  : _issuedJwt!,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.done),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() { _issuedJwt = null; _error = null; }),
            child: Text(context.l10n.sdJwtIssueAnother),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────────

class _SkillRow {
  final nameCtrl = TextEditingController();
  String level = 'INTERMEDIATE';
}

class _SkillInputRow extends StatefulWidget {
  final _SkillRow row;
  final List<String> levels;
  final bool canRemove;
  final VoidCallback onRemove;

  const _SkillInputRow({
    required this.row,
    required this.levels,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  State<_SkillInputRow> createState() => _SkillInputRowState();
}

class _SkillInputRowState extends State<_SkillInputRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: widget.row.nameCtrl,
            decoration: InputDecoration(
              hintText: context.l10n.sdJwtSkillNameHint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: widget.row.level,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: widget.levels
                .map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 12))))
                .toList(),
            onChanged: (v) => setState(() => widget.row.level = v ?? widget.row.level),
          ),
        ),
        if (widget.canRemove) ...[
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
            onPressed: widget.onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ],
    );
  }
}

class _SdJwtInfoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _SdJwtInfoBanner({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  final Color color;

  const _IssueButton({
    required this.label,
    required this.loading,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
