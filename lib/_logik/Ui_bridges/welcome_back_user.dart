// import 'package:flutter/material.dart';
// import 'dart:math';

// class WelcomeBackUser extends StatefulWidget {
//   final String userType;
//   const WelcomeBackUser({super.key, required this.userType});

//   @override
//   State<WelcomeBackUser> createState() => _WelcomeBackUserState();
// }

// class _WelcomeBackUserState extends State<WelcomeBackUser> {
//   // List of image assets
//   final List<String> imageAssets = [
//     'assets/avatars/h.png',
//     'assets/avatars/j.png',
//     'assets/avatars/h.png',
//     'assets/avatars/j.png',
//     'assets/avatars/h.png',
//     'assets/avatars/j.png',
//     'assets/avatars/h.png',
//     'assets/avatars/j.png',
//     'assets/avatars/a.jpeg',
//     'assets/avatars/b.jpg',
//     'assets/avatars/c.jpg',
//     'assets/avatars/d.jpg',
//     'assets/avatars/e.jpg',
//     'assets/avatars/f.png',
//     'assets/avatars/g.png',
//     'assets/avatars/h.png',
//     'assets/avatars/i.png',
//     'assets/avatars/j.png',
//   ];

//   @override
//   void initState() {
//     super.initState();

//     // Navigate to another screen after 3 Sec,
//     Future.delayed(const Duration(seconds: 3), () {
//       String usertype = widget.userType;

//       // if (usertype == 'Seller') {
//       //   // Navigate to Seller's home page
//       //   Navigator.pushReplacement(
//       //       context,
//       //       MaterialPageRoute(
//       //           builder: (context) => GenHomePage(
//       //                 userType: 'Seller',
//       //               )));
//       // } else {
//       //   // Navigate to Buyer's home page
//       //   Navigator.pushReplacement(
//       //       context,
//       //       MaterialPageRoute(
//       //           builder: (context) => GenHomePage(
//       //                 userType: 'Buyer',
//       //               )));
//       // }
//     });
//   }

//   // Function to get a random image
//   String getRandomImage() {
//     final random = Random();
//     return imageAssets[random.nextInt(imageAssets.length)];
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get a random image each time the widget is built
//     // String randomImage = getRandomImage();
//     var theme = getThemeColors();
//     final random = Random();
//     String randomImage = imageAssets[random.nextInt(imageAssets.length)];

//     return Scaffold(
//       body: Center(
//         child: Stack(
//           children: [
//             //background image
//             Container(
//               decoration: bkgndcolor_grad,
//             ),
//             Container(
//               alignment: Alignment.center,
//               margin: const EdgeInsets.symmetric(vertical: 30),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(
//                     height: 9,
//                   ),
//                   TypewriterTextCustom(
//                     textchoice: "WELCOME",
//                     fontsizee: 44,
//                     bold: true,
//                     millisecspd: 180,
//                     color: theme.textColor,
//                   ),
//                   const SizedBox(
//                     height: 9,
//                   ),
//                   const TypewriterTextCustom(
//                       textchoice: "BACK",
//                       fontsizee: 40,
//                       bold: true,
//                       color: auxColor,
//                       millisecspd: 180),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   ClipOval(
//                       child: Image.asset(
//                     randomImage,
//                     width: 250.0,
//                     height: 250.0,
//                     fit: BoxFit.cover,
//                   )),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
