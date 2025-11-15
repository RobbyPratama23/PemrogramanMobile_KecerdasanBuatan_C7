import 'package:flutter/material.dart';

class AppColors {
  static const primaryGreen = Color(0xFF4CAF50);
  static const darkGreen = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFF81C784);
  static const primaryBlue = Color(0xFF2196F3);
  static const lightBlue = Color(0xFF64B5F6);
  static const primaryOrange = Color(0xFFFF9800);
  static const lightOrange = Color(0xFFFFB74D);
  static const primaryPurple = Color(0xFF9C27B0);
  static const lightPurple = Color(0xFFBA68C8);
  static const scaffoldBackground = Color(0xFFF5F5F5);
}

class AppGradients {
  static const greenGradient = LinearGradient(
    colors: [AppColors.primaryGreen, AppColors.darkGreen],
  );

  static const lightGreenGradient = LinearGradient(
    colors: [AppColors.primaryGreen, AppColors.lightGreen],
  );

  static const blueGradient = LinearGradient(
    colors: [AppColors.primaryBlue, AppColors.lightBlue],
  );

  static const orangeGradient = LinearGradient(
    colors: [AppColors.primaryOrange, AppColors.lightOrange],
  );

  static const purpleGradient = LinearGradient(
    colors: [AppColors.primaryPurple, AppColors.lightPurple],
  );
}

class AppTextStyles {
  static const appBarTitle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const bodyMedium = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );
}
