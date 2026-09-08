import 'package:flutter/material.dart';

class AppTheme {
  // Colors based on the provided design
  static const Color primaryGreen = Color(0xFF006B56); // Buttons, Next Collection card
  static const Color darkGreen = Color(0xFF004D40); // Header text, dark backgrounds
  static const Color lightBlueBackground = Color(0xFFE8F1F5); // Light card backgrounds
  static const Color backgroundColor = Color(0xFFF7F9FC); // Main app background
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);
  static const Color white = Colors.white;

  // Status colors for dashboard
  static const Color statusOnRoute = Color(0xFFD1FAE5);
  static const Color statusOnRouteText = Color(0xFF065F46);
  static const Color statusDelayed = Color(0xFFFEE2E2);
  static const Color statusDelayedText = Color(0xFF991B1B);
  static const Color statusMaintenance = Color(0xFFE2E8F0);
  static const Color statusMaintenanceText = Color(0xFF475569);
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: darkGreen,
        surface: white,
        onPrimary: white,
        onSurface: textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: darkGreen),
        titleTextStyle: TextStyle(
          color: darkGreen,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textLight,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textDark),
        bodyMedium: TextStyle(color: textLight),
      ),
    );
  }
}
