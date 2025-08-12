import 'package:flutter/material.dart';

class AppColors {
  // Theme management
  static AppTheme currentTheme = AppTheme.moonlight;

  // Color getters
  static Color primary(ColorShade shade) => _getColor(_primaryColors, shade);
  static Color neutrals(ColorShade shade) => _getColor(_neutralColors, shade);
  static Color error(ColorShade shade) => _getColor(_errorColors, shade);
  static Color warning(ColorShade shade) => _getColor(_warningColors, shade);
  static Color success(ColorShade shade) => _getColor(_successColors, shade);

  // Moonlight theme colors
  static const Map<ColorShade, Color> _moonlightPrimary = {
    ColorShade.c25: Color(0xFFE6E6FF),
    ColorShade.c50: Color(0xFFCCCCFF),
    ColorShade.c100: Color(0xFFBEBEF5),
    ColorShade.c200: Color(0xFFB0B0E0),
    ColorShade.c300: Color(0xFFA3A3CC),
    ColorShade.c400: Color(0xFF8080B2),
    ColorShade.c500: Color(0xFF5C5C99),
    ColorShade.c600: Color(0xFF4A4A88),
    ColorShade.c700: Color(0xFF3B3B7A),
    ColorShade.c800: Color(0xFF292966),
    ColorShade.c900: Color(0xFF1A1A4D),
  };

  static const Map<ColorShade, Color> _moonlightNeutrals = {
    ColorShade.c25: Color(0xFFF4F4F4),
    ColorShade.c50: Color(0xFFDFDBE1),
    ColorShade.c100: Color(0xFFB0A2BA),
    ColorShade.c200: Color(0xFF887795),
    ColorShade.c300: Color(0xFF6C5A7A),
    ColorShade.c400: Color(0xFF5B446D),
    ColorShade.c500: Color(0xFF3F2F4B),
    ColorShade.c600: Color(0xFF271B31),
    ColorShade.c700: Color(0xFF160C1D),
    ColorShade.c800: Color(0xFF0F0616),
    ColorShade.c900: Color(0xFF06010B),
  };

  static const Map<ColorShade, Color> _moonlightError = {
    ColorShade.c25: Color(0xFFFFFBFA),
    ColorShade.c50: Color(0xFFFEF3F2),
    ColorShade.c100: Color(0xFFFEE4E2),
    ColorShade.c200: Color(0xFFFECDCA),
    ColorShade.c300: Color(0xFFFDA29B),
    ColorShade.c400: Color(0xFFF97066),
    ColorShade.c500: Color(0xFFF04438),
    ColorShade.c600: Color(0xFFD92D20),
    ColorShade.c700: Color(0xFFB42318),
    ColorShade.c800: Color(0xFF912018),
    ColorShade.c900: Color(0xFF7A271A),
  };

  static const Map<ColorShade, Color> _moonlightWarning = {
    ColorShade.c25: Color(0xFFFFFCF5),
    ColorShade.c50: Color(0xFFFFFAEB),
    ColorShade.c100: Color(0xFFFEF0C7),
    ColorShade.c200: Color(0xFFFEDF89),
    ColorShade.c300: Color(0xFFFEC84B),
    ColorShade.c400: Color(0xFFFDB022),
    ColorShade.c500: Color(0xFFF79009),
    ColorShade.c600: Color(0xFFDC6803),
    ColorShade.c700: Color(0xFFB54708),
    ColorShade.c800: Color(0xFF93370D),
    ColorShade.c900: Color(0xFF7A2E0E),
  };

  static const Map<ColorShade, Color> _moonlightSuccess = {
    ColorShade.c25: Color(0xFFF6FEF9),
    ColorShade.c50: Color(0xFFECFDF3),
    ColorShade.c100: Color(0xFFD1FADF),
    ColorShade.c200: Color(0xFFA6F4C5),
    ColorShade.c300: Color(0xFF6CE9A6),
    ColorShade.c400: Color(0xFF32D583),
    ColorShade.c500: Color(0xFF12B76A),
    ColorShade.c600: Color(0xFF039855),
    ColorShade.c700: Color(0xFF027A48),
    ColorShade.c800: Color(0xFF05603A),
    ColorShade.c900: Color(0xFF054F31),
  };

  // Apartmita theme colors
  static const Map<ColorShade, Color> _apartmitaPrimary = {
    ColorShade.c25: Color(0xFFFFFAF0),
    ColorShade.c50: Color(0xFFFFE8D6),
    ColorShade.c100: Color(0xFFFFD4B0),
    ColorShade.c200: Color(0xFFFFB680),
    ColorShade.c300: Color(0xFFFF924D),
    ColorShade.c400: Color(0xFFFF6C1A),
    ColorShade.c500: Color(0xFFE65A00),
    ColorShade.c600: Color(0xFFCC4D00),
    ColorShade.c700: Color(0xFFB34000),
    ColorShade.c800: Color(0xFF802D00),
    ColorShade.c900: Color(0xFF661E00),
  };

  static const Map<ColorShade, Color> _apartmitaNeutrals = {
    ColorShade.c25: Color(0xFFF5F5F5),
    ColorShade.c50: Color(0xFFE0E0E0),
    ColorShade.c100: Color(0xFFC0C0C0),
    ColorShade.c200: Color(0xFFA0A0A0),
    ColorShade.c300: Color(0xFF808080),
    ColorShade.c400: Color(0xFF606060),
    ColorShade.c500: Color(0xFF404040),
    ColorShade.c600: Color(0xFF303030),
    ColorShade.c700: Color(0xFF202020),
    ColorShade.c800: Color(0xFF101010),
    ColorShade.c900: Color(0xFF000000),
  };

  // Empty maps for other color types in apartmita theme
  static const Map<ColorShade, Color> _apartmitaError = {};
  static const Map<ColorShade, Color> _apartmitaWarning = {};
  static const Map<ColorShade, Color> _apartmitaSuccess = {};

  // Theme-based color map getters
  static Map<ColorShade, Color> get _primaryColors =>
      currentTheme == AppTheme.moonlight ? _moonlightPrimary : _apartmitaPrimary;

  static Map<ColorShade, Color> get _neutralColors =>
      currentTheme == AppTheme.moonlight ? _moonlightNeutrals : _apartmitaNeutrals;

  static Map<ColorShade, Color> get _errorColors =>
      currentTheme == AppTheme.moonlight ? _moonlightError : _apartmitaError;

  static Map<ColorShade, Color> get _warningColors =>
      currentTheme == AppTheme.moonlight ? _moonlightWarning : _apartmitaWarning;

  static Map<ColorShade, Color> get _successColors =>
      currentTheme == AppTheme.moonlight ? _moonlightSuccess : _apartmitaSuccess;

  // Helper method to get color from map
  static Color _getColor(Map<ColorShade, Color> colors, ColorShade shade) {
    return colors[shade] ?? Colors.black;
  }

  // Theme changer with optional callback
  static void setTheme(AppTheme theme, {VoidCallback? onChanged}) {
    currentTheme = theme;
    onChanged?.call();
  }
}

enum ColorShade {
  c25, c50, c100, c200, c300, c400, c500, c600, c700, c800, c900
}

enum AppTheme {
  moonlight, apartmita
}

// Extension for easy color access
extension ColorShadeExtension on ColorShade {
  String get name {
    return toString().split('.').last;
  }
}

// Extension for theme management
extension AppThemeExtension on AppTheme {
  String get name {
    return toString().split('.').last;
  }
}