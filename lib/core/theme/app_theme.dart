import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      scaffoldBackgroundColor: AppColors.background,

      
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primaryDark,
        disabledColor: AppColors.elevatedSurface,
        labelStyle: TextStyle(
          color: AppColors.text,
          fontFamily: 'IBMPlexMono',
          fontSize: 12,
        ),
        secondaryLabelStyle: TextStyle(
          color: AppColors.primary,
          fontFamily: 'IBMPlexMono',
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        checkmarkColor: AppColors.primary,
        side: BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),


      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.background,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.error,
      ),

      fontFamily: 'IBMPlexMono',

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.text,
          fontFamily: 'PressStart2P',
          fontSize: 30,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          color: AppColors.text,
          fontFamily: 'PressStart2P',
          fontSize: 12,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          color: AppColors.text,
          fontFamily: 'IBMPlexMono',
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(
          color: AppColors.text,
          fontFamily: 'IBMPlexMono',
          fontSize: 12,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          color: AppColors.muted,
          fontFamily: 'IBMPlexMono',
          fontSize: 11,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          color: AppColors.muted,
          fontFamily: 'IBMPlexMono',
          fontSize: 9,
          height: 1.2,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: const CardThemeData(
        color: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.border),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          minimumSize: const Size(double.infinity, 52),
          textStyle: const TextStyle(fontFamily: 'PressStart2P', fontSize: 10),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    );
  }
}
