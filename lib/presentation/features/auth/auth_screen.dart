import 'package:flutter/material.dart';
import 'package:identity_frontend/core/themes/app_theme.dart';
import 'package:identity_frontend/presentation/widgets/input_field.dart';
import 'package:identity_frontend/presentation/widgets/primary_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Icon(Icons.language, color: AppTheme.primaryColor, size: 24),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ],
        actionsPadding: EdgeInsets.only(right: 24),
      ),
      bottomSheet: Text(
        'Phiên bản 3.0.0',
        style: TextStyle(color: AppTheme.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Chào mừng quay lại",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 24),

            AppInput(hint: "Email", controller: emailCtrl),
            const SizedBox(height: 12),
            AppInput(hint: "Mật khẩu", controller: passCtrl, isPassword: true),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Quên mật khẩu?',
                  style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                ),
              ],
            ),

            const SizedBox(height: 12),

            PrimaryButton(
              title: "Đăng nhập",
              onPressed: () {
                Navigator.pushNamed(context, '/kyc-welcome');
              },
            ),

            const SizedBox(height: 36),
            const Divider(height: 1, indent: 24),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bạn chưa có tài khoản?',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero
                  ),
                  onPressed: () {},
                  child: Text(
                    'Đăng ký',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
