import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/presentation/screens/chat/chat_screen.dart';

class DeliveryRequestCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final double distance;

  final VoidCallback onMessage;
  final VoidCallback onOffer;

  const DeliveryRequestCard({
    super.key,
    required this.data,
    required this.distance,
    required this.onMessage,
    required this.onOffer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              data["imageUrl"] ?? "",
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["title"] ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${data["pickupAddress"]} → ${data["dropAddress"]}",
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${distance.toStringAsFixed(1)} km",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.message),
                      onPressed: onMessage,
                    ),
                    IconButton(
                      icon: const Icon(Icons.local_shipping),
                      onPressed: onOffer,
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
