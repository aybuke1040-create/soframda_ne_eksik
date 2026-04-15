import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryRequest {
  final String id;
  final String title;
  final String description;

  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;

  final String dropAddress;
  final double dropLat;
  final double dropLng;

  final String deliveryTime;

  final String ownerId;
  final String ownerName;

  final String status;
  final DateTime createdAt;

  DeliveryRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropAddress,
    required this.dropLat,
    required this.dropLng,
    required this.deliveryTime,
    required this.ownerId,
    required this.ownerName,
    required this.status,
    required this.createdAt,
  });

  factory DeliveryRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DeliveryRequest(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      pickupAddress: data['pickupAddress'] ?? '',
      pickupLat: (data['pickupLat'] ?? 0).toDouble(),
      pickupLng: (data['pickupLng'] ?? 0).toDouble(),
      dropAddress: data['dropAddress'] ?? '',
      dropLat: (data['dropLat'] ?? 0).toDouble(),
      dropLng: (data['dropLng'] ?? 0).toDouble(),
      deliveryTime: data['deliveryTime'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      status: data['status'] ?? 'open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
