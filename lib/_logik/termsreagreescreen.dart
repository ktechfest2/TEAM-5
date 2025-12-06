// import 'package:farmket/_logik/auth_wrapper.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class TermsReAgreeScreen extends StatefulWidget {
//   final String uid;
//   const TermsReAgreeScreen({super.key, required this.uid});

//   @override
//   State<TermsReAgreeScreen> createState() => _TermsReAgreeScreenState();
// }

// class _TermsReAgreeScreenState extends State<TermsReAgreeScreen> {
//   bool loading = false;
//   String terms = "";

//   @override
//   void initState() {
//     super.initState();
//     fetchTerms();
//   }

//   Future<void> fetchTerms() async {
//     final querySnapshot = await FirebaseFirestore.instance
//         .collection('terms_conditions')
//         .limit(1)
//         .get();

//     if (querySnapshot.docs.isNotEmpty) {
//       final fetchedTerms = querySnapshot.docs.first['content'] ?? "";
//       if (mounted) setState(() => terms = fetchedTerms);
//     } else {
//       if (mounted) setState(() => terms = "No terms available.");
//     }
//   }

//   Future<void> accept() async {
//     const String currentTermsVersion = "v1.0";
//     setState(() => loading = true);

//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.uid)
//         .update({
//       "acceptedTerms": true,
//       "acceptedTermsAt": FieldValue.serverTimestamp(),
//       "termsVersion": currentTermsVersion,
//       "device": {
//         "platform": Theme.of(context).platform.toString(),
//       },
//     });

//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const AuthWrapper()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Updated Terms & Conditions")),
//       body: loading
//           ? const Center(child: CircularProgressIndicator(color: Colors.green))
//           : Padding(
//               padding: const EdgeInsets.all(18),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: Text(terms),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: accept,
//                     child: const Text("I Agree"),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
