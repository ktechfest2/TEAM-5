import 'package:aurion_hotel/_components/color.dart';
import 'package:aurion_hotel/_logik/Ui_bridges/splash_screen_to.dart';
import 'package:aurion_hotel/_logik/Ui_bridges/welcome_new_user.dart';
import 'package:aurion_hotel/_logik/email_service.dart';
import 'package:aurion_hotel/_logik/notification_services.dart';
import 'package:aurion_hotel/main_codes/HotelHomeScreen.dart';
import 'package:aurion_hotel/main_codes/blogin_page.dart';
import 'package:aurion_hotel/main_codes/introScreen.dart';
// import 'package:aurion_hotel/main_codes/general_home_page.dart';
import 'package:aurion_hotel/main_codes/onboarding_screens/onboardingview.dart';
import 'package:aurion_hotel/main_codes/preference_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:aurion_hotel/_components/color.dart';

class SignupPagee extends StatefulWidget {
  const SignupPagee({super.key});

  @override
  State<SignupPagee> createState() => _SignupPageeState();
}

class _SignupPageeState extends State<SignupPagee> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureRetypePassword = true;
  bool _isFilled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkFields);
    _passwordController.addListener(_checkFields);
    _retypePasswordController.addListener(_checkFields);
  }

  void _checkFields() {
    setState(() {
      _isFilled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _retypePasswordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }

  void showErrormsg(String message) {
    showDialog(
      //hello
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

  void showTermsDialog() async {
    //rollingh dialog stuff while fecthingg
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(color: auxColor),
        );
      },
    );

    String terms = await fetchTermsFromFirestore();
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Terms & Conditions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      terms,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("I Agree"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
            child: CircularProgressIndicator(
          color: auxColor,
        )),
      );

      UserCredential userCredential;

      // if (kIsWeb) {
      // Web sign-in using popup
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      userCredential =
          await FirebaseAuth.instance.signInWithPopup(authProvider);
      // } else {
      //   // Mobile sign-in using GoogleSignIn
      //   final GoogleSignIn googleSignIn = GoogleSignIn();
      //   await googleSignIn.signOut(); // Force account picker

      //   final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      //   if (googleUser == null) {
      //     Navigator.pop(context); // Close loading
      //     return;
      //   }

      //   final GoogleSignInAuthentication googleAuth =
      //       await googleUser.authentication;

      //   final credential = GoogleAuthProvider.credential(
      //     accessToken: googleAuth.accessToken,
      //     idToken: googleAuth.idToken,
      //   );

      //   userCredential =
      //       await FirebaseAuth.instance.signInWithCredential(credential);
      // }

      // User info
      String uid = userCredential.user!.uid;
      String name = userCredential.user!.displayName ?? 'No Name';
      String email = userCredential.user!.email ?? 'No Email';

      final docRef = FirebaseFirestore.instance.collection("users").doc(uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          "name": name,
          "email": email,
          "legalname": "",
          "uid": uid,
          "phone": "",
          "idType": "",
          "idDocumentUrl": "",
          "verified": false,
          "fraudScore": 0,
          "preferences": [],
          "isActive": false,
          "currentRoomId": "",
          "bookingHistory": [],
          "orders": [],
          "churnRisk": 0.0,
          "country": "",
          "state": "",
          "createdAt": FieldValue.serverTimestamp(),
          "lastSeen": FieldValue.serverTimestamp(),
        });
      }

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setString('user_uid', uid);

      Navigator.pop(context); // Close loading dialog

      // Check registration completeness
      final data = (await docRef.get()).data() ?? {};
      final idurl = data['idDocumentUrl'];
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
        // User is verified but hasn't completed verification
        await sendSignupEmail(email, name);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SplashScreenTo(screen: VerificationFlowScreen()),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      showErrormsg("Failed to sign in with Google");
      print("❌ Google Sign-In error: $e");
    }
  }

  Future<String> fetchTermsFromFirestore() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('terms_conditions')
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['content'] ?? "";
    } else {
      return "No terms available.";
    }
  }

  void userRegister(
    // String name,
    String email,
    String pwd,
    String confirmPwd,
    bool termsCnd,
  ) async {
    if (!termsCnd) {
      showErrormsg("Please accept the Terms and Conditions");
      return;
    }

    if (pwd != confirmPwd) {
      showErrormsg("Passwords don't match");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pwd);

      String uid = userCredential.user!.uid;

      // Save user info to Firestore
      final docRef = FirebaseFirestore.instance.collection("users").doc(uid);

      await docRef.set({
        "name": "User", // default name, or get from a text field
        "email": email,
        "legalname": "", //from the AI doc extract later
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

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setString('user_uid', uid);

      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog

      await Future.delayed(const Duration(milliseconds: 100));

      // Check registration completeness
      final data = (await docRef.get()).data() ?? {};
      final idurl = data['idDocumentUrl'];

      final pref = data['preferences'] as List<dynamic>? ?? [];

      final bool isVerified = idurl != null &&
          idurl.toString().trim().isNotEmpty &&
          data['verified'] == true;

      final bool hasPreferences = pref.isNotEmpty;

      if (mounted) {
        if (isVerified && hasPreferences) {
          await sendLoginAlertEmail(email, "User"); //login email alert
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
          await sendSignupEmail(email, "");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SplashScreenTo(screen: PreferencesScreen()),
            ),
          );
        } else {
          await sendSignupEmail(
              email, "User"); //email notification during signup completion
          // createNotification(
          //   title: "New User",
          //   message: "A new user has signed in",
          //   type: "users",
          //   // actionId: orderId,
          // );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SplashScreenTo(screen: VerificationFlowScreen()),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context, rootNavigator: true).pop();

      String message = "Signup failed. Try again.";
      if (e.code == 'email-already-in-use') {
        message = "Email is already in use.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address.";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak.";
      }

      print("❌ FirebaseAuthException: ${e.code}");
      showErrormsg(message);
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print("❌ Unexpected error: $e");
      showErrormsg("An unexpected error occurred. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Onboardingview()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1A2F), // Midnight Navy
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFD4A73B)
                        .withOpacity(0.3), // Gold Accent border
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),

                      // Logo
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFFD4A73B),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage("assets/icon.png"),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Title
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Color(0xFFF8F9FA), // Soft White
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Register to continue your stay",
                        style: TextStyle(
                          color: Color(0xFFF8F9FA),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Email
                      buildDarkInput(
                        controller: _emailController,
                        label: "Email",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Password
                      buildDarkInput(
                        controller: _passwordController,
                        label: "Create Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        obscure: _obscurePassword,
                        toggle: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      const SizedBox(height: 20),

                      // Retype Password
                      buildDarkInput(
                        controller: _retypePasswordController,
                        label: "Retype Password",
                        icon: Icons.lock_reset_outlined,
                        isPassword: true,
                        obscure: _obscureRetypePassword,
                        toggle: () => setState(() =>
                            _obscureRetypePassword = !_obscureRetypePassword),
                      ),

                      const SizedBox(height: 20),

                      InkWell(
                        onTap: showTermsDialog,
                        child: const Text.rich(
                          TextSpan(
                            text: "By continuing, you agree to our ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFF8F9FA),
                            ),
                            children: [
                              TextSpan(
                                text: "Terms & Conditions",
                                style: TextStyle(
                                  color: Color(0xFFD4A73B),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 9),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4A73B),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                          ),
                          onPressed: _isFilled
                              ? () {
                                  if (_formKey.currentState!.validate()) {
                                    userRegister(
                                      _emailController.text,
                                      _passwordController.text,
                                      _retypePasswordController.text,
                                      true,
                                    );
                                  } else {
                                    setState(() => _autoValidate = true);
                                  }
                                }
                              : null,
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // const SizedBox(height: 30),

                      const SizedBox(height: 12),

// Divider
                      Row(
                        children: const [
                          Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("OR",
                                style: TextStyle(color: Colors.black)),
                          ),
                          Expanded(child: Divider(thickness: 1)),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // Google Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () {
                            signInWithGoogle(context);
                          },
                          icon: Image.asset(
                            "assets/google.png",
                            height: 24,
                            width: 24,
                          ),
                          label: const Text(
                            "Sign Up with Google",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Already have account
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            "Have an account? Sign In",
                            style: TextStyle(
                              color: auxColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
  //         MaterialPageRoute(builder: (context) => const Onboardingview()),
  //       );
  //       return false;
  //     },
  //     child: Scaffold(
  //       backgroundColor: Colors.white, // Light theme background
  //       body: SafeArea(
  //         child: LayoutBuilder(
  //           builder: (context, constraints) {
  //             // Use max width for desktop
  //             double maxWidth =
  //                 constraints.maxWidth > 600 ? 500 : constraints.maxWidth * 0.9;

  //             return Center(
  //               child: SingleChildScrollView(
  //                 child: ConstrainedBox(
  //                   constraints: BoxConstraints(maxWidth: maxWidth),
  //                   child: Form(
  //                     key: _formKey,
  //                     autovalidateMode: _autoValidate
  //                         ? AutovalidateMode.onUserInteraction
  //                         : AutovalidateMode.disabled,
  //                     child: Container(
  //                       padding: const EdgeInsets.symmetric(
  //                           vertical: 30, horizontal: 25),
  //                       decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         borderRadius: BorderRadius.circular(20),
  //                         boxShadow: [
  //                           BoxShadow(
  //                             color: Colors.black.withOpacity(0.05),
  //                             blurRadius: 20,
  //                             spreadRadius: 3,
  //                             offset: const Offset(0, 10),
  //                           ),
  //                         ],
  //                       ),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           const SizedBox(height: 40),
  //                           // Logo
  //                           Center(
  //                             child: Image.asset(
  //                               "assets/icon.jpg",
  //                               height: 150,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 20),

  //                           // Title
  //                           const Text(
  //                             "Sign Up",
  //                             style: TextStyle(
  //                               fontSize: 30,
  //                               fontWeight: FontWeight.bold,
  //                               color: Colors.black,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 8),

  //                           // Subtitle
  //                           const Text(
  //                             "Create a valid account to continue",
  //                             textAlign: TextAlign.center,
  //                             style: TextStyle(
  //                               fontSize: 14,
  //                               color: Colors.black,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 25),

  //                           // Email Field
  //                           TextField(
  //                             controller: _emailController,
  //                             style: const TextStyle(color: Colors.black),
  //                             keyboardType: TextInputType.emailAddress,
  //                             decoration: InputDecoration(
  //                               prefixIcon: const Icon(Icons.email_outlined,
  //                                   color: Colors.black),
  //                               labelText: "Email",
  //                               labelStyle:
  //                                   const TextStyle(color: Colors.black),
  //                               border: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(30),
  //                                 borderSide:
  //                                     const BorderSide(color: Colors.black),
  //                               ),
  //                               enabledBorder: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(30),
  //                                 borderSide:
  //                                     const BorderSide(color: Colors.black),
  //                               ),
  //                               focusedBorder: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(30),
  //                                 borderSide: const BorderSide(
  //                                     color: auxColor, width: 2),
  //                               ),
  //                             ),
  //                           ),
  //                           const SizedBox(height: 15),

  //                           // Password Field
  //                           TextField(
  //                             controller: _passwordController,
  //                             style: const TextStyle(color: Colors.black),
  //                             obscureText: _obscurePassword,
  //                             decoration: InputDecoration(
  //                               prefixIcon: const Icon(Icons.lock_outline,
  //                                   color: Colors.black),
  //                               labelText: "Create Password",
  //                               labelStyle:
  //                                   const TextStyle(color: Colors.black),
  //                               suffixIcon: IconButton(
  //                                 icon: Icon(
  //                                   _obscurePassword
  //                                       ? Icons.visibility_off
  //                                       : Icons.visibility,
  //                                   color: Colors.black,
  //                                 ),
  //                                 onPressed: () {
  //                                   setState(() {
  //                                     _obscurePassword = !_obscurePassword;
  //                                   });
  //                                 },
  //                               ),
  //                               border: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(30),
  //                                 borderSide:
  //                                     const BorderSide(color: Colors.black),
  //                               ),
  //                               enabledBorder: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(30),
  //                                 borderSide:
  //                                     const BorderSide(color: Colors.black),
  //                               ),
  //                               focusedBorder: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(30),
  //                                 borderSide: const BorderSide(
  //                                     color: auxColor, width: 2),
  //                               ),
  //                             ),
  //                           ),
  //                           const SizedBox(height: 15),

  //                           // Retype Password Field
  //                           TextField(
  //                             controller: _retypePasswordController,
  //                             obscureText: _obscureRetypePassword,
  //                             style: const TextStyle(color: Colors.black),
  //                             decoration: InputDecoration(
  //                               prefixIcon: const Icon(
  //                                   Icons.lock_reset_outlined,
  //                                   color: Colors.black),
  //                               labelText: "Retype Password",
  //                               labelStyle:
  //                                   const TextStyle(color: Colors.black),
  //                               suffixIcon: IconButton(
  //                                 icon: Icon(
  //                                   _obscureRetypePassword
  //                                       ? Icons.visibility_off
  //                                       : Icons.visibility,
  //                                   color: Colors.black,
  //                                 ),
  //                                 onPressed: () {
  //                                   setState(() {
  //                                     _obscureRetypePassword =
  //                                         !_obscureRetypePassword;
  //                                   });
  //                                 },
  //                               ),
  //                               border: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(30),
  //                                 borderSide:
  //                                     const BorderSide(color: Colors.black),
  //                               ),
  //                               enabledBorder: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(30),
  //                                 borderSide:
  //                                     const BorderSide(color: Colors.black),
  //                               ),
  //                               focusedBorder: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(30),
  //                                 borderSide: const BorderSide(
  //                                     color: auxColor, width: 2),
  //                               ),
  //                             ),
  //                           ),

  //                           const SizedBox(height: 15),

  //                           // Terms and conditions //from firebaseee
  //                           InkWell(
  //                             onTap: () {
  //                               showTermsDialog();
  //                             },
  //                             child: const Text.rich(
  //                               TextSpan(
  //                                 text: "By continuing, you agree to our ",
  //                                 style: TextStyle(
  //                                     fontSize: 11, color: Colors.black),
  //                                 children: [
  //                                   TextSpan(
  //                                     text: "Terms & Conditions",
  //                                     style: TextStyle(
  //                                       color: auxColor2,
  //                                       fontWeight: FontWeight.bold,
  //                                       decoration: TextDecoration.underline,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               textAlign: TextAlign.center,
  //                             ),
  //                           ),

  //                           const SizedBox(height: 20),

  //                           // Sign Up Button with border
  //                           SizedBox(
  //                             width: double.infinity,
  //                             child: ElevatedButton(
  //                               style: ButtonStyle(
  //                                 backgroundColor:
  //                                     WidgetStateProperty.resolveWith<Color>(
  //                                   (states) {
  //                                     if (states
  //                                         .contains(WidgetState.disabled)) {
  //                                       return Colors
  //                                           .black; // inactive state background
  //                                     }
  //                                     return auxColor; // active state background
  //                                   },
  //                                 ),
  //                                 foregroundColor:
  //                                     WidgetStateProperty.all<Color>(
  //                                         Colors.white),
  //                                 shape: WidgetStateProperty.all<
  //                                     RoundedRectangleBorder>(
  //                                   RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.circular(30),
  //                                     side: BorderSide(
  //                                       color:
  //                                           _isFilled ? auxColor : Colors.black,
  //                                       width: 2,
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 padding: WidgetStateProperty.all<EdgeInsets>(
  //                                   const EdgeInsets.symmetric(vertical: 15),
  //                                 ),
  //                               ),
  //                               onPressed: _isFilled
  //                                   ? () {
  //                                       if (_formKey.currentState!.validate()) {
  //                                         userRegister(
  //                                           // usernameController.text,
  //                                           _emailController.text,
  //                                           _passwordController.text,
  //                                           _retypePasswordController.text,
  //                                           true,
  //                                         );
  //                                       } else {
  //                                         setState(() {
  //                                           _autoValidate = true;
  //                                         });
  //                                       }
  //                                     }
  //                                   : null,
  //                               child: const Text(
  //                                 "Sign Up",
  //                                 style: TextStyle(fontSize: 18),
  //                               ),
  //                             ),
  //                           ),

  //                           // const SizedBox(height: 50),

  //                           const SizedBox(height: 12),

  //                           // Divider
  //                           Row(
  //                             children: const [
  //                               Expanded(child: Divider(thickness: 1)),
  //                               Padding(
  //                                 padding: EdgeInsets.symmetric(horizontal: 10),
  //                                 child: Text("OR",
  //                                     style: TextStyle(color: Colors.black)),
  //                               ),
  //                               Expanded(child: Divider(thickness: 1)),
  //                             ],
  //                           ),

  //                           const SizedBox(height: 12),

  //                           // Google Button
  //                           SizedBox(
  //                             width: double.infinity,
  //                             child: OutlinedButton.icon(
  //                               style: OutlinedButton.styleFrom(
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(30),
  //                                 ),
  //                                 padding:
  //                                     const EdgeInsets.symmetric(vertical: 15),
  //                               ),
  //                               onPressed: () {
  //                                 signInWithGoogle(context);
  //                               },
  //                               icon: Image.asset(
  //                                 "assets/google.png",
  //                                 height: 24,
  //                                 width: 24,
  //                               ),
  //                               label: const Text(
  //                                 "Sign Up with Google",
  //                                 style: TextStyle(
  //                                     fontSize: 16, color: Colors.black),
  //                               ),
  //                             ),
  //                           ),

  //                           const SizedBox(height: 20),

  //                           // Already have account
  //                           GestureDetector(
  //                             onTap: () {
  //                               Navigator.pushReplacement(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                     builder: (context) => const LoginPage()),
  //                               );
  //                             },
  //                             child: const Padding(
  //                               padding: EdgeInsets.only(bottom: 20),
  //                               child: Text(
  //                                 "Have an account? Sign In",
  //                                 style: TextStyle(
  //                                   color: auxColor,
  //                                   fontWeight: FontWeight.bold,
  //                                   fontSize: 16,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget buildDarkInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Color(0xFFF8F9FA)), // Soft White
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFF8F9FA)),
        prefixIcon: Icon(icon, color: Color(0xFFD4A73B)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFFD4A73B),
                ),
                onPressed: toggle,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFD4A73B), width: 2),
        ),
      ),
    );
  }
}
