import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';

class SplashScreenTo extends StatelessWidget {
  final Widget screen;
  const SplashScreenTo({super.key, required this.screen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // full black background
      body: Stack(
        children: [
          /// BACKGROUND
          Container(
            color: Colors.black,
          ),

          /// GIF SPLASH
          AnimatedSplashScreen(
            splash: Center(
              child: SizedBox(
                width: 260,
                height: 260,
                child: Image.asset(
                  'assets/animation/loading.gif', //
                  fit: BoxFit.contain, // keeps centered & clean
                ),
              ),
            ),
            nextScreen: screen,
            duration: 1300,
            backgroundColor: Colors.transparent,
            splashIconSize: 260, // same as the SizedBox
            splashTransition: SplashTransition.fadeTransition,
          ),
        ],
      ),
    );
  }
}
