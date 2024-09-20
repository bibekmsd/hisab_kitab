import 'package:flutter/material.dart';
import 'package:hisab_kitab/Responsive%20UI/responsive_builder.dart';

class ResponsiveUtils {
  static double getFontSize(DeviceType deviceType, double baseFontSize) {
    switch (deviceType) {
      case DeviceType.mobile:
        return baseFontSize;
      case DeviceType.tablet:
        return baseFontSize * 1.2;
      case DeviceType.desktop:
        return baseFontSize * 1.4;
    }
  }

  static EdgeInsets getPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16.0);
      case DeviceType.tablet:
        return const EdgeInsets.all(24.0);
      case DeviceType.desktop:
        return const EdgeInsets.all(32.0);
    }
  }

  static double getMaxWidth(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 700.0;
      case DeviceType.desktop:
        return 1200.0;
    }
  }
}
