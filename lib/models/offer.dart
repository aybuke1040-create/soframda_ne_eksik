import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String id;
  final String requestId;
  final String senderId;
  final String requestOwnerId;
  final double price;
  final String message;
  final String status;
  final Timestamp createdAt;

  OfferModel({
    required this.id,
    required this.requestId,
    required this.senderId,
    required this.requestOwnerId,
    required this.price,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory OfferModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OfferModel(
      id: doc.id,
      requestId: data['requestId'],
      senderId: data['senderId'],
      requestOwnerId: data['requestOwnerId'],
      price: (data['price'] as num).toDouble(),
      message: data['message'],
      status: data['status'],
      createdAt: data['createdAt'],
    );
  }
}
