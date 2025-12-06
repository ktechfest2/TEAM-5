import 'package:flutter/material.dart';

class ThemeColorsMainPages {
  final List<Color> backgroundGradient;
  final Color buttonColor;
  final Color textColor;
  final Color fieldFillColor;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color iconColor;
  final Color? auxIconColor; // Optional auxIconColor
  final Color errorcolor;

  ThemeColorsMainPages({
    required this.backgroundGradient,
    required this.buttonColor,
    required this.textColor,
    required this.fieldFillColor,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.iconColor,
    this.auxIconColor, // AuxIconColor is optional
    required this.errorcolor,
  });
}

ThemeColorsMainPages getThemeColorsMainPages(String userType,
    {Brightness brightness = Brightness.dark, Color? auxIconColor}) {
  final isDark = brightness == Brightness.dark;

  switch (userType.toLowerCase()) {
    case 'freelancer':
      return isDark
          ? ThemeColorsMainPages(
              backgroundGradient: [
                Color.fromARGB(255, 15, 4, 0),
                Color.fromARGB(255, 1, 0, 0)
              ],
              buttonColor: Color(0xFFEF6C00),
              textColor: Colors.white,
              fieldFillColor: Color(0xFF1A0A00),
              // borderColor: Colors.deepOrange.shade700,
              borderColor: Colors.transparent,
              focusedBorderColor: Colors.orange.shade400,
              iconColor: Colors.orange.shade200,
              auxIconColor: auxIconColor ??
                  Colors.deepOrangeAccent, // Default if not provided
              errorcolor: Colors.white70,
            )
          : ThemeColorsMainPages(
              backgroundGradient: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
              buttonColor: Color(0xFFEF6C00),
              textColor: Colors.black87,
              fieldFillColor: Color(0xFFFFF8E1),
              borderColor: Colors.orange.shade300,
              focusedBorderColor: Colors.deepOrange,
              iconColor: Colors.deepOrange,
              auxIconColor: auxIconColor ??
                  Colors.orangeAccent, // Default if not provided
              errorcolor: Colors.red.shade400,
            );

    case 'client':
      return isDark
          ? ThemeColorsMainPages(
              backgroundGradient: [Color(0xFF0A0F2C), Color(0xFF000814)],
              buttonColor: Color(0xFF1E88E5),
              textColor: Colors.white,
              fieldFillColor: Color(0xFF1A1A2E),
              borderColor: Colors.blueAccent.shade100,
              focusedBorderColor: Colors.cyanAccent.shade200,
              iconColor: Colors.grey.shade300,
              auxIconColor: auxIconColor ??
                  Colors.blueAccent.shade200, // Default if not provided
              errorcolor: Colors.redAccent.shade100,
            )
          : ThemeColorsMainPages(
              backgroundGradient: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
              buttonColor: Color(0xFF1E88E5),
              textColor: Colors.black87,
              fieldFillColor: Color(0xFFFFFFFF),
              borderColor: Colors.blue.shade200,
              focusedBorderColor: Colors.blue.shade500,
              iconColor: Colors.blueGrey,
              auxIconColor: auxIconColor ??
                  Colors.blue.shade400, // Default if not provided
              errorcolor: Colors.red.shade400,
            );

    case 'both':
      return isDark
          ? ThemeColorsMainPages(
              backgroundGradient: [Color(0xFF1D0033), Color(0xFF0D001A)],
              buttonColor: Color(0xFF6A1B9A),
              textColor: Colors.white,
              fieldFillColor: Color(0xFF1A1A2E),
              borderColor: Colors.purple.shade200,
              focusedBorderColor: Colors.pink.shade300,
              iconColor: Colors.purple.shade100,
              auxIconColor: auxIconColor ??
                  Colors.purple.shade300, // Default if not provided
              errorcolor: Colors.pinkAccent.shade100,
            )
          : ThemeColorsMainPages(
              backgroundGradient: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
              buttonColor: Color(0xFF6A1B9A),
              textColor: Colors.black87,
              fieldFillColor: Color(0xFFFFFFFF),
              borderColor: Colors.purple.shade300,
              focusedBorderColor: Colors.purple.shade600,
              iconColor: Colors.deepPurple,
              auxIconColor: auxIconColor ??
                  Colors.purple.shade400, // Default if not provided
              errorcolor: Colors.pink.shade400,
            );

    case 'login':
      return isDark
          ? ThemeColorsMainPages(
              backgroundGradient: [Color(0xFF1A0026), Color(0xFF0B0014)],
              buttonColor: Color(0xFF8E24AA),
              textColor: Colors.white,
              fieldFillColor: Color(0xFF24003E),
              borderColor: Colors.deepPurple.shade200,
              focusedBorderColor: Colors.purpleAccent.shade100,
              iconColor: Colors.deepPurple.shade100,
              auxIconColor: auxIconColor ??
                  Colors.purpleAccent.shade200, // Default if not provided
              errorcolor: Colors.pinkAccent.shade100,
            )
          : ThemeColorsMainPages(
              backgroundGradient: [Color(0xFFF3E5F5), Color(0xFFD1C4E9)],
              buttonColor: Color(0xFF8E24AA),
              textColor: Colors.black87,
              fieldFillColor: Color(0xFFFFFFFF),
              borderColor: Colors.purple.shade300,
              focusedBorderColor: Colors.purple.shade700,
              iconColor: Colors.deepPurple,
              auxIconColor: auxIconColor ??
                  Colors.purple.shade500, // Default if not provided
              errorcolor: Colors.pink.shade400,
            );

    default:
      throw ArgumentError('Unknown userType: $userType');
  }
}
