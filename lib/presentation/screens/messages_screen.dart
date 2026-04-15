import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soframda_ne_eksik/presentation/screens/chat/chat_screen.dart';
import 'user_service.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("USERS MAP: ${userSnapshot.data}");
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Mesajlar")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where(
              Filter.or(
                Filter('buyerId', isEqualTo: currentUserId),
                Filter('sellerId', isEqualTo: currentUserId),
              ),
            )
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Bir hata oluştu"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          final otherUserIds = chats
              .map((doc) => doc["otherUserId"] as String?)
              .where((id) => id != null && id.isNotEmpty)
              .toSet()
              .toList();

          print("OTHER IDS: $otherUserIds");

          if (chats.isEmpty) {
            return const Center(
              child: Text("Henüz mesaj yok", style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final data = chats[index].data() as Map<String, dynamic>;

              final chatId = chats[index].id;

              final buyerId = data['buyerId'];
              final sellerId = data['sellerId'];
              final lastMessage = data['lastMessage'] ?? "";
              final lastMessageTime =
                  (data['lastMessageTime'] as Timestamp?)?.toDate();

              final currentUserId = FirebaseAuth.instance.currentUser!.uid;

              FutureBuilder<Map<String, Map<String, dynamic>>>(
                future: UserService().getUsersByIds(otherUserIds),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final usersMap = userSnapshot.data!;

                  return GridView.builder(
                    itemCount: chats.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (context, index) {
                      final chat = chats[index].data() as Map<String, dynamic>;

                      final otherUserId = chat["otherUserId"];

                      final userData = usersMap[otherUserId];
                      final name = userData?["name"] ?? "Kullanıcı";

                      return Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name, // 🔥 ARTIK BURASI
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(chat["lastMessage"] ?? ""),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
