import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:soframda_ne_eksik/presentation/screens/chat/chat_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/profile/profile_screen.dart';
import 'package:soframda_ne_eksik/services/chat_service.dart';
import 'package:soframda_ne_eksik/services/credit_service.dart';
import '../offers/send_offer_screen.dart';

class FoodDetailScreen extends StatefulWidget {
  final String requestId;
  final String ownerId;
  final String title;
  final String imageUrl;
  final dynamic price;
  final dynamic portion;
  final String ownerName;

  const FoodDetailScreen({
    super.key,
    required this.requestId,
    required this.ownerId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.portion,
    required this.ownerName,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final chatService = ChatService();

  bool isFavorite = false;
  bool loadingFav = true;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc(widget.requestId)
        .get();

    setState(() {
      isFavorite = doc.exists;
      loadingFav = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final ref = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc(widget.requestId);

    if (isFavorite) {
      await ref.delete();
    } else {
      await ref.set({
        "requestId": widget.requestId,
        "ownerId": widget.ownerId,
        "title": widget.title,
        "imageUrl": widget.imageUrl,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? "Favorilerden çıkarıldı" : "Favorilere eklendi ❤️",
        ),
        duration: const Duration(milliseconds: 600),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.imageUrl.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.restaurant, size: 60, color: Colors.grey),
        ),
      );
    }

    return Image.network(
      widget.imageUrl,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          height: 250,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = userId == widget.ownerId;
    _buildActionCard(
      icon: Icons.edit,
      title: "Düzenle",
      color: Colors.blue,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SendOfferScreen(
              // 🔥 şimdilik reuse
              requestId: widget.requestId,
              ownerId: widget.ownerId,
            ),
          ),
        );
      },
    );

    var buildActionCard = _buildActionCard(
      icon: Icons.delete,
      title: "İlanı Sil",
      color: Colors.red,
      onTap: () async {
        final confirm = await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("İlan silinsin mi?"),
            content: const Text("Bu işlem geri alınamaz"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("İptal"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Sil"),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await FirebaseFirestore.instance
              .collection("requests")
              .doc(widget.requestId)
              .delete();

          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("İlan silindi")),
          );
        }
      },
    );

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("requests")
          .doc(widget.requestId)
          .snapshots(),
      builder: (context, requestSnapshot) {
        final requestData = requestSnapshot.data?.data() ?? <String, dynamic>{};
        final isFeatured = requestData["isFeatured"] == true;
        final featuredUntil = requestData["featuredUntil"] as Timestamp?;
        final isFeatureActive = isFeatured &&
            featuredUntil != null &&
            featuredUntil.toDate().isAfter(DateTime.now());

        return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (!loadingFav)
            IconButton(
              onPressed: _toggleFavorite,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isFavorite),
                  color: Colors.red,
                ),
              ),
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// PRICE
                  Text(
                    "${widget.price} ₺ • ${widget.portion} porsiyon",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// OWNER
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserProfileScreen(
                            userId: widget.ownerId,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Hazırlayan: ${widget.ownerName}",
                      style: const TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// GRID BUTTONS (PREMIUM)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      _buildActionCard(
                        icon: Icons.chat,
                        title: "Mesaj Gönder\n(İlk mesaj 10 kredi)",
                        color: Colors.blue,
                        onTap: () async {
                          final chatId = await chatService.createChatRoom(
                            userId,
                            widget.ownerId,
                            widget.requestId,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(chatId: chatId),
                            ),
                          );
                        },
                      ),
                      _buildActionCard(
                        icon: Icons.shopping_bag,
                        title: "Sipariş Ver",
                        color: Colors.green,
                        onTap: () async {
                          final chatId = await chatService.createChatRoom(
                            userId,
                            widget.ownerId,
                            widget.requestId,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(chatId: chatId),
                            ),
                          );
                        },
                      ),
                      if (isOwner)
                        _buildActionCard(
                          icon: Icons.star,
                          title: "Öne Çıkar (50 kredi)",
                          color: Colors.orange,
                          onTap: () async {
                            if (isFeatureActive) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Bu ilan zaten öne çıkarılmış."),
                                ),
                              );
                              return;
                            }

                            final success = await CreditService().performAction(
                              userId: userId,
                              cost: 50,
                              actionName: "feature",
                              onSuccess: () async {
                                await FirebaseFirestore.instance
                                    .collection("requests")
                                    .doc(widget.requestId)
                                    .update({
                                  "isFeatured": true,
                                  "featuredUntil": Timestamp.fromDate(
                                    DateTime.now().add(const Duration(days: 3)),
                                  ),
                                });
                              },
                            );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Öne çıkarıldı 🚀"),
                                ),
                              );
                            }
                          },
                        ),
                      _buildActionCard(
                        icon: Icons.local_offer,
                        title: "Teklif Ver",
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SendOfferScreen(
                                requestId: widget.requestId,
                                ownerId: widget.ownerId,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    final VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
