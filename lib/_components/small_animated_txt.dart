import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class Smallanimatedtxt extends StatelessWidget {
  const Smallanimatedtxt({super.key, required this.txt});
  final String txt;

  @override
  Widget build(BuildContext context) {
    // double screenwidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          txt,
          textStyle: const TextStyle(
            fontSize: 15.0,
            // fontSize: screenwidth* 0.033,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            // fontFamily: fontfam,
          ),
          textAlign: TextAlign.center,
          speed: const Duration(milliseconds: 30), // Adjust speed here
        ),
      ],
      totalRepeatCount: 1,
      pause: const Duration(milliseconds: 1000),
      displayFullTextOnTap: true,
      stopPauseOnTap: true,
    );
  }
}
