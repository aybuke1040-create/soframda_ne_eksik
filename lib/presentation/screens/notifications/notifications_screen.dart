import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/core/utils/text_utils.dart';
import 'package:soframda_ne_eksik/presentation/screens/chat/chat_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/delivery/delivery_detail_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/design/design_detail_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/food/food_detail_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/ready_to_serve/ready_food_detail_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/requests/request_detail_screen.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _showInactiveMessage(BuildContext context) {
    return ActionFeedbackService.show(
      context,
      title: 'İlan aktif değil',
      message: 'Bu ilan şu an aktif değildir.',
      icon: Icons.info_outline_rounded,
    );
  }

  Future<void> _openNotification(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final requestId = (data['requestId'] ?? '').toString();
    final chatId = (data['chatId'] ?? '').toString();

    if (chatId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(chatId: chatId),
        ),
      );
      return;
    }

    if (requestId.isEmpty) {
      return;
    }

    final requestDoc = await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .get();

    if (!requestDoc.exists) {
      if (context.mounted) {
        await _showInactiveMessage(context);
      }
      return;
    }

    final requestData = requestDoc.data() ?? <String, dynamic>{};
    final ownerId = (requestData['ownerId'] ?? data['ownerId'] ?? '').toString();
    final requestType = (requestData['type'] ?? requestData['requestType'] ?? '')
        .toString();
    final status = (requestData['status'] ?? 'open').toString();
    final isActive = status == 'open';

    if (!isActive) {
      await _showInactiveMessage(context);
      return;
    }

    if (!context.mounted) {
      return;
    }

    Widget page;
    switch (requestType) {
      case 'delivery':
        page = DeliveryDetailScreen(requestId: requestId);
        break;
      case 'design':
        page = DesignDetailScreen(requestId: requestId);
        break;
      case 'ready_food':
        page = ReadyFoodDetailScreen(requestId: requestId);
        break;
      case 'food':
        page = FoodDetailScreen(
          requestId: requestId,
          ownerId: ownerId,
          title: (requestData['title'] ?? '').toString(),
          imageUrl: (requestData['imageUrl'] ?? '').toString(),
          price: requestData['price'],
          portion: requestData['portion'],
          ownerName: (requestData['ownerName'] ?? requestData['userName'] ?? '')
              .toString(),
        );
        break;
      case 'food_request':
      default:
        page = RequestDetailScreen(requestId: requestId, ownerId: ownerId);
        break;
    }

    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    } catch (_) {
      if (context.mounted) {
        await _showInactiveMessage(context);
      }
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

    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Bildirimler yüklenirken hata oluştu: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Henüz bildirim yok'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = normalizeNotificationText((data['title'] ?? '').toString());
              final body = normalizeNotificationText((data['body'] ?? '').toString());
              final isRead = data['read'] == true;

              return ListTile(
                leading: Icon(
                  Icons.notifications,
                  color: isRead ? Colors.grey : Colors.orange,
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(body),
                onTap: () async {
                  try {
                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(doc.id)
                        .update({'read': true});
                  } catch (_) {
                    // Bildirim okunmuş işaretlenemese de yönlendirme çalışsın.
                  }

                  if (!context.mounted) {
                    return;
                  }

                  await _openNotification(context, data);
                },
              );
            },
          );
        },
      ),
    );
  }
}
