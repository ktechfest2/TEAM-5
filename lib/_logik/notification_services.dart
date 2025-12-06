import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createNotification({
  required String title,
  required String message,
  required String type,
}) async {
  try {
    await FirebaseFirestore.instance.collection('admins_notification').add({
      "title": title,
      "message": message,
      "type": type, // services, book, users, chats, fraud
      "timestamp": FieldValue.serverTimestamp(),
      "createdBy": "system",
      "readBy": [], // no adminss have readdt yet by default
    });
    print("Notification created successfully");
  } catch (e) {
    print("Failed to create notification: $e");
  }
}


// xamples 
// createNotification(
//   title: "New Order",
//   message: "A new order has been placed",
//   type: "orders",
//   actionId: orderId,
// );


// createNotification(
//   title: "New Product Added",
//   message: "$productName was added",
//   type: "products",
//   actionId: productId,
// );


// createNotification(
//   title: "USSD Request",
//   message: "A USSD buy request just arrived",
//   type: "ussd",
// );

