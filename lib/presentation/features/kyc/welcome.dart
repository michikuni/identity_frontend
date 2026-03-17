import 'package:flutter/material.dart';
import 'package:identity_frontend/presentation/widgets/primary_button.dart';

class KycWelcomeScreen extends StatelessWidget {
  const KycWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 60),

            const Icon(Icons.verified_user, size: 80),

            const SizedBox(height: 16),

            const Text(
              "Xác minh danh tính",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            Card(
              child: Column(
                children: const [
                  ListTile(title: Text("1. Chụp giấy tờ")),
                  ListTile(title: Text("2. Quét khuôn mặt")),
                  ListTile(title: Text("3. Xác nhận")),
                ],
              ),
            ),

            const Spacer(),

            PrimaryButton(
              title: "Bắt đầu ngay",
              onPressed: () {
                Navigator.pushNamed(context, '/dashboard');
              },
            ),
          ],
        ),
      ),
    );
  }
}