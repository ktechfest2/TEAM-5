// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:url_launcher/url_launcher.dart';

// class AboutUsScreen extends StatelessWidget {
//   const AboutUsScreen({super.key});

//   Future<Map<String, dynamic>?> _getAboutData() async {
//     final doc = await FirebaseFirestore.instance
//         .collection('about_us')
//         .doc('company_info')
//         .get();
//     return doc.data();
//   }

//   /// Launch a website in the browser
//   Future<void> _launchWebsite(String url) async {
//     final uri = Uri.parse(url);
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       throw 'Could not launch $url';
//     }
//   }

//   /// Launch email client
//   Future<void> _launchEmail(String email) async {
//     final uri = Uri(
//       scheme: 'mailto',
//       path: email,
//       query: Uri.encodeFull('subject=Hello from our App'),
//     );
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       throw 'Could not send email to $email';
//     }
//   }

//   /// Launch dialer
//   Future<void> _launchPhone(String phoneNumber) async {
//     final uri = Uri(scheme: 'tel', path: phoneNumber);
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       throw 'Could not call $phoneNumber';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("About Us"),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: FutureBuilder<Map<String, dynamic>?>(
//         future: _getAboutData(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final data = snapshot.data!;
//           final partners = List<Map<String, dynamic>>.from(data['partners']);

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Company Name
//                 Center(
//                   child: Text(
//                     data['companyName'],
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: isDark ? Colors.greenAccent : Colors.green,
//                         ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Description
//                 Text(
//                   data['description'],
//                   style: Theme.of(context).textTheme.bodyLarge,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 24),

//                 // Mission & Vision
//                 _buildInfoCard("Our Mission", data['mission'], context, isDark),
//                 _buildInfoCard("Our Vision", data['vision'], context, isDark),

//                 const SizedBox(height: 24),

//                 // Partners
//                 Text("Our Partners",
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         )),
//                 const SizedBox(height: 12),

//                 Column(
//                   children: partners.map((partner) {
//                     return GestureDetector(
//                       onTap: () => _launchWebsite(partner['website']),
//                       child: Card(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         elevation: 3,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: ListTile(
//                           leading:
//                               const Icon(Icons.business, color: Colors.green),
//                           title: Text(partner['name']),
//                           subtitle: Text(partner['role']),
//                           trailing:
//                               const Icon(Icons.open_in_new, color: Colors.grey),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),

//                 const SizedBox(height: 24),

//                 // Contact info
//                 Text("Contact Us",
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         )),
//                 const SizedBox(height: 8),

//                 ListTile(
//                   leading: const Icon(Icons.web, color: Colors.green),
//                   title: Text(data['website']),
//                   onTap: () => _launchWebsite(data['website']),
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.email, color: Colors.green),
//                   title: Text(data['contactEmail']),
//                   onTap: () => _launchEmail(data['contactEmail']),
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.phone, color: Colors.green),
//                   title: Text(data['contactPhone']),
//                   onTap: () => _launchPhone(data['contactPhone']),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildInfoCard(
//       String title, String content, BuildContext context, bool isDark) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 4,
//       shadowColor: Colors.green.withOpacity(0.3),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title,
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: isDark ? Colors.greenAccent : Colors.green,
//                     )),
//             const SizedBox(height: 8),
//             Text(content, style: Theme.of(context).textTheme.bodyMedium),
//           ],
//         ),
//       ),
//     );
//   }
// }
