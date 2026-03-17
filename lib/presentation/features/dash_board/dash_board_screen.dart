import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TrustID"),
        actions: const [
          Icon(Icons.notifications),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile
            Row(
              children: const [
                CircleAvatar(),
                SizedBox(width: 12),
                Text("Xin chào, Nguyễn Văn A"),
              ],
            ),

            const SizedBox(height: 16),

            // Balance Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0047AB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Số dư", style: TextStyle(color: Colors.white)),
                  Text(
                    "10,000,000đ",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Services
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              children: const [
                Icon(Icons.send),
                Icon(Icons.qr_code),
                Icon(Icons.account_balance_wallet),
                Icon(Icons.upgrade),
              ],
            ),
          ],
        ),
      ),
    );
  }
}