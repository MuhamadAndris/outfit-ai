import 'package:flutter/material.dart';

/// Semua warna aplikasi ada di sini, supaya mudah diganti.
class AppColors {
  static const ink = Color(0xFF14213D);
  static const muted = Color(0xFF5B6478);
  static const background = Color(0xFFF5F7FA);
  static const border = Color(0xFFDDE3EC);
  static const soft = Color(0xFFE8EDF5);
  static const accent = Color(0xFFC8431F);
  static const success = Color(0xFF0F766E);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          primary: AppColors.accent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.ink,
          elevation: 0,
        ),
      );
}

/// Dekorasi kartu putih berbingkai, dipakai berulang di banyak widget.
BoxDecoration cardDecoration({bool selected = false}) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: selected ? AppColors.accent : AppColors.border,
        width: selected ? 2 : 1,
      ),
    );
