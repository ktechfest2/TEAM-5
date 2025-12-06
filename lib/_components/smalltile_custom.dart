import 'package:aurion_hotel/_logik/theme/theme_colors.dart';
import 'package:flutter/material.dart';

class SmalltileCustom extends StatelessWidget {
  final String imgPath;
  // final bool apple;

  const SmalltileCustom({super.key, required this.imgPath});

  @override
  Widget build(BuildContext context) {
    final theme = getThemeColors();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // color: Colors.transparent,
        color: theme.fieldFillColor,
        border: Border.all(color: theme.borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Image.asset(
        imgPath,
        height: 40,
        // color: Colors.transparent,
      ),
    );
  }
}
