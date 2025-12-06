import 'package:aurion_hotel/_components/color.dart';
import 'package:aurion_hotel/main_codes/HotelHomeScreen.dart';
import 'package:aurion_hotel/main_codes/introScreen.dart';
import 'package:aurion_hotel/main_codes/onboarding_screens/onboardingview.dart';
import 'package:aurion_hotel/main_codes/preference_Screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  /// Check if biometric login is enabled
  Future<bool> _checkBiometricLogin(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final biometricEnabled = doc.data()?['biometricEnabled'] ?? false;

    if (!biometricEnabled) return true;

    final localAuth = LocalAuthentication();
    try {
      return await localAuth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options:
            const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }

  /// Decide which screen to navigate to based on Firestore user data
  Future<Widget> _handleUserRedirection(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = userDoc.data();

    if (data == null) return const Onboardingview();

    final bool verified = data['verified'] as bool? ?? false;
    final List prefs = data['preferences'] as List? ?? [];

    if (!verified) {
      return const VerificationFlowScreen();
    }

    if (prefs.isEmpty) {
      return const PreferencesScreen();
    }

    // All good → navigate to main screen
    return const HotelHomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: auxColor)),
          );
        }

        if (!snapshot.hasData) {
          return const Onboardingview();
        }

        final user = snapshot.data!;

        return FutureBuilder<bool>(
          future: _checkBiometricLogin(user.uid),
          builder: (context, bioSnapshot) {
            if (bioSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: CircularProgressIndicator(color: auxColor)),
              );
            }

            if (bioSnapshot.hasData && bioSnapshot.data == true) {
              return FutureBuilder<Widget>(
                future: _handleUserRedirection(user.uid),
                builder: (context, redirectSnapshot) {
                  if (redirectSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      backgroundColor: Colors.white,
                      body: Center(
                          child: CircularProgressIndicator(color: auxColor)),
                    );
                  }

                  return redirectSnapshot.data ?? const Onboardingview();
                },
              );
            }

            // Biometric failed → fallback
            return const Onboardingview();
          },
        );
      },
    );
  }
}
