import 'dart:io';

import 'package:flutter/material.dart';

enum ScreenType { small, medium, large, tablet }

class AppDimensions {
  AppDimensions._();

  static const double baseWidth = 390.0;

  static const double smallScreenMax = 360.0;
  static const double mediumScreenMax = 600.0;
  static const double largeScreenMax = 840.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border radius
  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;

  // Icon sizes
  static const double iconSizeXS = 16.0;
  static const double iconSizeS = 20.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 40.0;
  static const double iconSizeXXL = 48.0;

  // Button heights
  static const double buttonHeightS = 32.0;
  static const double buttonHeightM = 40.0;
  static const double buttonHeightL = 48.0;
  static const double buttonHeightXL = 56.0;

  // Text sizes
  static const double textSize11 = 11.0;
  static const double textSize12 = 12.0;
  static const double textSize14 = 14.0;
  static const double textSize16 = 16.0;
  static const double textSize18 = 18.0;
  static const double textSize20 = 20.0;
  static const double textSize24 = 24.0;
  static const double textSize28 = 28.0;
  static const double textSize32 = 32.0;
  static const double textSize36 = 36.0;
  static const double textSize48 = 48.0;

  static const double appBarHeight = 56.0;

  static ScreenType screenType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).shortestSide;
    if (width < smallScreenMax) return ScreenType.small;
    if (width < mediumScreenMax) return ScreenType.medium;
    if (width < largeScreenMax) return ScreenType.large;
    return ScreenType.tablet;
  }

  static double normalize(BuildContext context, double value) {
    final double shortSide = MediaQuery.sizeOf(context).shortestSide;

    if (Platform.isAndroid) {
      return _normalizeAndroid(shortSide, value);
    } else if (Platform.isIOS) {
      return _normalizeIOS(shortSide, value);
    }

    return value;
  }

  static double _normalizeAndroid(double shortSide, double value) {
    const double baseDp = 360.0;
    final double scale = shortSide / baseDp;

    if (shortSide < 600) {
      return value * scale.clamp(0.9, 1.3);
    }
    final double tabletScale = 1.3 + (scale - (600 / baseDp)) * 0.15;
    return value * tabletScale.clamp(1.3, 1.6);
  }

  static double _normalizeIOS(double shortSide, double value) {
    const double baseDp = 390.0;
    final double scale = shortSide / baseDp;

    if (shortSide < 600) {
      return value * scale.clamp(0.9, 1.15);
    } else {
      return value * scale.clamp(1.3, 1.5);
    }
  }
}
