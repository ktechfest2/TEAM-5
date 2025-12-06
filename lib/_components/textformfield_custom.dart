import 'package:flutter/material.dart';
import 'package:aurion_hotel/_logik/theme/theme_colors.dart';

class TextformfieldCustom extends StatelessWidget {
  final controller;
  final String labelText;
  final bool obscureText; //hide text?
  final iconch;
  final prefix_icon;
  final validator;
  final keyboardtype;
  final iconcolor;
  final padding_double;
  // final String userType;
  const TextformfieldCustom({
    super.key,
    required this.controller,
    required this.labelText,
    required this.obscureText,
    this.iconch,
    required this.validator,
    this.keyboardtype,
    this.iconcolor,
    required this.padding_double,
    this.prefix_icon,
    // required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = getThemeColors();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextFormField(
        style: TextStyle(color: theme.textColor),
        cursorColor: theme.iconColor,
        validator: validator,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.borderColor),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.focusedBorderColor),
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.borderColor),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.errorcolor),
            borderRadius: BorderRadius.circular(10),
          ),
          // fillColor: Colors.transparent,
          fillColor: theme.fieldFillColor,

          filled: true,
          errorStyle: TextStyle(color: theme.errorcolor, fontSize: 12),
          labelText: labelText,
          labelStyle: TextStyle(color: theme.iconColor),
          suffixIcon: iconch != null
              ? IconTheme(
                  data: IconThemeData(color: theme.iconColor), child: iconch!)
              : null,
        ),
      ),
    );
  }
}
