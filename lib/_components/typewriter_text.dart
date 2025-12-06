import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class TypewriterTextCustom extends StatelessWidget {
  final String textchoice;
  final double fontsizee;
  final color;
  final bool bold;
  final fontfamily;
  final int millisecspd;
  const TypewriterTextCustom(
      {super.key,
      required this.textchoice,
      required this.fontsizee,
      this.color,
      required this.bold,
      this.fontfamily,
      required this.millisecspd});

  @override
  Widget build(BuildContext context) {
    // double screenwidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          textchoice,
          textStyle: TextStyle(
            fontSize: fontsizee,
            // fontSize: screenwidth* 0.11,
            color: color,
            fontWeight: bold ? FontWeight.bold : null,
            fontFamily: fontfamily,
          ),
          speed: Duration(milliseconds: millisecspd), // Adjust speed here
        ),
      ],
      totalRepeatCount: 1,
      pause: const Duration(milliseconds: 1000),
      displayFullTextOnTap: true,
      stopPauseOnTap: true,
    );
  }
}
