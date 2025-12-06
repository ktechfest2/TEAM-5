import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String text;
  final Timestamp? timestamp;
  final String type; // text, image, file
  final List<String> readBy;
  final String? fileUrl;
  final String? fileName;

  ChatMessage({
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.type,
    required this.readBy,
    this.fileUrl,
    this.fileName,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      type: map['type'] ?? 'text',
      timestamp:
          map['timestamp'] is Timestamp ? map['timestamp'] as Timestamp : null,
      readBy: map['readBy'] != null ? List<String>.from(map['readBy']) : [],
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
      'type': type,
      'readBy': readBy,
      'fileUrl': fileUrl,
      'fileName': fileName,
    };
  }
}

Future<List<String>> fetchAdminIds() async {
  final snap = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'admin')
      .get();
  return snap.docs.map((d) => d.id).toList();
}

/// Get existing chat or create it if it doesn't exist
Future<String> getOrCreateSupportChat(String userId) async {
  final chatRef = FirebaseFirestore.instance.collection('chats').doc(userId);
  final snapshot = await chatRef.get();
  if (snapshot.exists) return chatRef.id;

  final adminIds = await fetchAdminIds();
  final unreadMap = <String, bool>{};
  unreadMap[userId] = false;
  for (final a in adminIds) {
    unreadMap[a] = false;
  }

  await chatRef.set({
    'userId': userId,
    'users': [userId],
    'admins': adminIds,
    'lastMessage': '',
    'timestamp': FieldValue.serverTimestamp(),
    'unread': unreadMap,
  });

  return chatRef.id;
}

/// Send message from user to Admin Team
Future<void> sendSupportMessageFromUser(String userId, String text) async {
  final chatId = await getOrCreateSupportChat(userId);
  final currentUserId = userId;
  final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
  final data = (await chatRef.get()).data()!;
  final adminIds = List<String>.from(data['admins']);

  final message = {
    'senderId': currentUserId,
    'text': text,
    'timestamp': FieldValue.serverTimestamp(),
    'readBy': [currentUserId],
    'type': 'text',
    'fileUrl': null,
    'fileName': null,
  };

  await chatRef.collection('messages').add(message);

  final update = <String, dynamic>{};
  for (final a in adminIds) {
    update["unread.$a"] = true;
  }
  update["unread.$userId"] = false;

  await chatRef.update({
    'lastMessage': text,
    'timestamp': FieldValue.serverTimestamp(),
    ...update,
  });
}
