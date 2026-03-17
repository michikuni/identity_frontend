import 'package:flutter/material.dart';
import 'package:identity_frontend/core/themes/app_theme.dart';
import 'package:identity_frontend/presentation/widgets/input_field.dart';
import 'package:identity_frontend/presentation/widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: Icon(Icons.arrow_back_ios_new_rounded),),
      body: Padding(padding: EdgeInsets.all(24), child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
              "Bắt đầu đăng ký",
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
            AppInput(hint: "Xác nhận mật khẩu", controller: passCtrl, isPassword: true),

            const SizedBox(height: 24),

            PrimaryButton(
              title: "Đăng ký",
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
                  'Đã có tài khoản? ',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Đăng nhập',
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
      ),),
    );
  }
}