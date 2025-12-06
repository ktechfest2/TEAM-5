import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:aurion_hotel/_logik/chat/chat_model.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  late List<String> adminIds = [];
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadAdmins().then((_) => _clearUnreadForCurrentUser());
  }

  Future<void> _loadAdmins() async {
    final doc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get();
    if (doc.exists && doc.data()!.containsKey("admins")) {
      adminIds = List<String>.from(doc['admins']);
      isAdmin = adminIds.contains(currentUserId);
    }
  }

  Future<void> _clearUnreadForCurrentUser() async {
    FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
      "unread.$currentUserId": false,
    });
  }

  Future<void> _sendMessage(
      {String? text, String? url, String type = "text"}) async {
    if ((text == null || text.trim().isEmpty) && url == null) return;
    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
    final message = {
      'senderId': currentUserId,
      'text': text ?? (type == 'image' ? "[Image]" : "[File]"),
      'timestamp': FieldValue.serverTimestamp(),
      'readBy': [currentUserId],
      'type': type,
      'fileUrl': url,
      'fileName': text,
    };

    await chatRef.collection('messages').add(message);

    final update = <String, dynamic>{};
    if (isAdmin) {
      update["unread.${widget.otherUserId}"] = true;
      for (var a in adminIds) {
        update["unread.$a"] = false;
      }
    } else {
      for (var a in adminIds) {
        update["unread.$a"] = true;
      }
      update["unread.$currentUserId"] = false;
    }

    await chatRef.update({
      'lastMessage': text ?? (type == "image" ? "[Image]" : "[File]"),
      'timestamp': FieldValue.serverTimestamp(),
      ...update,
    });

    // createNotification(
    //   title: "A New Chat",
    //   message: "A New Chat has been sent to Admins",
    //   type: "chats",
    // );

    _controller.clear();
    _scrollToBottom();
  }

  Future<void> _pickImage() async {
    try {
      XFile? image;
      if (!kIsWeb) {
        image = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image == null) return;
        final file = File(image.path);
        final name = DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef =
            FirebaseStorage.instance.ref("chats/${widget.chatId}/$name");
        await storageRef.putFile(file);
        final url = await storageRef.getDownloadURL();
        _sendMessage(url: url, type: "image");
      } else {
        final result = await file_picker.FilePicker.platform
            .pickFiles(type: file_picker.FileType.image);
        if (result != null && result.files.single.bytes != null) {
          final data = result.files.single.bytes!;
          final name = DateTime.now().millisecondsSinceEpoch.toString();
          final storageRef =
              FirebaseStorage.instance.ref("chats/${widget.chatId}/$name");
          await storageRef.putData(data);
          final url = await storageRef.getDownloadURL();
          _sendMessage(url: url, type: "image");
        }
      }
    } catch (e) {
      print("Image upload error: $e");
    }
  }

  Future<void> _pickFile() async {
    final result = await file_picker.FilePicker.platform.pickFiles();
    if (result == null) return;
    final picked = result.files.single;
    final path = "chats/${widget.chatId}/files/${picked.name}";
    final storageRef = FirebaseStorage.instance.ref(path);
    if (kIsWeb) {
      if (picked.bytes != null) await storageRef.putData(picked.bytes!);
    } else {
      await storageRef.putFile(File(picked.path!));
    }
    final url = await storageRef.getDownloadURL();
    _sendMessage(text: picked.name, url: url, type: "file");
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _markMessageRead(String messageId) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'readBy': FieldValue.arrayUnion([currentUserId])
    });
  }

  String _formatTime(DateTime? date) =>
      date == null ? "" : DateFormat('h:mm a').format(date);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName = isAdmin ? widget.otherUserName : "Admin Team";

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
              child: Text(displayName[0],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Text(displayName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Delete Chat"),
                  content:
                      const Text("This hides the chat from your view only."),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete",
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatId)
                    .update({
                  "users": FieldValue.arrayRemove([currentUserId])
                });
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.green));
                }
                final messages = snapshot.data!.docs;
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
                if (messages.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msgDoc = messages[index];
                    final msg = ChatMessage.fromMap(
                        msgDoc.data() as Map<String, dynamic>);
                    final isMe = msg.senderId == currentUserId;
                    if (!isMe) _markMessageRead(msgDoc.id);

                    Widget content;
                    if (msg.type == "text") {
                      content = Text(msg.text,
                          style: TextStyle(
                              color: isMe
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.grey[200]
                                      : Colors.grey[850]),
                              fontSize: 16));
                    } else if (msg.type == "image") {
                      content = GestureDetector(
                        onTap: () => showDialog(
                            context: context,
                            builder: (_) => Dialog(
                                child: Image.network(msg.fileUrl!,
                                    fit: BoxFit.contain))),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(msg.fileUrl!,
                                width: 200, height: 200, fit: BoxFit.cover)),
                      );
                    } else {
                      content = InkWell(
                        onTap: () {},
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.attach_file, size: 20),
                          const SizedBox(width: 6),
                          Text(msg.fileName ?? msg.text)
                        ]),
                      );
                    }

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                            color: isMe
                                ? Colors.green.shade600
                                : (isDark
                                    ? Colors.grey[850]
                                    : Colors.grey[200]),
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              content,
                              const SizedBox(height: 6),
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                Text(_formatTime(msg.timestamp?.toDate()),
                                    style: TextStyle(
                                        color: isMe
                                            ? Colors.white70
                                            : Colors.grey[600],
                                        fontSize: 12)),
                                if (isMe) ...[
                                  const SizedBox(width: 6),
                                  Icon(
                                      msg.readBy.contains(widget.otherUserId)
                                          ? Icons.done_all
                                          : Icons.done,
                                      color: msg.readBy
                                              .contains(widget.otherUserId)
                                          ? Colors.blue
                                          : Colors.white70,
                                      size: 16)
                                ]
                              ])
                            ]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: isDark
                ? Colors.grey[900]
                : Colors.white, // container background
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image,
                      color: isDark ? Colors.white70 : Colors.grey),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: Icon(Icons.attach_file,
                      color: isDark ? Colors.white70 : Colors.grey),
                  onPressed: _pickFile,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type a message...",
                        hintStyle: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ClipOval(
                  child: Material(
                    color: Colors
                        .green, // can keep green for send button or use conditional
                    child: InkWell(
                      onTap: () {
                        if (_controller.text.trim().isNotEmpty) {
                          _sendMessage(text: _controller.text.trim());
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
