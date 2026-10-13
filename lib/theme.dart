import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1A4DB3);
  static const ink = Color(0xFF111827);
  static const body = Color(0xFF4B5563);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const surface = Color(0xFFF3F4F6);
  static const page = Color(0xFFF5F6F8);
  static const sidebarLight = Color(0xFFEEF1F6);
  static const white = Color(0xFFFFFFFF);
  static const danger = Color(0xFFC62828);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.white,
  );
}
