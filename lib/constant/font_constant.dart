import 'package:flutter/material.dart';

class AppTypography {
  // Font families
  static const String montserrat = 'Montserrat';
  
  // Predefined text styles
  static TextStyle h1xl({Color? color, FontWeight? weight}) => _textStyle(32, 40, color, weight);
  static TextStyle h1({Color? color, FontWeight? weight}) => _textStyle(32, 40, color, weight);
  static TextStyle h2({Color? color, FontWeight? weight}) => _textStyle(16, 22, color, weight);
  static TextStyle lead({Color? color, FontWeight? weight}) => _textStyle(20, 28, color, weight);
  static TextStyle large({Color? color, FontWeight? weight}) => _textStyle(16, 24, color, weight);
  static TextStyle medium({Color? color, FontWeight? weight}) => _textStyle(14, 20, color, weight);
  static TextStyle small({Color? color, FontWeight? weight}) => _textStyle(10, 14, color, weight);
  static TextStyle slug({Color? color, FontWeight? weight}) => _textStyle(14, 20, color, weight);
  
  // Custom size
  static TextStyle custom(double size, {Color? color, FontWeight? weight}) => 
      _textStyle(size, size + 8, color, weight);

  // Base text style generator
  static TextStyle _textStyle(double fontSize, double lineHeight, Color? color, FontWeight? weight) {
    return TextStyle(
      fontFamily: montserrat,
      fontSize: fontSize,
      height: lineHeight / fontSize,
      color: color,
      fontWeight: weight,
    );
  }

  // Convenience text widget builder
  static Text text(
    String text, {
    TextStyle? style,
    Color? color,
    FontWeight? weight,
    TextAlign? align,
    double? fontSize,
    int? maxLines,
  }) {
    return Text(
      text,
      style: (style ?? _textStyle(14, 22, color, weight)).copyWith(
        color: color,
        fontWeight: weight,
        fontSize: fontSize,
      ),
      textAlign: align,
      maxLines: maxLines,
    );
  }
}

// Font weights for easier access
class FontWeights {
  static const FontWeight regular = FontWeight.normal;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.bold;
}