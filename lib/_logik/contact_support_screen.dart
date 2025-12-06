// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ContactSupportScreen extends StatelessWidget {
//   const ContactSupportScreen({super.key});

//   Future<void> _launchUrl(String url) async {
//     //mainnnnnnn
//     final Uri uri = Uri.parse(url);
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       throw 'Could not launch $url';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     // final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Contact Support"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _supportCard(
//               context,
//               icon: Icons.chat_bubble_outline,
//               title: "Farmket Bot-Chat🌱",
//               subtitle: "Coming soon...",
//               color: Colors.grey,
//               onTap: () {},
//               disabled: true,
//             ),
//             const SizedBox(height: 16),
//             _supportCard(
//               context,
//               icon: Icons.call,
//               title: "Call Support",
//               subtitle: "+234 706 173 5251",
//               color: theme.colorScheme.primary,
//               onTap: () => _launchUrl("tel:+2347061735251"),
//             ),
//             const SizedBox(height: 16),
//             _supportCard(
//               context,
//               icon: Icons.email_outlined,
//               title: "Email Support",
//               subtitle: "farmketseedo@gmail.com",
//               color: theme.colorScheme.secondary,
//               onTap: () => _launchUrl(
//                   "mailto:farmketseedo@gmail.com?subject=Support Request"),
//             ),
//             const SizedBox(height: 16),
//             _supportCard(
//               context,
//               icon: Icons.chat_bubble_outline_rounded,
//               title: "WhatsApp Chat",
//               subtitle: "Chat with us on WhatsApp",
//               color: Colors.green.shade600,
//               onTap: () => _launchUrl("https://wa.me/2347061735251"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _supportCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//     bool disabled = false,
//   }) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return InkWell(
//       onTap: disabled ? null : onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           color:
//               disabled ? theme.disabledColor.withOpacity(0.1) : theme.cardColor,
//           boxShadow: [
//             BoxShadow(
//               color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.2),
//               blurRadius: 8,
//               offset: const Offset(2, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 28,
//               backgroundColor: color.withOpacity(0.15),
//               child: Icon(icon, size: 28, color: color),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color:
//                           theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (!disabled)
//               Icon(Icons.arrow_forward_ios,
//                   size: 18, color: theme.iconTheme.color?.withOpacity(0.7)),
//           ],
//         ),
//       ),
//     );
//   }
// }
