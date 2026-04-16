import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF3949AB);
  static const Color primaryDark = Color(0xFF0D1257);

  // Accent
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);

  // Backgrounds
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFFCBD5E1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // Status
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFF0F9FF);

  // Inactive / Disabled
  static const Color inactive = Color(0xFF94A3B8);
  static const Color disabled = Color(0xFFE2E8F0);

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF1A237E),
    Color(0xFF3949AB),
  ];
  static const List<Color> accentGradient = [
    Color(0xFFF59E0B),
    Color(0xFFFBBF24),
  ];
  static const List<Color> cardGradient = [
    Color(0xFF1A237E),
    Color(0xFF283593),
  ];

  // Shadow
  static const Color shadow = Color(0x1A1A237E);
  static const Color shadowLight = Color(0x0D000000);
}
