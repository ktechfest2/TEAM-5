import 'package:aurion_hotel/_logik/theme/theme_colors.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController pswdcontroller;
  final String labeltext;
  // final String userType;
  final FormFieldValidator<String>? validator;

  const PasswordField({
    super.key,
    required this.pswdcontroller,
    required this.labeltext,
    // required this.userType,
    this.validator,
  });

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = getThemeColors();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextFormField(
        style: TextStyle(color: theme.textColor),
        cursorColor: theme.iconColor,
        controller: widget.pswdcontroller,
        validator: widget.validator,
        obscureText: !_isPasswordVisible,
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
          labelText: widget.labeltext,
          labelStyle: TextStyle(color: theme.iconColor),
          errorStyle: TextStyle(color: theme.errorcolor, fontSize: 12),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: theme.iconColor,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }
}
