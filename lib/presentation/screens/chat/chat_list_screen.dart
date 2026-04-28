import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/moderation_service.dart';

import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  Future<void> _hideChatForCurrentUser(
    BuildContext context,
    String chatId,
    String currentUserId,
  ) async {
    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sohbet silinsin mi?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bu işlem sohbeti sadece senin mesajlar listenizden kaldırır.',
                  style: TextStyle(height: 1.45, color: Colors.black54),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext, false),
                        child: const Text('Vazgeç'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(sheetContext, true),
                        child: const Text('Sohbeti Sil'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'deletedFor.$currentUserId': true,
    });

    if (context.mounted) {
      await ActionFeedbackService.showMessage(
        context,
        title: 'Sohbet kaldırıldı',
        message: 'Sohbet listeden kaldırıldı.',
        icon: Icons.delete_outline_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Kullanıcı bulunamadı')),
      );
    }

    final currentUserId = user.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Mesajlar')),
      body: StreamBuilder<Set<String>>(
        stream: ModerationService().watchBlockedUserIds(),
        builder: (context, blockedSnapshot) {
          final blockedUserIds = blockedSnapshot.data ?? const <String>{};

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where('users', arrayContains: currentUserId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Mesajlar yüklenirken bir hata oluştu.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final chats = [...(snapshot.data?.docs ?? const [])]
                  .where((doc) {
                    final data = doc.data();
                    final deletedFor = Map<String, dynamic>.from(
                      data['deletedFor'] ?? const {},
                    );
                    final users = List<String>.from(data['users'] ?? const []);
                    final otherUserId = users.firstWhere(
                      (id) => id != currentUserId,
                      orElse: () => '',
                    );
                    return deletedFor[currentUserId] != true &&
                        (otherUserId.isEmpty ||
                            !blockedUserIds.contains(otherUserId));
                  })
                  .toList()
                ..sort((a, b) {
                  final aTime = a.data()['lastMessageTime'];
                  final bTime = b.data()['lastMessageTime'];
                  final aMs =
                      aTime is Timestamp ? aTime.millisecondsSinceEpoch : 0;
                  final bMs =
                      bTime is Timestamp ? bTime.millisecondsSinceEpoch : 0;
                  return bMs.compareTo(aMs);
                });

              if (chats.isEmpty) {
                return const Center(
                  child: Text('Henüz mesaj yok'),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final data = chat.data();
                  final users = List<String>.from(data['users'] ?? const []);
                  final otherUserId = users.firstWhere(
                    (id) => id != currentUserId,
                    orElse: () => '',
                  );

                  final names =
                      Map<String, dynamic>.from(data['names'] ?? const {});
                  final photos =
                      Map<String, dynamic>.from(data['photos'] ?? const {});
                  final lastMessage = (data['lastMessage'] ?? '').toString();
                  final unreadCount = (data['unreadCount'] is int)
                      ? data['unreadCount'] as int
                      : 0;

                  if (otherUserId.isEmpty) {
                    return _ChatItem(
                      chatId: chat.id,
                      name: 'Sohbet',
                      photoUrl: '',
                      lastMessage: lastMessage,
                      unreadCount: unreadCount,
                      onDelete: () => _hideChatForCurrentUser(
                        context,
                        chat.id,
                        currentUserId,
                      ),
                    );
                  }

                  return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUserId)
                        .get(),
                    builder: (context, userSnapshot) {
                      final userData = userSnapshot.data?.data() ?? const {};
                      final fallbackName =
                          (userData['name'] ?? '').toString().trim();
                      final displayName =
                          (names[otherUserId] ?? fallbackName).toString().trim();
                      final photoUrl =
                          (photos[otherUserId] ?? userData['photoUrl'] ?? '')
                              .toString();

                      return _ChatItem(
                        chatId: chat.id,
                        name: displayName.isEmpty ? 'Kullanıcı' : displayName,
                        photoUrl: photoUrl,
                        lastMessage: lastMessage,
                        unreadCount: unreadCount,
                        onDelete: () => _hideChatForCurrentUser(
                          context,
                          chat.id,
                          currentUserId,
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

class _ChatItem extends StatelessWidget {
  final String chatId;
  final String name;
  final String photoUrl;
  final String lastMessage;
  final int unreadCount;
  final VoidCallback onDelete;

  const _ChatItem({
    required this.chatId,
    required this.name,
    required this.photoUrl,
    required this.lastMessage,
    required this.unreadCount,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: unreadCount > 0 ? Colors.orange.shade50 : Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage:
                      photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Sohbeti Sil'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                lastMessage.isEmpty ? 'Henüz mesaj yok' : lastMessage,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight:
                      unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(chatId: chatId),
                    ),
                  );
                },
                child: const Text('Sohbete Git'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
