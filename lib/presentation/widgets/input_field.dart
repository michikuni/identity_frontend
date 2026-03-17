import 'package:flutter/material.dart';
import 'package:identity_frontend/core/themes/app_theme.dart';

class AppInput extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController controller;

  const AppInput({
    super.key,
    required this.hint,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.textPrimary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}