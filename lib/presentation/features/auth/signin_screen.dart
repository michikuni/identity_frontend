import 'package:flutter/material.dart';
import 'package:identity_frontend/core/themes/app_theme.dart';
import 'package:identity_frontend/presentation/widgets/input_field.dart';
import 'package:identity_frontend/presentation/widgets/primary_button.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios_new_rounded),
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
      bottomSheet: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        color: Colors.white,
        child: Text(
          'Phiên bản 3.0.0',
          style: TextStyle(color: AppTheme.textPrimary),
          textAlign: TextAlign.center,
        ),
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
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {
                    Navigator.pushNamed(context, '/sign-up');
                  },
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
