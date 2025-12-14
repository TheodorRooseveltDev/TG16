import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0x40000000),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get navbarShadow => [
        BoxShadow(
          color: const Color(0x60000000),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cyanGlow => [
        BoxShadow(
          color: AppColors.primaryGlow,
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cyanGlowIntense => [
        BoxShadow(
          color: const Color(0x9900D4E5),
          blurRadius: 32,
          spreadRadius: 4,
        ),
      ];
}
