import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:QuickMath_Kids/billing/billing_service.dart';

class AppTheme {
  static double _scaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseScale = screenWidth / 360; // Base scaling factor
    // Cap the scaling factor for tablets to avoid excessive shrinking
    return screenWidth > 600 ? baseScale.clamp(0.8, 1.2) : baseScale;
  }

  static ThemeData getTheme(WidgetRef ref, bool isDarkMode, BuildContext context) {
    final billingService = ref.watch(billingServiceProvider);
    final bool isPremium = billingService.isPremium;
    final scale = _scaleFactor(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    // Core colors
    final Color primaryColor = isPremium ? Colors.amber[600]! : Colors.blue[600]!;
    final Color secondaryColor = isPremium ? Colors.amber[300]! : Colors.blue[300]!;
    final Color backgroundColor = isDarkMode ? Colors.black : Colors.white;

    // Ensure 50% White (Light Mode) / 50% Black (Dark Mode)
    final Color surfaceColor = isDarkMode
        ? Color.alphaBlend(primaryColor.withOpacity(0.3), Colors.black)
        : Color.alphaBlend(primaryColor.withOpacity(0.3), Colors.white);

    final Color onPrimaryColor = isDarkMode ? Colors.white : Colors.black;
    final Color onSurfaceColor = isDarkMode ? Colors.white : Colors.black;

    return ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        onPrimary: onPrimaryColor,
        secondary: secondaryColor,
        onSecondary: onSurfaceColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        background: backgroundColor,
        onBackground: onSurfaceColor,
        error: Colors.red,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor.withOpacity(0.7),
        foregroundColor: onPrimaryColor,
        elevation: 0,
        toolbarHeight: 56 * scale,
        titleTextStyle: TextStyle(
          color: onPrimaryColor,
          fontSize: (isTablet ? 18 : 20) * scale,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: onPrimaryColor,
          size: 22 * scale,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor.withOpacity(0.8),
          foregroundColor: onPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10 * scale,
            horizontal: 18 * scale,
          ),
          textStyle: TextStyle(
            fontSize: (isTablet ? 16 : 16) * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12 * scale),
        ),
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: (isTablet ? 18 : 18) * scale,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
        titleLarge: TextStyle(
          fontSize: (isTablet ? 16 : 16) * scale,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
        bodyLarge: TextStyle(
          fontSize: (isTablet ? 14 : 14) * scale, // Reduced further for tablets
          color: onSurfaceColor,
        ),
        titleMedium: TextStyle(
          fontSize: (isTablet ? 14 : 14) * scale,
          color: onSurfaceColor
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
        size: 22 * scale,
      ),
      dividerColor: secondaryColor.withOpacity(0.3),
      scaffoldBackgroundColor: backgroundColor,
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(
          fontSize: (isTablet ? 14 : 14) * scale, // Reduced for consistency
          color: onSurfaceColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8 * scale)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: secondaryColor.withOpacity(0.3),
        circularTrackColor: secondaryColor.withOpacity(0.3),
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: TextStyle(
          fontSize: (isTablet ? 14 : 14) * scale,
          color: onSurfaceColor,
        ),
        backgroundColor: surfaceColor,
      ),
    );
  }
}