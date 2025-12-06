// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:farmket/_logik/Ui_bridges/splash_screen_to.dart';
// import 'package:farmket/_logik/email_service.dart';
// import 'package:farmket/main_codes/_buyers/_buyers_logik/checkout_screen.dart';
// import 'package:farmket/main_codes/_buyers/_buyers_logik/payment/banktransfer_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class OrderHistoryScreen extends StatelessWidget {
//   final String userType; // 'buyer' or 'seller'

//   const OrderHistoryScreen({
//     super.key,
//     required this.userType,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final currentUserId = FirebaseAuth.instance.currentUser!.uid;
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Order History",
//           style: TextStyle(
//             color: theme.colorScheme.onSurface,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new_rounded,
//               color: theme.colorScheme.onSurface),
//           onPressed: () => Navigator.pop(context),
//         ),
//         elevation: 0,
//         backgroundColor: theme.colorScheme.surface,
//       ),
//       body: Column(
//         children: [
//           Divider(height: 2, color: theme.dividerColor, thickness: 2),
//           const SizedBox(height: 20),
//           Container(
//             alignment: Alignment.centerLeft,
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Text(
//               userType == 'buyer' ? "Your Recent Orders" : "Your Sold Products",
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('orders')
//                   .orderBy('createdAt', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(
//                     child: Text(
//                       "No orders yet",
//                       style: TextStyle(
//                           color: theme.colorScheme.onSurface.withOpacity(0.5),
//                           fontSize: 16),
//                     ),
//                   );
//                 }

//                 final orders = snapshot.data!.docs;

//                 return ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   itemCount: orders.length,
//                   itemBuilder: (context, index) {
//                     final order = orders[index].data()! as Map<String, dynamic>;
//                     List items = order['items'] ?? [];

//                     // Filter based on userType
//                     if (userType == 'seller') {
//                       items = items
//                           .where((i) => i['sellerId'] == currentUserId)
//                           .toList();
//                       if (items.isEmpty) return const SizedBox.shrink();
//                     } else if (userType == 'buyer') {
//                       if (order['buyerId'] != currentUserId) {
//                         return const SizedBox.shrink();
//                       }
//                     }

//                     final total = order['totalCost'] ?? 0;
//                     final createdAt = order['createdAt'] as Timestamp?;
//                     final dateStr = createdAt != null
//                         ? DateFormat.yMMMEd()
//                             .add_jm()
//                             .format(createdAt.toDate())
//                         : '';
//                     final status = order['status']?.toString() ?? 'Pending';

//                     // Random colorful icon for card
//                     final icons = [
//                       Icons.agriculture,
//                       Icons.shopping_cart,
//                       Icons.local_grocery_store,
//                       Icons.eco,
//                       Icons.emoji_food_beverage,
//                       Icons.grass,
//                     ];
//                     final colors = [
//                       Colors.green,
//                       Colors.orange,
//                       Colors.purple,
//                       Colors.blue,
//                       Colors.teal,
//                       Colors.brown,
//                     ];
//                     final icon = icons[index % icons.length];
//                     final color = colors[index % colors.length];

//                     final title = userType == 'buyer'
//                         ? "${items.length} items ordered"
//                         : "${items.length} sold";

//                     final formattedTotal = NumberFormat.currency(
//                       locale: 'en_NG',
//                       symbol: '₦',
//                       decimalDigits: 0,
//                     ).format(total);

//                     // For seller: show paid/unpaid
//                     final isPaid = userType == 'seller' &&
//                         (order['paymentStatus']?.toString() == 'paid');

//                     return GestureDetector(
//                       onTap: () async {
//                         // Mark order as seen by seller before opening details
//                         if (userType == 'seller' &&
//                             order['seenBySeller'] != true) {
//                           await FirebaseFirestore.instance
//                               .collection('orders')
//                               .doc(orders[index].id)
//                               .update({'seenBySeller': true});
//                         }

//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => OrderDetailScreen(
//                               order: order,
//                               userType: userType,
//                               userId: currentUserId,
//                               orderId: orders[index].id,
//                             ),
//                           ),
//                         );
//                       },
//                       child: OrderCard(
//                         icon: icon,
//                         title: title,
//                         orderId: orders[index].id,
//                         date: dateStr,
//                         status: status,
//                         amount: formattedTotal,
//                         color: color,
//                         showPaidTag: isPaid,
//                         showUnseenDot: userType == 'seller' &&
//                             order['seenBySeller'] != true,
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Reusable Order Card
// class OrderCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String orderId;
//   final String date;
//   final String status;
//   final String amount;
//   final Color color;
//   final bool showPaidTag;
//   final bool showUnseenDot; // 👈 NEW

//   const OrderCard({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.orderId,
//     required this.date,
//     required this.status,
//     required this.amount,
//     required this.color,
//     this.showPaidTag = false,
//     this.showUnseenDot = false, // 👈 NEW default false
//   });

//   Color _getStatusColor() {
//     switch (status) {
//       case "delivered":
//         return Colors.green;
//       case "processing":
//         return Colors.blue;
//       case "pending":
//         return Colors.orange;
//       case "cancelled":
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: theme.colorScheme.surface,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//         border: Border.all(
//             color:
//                 isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: color, size: 26),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: theme.colorScheme.onSurface)),
//                 const SizedBox(height: 4),
//                 Text("$orderId • $date",
//                     style: theme.textTheme.bodySmall
//                         ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     amount,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                   if (showUnseenDot) // 👈 show red dot
//                     Container(
//                       margin: const EdgeInsets.only(left: 6),
//                       width: 10,
//                       height: 10,
//                       decoration: const BoxDecoration(
//                         color: Colors.red,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor().withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   status,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: _getStatusColor(),
//                   ),
//                 ),
//               ),
//               if (showPaidTag)
//                 Container(
//                   margin: const EdgeInsets.only(top: 4),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Text(
//                     "Paid",
//                     style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.blue),
//                   ),
//                 ),
//               if (!showPaidTag && status == 'Pending')
//                 Container(
//                   margin: const EdgeInsets.only(top: 4),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Text(
//                     "Not Paid",
//                     style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.orange),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Placeholder OrderDetailScreen (to implement further)

// class OrderDetailScreen extends StatefulWidget {
//   final Map<String, dynamic> order;
//   final String userType;
//   final String userId;
//   final String orderId;

//   const OrderDetailScreen({
//     super.key,
//     required this.order,
//     required this.userType,
//     required this.userId,
//     required this.orderId,
//   });

//   @override
//   State<OrderDetailScreen> createState() => _OrderDetailScreenState();
// }

// bool _isCancelling = false;

// class _OrderDetailScreenState extends State<OrderDetailScreen> {
//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'delivered':
//         return Colors.green;
//       case 'processing':
//         return Colors.blue;
//       case 'pending':
//         return Colors.orange;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _formatCurrency(num value) {
//     return NumberFormat.currency(locale: 'en_NG', symbol: "₦", decimalDigits: 0)
//         .format(value);
//   }
// Future<void> restoreStockBeforeOrderDeletion(String orderId) async {
//   final firestore = FirebaseFirestore.instance;
//   final orderRef = firestore.collection('orders').doc(orderId);

//   await firestore.runTransaction((tx) async {
//     final orderSnap = await tx.get(orderRef);
//     if (!orderSnap.exists) return;

//     final orderData = orderSnap.data()!;
//     final items = List<Map<String, dynamic>>.from(orderData['items']);

//     // --------------------------------------------
//     // 1. READ PHASE (read everything first)
//     // --------------------------------------------
//     final List<Map<String, dynamic>> productStates = [];

//     for (final item in items) {
//       final productId = item['productId'];
//       final qtyOrdered = (item['quantity'] as num).toInt();

//       final productRef = firestore.collection('product').doc(productId);
//       final productSnap = await tx.get(productRef);

//       if (!productSnap.exists) continue;

//       final currentStock = (productSnap['quantity'] as num).toInt();

//       productStates.add({
//         "ref": productRef,
//         "newStock": currentStock + qtyOrdered,
//       });
//     }

//     // --------------------------------------------
//     // 2. WRITE PHASE (write only after ALL reads done)
//     // --------------------------------------------
//     for (final p in productStates) {
//       final newStock = p['newStock'];

//       tx.update(p['ref'], {
//         "quantity": newStock,
//         "status": newStock > 0 ? "Active" : "Sold",
//         "updatedAt": FieldValue.serverTimestamp(),
//       });
//     }
//   });
// }



//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     // Filter items based on user type
//     final items = (widget.order['items'] as List<dynamic>)
//         .where((item) =>
//             !(widget.userType == 'seller' && item['sellerId'] != widget.userId))
//         .toList();

//     // Calculate seller total if user is seller
// // Calculate seller total if user is seller
//     num total = 0;
//     if (widget.userType == 'seller') {
//       for (var item in items) {
//         final price = (item['price'] ?? 0) as num;
//         final quantity = (item['quantity'] ?? 1) as num;
//         total += price * quantity;
//       }
//     } else {
//       total = (widget.order['totalCost'] ?? 0) as num;
//     }

//     final sellerPaid = widget.order['sellerpaid'] ?? false;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Order Details",
//             style: TextStyle(color: theme.colorScheme.onSurface)),
//         backgroundColor: theme.colorScheme.surface,
//         iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           // --- Order Info ---
//           Text(
//             "Your Order: ${widget.order['orderId'] ?? ''}",
//             style: theme.textTheme.titleMedium
//                 ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Text(
//                 "Status: ",
//                 style: theme.textTheme.titleMedium
//                     ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(widget.order['status'] ?? '')
//                       .withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   widget.order['status'] ?? '',
//                   style: TextStyle(
//                     color: _getStatusColor(widget.order['status'] ?? ''),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "Total: ${_formatCurrency(total)}",
//             style: theme.textTheme.titleMedium
//                 ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           const SizedBox(height: 8),
//           if (widget.userType == 'seller')
//             Row(
//               children: [
//                 Text(
//                   "Paid to Seller: ",
//                   style: theme.textTheme.titleMedium
//                       ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: sellerPaid
//                         ? Colors.green.withOpacity(0.1)
//                         : Colors.orange.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     sellerPaid ? "Yes" : "No",
//                     style: TextStyle(
//                       color: sellerPaid ? Colors.green : Colors.orange,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           const SizedBox(height: 16),

//           // --- Delivery & Payment Info ---
//           Text(
//             "Delivery Address:",
//             style: theme.textTheme.titleMedium
//                 ?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           Text(widget.order['delivery']?['address'] ?? "N/A"),
//           const SizedBox(height: 8),
//           Text(
//             "Delivery Type:",
//             style: theme.textTheme.titleMedium
//                 ?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           Text(widget.order['delivery']?['type'] ?? "N/A"),
//           const SizedBox(height: 8),
//           Text(
//             "Payment Method:",
//             style: theme.textTheme.titleMedium
//                 ?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           Text(widget.order['paymentMethod'] ?? "N/A"),
//           const SizedBox(height: 8),
//           Text(
//             "Payment Status:",
//             style: theme.textTheme.titleMedium
//                 ?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           Text(widget.order['paymentStatus'] ?? "N/A"),
//           const SizedBox(height: 16),

//           // --- Items Table ---
//           Text(
//             "Items:",
//             style: theme.textTheme.titleLarge
//                 ?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Table(
//             border: TableBorder.all(
//               color: theme.dividerColor,
//               width: 1,
//               style: BorderStyle.solid,
//             ),
//             columnWidths: const {
//               0: FlexColumnWidth(2),
//               1: FlexColumnWidth(1),
//               2: FlexColumnWidth(1),
//             },
//             children: [
//               // Header row
//               TableRow(
//                 decoration: BoxDecoration(
//                     color: theme.colorScheme.primary.withOpacity(0.1)),
//                 children: const [
//                   Padding(
//                       padding: EdgeInsets.all(8),
//                       child: Text("Product",
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                   Padding(
//                       padding: EdgeInsets.all(8),
//                       child: Text("Qty",
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                   Padding(
//                       padding: EdgeInsets.all(8),
//                       child: Text("Price",
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                 ],
//               ),
//               // Item rows
//               ...items.map((item) {
//                 return TableRow(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8),
//                       child: Row(
//                         children: [
//                           Image.network(item['image'] ?? '',
//                               width: 40, height: 40, fit: BoxFit.cover),
//                           const SizedBox(width: 6),
//                           Flexible(
//                               child: Text(item['productName'] ?? '',
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold))),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8),
//                       child: Text("${item['quantity']}"),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8),
//                       child: Text(_formatCurrency(item['price'] ?? 0)),
//                     ),
//                   ],
//                 );
//               }),
//             ],
//           ),
//           const SizedBox(height: 20),

//           ///button to go to checkout if the paymentmethod is Null(
//           /// meaning the user has not paid yet
//           //fetch order Id

//           if (widget.userType == 'buyer' &&
//               (widget.order['paymentStatus'] == 'not paid'))
//             ElevatedButton.icon(
//               onPressed: () {
//                 // Navigate to checkout screen with orderId
//                 //if orderid is null return nothing and snackbar Error
//                 if (widget.orderId.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content:
//                             Text("Something wrong happened. Contact support.")),
//                   );
//                   return;
//                 }
//                 // if payment Method is Bank Transfer go to bank transfer Screen
//                 if (widget.order['paymentMethod'] == 'Bank Transfer') {
//                   // Navigate to bank transfer instructions screen
//                   //snackbar to inform user
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text(
//                           "If you have paid initially, do not pay again. We are confirming your payment."),
//                       duration: Duration(seconds: 7),
//                     ),
//                   );
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => SplashScreenTo(
//                         screen: BankTransferScreen(
//                           orderId: widget.orderId,
//                           amountToPay: widget.order['totalCost'],
//                         ),
//                       ), //banktransfer,
//                     ),
//                   );

//                   return;
//                 }
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => SplashScreenTo(
//                       screen: CheckoutScreen(
//                         orderId: widget.orderId, //actuaL ORDERID
//                       ),
//                     ), //checkout,
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.payment),
//               label: const Text("Pay for product"),
//             ),
//           const SizedBox(height: 10),
//           //deletr order Button if cancelled or not paid
//           if (widget.userType == 'buyer' &&
//               (widget.order['status'] == 'cancelled' ||
//                   widget.order['paymentStatus'] == 'not paid'))
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//               ),
//               onPressed: () async {
//                 // Confirm deletion
//                 final confirm = await showDialog<bool>(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: const Text("Confirm Deletion"),
//                     content: const Text(
//                         "Are you sure you want to delete this order?"),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context, false),
//                         child: const Text("No"),
//                       ),
//                       TextButton(
//                         onPressed: () => Navigator.pop(context, true),
//                         child: const Text("Yes"),
//                       ),
//                     ],
//                   ),
//                 );
//                 if (confirm != true) return;

//                 // Delete order
//                 try {
//                   // Restore stock FIRST
//                   await restoreStockBeforeOrderDeletion(widget.orderId);
//                   await FirebaseFirestore.instance
//                       .collection('orders')
//                       .doc(widget.orderId)
//                       .delete();
//                   Navigator.pop(context); // Go back after deletion
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Error deleting order: $e")),
//                   );
//                   print("Error deleting order: $e");
//                 }
//               },
//               icon: const Icon(Icons.delete),
//               label: const Text("Delete Order"),
//             ),

//           if (widget.userType == 'buyer' &&
//               widget.order['status'] == 'pending' &&
//               widget.order['paymentMethod'] == 'POD' &&
//               widget.order['paymentStatus'] == 'pending')
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//               ),
//               onPressed: _isCancelling
//                   ? null
//                   : () async {
//                       final confirm = await showDialog<bool>(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: const Text("Confirm Cancellation"),
//                           content: const Text(
//                               "Are you sure you want to cancel this order?"),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, false),
//                               child: const Text("No"),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, true),
//                               child: const Text("Yes"),
//                             ),
//                           ],
//                         ),
//                       );
//                       if (confirm != true) return;

//                       setState(() => _isCancelling = true);

//                       try {
//                         // Restore stock FIRST
//                   await restoreStockBeforeOrderDeletion(widget.orderId);
//                         // Update order status to 'cancelled'
//                         await FirebaseFirestore.instance
//                             .collection('orders')
//                             .doc(widget.orderId)
//                             .update({'status': 'cancelled'});

//                         final items = (widget.order['items'] as List<dynamic>);
//                         for (var item in items) {
//                           final productId = item['productId'];
//                           final qtyBought = item['quantity'] ?? 0;

//                           final productRef = FirebaseFirestore.instance
//                               .collection('product')
//                               .doc(productId);

//                           await FirebaseFirestore.instance
//                               .runTransaction((transaction) async {
//                             final snap = await transaction.get(productRef);
//                             if (!snap.exists) return;

//                             final currentQty = (snap['quantity'] ?? 0) as int;
//                             final newQty = currentQty + qtyBought;

//                             transaction.update(productRef, {
//                               'quantity': newQty,
//                               'status': 'Active',
//                             });
//                           });
//                         }

// // === SEND CANCELLATION EMAILS ===

// // Buyer Email
//                         final buyerId = widget.order['buyerId'];
//                         final buyerDoc = await FirebaseFirestore.instance
//                             .collection('users')
//                             .doc(buyerId)
//                             .get();

//                         final buyerEmail = buyerDoc['email'] ?? '';
//                         final buyerName = widget.order['buyerName'] ?? 'Buyer';
//                         final totalCost =
//                             (widget.order['totalCost'] ?? 0).toDouble();

//                         // Build enriched items with sellingType
//                         final enrichedItems = <Map<String, dynamic>>[];
//                         for (var item in items) {
//                           final productId = item['productId'] ?? '';
//                           String sellingType = '';
//                           if (productId.isNotEmpty) {
//                             final productDoc = await FirebaseFirestore.instance
//                                 .collection('product')
//                                 .doc(productId)
//                                 .get();
//                             if (productDoc.exists) {
//                               sellingType = productDoc['sellingType'] ?? '';
//                             }
//                           }

//                           enrichedItems.add({
//                             ...item,
//                             'sellingType': sellingType,
//                           });
//                         }

// // Then pass enrichedItems to the email function
//                         if (buyerEmail.isNotEmpty) {
//                           await sendBuyerCancellationEmail(
//                             buyerEmail: buyerEmail,
//                             buyerName: buyerName,
//                             orderId: widget.orderId,
//                             totalCost: totalCost,
//                             items: enrichedItems, // 👈 includes sellingType
//                           );
//                         }

// // Loop through sellers
//                         for (var item in items) {
//                           final sellerId = item['sellerId'] ?? '';
//                           if (sellerId.isEmpty) continue;

//                           // fetch product doc for sellingType
//                           final productId = item['productId'] ?? '';
//                           String sellingType = '';
//                           if (productId.isNotEmpty) {
//                             final productDoc = await FirebaseFirestore.instance
//                                 .collection('product')
//                                 .doc(productId)
//                                 .get();
//                             if (productDoc.exists) {
//                               sellingType = productDoc['sellingType'] ?? '';
//                             }
//                           }

//                           // add sellingType into this item map
//                           final enrichedItem = {
//                             ...item,
//                             'sellingType': sellingType,
//                           };

//                           final sellerDoc = await FirebaseFirestore.instance
//                               .collection('users')
//                               .doc(sellerId)
//                               .get();

//                           final sellerEmail = sellerDoc['email'] ?? '';
//                           final sellerName = item['sellerName'] ?? 'Seller';

//                           if (sellerEmail.isNotEmpty) {
//                             await sendSellerCancellationEmail(
//                               sellerEmail: sellerEmail,
//                               sellerName: sellerName,
//                               orderId: widget.orderId,
//                               buyerName: buyerName,
//                               sellerItems: [
//                                 enrichedItem
//                               ], // 👈 enriched with sellingType
//                             );
//                           }
//                         }

//                         if (mounted) Navigator.pop(context);
//                       } catch (e) {
//                         if (mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                                 content: Text("Error cancelling order: $e")),
//                           );
//                         }
//                       } finally {
//                         if (mounted) {
//                           setState(() => _isCancelling = false);
//                         }
//                       }
//                     },
//               icon: _isCancelling
//                   ? const SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : const Icon(Icons.cancel),
//               label: Text(_isCancelling ? "Cancelling..." : "Cancel Order"),
//             ),
//           //cancel order button if status is pending and delivery is POD also if paymentstatus is Pending
//         ]),
//       ),
//     );
//   }
// }
