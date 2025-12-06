// Modern, techy beautiful theme using provided color palette

import 'package:flutter/material.dart';

class ThemeColors {
  final List<Color> backgroundGradient;
  final Color buttonColor;
  final Color textColor;
  final Color fieldFillColor;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color iconColor;
  final Color errorcolor;

  ThemeColors({
    required this.backgroundGradient,
    required this.buttonColor,
    required this.textColor,
    required this.fieldFillColor,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.iconColor,
    required this.errorcolor,
  });
}

ThemeColors getThemeColors() {
  return ThemeColors(
    backgroundGradient: [
      Color(0xFFF8FEFC), // Sparkling Snow
      Color(0xFFFFFFFF), // White
    ],
    buttonColor: Color(0xFF02BE62), // Intoxicate
    textColor: Color(0xFF502E11), // Moelleux Au Chocolat
    fieldFillColor: Color.fromARGB(255, 241, 252, 249), // Sparkling Snow
    borderColor: Color(0xFF31C67E), // Seaweed
    focusedBorderColor: Color(0xFF18B369), // Green Mana
    iconColor: Color(0xFF55371C), // Moelleux Au Chocolat (darker)
    errorcolor: Color(0xFF746151), // Heavy Brown
  );
}
