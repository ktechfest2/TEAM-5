import 'package:aurion_hotel/_logik/theme/theme_colors.dart';
import 'package:flutter/material.dart';

class MytextfieldCustom extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final Widget? iconch;
  // final String userType;
  final FormFieldValidator<String>? validator;

  const MytextfieldCustom({
    super.key,
    required this.controller,
    required this.labelText,
    required this.obscureText,
    // required this.userType,
    this.iconch,
    this.validator,
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
