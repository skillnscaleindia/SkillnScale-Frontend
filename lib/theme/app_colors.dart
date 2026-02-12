import 'package:flutter/material.dart';

class AppColors {
  // Primary — Urban Company-inspired deep dark
  static const Color primary = Color(0xFF1C1C1E);
  static const Color primaryLight = Color(0xFF2C2C2E);
  static const Color accent = Color(0xFF6C63FF); // Vibrant purple accent
  static const Color accentLight = Color(0xFF8B83FF);

  // Functional
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);

  // Light Theme
  static const Color lightBackground = Color(0xFFF8F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1C1C1E);
  static const Color lightSubtitle = Color(0xFF8E8E93);
  static const Color lightDivider = Color(0xFFE5E5EA);
  static const Color lightCardBorder = Color(0xFFF2F2F7);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkOnSurface = Color(0xFFF5F5F7);
  static const Color darkSubtitle = Color(0xFF98989D);
  static const Color darkDivider = Color(0xFF38383A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient promoGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF34C759), Color(0xFF30D158)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Service category colors
  static const List<Color> serviceCategoryColors = [
    Color(0xFFE8F5E9), // Green tint
    Color(0xFFE3F2FD), // Blue tint
    Color(0xFFFFF3E0), // Orange tint
    Color(0xFFF3E5F5), // Purple tint
    Color(0xFFE0F7FA), // Cyan tint
    Color(0xFFFCE4EC), // Pink tint
    Color(0xFFFFF8E1), // Amber tint
    Color(0xFFEDE7F6), // Deep purple tint
  ];

  static const List<Color> serviceCategoryIconColors = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFE91E63),
    Color(0xFFFFC107),
    Color(0xFF673AB7),
  ];
}
