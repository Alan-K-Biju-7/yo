import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppColors {
  static const primary = Color(0xFF1854A5);
  static const accent = Color(0xFF25A5E8);
  static const page = Color(0xFFFFF8FF);
  static const surface = Color(0xFFFFFBFF);
  static const purple = Color(0xFF70519C);
  static const lavender = Color(0xFFE9D8FF);
  static const infoCard = Color(0xFFADD8F7);
  static const danger = Color(0xFFE6534E);
  static const ink = Color(0xFF1D1A20);
  static const muted = Color(0xFF969197);
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.page,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 28),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFFF8F8F8),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        bodyLarge: const TextStyle(
          color: AppColors.ink,
          fontSize: 22,
          height: 1.35,
        ),
      ),
    );
  }
}
