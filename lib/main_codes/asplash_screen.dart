import 'package:aurion_hotel/_logik/auth_wrapper.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // List of image assets

  @override
  void initState() {
    super.initState();
    // Navigate to another screen after 3 Sec,
    Future.delayed(Duration(seconds: 6), () {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => AuthWrapper())); //Authwrapper
    });
  }

  @override
  Widget build(BuildContext context) {
    return introWelcomeScreen();
  }

  Widget introWelcomeScreen() {
    // Get a random image each time the widget is built
    // String randomImage = getRandomImage();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFFFF), // Pure white top
                  Color(0xFFFDFDFD), // Slight mist white (barely visible)
                  Color(0xFFFFFFFF), // Center: pure white
                  Color(0xFFF5F7F8), // Very soft grey-white
                  Color(0xFFEEF1F2), // Mild shade at the bottom
                ],
                stops: [
                  0.0,
                  0.25,
                  0.5,
                  0.75,
                  1.0,
                ],
              ),
            ),
          ),
          Center(
            child: Image.asset(
              "assets/aurion_intro.gif",
              width: 600.0,
              height: 220.0,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'WittyHub',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///df
