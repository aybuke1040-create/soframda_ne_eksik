import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String title;
  final String imageUrl;
  final dynamic price;
  final dynamic portion;
  final String ownerName;
  final String ownerId;
  final double latitude;
  final double longitude;
  final double ratingAverage;
  final int ratingCount;

  RequestModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.portion,
    required this.ownerName,
    required this.ownerId,
    required this.latitude,
    required this.longitude,
    required this.ratingAverage,
    required this.ratingCount,
  });

  factory RequestModel.fromFirestore(Map<String, dynamic> data, String id) {
    return RequestModel(
      id: id,
      title: data["title"] ?? "",
      imageUrl: data["imageUrl"] ?? "",
      price: data["price"],
      ownerName: data["ownerName"] ?? "",
      ownerId: data["ownerId"] ?? "",
      latitude: (data["latitude"] ?? 0).toDouble(),
      longitude: (data["longitude"] ?? 0).toDouble(),
      ratingAverage: (data['ratingAverage'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      portion: data['portion'] ?? 1,
    );
  }
}
