import 'package:aurion_hotel/_components/color.dart';
import 'package:aurion_hotel/_logik/Ui_bridges/splash_screen_to.dart';
import 'package:aurion_hotel/main_codes/asplash_screen.dart';
import 'package:aurion_hotel/main_codes/blogin_page.dart';
import 'package:aurion_hotel/main_codes/bsignup_pagge.dart';
import 'package:aurion_hotel/main_codes/onboarding_screens/onboarding_items.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';

class Onboardingview extends StatefulWidget {
  const Onboardingview({super.key});

  @override
  State<Onboardingview> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<Onboardingview> {
  final controller = OnboardingItems();
  final pageController = PageController();
  bool isLastPage = false;

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND GIF / LOTTIE FULLSCREEN
          PageView.builder(
            controller: pageController,
            itemCount: controller.items.length,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == controller.items.length - 1;
              });
            },
            itemBuilder: (context, index) {
              final item = controller.items[index];
              final isLottie = item.image.toLowerCase().endsWith('.json');

              return SizedBox.expand(
                child: isLottie
                    ? Lottie.asset(
                        item.image,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        item.image,
                        fit: BoxFit.cover,
                      ),
              );
            },
          ),

          /// DARK GRADIENT OVERLAY FOR READABILITY
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.2),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),

          /// FOREGROUND CONTROLS
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// DOTS
                  SmoothPageIndicator(
                    controller: pageController,
                    count: controller.items.length,
                    effect: const WormEffect(
                      dotColor: Colors.white60,
                      activeDotColor: Color(0xFFD4A73B),
                      dotHeight: 12,
                      dotWidth: 12,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// BUTTONS AREA
                  isLastPage ? getStartedBtn() : nextSkipButtons(),

                  const SizedBox(height: 20),

                  loginPrompt(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// SKIP + NEXT floating buttons
  Widget nextSkipButtons() {
    return Row(
      mainAxisAlignment: isDesktop(context)
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,
      children: [
        /// SKIP BUTTON
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextButton(
            onPressed: () =>
                pageController.jumpToPage(controller.items.length - 1),
            child: const Text(
              "Skip",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),

        /// spacing between buttons
        SizedBox(width: isDesktop(context) ? 45 : 20),

        /// NEXT BUTTON
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD4A73B),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextButton(
            onPressed: () => pageController.nextPage(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            ),
            child: const Text(
              "Next",
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  /// GET STARTED button
  Widget getStartedBtn() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 300, // keeps the button clean + centered
          minWidth: 200,
        ),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A73B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SplashScreenTo(
                    screen: const SignupPagee(),
                  ),
                ),
              );
            },
            child: const Text(
              "Get Started",
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// LOGIN PROMPT
  Widget loginPrompt() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SplashScreenTo(
              screen: LoginPage(),
            ),
          ),
        );
      },
      child: const Text.rich(
        TextSpan(
          text: "Already have an account? ",
          style: TextStyle(color: Colors.white, fontSize: 14),
          children: [
            TextSpan(
              text: "LOGIN",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4A73B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:aurion_hotel/_components/color.dart';
// import 'package:aurion_hotel/_logik/Ui_bridges/splash_screen_to.dart';
// import 'package:aurion_hotel/main_codes/asplash_screen.dart';
// import 'package:aurion_hotel/main_codes/blogin_page.dart';
// import 'package:aurion_hotel/main_codes/bsignup_pagge.dart';
// import 'package:aurion_hotel/main_codes/onboarding_screens/onboarding_items.dart';
// import 'package:flutter/material.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:lottie/lottie.dart';

// class Onboardingview extends StatefulWidget {
//   const Onboardingview({super.key});

//   @override
//   State<Onboardingview> createState() => _OnboardingViewState();
// }

// class _OnboardingViewState extends State<Onboardingview> {
//   final controller = OnboardingItems();
//   final pageController = PageController();
//   bool isLastPage = false;

//   bool isDesktop(BuildContext context) {
//     return MediaQuery.of(context).size.width > 600;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//               builder: (context) => const SplashScreenTo(
//                     screen: SplashScreen(),
//                   )),
//         );
//         return false;
//       },
//       child: Scaffold(
//         body: Container(
//           color: const Color(0xFF0A1A2F), // deep luxury navy
//           child: Stack(
//             children: [
//               /// MAIN PAGE VIEW
//               PageView.builder(
//                 controller: pageController,
//                 itemCount: controller.items.length,
//                 onPageChanged: (index) {
//                   setState(() {
//                     isLastPage = (controller.items.length - 1 == index);
//                   });
//                 },
//                 itemBuilder: (context, index) {
//                   final item = controller.items[index];
//                   final isLottie = item.image.toLowerCase().endsWith('.json');

//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         /// ANIMATION (FULLER HEIGHT)
//                         Container(
//                           height: isDesktop(context)
//                               ? MediaQuery.of(context).size.height * 0.70
//                               : MediaQuery.of(context).size.height * 0.45,
//                           width: double.infinity,
//                           decoration: isDesktop(context)
//                               ? BoxDecoration(
//                                   borderRadius: BorderRadius.circular(25),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.3),
//                                       blurRadius: 30,
//                                       spreadRadius: 5,
//                                       offset: const Offset(0, 12),
//                                     ),
//                                   ],
//                                 )
//                               : null,
//                           clipBehavior: Clip.antiAlias,
//                           child: isLottie
//                               ? Lottie.asset(item.image, fit: BoxFit.cover)
//                               : Image.asset(item.image, fit: BoxFit.cover),
//                         ),

//                         const SizedBox(height: 35),

//                         /// TITLE ONLY
//                         Text(
//                           item.title,
//                           style: const TextStyle(
//                             fontSize: 30,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFFD4A73B), // aurion gold
//                             height: 1.3,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),

//               /// BOTTOM NAVIGATION + BUTTONS
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       isLastPage ? getStartedButton() : navigationControls(),
//                       const SizedBox(height: 20),
//                       loginPrompt(),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget navigationControls() {
//     bool desktop = isDesktop(context);

//     return Row(
//       mainAxisAlignment: desktop
//           ? MainAxisAlignment.spaceEvenly
//           : MainAxisAlignment.spaceBetween,
//       children: [
//         TextButton(
//           onPressed: () =>
//               pageController.jumpToPage(controller.items.length - 1),
//           child: const Text(
//             "Skip",
//             style: TextStyle(color: Colors.white70),
//           ),
//         ),
//         SmoothPageIndicator(
//           controller: pageController,
//           count: controller.items.length,
//           onDotClicked: (index) => pageController.animateToPage(
//             index,
//             duration: const Duration(milliseconds: 600),
//             curve: Curves.easeInOut,
//           ),
//           effect: const WormEffect(
//             dotColor: Colors.white24,
//             activeDotColor: Color(0xFFD4A73B),
//             dotHeight: 12,
//             dotWidth: 12,
//           ),
//         ),
//         TextButton(
//           onPressed: () => pageController.nextPage(
//             duration: const Duration(milliseconds: 600),
//             curve: Curves.easeInOut,
//           ),
//           child: const Text(
//             "Next",
//             style: TextStyle(color: Color(0xFFD4A73B)),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget getStartedButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 55,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Color(0xFFD4A73B),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           elevation: 4,
//         ),
//         onPressed: () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SplashScreenTo(screen: const SignupPagee()),
//             ),
//           );
//         },
//         child: const Text(
//           "Get Started",
//           style: TextStyle(fontSize: 16, color: Colors.white),
//         ),
//       ),
//     );
//   }

//   Widget loginPrompt() {
//     return GestureDetector(
//       onTap: () {
//         // TODO: Navigate to login screen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const SplashScreenTo(
//               screen: LoginPage(),
//             ), //login page
//           ),
//         );
//       },
//       child: const Text.rich(
//         TextSpan(
//           text: "Already have an account? ",
//           style: TextStyle(color: Colors.white, fontSize: 14),
//           children: [
//             TextSpan(
//               text: "LOGIN",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFFD4A73B),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
