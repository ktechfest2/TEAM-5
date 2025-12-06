// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:url_launcher/url_launcher.dart';

// class RefundPolicyScreen extends StatelessWidget {
//   const RefundPolicyScreen({super.key});

//   Future<DocumentSnapshot> _getPolicy() async {
//     return FirebaseFirestore.instance
//         .collection('refund_policies')
//         .doc('app_policy')
//         .get();
//   }

//   Future<void> _launchEmail(String email) async {
//     final Uri emailUri = Uri(scheme: 'mailto', path: email, queryParameters: {
//       'subject': "Refund_Request",
//     });
//     if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
//       throw 'Could not launch $emailUri';
//     }
//   }

//   Future<void> _launchWhatsApp(String number) async {
//     //mainnnnnnn
//     final Uri whatsappUri = Uri.parse("https://wa.me/$number");
//     if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
//       throw 'Could not launch $whatsappUri';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Refund Policy"),
//         centerTitle: true,
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: _getPolicy(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text("Refund policy not available"));
//           }

//           final data = snapshot.data!.data() as Map<String, dynamic>;
//           final sections = List<Map<String, dynamic>>.from(data['sections']);
//           final email = data['supportEmail'];
//           final whatsapp = data['supportWhatsApp'];

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ListView(
//               children: [
//                 Text(
//                   data['title'] ?? 'Refund Policy',
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 const SizedBox(height: 20),
//                 ...sections.map((section) {
//                   return Card(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             section['heading'] ?? "",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleMedium
//                                 ?.copyWith(fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             section['content'] ?? "",
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//                 const SizedBox(height: 30),
//                 Text(
//                   data['supportPrompt'] ?? '',
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                         fontWeight: FontWeight.w500,
//                       ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () => _launchEmail(email),
//                       icon: const Icon(Icons.email),
//                       label: const Text("Email Support"),
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     ElevatedButton.icon(
//                       onPressed: () => _launchWhatsApp(whatsapp),
//                       icon: const Icon(Icons.chat),
//                       label: const Text("WhatsApp"),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
