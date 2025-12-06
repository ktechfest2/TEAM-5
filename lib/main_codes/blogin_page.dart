import 'package:aurion_hotel/_components/color.dart';
import 'package:aurion_hotel/_logik/Ui_bridges/splash_screen_to.dart';
import 'package:aurion_hotel/_logik/Ui_bridges/welcome_back_user.dart';
import 'package:aurion_hotel/_logik/Ui_bridges/welcome_new_user.dart';
import 'package:aurion_hotel/_logik/email_service.dart';
import 'package:aurion_hotel/main_codes/HotelHomeScreen.dart';
import 'package:aurion_hotel/main_codes/bsignup_pagge.dart';
// import 'package:aurion_hotel/main_codes/cintro_screen.dart';
import 'package:aurion_hotel/main_codes/forgotpassword.dart';
import 'package:aurion_hotel/main_codes/introScreen.dart';
import 'package:aurion_hotel/main_codes/onboarding_screens/onboardingview.dart';
import 'package:aurion_hotel/main_codes/preference_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isFilled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkFields);
    _passwordController.addListener(_checkFields);
  }

  void _checkFields() {
    setState(() {
      _isFilled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor:
              Colors.black.withOpacity(0.8), // Dark background with opacity
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline, // Error icon
                  color: Colors.redAccent,
                  size: 40,
                ),
                const SizedBox(height: 15),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white, // White text for contrast
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';

    // Use Firebase's built-in validation for emails (more lenient than regex)
    const emailRegex = r'^[^@]+@[^@]+\.[^@]+$';
    if (!RegExp(emailRegex).hasMatch(value)) {
      String emailError = 'Enter a valid email address';
      return emailError;
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      UserCredential userCredential;

      // if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      userCredential =
          await FirebaseAuth.instance.signInWithPopup(authProvider);
      // }
      // final GoogleSignIn googleSignIn = GoogleSignIn();

      // // Force account picker
      // await googleSignIn.signOut();

      // GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // if (googleUser == null) {
      //   Navigator.pop(context);
      //   return;
      // }

      // final GoogleSignInAuthentication googleAuth =
      //     await googleUser.authentication;

      // final credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth.accessToken,
      //   idToken: googleAuth.idToken,
      // );

      // userCredential =
      //     await FirebaseAuth.instance.signInWithCredential(credential);

      String uid = userCredential.user!.uid;
      String name = userCredential.user!.displayName ?? "User";
      String email = userCredential.user!.email ?? "Email not found";

      final docRef = FirebaseFirestore.instance.collection("users").doc(uid);
      DocumentSnapshot userDoc = await docRef.get();

      // If the user doc doesn't exist, create a base one
      if (!userDoc.exists) {
        await docRef.set({
          "name": name, // default name, or get from a text field
          "email": email,
          "legalname": "",
          "uid": uid,
          "phone": "",
          "idType": "",
          "idDocumentUrl": "",
          "verified": false,
          "fraudScore": 0,
          "preferences": [],
          "isActive": false, //active in the room
          "currentRoomId": "",
          "bookingHistory": [],
          "orders": [],
          "churnRisk": 0.0,
          "country": "",
          "state": "",
          "createdAt": FieldValue.serverTimestamp(),
          "lastSeen": FieldValue.serverTimestamp(),
        });
        await sendSignupEmail(
            email, name); //email notification during signup completion
        Navigator.pop(context);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) =>
        //           const SplashScreenTo(screen: WelcomeSplashscreen())),
        // );
        return;
      }

      // Extract existing data
      final data = userDoc.data() as Map<String, dynamic>;
      // final role = data['role'];

      // Check registration completeness
      // final data = (await docRef.get()).data() ?? {};
      final idurl = data['idDocumentUrl'];

      final bool isVerfied = idurl != null &&
          idurl.toString().trim().isNotEmpty &&
          data['verified'] == true;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_uid', uid);
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);

      Navigator.pop(context); // Close loading

      final pref = data['preferences'] as List<dynamic>? ?? [];

      final bool isVerified = idurl != null &&
          idurl.toString().trim().isNotEmpty &&
          data['verified'] == true;

      final bool hasPreferences = pref.isNotEmpty;

      if (isVerified && hasPreferences) {
        await sendLoginAlertEmail(email, "User");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SplashScreenTo(
              screen: HotelHomeScreen(),
            ),
          ),
        );
      } else if (!hasPreferences) {
        // User needs to set preferences
        await sendSignupEmail(email, name);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SplashScreenTo(screen: PreferencesScreen()),
          ),
        );
      } else {
        // Redirect to IntroScreen to complete missing role/country/state
        await sendLoginAlertEmail(email, name); //login email alert
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const SplashScreenTo(screen: VerificationFlowScreen()),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorMessage("Failed to Login with Google: ${e.toString()}");
      print("❌ Login error: $e");
    }
  }

  void userLogin() async {
    if (_formKey.currentState!.validate()) {
      // Show loading spinner
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: auxColor),
        ),
      );

      try {
        // Attempt Firebase login
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Get user UID
        String uid = userCredential.user!.uid;

        // Fetch user data from Firestore
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection("users").doc(uid).get();

        if (!userDoc.exists) {
          Navigator.pop(context);
          showErrorMessage("User not found. Try signing up.");
          return;
        }

        final data = userDoc.data() as Map<String, dynamic>;
        final name = data['name'] ?? '';
        final email = data['email'] ?? '';
        final idurl = data['idDocumentUrl'];
        final bool isVerfied = idurl != null &&
            idurl.toString().trim().isNotEmpty &&
            data['verified'] == true;

        // Save data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_uid', uid);
        await prefs.setString('user_name', name);
        await prefs.setString('user_email', email);

        Navigator.pop(context); // Close loading

        final pref = data['preferences'] as List<dynamic>? ?? [];

        final bool isVerified = idurl != null &&
            idurl.toString().trim().isNotEmpty &&
            data['verified'] == true;

        final bool hasPreferences = pref.isNotEmpty;

        if (isVerified && hasPreferences) {
          await sendLoginAlertEmail(email, "User");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SplashScreenTo(
                screen: HotelHomeScreen(),
              ),
            ),
          );
        } else if (!hasPreferences) {
          // User needs to set preferences
          await sendSignupEmail(email, name);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SplashScreenTo(screen: PreferencesScreen()),
            ),
          );
        } else {
          // Incomplete profile → Go to onboarding
          await sendLoginAlertEmail(email, name); //login email alert
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const SplashScreenTo(screen: IntroScreen()),
          //   ),
          // );
        }
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context); // Close loading spinner

        String errorMsg = "An unknown error occurred.";
        print('Error Code: ${e.code}');
        switch (e.code) {
          case 'user-not-found':
            errorMsg = "No user found for that email.";
            break;
          case 'wrong-password':
            errorMsg = "Incorrect password.";
            break;
          case 'invalid-email':
            errorMsg = "Invalid email address.";
            break;
          case 'invalid-credential':
            errorMsg = "Login Failed. Check Your Email or Password.";
            break;
          default:
            errorMsg = e.message ?? "Please try again later.";
        }
        showErrorMessage(errorMsg);
      } catch (e) {
        Navigator.pop(context);
        showErrorMessage("Unexpected error: ${e.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const SplashScreenTo(screen: Onboardingview())),
        );
        return false;
      },
      child: Scaffold(
        // Dark aesthetic gradient background
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A1A2F), // deep navy
                Color(0xFF081421), // darker fade
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double maxWidth = constraints.maxWidth > 600
                  ? 480
                  : constraints.maxWidth * 0.92;

              return Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 35),

                          /// APP LOGO
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white.withOpacity(0.12),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  const AssetImage("assets/icon.png"),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// TITLE
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "Sign in to continue",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 28),

                          /// EMAIL INPUT
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: Colors.white70),
                              labelText: "Email",
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.08),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide:
                                    const BorderSide(color: auxColor, width: 2),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          /// PASSWORD INPUT
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: _validatePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: Colors.white70),
                              labelText: "Password",
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.08),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide:
                                    const BorderSide(color: auxColor, width: 2),
                              ),
                            ),
                          ),

                          /// FORGOT PASSWORD
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordPage()),
                                );
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: auxColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          /// LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isFilled ? userLogin : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFilled
                                    ? auxColor
                                    : auxColor.withOpacity(0.3),
                                disabledBackgroundColor:
                                    auxColor.withOpacity(0.25),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          /// DIVIDER
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.white24),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text("OR",
                                    style: TextStyle(color: Colors.white70)),
                              ),
                              Expanded(
                                child: Divider(color: Colors.white24),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          /// GOOGLE SIGN IN
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => loginWithGoogle(context),
                              icon: Image.asset(
                                "assets/google.png",
                                height: 22,
                              ),
                              label: const Text(
                                "Continue with Google",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          /// SIGN UP LINK
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.white70),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignupPagee()),
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: auxColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return WillPopScope(
  //     onWillPop: () async {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) =>
  //                 const SplashScreenTo(screen: Onboardingview())),
  //       );
  //       return false;
  //     },
  //     child: Scaffold(
  //       backgroundColor: Colors.white, // light theme background
  //       body: Form(
  //         key: _formKey,
  //         child: SafeArea(
  //           child: SingleChildScrollView(
  //             physics: const BouncingScrollPhysics(),
  //             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 // Logo
  //                 SizedBox(
  //                   height: 180,
  //                   child: Image.asset("assets/icon.jpg", fit: BoxFit.contain),
  //                 ),

  //                 const Text(
  //                   "Sign In",
  //                   style: TextStyle(
  //                     fontSize: 28,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black,
  //                   ),
  //                 ),

  //                 const SizedBox(height: 5),

  //                 const Text(
  //                   "Enter a valid email and password to continue",
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(fontSize: 13, color: Colors.black87),
  //                 ),

  //                 const SizedBox(height: 25),

  //                 // Email Field
  //                 TextFormField(
  //                   controller: _emailController,
  //                   style: const TextStyle(color: Colors.black),
  //                   keyboardType: TextInputType.emailAddress,
  //                   validator: _validateEmail,
  //                   decoration: InputDecoration(
  //                     prefixIcon:
  //                         const Icon(Icons.email_outlined, color: Colors.black),
  //                     labelText: "Email",
  //                     labelStyle: const TextStyle(color: Colors.black),
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(30),
  //                       borderSide: const BorderSide(color: Colors.black),
  //                     ),
  //                     enabledBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(30),
  //                       borderSide: const BorderSide(color: Colors.black),
  //                     ),
  //                     focusedBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(30),
  //                       borderSide:
  //                           const BorderSide(color: Colors.green, width: 2),
  //                     ),
  //                   ),
  //                 ),

  //                 const SizedBox(height: 15),

  //                 // Password Field
  //                 TextFormField(
  //                   controller: _passwordController,
  //                   style: const TextStyle(color: Colors.black),
  //                   obscureText: _obscurePassword,
  //                   validator: _validatePassword,
  //                   decoration: InputDecoration(
  //                     prefixIcon:
  //                         const Icon(Icons.lock_outline, color: Colors.black),
  //                     labelText: "Password",
  //                     labelStyle: const TextStyle(color: Colors.black),
  //                     suffixIcon: IconButton(
  //                       icon: Icon(
  //                         _obscurePassword
  //                             ? Icons.visibility_off
  //                             : Icons.visibility,
  //                         color: Colors.black,
  //                       ),
  //                       onPressed: () {
  //                         setState(() {
  //                           _obscurePassword = !_obscurePassword;
  //                         });
  //                       },
  //                     ),
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(30),
  //                       borderSide: const BorderSide(color: Colors.black),
  //                     ),
  //                     enabledBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(30),
  //                       borderSide: const BorderSide(color: Colors.black),
  //                     ),
  //                     focusedBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(30),
  //                       borderSide:
  //                           const BorderSide(color: Colors.green, width: 2),
  //                     ),
  //                   ),
  //                 ),

  //                 Align(
  //                   alignment: Alignment.centerRight,
  //                   child: TextButton(
  //                     onPressed: () {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                             builder: (context) => const ForgotPasswordPage()),
  //                       );
  //                     },
  //                     child: const Text(
  //                       "Forgot Password?",
  //                       style: TextStyle(color: Colors.green),
  //                     ),
  //                   ),
  //                 ),

  //                 const SizedBox(height: 10),

  //                 // Login Button
  //                 SizedBox(
  //                   width: double.infinity,
  //                   child: ElevatedButton(
  //                     style: ButtonStyle(
  //                       backgroundColor: WidgetStateProperty.resolveWith<Color>(
  //                         (states) {
  //                           if (states.contains(WidgetState.disabled)) {
  //                             return Colors.black; // inactive
  //                           }
  //                           return Colors.green; // active
  //                         },
  //                       ),
  //                       foregroundColor:
  //                           WidgetStateProperty.all<Color>(Colors.white),
  //                       shape: WidgetStateProperty.all<RoundedRectangleBorder>(
  //                         RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(30),
  //                           side: BorderSide(
  //                             color: _isFilled ? Colors.green : Colors.black,
  //                             width: 2,
  //                           ),
  //                         ),
  //                       ),
  //                       padding: WidgetStateProperty.all<EdgeInsets>(
  //                         const EdgeInsets.symmetric(vertical: 15),
  //                       ),
  //                     ),
  //                     onPressed: _isFilled
  //                         ? () {
  //                             userLogin();
  //                           }
  //                         : null,
  //                     child: const Text(
  //                       "Login",
  //                       style: TextStyle(fontSize: 18),
  //                     ),
  //                   ),
  //                 ),

  //                 const SizedBox(height: 20),

  //                 // Divider
  //                 Row(
  //                   children: const [
  //                     Expanded(child: Divider(thickness: 1)),
  //                     Padding(
  //                       padding: EdgeInsets.symmetric(horizontal: 10),
  //                       child:
  //                           Text("OR", style: TextStyle(color: Colors.black)),
  //                     ),
  //                     Expanded(child: Divider(thickness: 1)),
  //                   ],
  //                 ),

  //                 const SizedBox(height: 20),

  //                 // Google Button
  //                 SizedBox(
  //                   width: double.infinity,
  //                   child: OutlinedButton.icon(
  //                     style: OutlinedButton.styleFrom(
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(30),
  //                       ),
  //                       padding: const EdgeInsets.symmetric(vertical: 15),
  //                     ),
  //                     onPressed: () => loginWithGoogle(context),
  //                     icon: Image.asset(
  //                       "assets/google.png",
  //                       height: 24,
  //                       width: 24,
  //                     ),
  //                     label: const Text(
  //                       "Sign in with Google",
  //                       style: TextStyle(fontSize: 16, color: Colors.black),
  //                     ),
  //                   ),
  //                 ),

  //                 const SizedBox(height: 30),

  //                 // Sign Up
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     const Text("Don't have an account?",
  //                         style: TextStyle(color: Colors.black)),
  //                     GestureDetector(
  //                       onTap: () {
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                               builder: (context) => const SignupPagee()),
  //                         );
  //                       },
  //                       child: const Text(
  //                         " Sign Up",
  //                         style: TextStyle(
  //                           color: Colors.green,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
