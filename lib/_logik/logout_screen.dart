import 'package:aurion_hotel/_logik/Ui_bridges/splash_screen_to.dart';
import 'package:aurion_hotel/_logik/theme/theme_provider.dart';
import 'package:aurion_hotel/main_codes/onboarding_screens/onboardingview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Log Out"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkTheme ? Colors.grey.shade900 : Colors.white,
        foregroundColor: isDarkTheme ? Colors.white : Colors.black87,
      ),
      body: Column(
        children: [
          // Divider below AppBar
          Container(
            height: 1,
            color: isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade300,
          ),

          const Spacer(),

          // Center Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logout Icon inside a container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, size: 80, color: Colors.red),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "Are you sure you want to log out?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                "You'll need to sign in again to access your account.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDarkTheme ? Colors.grey.shade600 : Colors.grey,
                ),
              ),
              const SizedBox(height: 40),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      try {
                        await FirebaseAuth.instance.signOut();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              'Logout failed: $e',
                              style: isDarkTheme
                                  ? TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)
                                  : TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SplashScreenTo(
                            screen: Onboardingview(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Log Out",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Colors.grey, width: 1.2),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkTheme ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),
        ],
      ),
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
    );
  }
}
