import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/presentation/widgets/primary_button.dart';
import 'bloc/request_bloc.dart';
import 'bloc/request_event.dart';
import 'bloc/request_state.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'LEAVE';
  String? _session = 'FULL_DAY';
  final _reasonCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  static const _types = [
    ('LEAVE', 'Nghỉ phép', Icons.beach_access_rounded),
    ('ATTENDANCE_CORRECTION', 'Sửa chấm công', Icons.edit_calendar_rounded),
    ('WFH', 'Làm tại nhà', Icons.home_work_rounded),
    ('BUSINESS_TRIP', 'Công tác', Icons.flight_rounded),
  ];

  static const _sessions = [
    ('FULL_DAY', 'Cả ngày'),
    ('MORNING', 'Buổi sáng'),
    ('AFTERNOON', 'Buổi chiều'),
  ];

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate == null || _endDate!.isBefore(picked)) _endDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày'), backgroundColor: AppColors.error),
      );
      return;
    }
    context.read<RequestBloc>().add(RequestCreate({
      'requestType': _type,
      'startDate': _startDate!.toIso8601String().substring(0, 10),
      'endDate': _endDate!.toIso8601String().substring(0, 10),
      if (_type == 'LEAVE') 'session': _session,
      'reason': _reasonCtrl.text.trim(),
    }));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RequestBloc, RequestState>(
      listener: (context, state) {
        if (state.actionSuccess) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tạo đơn thành công'), backgroundColor: AppColors.success),
          );
        } else if (state.status == RequestStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Lỗi'), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Tạo đơn'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Type selector
              _sectionLabel('Loại đơn'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _types.map((t) {
                  final selected = _type == t.$1;
                  return ChoiceChip(
                    selected: selected,
                    label: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(t.$3, size: 15, color: selected ? Colors.white : AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(t.$2),
                    ]),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
                    onSelected: (_) => setState(() => _type = t.$1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Date range
              _sectionLabel('Ngày'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _datePicker('Từ ngày', _startDate, () => _pickDate(true))),
                  const SizedBox(width: 12),
                  Expanded(child: _datePicker('Đến ngày', _endDate, () => _pickDate(false))),
                ],
              ),
              const SizedBox(height: 20),

              // Session (only for LEAVE)
              if (_type == 'LEAVE') ...[
                _sectionLabel('Buổi'),
                const SizedBox(height: 10),
                Row(
                  children: _sessions.map((s) {
                    final sel = _session == s.$1;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _session = s.$1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                            ),
                            child: Text(s.$2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: sel ? Colors.white : AppColors.textPrimary)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Reason
              _sectionLabel('Lý do'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reasonCtrl,
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập lý do' : null,
                decoration: const InputDecoration(
                  hintText: 'Nhập lý do...',
                  hintStyle: TextStyle(color: AppColors.textHint),
                ),
              ),
              const SizedBox(height: 32),

              BlocBuilder<RequestBloc, RequestState>(
                builder: (context, state) => PrimaryButton(
                  title: 'Gửi đơn',
                  isLoading: state.status == RequestStatus.loading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textSecondary),
      );

  Widget _datePicker(String label, DateTime? date, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.inactive),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  date != null ? '${date.day}/${date.month}/${date.year}' : label,
                  style: TextStyle(
                    fontSize: 13,
                    color: date != null ? AppColors.textPrimary : AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
