import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  bool valuee;
  final activecolor;
  final Function(bool?)? onChanged;
  CustomCheckbox({super.key, required this.valuee, this.activecolor, this.onChanged});

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  // bool rememberPassword = true;
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: widget.valuee,
      activeColor: widget.activecolor,
      onChanged: widget.onChanged,
    );
  }
}
