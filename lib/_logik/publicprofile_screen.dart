import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PublicProfileScreen extends StatelessWidget {
  final String userId;
  final bool isCurrentUser;

  const PublicProfileScreen(
      {super.key, required this.userId, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final nairaFormat =
        NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("User's Profile"),
        // backgroundColor: colorScheme.primary,
        // foregroundColor: colorScheme.onPrimary,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String role = userData['role'] ?? "Buyer";

          // Get verification status from subcollection

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    userData['name'][0], // First letter
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Name
                // and verification tick if seller

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userData['name'] ?? 'Unknown',
                      style: textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    if (role == "Seller" && (userData['premium'] ?? false))
                      const Icon(Icons.diamond_outlined,
                          color: Colors.orange, size: 20),
                    const SizedBox(width: 6),
                    if (role == "Seller" && (userData['verified'] ?? false))
                      const Icon(Icons.verified, color: Colors.blue, size: 20),
                  ],
                ),

                // Role tag
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: role == "Seller"
                        ? Colors.green.withOpacity(0.15)
                        : Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      color: role == "Seller" ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ROLE-BASED DETAILS
                if (role == "Seller") ...[
                  //verifcation tick if verified seller
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (userData['verified'] == true)
                        const Icon(Icons.verified,
                            color: Colors.blue, size: 20),
                      if (userData['verified'] == true)
                        const SizedBox(width: 6),
                      if (userData['verified'] == true)
                        const Text("Verified Seller",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (isCurrentUser == true)
                    _infoCard(
                      context,
                      "Total Sales",
                      //format in naira Format
                      nairaFormat.format(userData['totalsales']),
                    ),
                  if (isCurrentUser == false)
                    _infoCard(
                      context,
                      "Products ordered (by buyers) ",
                      //format in naira Format
                      "${userData['totalorders'] ?? 0}",
                    ),
                  _infoCard(
                    context,
                    "Products Sold: ",
                    "${userData['productsold'] ?? 0}",
                  ),
                  _infoCard(
                    context,
                    "Visitors",
                    "${userData['totalvisitors'] ?? 0}",
                  ),
                ] else ...[
                  _infoCard(
                    context,
                    "Total Orders",
                    "${userData['totalorders'] ?? 0}",
                  ),
                ],

                _infoCard(context, "Country", userData['country'] ?? "-"),
                _infoCard(context, "State", userData['state'] ?? "-"),

                const SizedBox(height: 20),

                // CHAT BUTTON
                Container(
                  child: isCurrentUser
                      ? const Center()
                      : ElevatedButton.icon(
                          onPressed: () async {
                            // final me = FirebaseAuth.instance.currentUser!;
                            // final otherUserId = userData['uid'] as String;
                            // final otherUserName =
                            //     userData['name'] as String? ?? 'Unknown';
                            // final otherUserAvatar =
                            //     userData['photoUrl'] as String?;

                            // final chatId =
                            //     await getOrCreateChat(me.uid, otherUserId);

                            // if (!context.mounted) return;
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) => ChatScreen(
                            //       chatId: chatId,
                            //       otherUserId: otherUserId,
                            //       otherUserName: otherUserName,
                            //       otherUserAvatar: otherUserAvatar,
                            //     ),
                            //   ),
                            // );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          icon: const Icon(Icons.chat, color: Colors.white),
                          label: const Text('Chat',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Info card - adapts to dark/light themes
  Widget _infoCard(BuildContext context, String title, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
          Text(value,
              style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: colorScheme.primary)),
        ],
      ),
    );
  }
}



////calling it in other screens;;
//Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => PublicProfileScreen(userId: profileUserId),
//   ),
// );

///
///