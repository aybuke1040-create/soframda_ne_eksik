import 'package:flutter/material.dart';
import '../screens/food/food_detail_screen.dart';
import '../screens/profile/profile_screen.dart';

class ReadyFoodGridCard extends StatelessWidget {
  final String requestId;
  final String ownerId;
  final String title;
  final String imageUrl;
  final dynamic price;
  final dynamic portion;
  final String ownerName;
  final double distance;
  final double rating;
  final int ratingCount;

  /// 🔥 YENİ
  final bool alreadyOffered;

  const ReadyFoodGridCard({
    super.key,
    required this.requestId,
    required this.ownerId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.portion,
    required this.ownerName,
    required this.distance,
    required this.rating,
    required this.ratingCount,
    this.alreadyOffered = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodDetailScreen(
              requestId: requestId,
              ownerId: ownerId,
              title: title,
              imageUrl: imageUrl,
              price: price.toInt(),
              portion: portion,
              ownerName: ownerName,
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 📷 FOTO / PLACEHOLDER
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: _buildFoodImage(imageUrl),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 📝 TITLE (OVERFLOW FIX)
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// 💰 PRICE
                  Text(
                    "$price ₺ • $portion porsiyon",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 4),

                  /// 👤 OWNER
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserProfileScreen(
                            userId: ownerId,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// 📍 DISTANCE + ⭐ RATING (OVERFLOW FIX)
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on,
                              size: 12, color: Colors.orange),
                          const SizedBox(width: 2),
                          Text(
                            "${distance.toStringAsFixed(1)} km",
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              size: 12, color: Colors.orange),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            "($ratingCount)",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// 🎯 TEKLİF BUTONU
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        foregroundColor:
                            alreadyOffered ? Colors.grey : Colors.orange,
                        side: BorderSide(
                          color: alreadyOffered ? Colors.grey : Colors.orange,
                        ),
                      ),
                      onPressed: alreadyOffered ? null : () {},
                      icon: const Icon(Icons.local_offer, size: 14),
                      label: Text(
                        alreadyOffered ? "Teklif Verildi" : "Teklif",
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// 🔥 MODERN PLACEHOLDER
  Widget _buildFoodImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.restaurant, size: 40, color: Colors.grey),
            SizedBox(height: 6),
            Text(
              "Fotoğraf yok",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      },
    );
  }
}
