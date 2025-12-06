// import 'package:farmket/main_codes/_sellers/sellers_logik/_help_screen/faqs_screen.dart';
// import 'package:farmket/main_codes/_sellers/sellers_logik/_help_screen/terms_privacy_screen.dart';
// import 'package:farmket/main_codes/_sellers/sellers_logik/_help_screen/tutorials_screen.dart';
// import 'package:flutter/material.dart';

// class HelpScreen extends StatelessWidget {
//   const HelpScreen({super.key});

//   void _go(BuildContext context, String where) {
//     Widget page;
//     switch (where) {
//       case 'FAQs':
//         page = const FAQsScreen();
//         break;
//       case 'Tutorials & Guides':
//         page = const TutorialsScreen();
//         break;
//       case 'Terms & Privacy Policy':
//         page = const TermsPrivacyScreen(); // shows tabs for Terms + Privacy
//         break;
//       default:
//         page = const SizedBox();
//     }
//     Navigator.push(context, MaterialPageRoute(builder: (_) => page));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     final options = [
//       {
//         'title': 'FAQs',
//         'icon': Icons.question_answer_outlined,
//         'color': Colors.blueAccent
//       },
//       {
//         'title': 'Tutorials & Guides',
//         'icon': Icons.menu_book_outlined,
//         'color': Colors.greenAccent
//       },
//       {
//         'title': 'Terms & Privacy Policy',
//         'icon': Icons.privacy_tip_outlined,
//         'color': Colors.orangeAccent
//       },
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Help & Support'),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView.separated(
//           itemCount: options.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 16),
//           itemBuilder: (context, i) {
//             final item = options[i];
//             return InkWell(
//               onTap: () => _go(context, item['title'] as String),
//               borderRadius: BorderRadius.circular(16),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: isDark
//                       ? Colors.grey[900]
//                       : theme.colorScheme.surfaceContainerHighest,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: isDark
//                           ? Colors.black.withOpacity(0.3)
//                           : Colors.grey.withOpacity(0.2),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     radius: 24,
//                     backgroundColor: (item['color'] as Color).withOpacity(0.15),
//                     child: Icon(item['icon'] as IconData,
//                         color: item['color'] as Color),
//                   ),
//                   title: Text(
//                     item['title'] as String,
//                     style: theme.textTheme.titleMedium
//                         ?.copyWith(fontWeight: FontWeight.w600),
//                   ),
//                   trailing: Icon(Icons.arrow_forward_ios,
//                       color: theme.iconTheme.color, size: 18),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'tutorials_screen.dart';
// // import 'terms_privacy_screen.dart';

// // class HelpScreen extends StatelessWidget {
// //   const HelpScreen({super.key});

// //   void _navigateTo(BuildContext context, String title) {
// //     Widget page;
// //     switch (title) {
// //       case 'FAQs':
// //         page = const FAQsScreen();
// //         break;
// //       case 'Tutorials & Guides':
// //         page = const TutorialsScreen();
// //         break;
// //       case 'Terms & Privacy Policy':
// //         page = const TermsPrivacyScreen();
// //         break;
// //       default:
// //         page = const SizedBox();
// //     }
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(builder: (_) => page),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     final isDark = theme.brightness == Brightness.dark;

// //     final options = [
// //       {
// //         'title': 'FAQs',
// //         'icon': Icons.question_answer_outlined,
// //         'color': Colors.blueAccent,
// //       },
// //       {
// //         'title': 'Tutorials & Guides',
// //         'icon': Icons.menu_book_outlined,
// //         'color': Colors.greenAccent,
// //       },
// //       {
// //         'title': 'Terms & Privacy Policy',
// //         'icon': Icons.privacy_tip_outlined,
// //         'color': Colors.orangeAccent,
// //       },
// //     ];

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Help & Support"),
// //         centerTitle: true,
// //         elevation: 0,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: ListView.separated(
// //           itemCount: options.length,
// //           separatorBuilder: (_, __) => const SizedBox(height: 16),
// //           itemBuilder: (context, index) {
// //             final item = options[index];
// //             return GestureDetector(
// //               onTap: () => _navigateTo(context, item['title'] as String),
// //               child: Container(
// //                 decoration: BoxDecoration(
// //                   color: isDark
// //                       ? Colors.grey[900]
// //                       : theme.colorScheme.surfaceVariant,
// //                   borderRadius: BorderRadius.circular(16),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: isDark
// //                           ? Colors.black.withOpacity(0.3)
// //                           : Colors.grey.withOpacity(0.2),
// //                       blurRadius: 8,
// //                       offset: const Offset(0, 4),
// //                     ),
// //                   ],
// //                 ),
// //                 child: ListTile(
// //                   leading: CircleAvatar(
// //                     radius: 24,
// //                     backgroundColor: (item['color'] as Color).withOpacity(0.15),
// //                     child: Icon(
// //                       item['icon'] as IconData,
// //                       color: item['color'] as Color,
// //                     ),
// //                   ),
// //                   title: Text(
// //                     item['title'] as String,
// //                     style: theme.textTheme.titleMedium?.copyWith(
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                   trailing: Icon(
// //                     Icons.arrow_forward_ios,
// //                     color: theme.iconTheme.color,
// //                     size: 18,
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }
