// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class SellerNotificationScreen extends StatelessWidget {
//   const SellerNotificationScreen({super.key});

//   String formatTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final diff = now.difference(dateTime);
//     if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
//     if (diff.inHours < 24) return '${diff.inHours} hrs ago';
//     return DateFormat('dd MMM, hh:mm a').format(dateTime);
//   }

//   IconData getIconByType(String type) {
//     switch (type) {
//       case 'order':
//         return Icons.shopping_basket;
//       case 'payment':
//         return Icons.payment;
//       case 'delivery':
//         return Icons.local_shipping;
//       case 'tip':
//         return Icons.lightbulb;
//       default:
//         return Icons.notifications;
//     }
//   }

//   Future<void> markAsSeen(String notificationId) async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId != null) {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .collection('notifications')
//           .doc(notificationId)
//           .update({'seen': true});
//     }
//   }

//   Future<void> deleteNotification(String id) async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId != null) {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .collection('notifications')
//           .doc(id)
//           .delete();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDarkTheme = themeProvider.isDarkMode;

//     final backgroundColor = isDarkTheme ? Colors.black : Colors.white;
//     final dividerColor = isDarkTheme ? Colors.grey.shade800 : Colors.grey;
//     final textColor = isDarkTheme ? Colors.white : Colors.black;
//     final subTextColor = isDarkTheme ? Colors.grey.shade400 : Colors.black45;
//     final appBarColor = Colors.transparent;
//     final appBarForeground =
//         isDarkTheme ? Colors.green.shade200 : Colors.green.shade700;

//     final userId = FirebaseAuth.instance.currentUser?.uid;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         title: Text("Notifications", style: TextStyle(color: appBarForeground)),
//         backgroundColor: appBarColor,
//         foregroundColor: appBarForeground,
//         elevation: 0,
//         iconTheme: IconThemeData(color: appBarForeground),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.done_all),
//             tooltip: "Mark all as seen",
//             onPressed: () async {
//               await markAllAsSeen();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                     content: Text('All notifications marked as seen')),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete_forever),
//             tooltip: "Delete all",
//             onPressed: () async {
//               final confirm = await showDialog<bool>(
//                 context: context,
//                 builder: (ctx) => AlertDialog(
//                   title: const Text('Delete All Notifications'),
//                   content: const Text(
//                       'Are you sure you want to delete all notifications?'),
//                   actions: [
//                     TextButton(
//                       child: const Text('Cancel'),
//                       onPressed: () => Navigator.of(ctx).pop(false),
//                     ),
//                     TextButton(
//                       child: const Text('Delete'),
//                       onPressed: () => Navigator.of(ctx).pop(true),
//                     ),
//                   ],
//                 ),
//               );
//               if (confirm == true) {
//                 await deleteAllNotifications();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('All notifications deleted')),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Divider(height: 1, thickness: 1, color: dividerColor),
//           Expanded(
//             child: userId == null
//                 ? const Center(child: Text("User not logged in"))
//                 : StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection('users')
//                         .doc(userId)
//                         .collection('notifications')
//                         .orderBy('createdAt', descending: true)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }

//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                         return Center(
//                           child: Text(
//                             'No notifications yet.',
//                             style: TextStyle(color: subTextColor, fontSize: 18),
//                           ),
//                         );
//                       }

//                       final docs = snapshot.data!.docs;

//                       return ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: docs.length,
//                         itemBuilder: (context, index) {
//                           final doc = docs[index];
//                           final data =
//                               doc.data() as Map<String, dynamic>? ?? {};
//                           final title = data['title'] ?? '';
//                           final message = data['message'] ?? '';
//                           final seen = data['seen'] ?? false;
//                           final timestamp =
//                               (data['createdAt'] as Timestamp?)?.toDate();
//                           final type = data['type'] ?? 'order';
//                           final icon = getIconByType(type);

//                           return Dismissible(
//                             key: Key(doc.id),
//                             direction: DismissDirection.endToStart,
//                             background: Container(
//                               alignment: Alignment.centerRight,
//                               padding: const EdgeInsets.only(right: 20),
//                               color: Colors.red.shade100,
//                               child:
//                                   const Icon(Icons.delete, color: Colors.red),
//                             ),
//                             onDismissed: (_) async {
//                               await deleteNotification(doc.id);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Notification deleted')),
//                               );
//                             },
//                             child: GestureDetector(
//                               onTap: () => markAsSeen(doc.id),
//                               child: Padding(
//                                 padding: const EdgeInsets.only(bottom: 20),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     CircleAvatar(
//                                       backgroundColor:
//                                           Colors.green.withOpacity(0.1),
//                                       child: Icon(icon, color: Colors.green),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             title,
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 16,
//                                               color: textColor,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             message,
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: textColor,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 6),
//                                           if (timestamp != null)
//                                             Text(
//                                               formatTime(timestamp),
//                                               style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: subTextColor,
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                     if (!seen)
//                                       Container(
//                                         margin:
//                                             const EdgeInsets.only(left: 6.0),
//                                         width: 10,
//                                         height: 10,
//                                         decoration: const BoxDecoration(
//                                           color: Colors.red,
//                                           shape: BoxShape.circle,
//                                         ),
//                                       ),
//                                     IconButton(
//                                       icon: const Icon(Icons.delete_outline,
//                                           size: 20),
//                                       color: Colors.red.shade400,
//                                       tooltip: "Delete this notification",
//                                       onPressed: () async {
//                                         await deleteNotification(doc.id);
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           SnackBar(
//                                               content:
//                                                   Text('Notification deleted')),
//                                         );
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget bellIconWithBadge() {
//     final userId = FirebaseAuth.instance.currentUser?.uid;

//     if (userId == null) return const Icon(Icons.notifications);

//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .collection('notifications')
//           .where('seen', isEqualTo: false)
//           .snapshots(),
//       builder: (context, snapshot) {
//         final count = snapshot.data?.docs.length ?? 0;

//         return Stack(
//           children: [
//             const Icon(Icons.notifications),
//             if (count > 0)
//               Positioned(
//                 right: 0,
//                 top: 0,
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: const BoxDecoration(
//                     color: Colors.red,
//                     shape: BoxShape.circle,
//                   ),
//                   constraints:
//                       const BoxConstraints(minWidth: 20, minHeight: 20),
//                   child: Text(
//                     count.toString(),
//                     style: const TextStyle(color: Colors.white, fontSize: 12),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> markAllAsSeen() async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) return;

//     final snapshots = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userId)
//         .collection('notifications')
//         .where('seen', isEqualTo: false)
//         .get();

//     for (final doc in snapshots.docs) {
//       await doc.reference.update({'seen': true});
//     }
//   }

//   Future<void> deleteAllNotifications() async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) return;

//     final snapshots = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userId)
//         .collection('notifications')
//         .get();

//     for (final doc in snapshots.docs) {
//       await doc.reference.delete();
//     }
//   }
// }


// //firebase notification data arrangement;;
// // {
// //   title: "New Order",
// //   message: "You've received a new order.",
// //   createdAt: Timestamp,
// //   seen: false,
// //   type: "order"
// // }