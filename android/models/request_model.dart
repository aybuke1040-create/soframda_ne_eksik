class RequestModel {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final String ownerName;
  final double latitude;
  final double longitude;
  final double price;
  final int portion;
  final bool isReady;
  final String status;
  final double ratingAverage;
  final int ratingCount;
  final DateTime createdAt;
  final String type;

  RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.ownerName,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.portion,
    required this.isReady,
    required this.status,
    required this.ratingAverage,
    required this.ratingCount,
    required this.createdAt,
    required this.type,
  });

  factory RequestModel.fromFirestore(Map<String, dynamic> data, String id) {
    return RequestModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      price: (data['price'] ?? 0).toDouble(),
      portion: data['portion'] ?? 1,
      isReady: data['isReady'] ?? false,
      status: data['status'] ?? 'open',
      ratingAverage: (data['ratingAverage'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      createdAt: (data['createdAt']).toDate(),
      type: data['type'] ?? 'food_request',
    );
  }
}
