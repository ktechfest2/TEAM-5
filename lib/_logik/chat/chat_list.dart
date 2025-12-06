import 'package:aurion_hotel/_logik/chat/chat_model.dart';
import 'package:aurion_hotel/_logik/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  Future<void> _startSupportChat(BuildContext context) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final chatId = await getOrCreateSupportChat(currentUserId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chatId,
          otherUserId: "support",
          otherUserName: "Farmket Team",
        ),
      ),
    );
  }

  Future<void> _deleteChatForMe(BuildContext context, String chatId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(chatRef);
      if (!snapshot.exists) return;

      final users = List<String>.from(snapshot['users']);
      users.remove(userId);

      transaction.update(chatRef, {'users': users});
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Chat deleted successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (currentUser == null) {
      return const Center(child: Text('User not signed in'));
    }

    final currentUserId = currentUser.uid;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chats',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0.5,
        ),
        body: Column(
          children: [
            // -------------------- Support Chat Prompt --------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () => _startSupportChat(context),
                icon: const Icon(Icons.support_agent),
                label: const Text("Chat with Farmket Team"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            // -------------------- Chat List --------------------
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('users', arrayContains: currentUserId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, chatSnapshot) {
                  if (!chatSnapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.green));
                  }

                  final chatDocs = chatSnapshot.data!.docs;

                  if (chatDocs.isEmpty) {
                    return const Center(child: Text('No chats found.'));
                  }

                  // --- Existing chat list builder here ---
                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: chatDocs.length,
                    itemBuilder: (context, index) {
                      final chat = chatDocs[index];
                      final adminIds = List<String>.from(chat['admins'] ?? []);
                      final isSupportChat = adminIds.isNotEmpty;
                      final otherUserId = isSupportChat
                          ? "support"
                          : (chat['users'] as List)
                              .firstWhere((uid) => uid != currentUserId);

                      final unread =
                          (chat['unread'] ?? {}) as Map<String, dynamic>;
                      final isUnreadForMe =
                          (unread[currentUserId] ?? false) == true;

                      String displayName = "Support";
                      String? photoUrl;

                      if (!isSupportChat) {
                        displayName = chat['otherUserName'] ?? 'Unknown';
                        photoUrl = chat['otherUserPhoto'];
                      }

                      final lastMessage = chat['lastMessage'] ?? '';
                      final timestamp = chat['timestamp'] as Timestamp?;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatId: chat.id,
                                  otherUserId: otherUserId,
                                  otherUserName: displayName,
                                ),
                              ),
                            );
                          },
                          onLongPress: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Delete Chat"),
                                content: const Text(
                                    "This action will delete your chat."),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text("Cancel")),
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text("Delete")),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              _deleteChatForMe(context, chat.id);
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[900]
                                      : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: isDark
                                          ? Colors.grey[700]
                                          : Colors.grey[300],
                                      backgroundImage:
                                          (photoUrl != null && photoUrl != '')
                                              ? NetworkImage(photoUrl)
                                              : null,
                                      child:
                                          (photoUrl == null || photoUrl.isEmpty)
                                              ? Text(
                                                  displayName[0],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                )
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.grey[900],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            lastMessage,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (timestamp != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          _formatTimestamp(timestamp),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.grey[400]
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isUnreadForMe)
                                const Positioned(
                                  right: 12,
                                  top: 12,
                                  child: CircleAvatar(
                                    radius: 6,
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';

    return '${date.day}/${date.month}/${date.year}';
  }
}
