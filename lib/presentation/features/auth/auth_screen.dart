import 'package:flutter/material.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 80),

            const Text(
              "Chào mừng quay lại",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            AppInput(hint: "Email", controller: emailCtrl),
            const SizedBox(height: 12),
            AppInput(hint: "Mật khẩu", controller: passCtrl, isPassword: true),

            const SizedBox(height: 24),

            PrimaryButton(
              title: "Đăng nhập",
              onPressed: () {
                Navigator.pushNamed(context, '/kyc-welcome');
              },
            ),
          ],
        ),
      ),
    );
  }
}