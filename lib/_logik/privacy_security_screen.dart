// import 'package:farmket/_logik/Ui_bridges/splash_screen_to.dart';
// import 'package:farmket/main_codes/onboarding_screens/onboardingview.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class PrivacySecurityScreen extends StatefulWidget {
//   const PrivacySecurityScreen({super.key});

//   @override
//   State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
// }

// class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
//   final LocalAuthentication auth = LocalAuthentication();

//   /// Toggle biometric login
//   Future<void> _toggleBiometric(bool value) async {
//     if (value) {
//       try {
//         bool canCheckBiometrics = await auth.canCheckBiometrics;
//         bool isDeviceSupported = await auth.isDeviceSupported();

//         if (!canCheckBiometrics || !isDeviceSupported) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Biometric not supported on this device"),
//             ),
//           );
//           return;
//         }

//         bool didAuthenticate = await auth.authenticate(
//           localizedReason: 'Scan your fingerprint to enable biometric login',
//           options: const AuthenticationOptions(
//             biometricOnly: true,
//             stickyAuth: true,
//           ),
//         );

//         if (didAuthenticate) {
//           await _saveBiometricPreference(true);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Biometric login enabled"),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } catch (e) {
//         debugPrint("Biometric error: $e");
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Failed to enable biometric login"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } else {
//       await _saveBiometricPreference(false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Biometric login disabled"),
//         ),
//       );
//     }
//   }

//   Future<void> _saveBiometricPreference(bool enabled) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .update({'biometricEnabled': enabled});
//     }
//   }

//   /// Confirm delete account
//   void _confirmDeleteAccount() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: const Text("Delete Account"),
//         content: const Text(
//           "Are you sure you want to delete your account? "
//           "This action cannot be undone.",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             onPressed: () async {
//               Navigator.pop(ctx);
//               await _deleteAccount();
//             },
//             child: const Text("Delete"),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Delete account from Firebase
//   Future<void> _deleteAccount() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       // Determine the provider
//       final providerId =
//           user.providerData.isNotEmpty ? user.providerData[0].providerId : null;

//       AuthCredential? credential;

//       if (providerId == 'password') {
//         // Email/Password user → ask for password again
//         String? password =
//             await _askUserPassword(); // implement a dialog to ask password
//         if (password == null) return;

//         credential = EmailAuthProvider.credential(
//             email: user.email!, password: password);
//       } else if (providerId == 'google.com') {
//         // Google user → re-sign in with Google
//         final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//         if (googleUser == null) return; // user cancelled

//         final GoogleSignInAuthentication googleAuth =
//             await googleUser.authentication;
//         credential = GoogleAuthProvider.credential(
//           accessToken: googleAuth.accessToken,
//           idToken: googleAuth.idToken,
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Unsupported login provider for deletion"),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       // Re-authenticate
//       await user.reauthenticateWithCredential(credential);

//       // Delete Firestore data
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .delete();

//       // Delete Auth account
//       await user.delete();

//       // Navigate to onboarding
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SplashScreenTo(screen: Onboardingview()),
//         ),
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Account deleted"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } catch (e) {
//       debugPrint("Delete account error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to delete account: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<String?> _askUserPassword() async {
//     String? password;
//     await showDialog(
//       context: context,
//       builder: (ctx) {
//         final TextEditingController passCtrl = TextEditingController();
//         return AlertDialog(
//           title: const Text("Confirm Password"),
//           content: TextField(
//             controller: passCtrl,
//             obscureText: true,
//             decoration: const InputDecoration(labelText: "Password"),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(ctx).pop();
//               },
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 password = passCtrl.text.trim();
//                 Navigator.of(ctx).pop();
//               },
//               child: const Text("Confirm"),
//             ),
//           ],
//         );
//       },
//     );
//     return password;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final user = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Privacy & Security"),
//         centerTitle: true,
//       ),
//       body: user == null
//           ? const Center(child: Text("Not logged in"))
//           : StreamBuilder<DocumentSnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(user.uid)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || !snapshot.data!.exists) {
//                   return const Center(child: Text("User data not found"));
//                 }

//                 final data =
//                     snapshot.data!.data() as Map<String, dynamic>? ?? {};
//                 final biometricEnabled = data['biometricEnabled'] ?? false;

//                 return Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       // Biometric toggle
//                       Card(
//                         elevation: 3,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: SwitchListTile(
//                           title: const Text("Enable Fingerprint Login"),
//                           subtitle: const Text("Use fingerprint to sign in"),
//                           value: biometricEnabled,
//                           activeColor: Colors.green,
//                           onChanged: _toggleBiometric,
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       // Delete account
//                       Card(
//                         color:
//                             isDark ? Colors.red.shade900 : Colors.red.shade50,
//                         elevation: 3,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: ListTile(
//                           leading: Icon(Icons.delete_forever,
//                               color: isDark ? Colors.red[300] : Colors.red),
//                           title: const Text(
//                             "Delete Account",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           subtitle:
//                               const Text("Permanently remove your account"),
//                           onTap: _confirmDeleteAccount,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:local_auth/local_auth.dart';

// // class PrivacySecurityScreen extends StatefulWidget {
// //   const PrivacySecurityScreen({super.key});

// //   @override
// //   State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
// // }

// // class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
// //   final LocalAuthentication auth = LocalAuthentication();
// //   bool _biometricEnabled = false;
// //   bool _loading = true; // show loading state until Firestore fetch finishes

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadBiometricPreference();
// //   }

// //   /// Load saved biometric preference from Firestore
// //   Future<void> _loadBiometricPreference() async {
// //     final user = FirebaseAuth.instance.currentUser;
// //     if (user != null) {
// //       final doc = await FirebaseFirestore.instance
// //           .collection('users')
// //           .doc(user.uid)
// //           .get();

// //       if (doc.exists && doc.data() != null) {
// //         final data = doc.data()!;
// //         if (data.containsKey('biometricEnabled')) {
// //           setState(() {
// //             _biometricEnabled = data['biometricEnabled'] ?? false;
// //           });
// //         }
// //       }
// //     }
// //     setState(() => _loading = false);
// //   }

// //   /// Authenticate with fingerprint and toggle
// //   Future<void> _toggleBiometric(bool value) async {
// //     if (value) {
// //       try {
// //         bool canCheckBiometrics = await auth.canCheckBiometrics;
// //         bool isDeviceSupported = await auth.isDeviceSupported();

// //         if (!canCheckBiometrics || !isDeviceSupported) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //               content: Text("Biometric not supported on this device"),
// //             ),
// //           );
// //           return;
// //         }

// //         bool didAuthenticate = await auth.authenticate(
// //           localizedReason: 'Scan your fingerprint to enable biometric login',
// //           options: const AuthenticationOptions(
// //             biometricOnly: true,
// //             stickyAuth: true,
// //           ),
// //         );

// //         if (didAuthenticate) {
// //           setState(() => _biometricEnabled = true);
// //           await _saveBiometricPreference(true);
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //               content: Text("Biometric login enabled"),
// //               backgroundColor: Colors.green,
// //             ),
// //           );
// //         }
// //       } catch (e) {
// //         debugPrint("Biometric error: $e");
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text("Failed to enable biometric login"),
// //             backgroundColor: Colors.red,
// //           ),
// //         );
// //       }
// //     } else {
// //       setState(() => _biometricEnabled = false);
// //       await _saveBiometricPreference(false);
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text("Biometric login disabled"),
// //         ),
// //       );
// //     }
// //   }

// //   Future<void> _saveBiometricPreference(bool enabled) async {
// //     final user = FirebaseAuth.instance.currentUser;
// //     if (user != null) {
// //       await FirebaseFirestore.instance
// //           .collection('users')
// //           .doc(user.uid)
// //           .update({'biometricEnabled': enabled});
// //     }
// //   }

// //   /// Confirm delete account
// //   void _confirmDeleteAccount() {
// //     showDialog(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16),
// //         ),
// //         title: const Text("Delete Account"),
// //         content: const Text(
// //           "Are you sure you want to delete your account? "
// //           "This action cannot be undone.",
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(ctx),
// //             child: const Text("Cancel"),
// //           ),
// //           ElevatedButton(
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: Colors.red,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //             ),
// //             onPressed: () async {
// //               Navigator.pop(ctx);
// //               await _deleteAccount();
// //             },
// //             child: const Text("Delete"),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   /// Delete account from Firebase
// //   Future<void> _deleteAccount() async {
// //     try {
// //       final user = FirebaseAuth.instance.currentUser;

// //       if (user != null) {
// //         // Delete user data in Firestore if you have user collection
// //         await FirebaseFirestore.instance
// //             .collection('users')
// //             .doc(user.uid)
// //             .delete();

// //         // Delete FirebaseAuth account
// //         await user.delete();

// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text("Account deleted"),
// //             backgroundColor: Colors.red,
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       debugPrint("Delete account error: $e");
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text("Failed to delete account"),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final isDark = Theme.of(context).brightness == Brightness.dark;

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Privacy & Security"),
// //         centerTitle: true,
// //       ),
// //       body: _loading
// //           ? const Center(child: CircularProgressIndicator())
// //           : Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Column(
// //                 children: [
// //                   // Biometric toggle
// //                   Card(
// //                     elevation: 3,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(16),
// //                     ),
// //                     child: SwitchListTile(
// //                       title: const Text("Enable Fingerprint Login"),
// //                       subtitle: const Text("Use fingerprint to sign in"),
// //                       value: _biometricEnabled,
// //                       activeColor: Colors.green,
// //                       onChanged: _toggleBiometric,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 20),

// //                   // Delete account
// //                   Card(
// //                     color: isDark ? Colors.red.shade900 : Colors.red.shade50,
// //                     elevation: 3,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(16),
// //                     ),
// //                     child: ListTile(
// //                       leading: Icon(Icons.delete_forever,
// //                           color: isDark ? Colors.red[300] : Colors.red),
// //                       title: const Text(
// //                         "Delete Account",
// //                         style: TextStyle(fontWeight: FontWeight.bold),
// //                       ),
// //                       subtitle: const Text("Permanently remove your account"),
// //                       onTap: _confirmDeleteAccount,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //     );
// //   }
// // }
