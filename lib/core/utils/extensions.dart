import 'package:flutter/material.dart';
import 'package:identity_frontend/core/themes/app_dimensions.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';

extension BuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;

  /// Normalize a design value to the current screen density.
  double r(double value) => AppDimensions.normalize(this, value);

  ScreenType get screenType => AppDimensions.screenType(this);
}

extension StringX on String {
  String get capitalize =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : this;

  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');

  bool get isValidEmail {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(this);
  }

  bool get isValidPhone {
    final regex = RegExp(r'^\+?[0-9]{9,15}$');
    return regex.hasMatch(this);
  }
}

extension DateTimeX on DateTime {
  String toDisplayDate() {
    return '$day/$month/$year';
  }

  String toIso() => toIso8601String();
}

extension DoubleX on double {
  String toFormattedCurrency({String symbol = 'VND'}) {
    final parts = toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    int count = 0;
    for (int i = parts.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(parts[i]);
      count++;
    }
    final result = buffer.toString().split('').reversed.join('');
    return '$result $symbol';
  }
}