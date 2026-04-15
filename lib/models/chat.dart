import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final String requestId;
  final String buyerId;
  final String sellerId;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  Chat({
    required this.id,
    required this.requestId,
    required this.buyerId,
    required this.sellerId,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Chat(
      id: doc.id,
      requestId: data['requestId'],
      buyerId: data['buyerId'],
      sellerId: data['sellerId'],
      lastMessage: data['lastMessage'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
    );
  }
}
