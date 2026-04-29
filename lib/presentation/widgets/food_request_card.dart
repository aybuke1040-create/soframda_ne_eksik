import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/presentation/screens/chat/chat_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/profile/profile_screen.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/offer_service.dart';
import 'package:soframda_ne_eksik/services/paywall_service.dart';

class FoodRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback? onTap;
  final bool showActions;
  final String? subtitle;
  final String? trailingLabel;
  final Color trailingLabelColor;
  final IconData fallbackIcon;
  final String? topRightBadge;
  final Color topRightBadgeColor;

  const FoodRequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.showActions = true,
    this.subtitle,
    this.trailingLabel,
    this.trailingLabelColor = Colors.deepOrange,
    this.fallbackIcon = Icons.restaurant,
    this.topRightBadge,
    this.topRightBadgeColor = Colors.orange,
  });

  bool _looksLikePrivateContact(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }

    final compact = trimmed.replaceAll(' ', '');
    final hasAtSign = compact.contains('@');
    final digitsOnly = compact.replaceAll(RegExp(r'\D'), '');
    return hasAtSign || digitsOnly.length >= 10;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final ownerId = request["ownerId"]?.toString() ?? "";
    final requestId = request["id"]?.toString() ?? "";
    final isReadyRequest =
        request["isReady"] == true || request["type"] == "ready_food";
    final isOwner = currentUserId == ownerId;

    final imageUrl = request["imageUrl"]?.toString() ?? "";
    final title = request["title"]?.toString() ?? "";
    final fallbackUserName =
        (request["userName"] ?? request["ownerName"] ?? "").toString();
    final price = request["price"];
    final resolvedTrailingLabel = trailingLabel ??
        ((price != null && price is num) ? "₺$price" : null);

    final distanceRaw = request["distance"];
    final double? distance = distanceRaw is num ? distanceRaw.toDouble() : null;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: imageUrl.isEmpty
                  ? Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFF4E8D8),
                            Color(0xFFEAD2B7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        fallbackIcon,
                        size: 50,
                        color: const Color(0xFF9A6A3A),
                      ),
                    )
                  : (imageUrl.startsWith('assets/')
                      ? Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFF4E8D8),
                                  Color(0xFFEAD2B7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              fallbackIcon,
                              size: 50,
                              color: const Color(0xFF9A6A3A),
                            ),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        )),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      const Color(0xFF1E130D).withOpacity(0.82),
                      const Color(0xFF5A3923).withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            if (distance != null)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "${distance.toStringAsFixed(1)} km",
                    style: const TextStyle(
                      color: Color(0xFF5C3B20),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            if (topRightBadge != null && topRightBadge!.isNotEmpty)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: topRightBadgeColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: topRightBadgeColor.withOpacity(0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    topRightBadge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: showActions ? 35 : 10,
              left: 10,
              right: 10,
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: ownerId.isEmpty
                    ? null
                    : FirebaseFirestore.instance
                        .collection("users")
                        .doc(ownerId)
                        .snapshots(),
                builder: (context, ownerSnapshot) {
                  final profileName =
                      ownerSnapshot.data?.data()?["name"] as String? ?? "";
                  final ownerLine = profileName.trim().isNotEmpty
                      ? profileName.trim()
                      : (_looksLikePrivateContact(fallbackUserName)
                          ? ""
                          : fallbackUserName.trim());
                  final rawSubtitle =
                      (subtitle ?? fallbackUserName).toString().trim();
                  final infoSubtitle =
                      rawSubtitle.isEmpty ||
                              rawSubtitle == ownerLine ||
                              _looksLikePrivateContact(rawSubtitle)
                          ? ""
                          : rawSubtitle;

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F140F).withOpacity(0.55),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.14),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            height: 1.15,
                          ),
                        ),
                        if (ownerLine.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: ownerId.isEmpty
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => UserProfileScreen(
                                          userId: ownerId,
                                        ),
                                      ),
                                    );
                                  },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 12,
                                  color: Color(0xFFF4D9BA),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    ownerLine,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFFFF4E9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFFF4D9BA),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (infoSubtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            infoSubtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFE8D8C5),
                              fontSize: 11,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            if (resolvedTrailingLabel != null && resolvedTrailingLabel.isNotEmpty)
              Positioned(
                bottom: showActions ? 35 : 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: trailingLabelColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: trailingLabelColor.withOpacity(0.24),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    resolvedTrailingLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (showActions)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  color: const Color(0xFF170F0B).withOpacity(0.62),
                  child: isOwner
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _icon(Icons.edit, Colors.blue, () {
                              ActionFeedbackService.show(
                                context,
                                title: 'Düzenleme yakında',
                                message: 'Düzenleme yakında.',
                                icon: Icons.edit_outlined,
                              );
                            }),
                            _icon(Icons.delete, Colors.red, () async {
                              await FirebaseFirestore.instance
                                  .collection("requests")
                                  .doc(requestId)
                                  .delete();
                            }),
                            _icon(Icons.star, Colors.orange, () {
                              ActionFeedbackService.show(
                                context,
                                title: 'Öne çıkarıldı',
                                message: 'Öne çıkarıldı.',
                                icon: Icons.star_rounded,
                              );
                            }),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _icon(Icons.chat, Colors.blue, () async {
                              if (currentUserId == null || ownerId.isEmpty) {
                                return;
                              }

                              final ids = [currentUserId, ownerId]..sort();
                              final chatId = "${ids[0]}_${ids[1]}_$requestId";

                              await FirebaseFirestore.instance
                                  .collection("chats")
                                  .doc(chatId)
                                  .set({
                                "users": ids,
                                "participants": {
                                  ids[0]: true,
                                  ids[1]: true,
                                },
                                "requestId": requestId,
                                "lastMessage": "",
                                "lastMessageTime": FieldValue.serverTimestamp(),
                              }, SetOptions(merge: true));

                              if (!context.mounted) {
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(chatId: chatId),
                                ),
                              );
                            }),
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("offers")
                                  .doc("${requestId}_$currentUserId")
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final hasOrdered =
                                    snapshot.hasData && snapshot.data!.exists;

                                return _icon(
                                  hasOrdered ? Icons.check : Icons.shopping_bag,
                                  hasOrdered ? Colors.grey : Colors.green,
                                  hasOrdered || currentUserId == ownerId
                                      ? null
                                      : () async {
                                          final success = await OfferService()
                                              .sendOffer(
                                            requestId: requestId,
                                            ownerId: ownerId,
                                            price: 0,
                                            actionName: isReadyRequest
                                                ? 'order_ready_food'
                                                : 'send_offer',
                                          );

                                          if (!context.mounted) {
                                            return;
                                          }

                                          if (!success) {
                                            PaywallService.showInsufficientCreditsSheet(
                                              context,
                                              title: isReadyRequest
                                                  ? 'Siparis vermek icin 5 kredi gerekiyor'
                                                  : 'Teklif vermek icin 5 kredi gerekiyor',
                                              message: isReadyRequest
                                                  ? 'Siparisini olusturmak icin once kredi satin alabilir, sonra tek dokunusla devam edebilirsin.'
                                                  : 'Teklifini gondermek icin once kredi satin alabilir, sonra tek dokunusla devam edebilirsin.',
                                              highlight: isReadyRequest
                                                  ? 'Siparis kredi paketleri'
                                                  : 'Teklif kredi paketleri',
                                            );
                                            return;
                                          }

                                          await ActionFeedbackService.show(
                                            context,
                                            title: isReadyRequest
                                                ? 'Sipariş gönderildi'
                                                : 'Teklif gönderildi',
                                            message: isReadyRequest
                                                ? 'Sipariş gönderildi.'
                                                : 'Teklif gönderildi.',
                                            icon: Icons.check_circle_outline_rounded,
                                          );
                                        },
                                );
                              },
                            ),
                            _icon(Icons.favorite_border, Colors.pink, () async {
                              if (currentUserId == null) {
                                return;
                              }

                              final favRef = FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(currentUserId)
                                  .collection("favorites")
                                  .doc(requestId);

                              final doc = await favRef.get();

                              if (doc.exists) {
                                await favRef.delete();
                              } else {
                                await favRef.set({
                                  "createdAt": FieldValue.serverTimestamp(),
                                });
                              }
                            }),
                          ],
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _icon(IconData icon, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
