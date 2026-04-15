import 'package:flutter/material.dart';

class FoodCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final dynamic price;
  final dynamic portion;

  const FoodCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.portion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 14),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// FOOD IMAGE
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _foodImage(data["imageUrl"]),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// PRICE
                  Row(
                    children: [
                      Text(
                        "$price ₺",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "• $portion porsiyon",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// RATING (placeholder)
                  Row(
                    children: const [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 4),
                      Text("4.8"),
                      SizedBox(width: 4),
                      Text(
                        "(23)",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _foodImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty || !imageUrl.startsWith("http")) {
      return Image.asset(
        "assets/images/food_placeholder.png",
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "assets/images/food_placeholder.png",
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
