import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/presentation/screens/chat/chat_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/offers/send_offer_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/profile/profile_screen.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/chat_service.dart';
import 'package:soframda_ne_eksik/services/credit_service.dart';
import 'package:soframda_ne_eksik/services/moderation_service.dart';
import 'package:soframda_ne_eksik/services/request_delete_service.dart';

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
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final ChatService chatService = ChatService();

  bool isFavorite = false;
  bool loadingFav = true;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(widget.requestId)
        .get();

    if (!mounted) return;
    setState(() {
      isFavorite = doc.exists;
      loadingFav = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(widget.requestId);

    if (isFavorite) {
      await ref.delete();
    } else {
      await ref.set({
        'requestId': widget.requestId,
        'ownerId': widget.ownerId,
        'title': widget.title,
        'imageUrl': widget.imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    if (!mounted) return;
    setState(() {
      isFavorite = !isFavorite;
    });

    await ActionFeedbackService.showMessage(
      context,
      title: isFavorite ? 'Favorilere eklendi' : 'Favorilerden cikarildi',
      message: isFavorite ? 'Favorilere eklendi.' : 'Favorilerden cikarildi.',
      icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
    );
  }

  Future<void> _deleteRequest() async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Ilan silinsin mi?'),
            content: const Text('Bu islem geri alinamaz.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Iptal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Sil'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    await RequestDeleteService().deleteRequest(widget.requestId);
    if (!mounted) return;

    Navigator.pop(context);

    await ActionFeedbackService.show(
      context,
      title: 'Ilan silindi',
      message: 'Ilan ve iliskili kayitlar kaldirildi.',
      icon: Icons.delete_outline_rounded,
    );
  }

  Future<void> _openChat() async {
    final chatId = await chatService.createChatRoom(
      userId,
      widget.ownerId,
      widget.requestId,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)),
    );
  }

  Future<String?> _pickModerationReason() async {
    const reasons = <String>[
      'Hakaret veya taciz',
      'Uygunsuz icerik',
      'Spam veya dolandiricilik',
      'Tehdit veya guvensiz davranis',
      'Diger',
    ];

    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bu ilani neden sikayet etmek istiyorsun?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                ...reasons.map(
                  (reason) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(reason),
                    onTap: () => Navigator.pop(sheetContext, reason),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _reportRequest() async {
    final reason = await _pickModerationReason();
    if (reason == null) return;

    await ModerationService().reportRequest(
      requestId: widget.requestId,
      ownerId: widget.ownerId,
      reason: reason,
      metadata: {
        'surface': 'food_detail',
        'title': widget.title,
      },
    );

    if (!mounted) return;
    await ActionFeedbackService.show(
      context,
      title: 'Sikayet alindi',
      message: 'Bildirim alindi. Moderasyon ekibimiz en gec 24 saat icinde inceleyecek.',
      icon: Icons.flag_outlined,
    );
  }

  Future<void> _blockOwner() async {
    await ModerationService().blockUser(
      targetUserId: widget.ownerId,
      reason: 'Hazir yemek ilaninda kullanici engellendi',
      metadata: {
        'surface': 'food_detail',
        'requestId': widget.requestId,
      },
    );

    if (!mounted) return;
    await ActionFeedbackService.show(
      context,
      title: 'Kullanici engellendi',
      message: 'Bu kullanicinin ilanlari ve iletisimleri artik sana gosterilmeyecek.',
      icon: Icons.block_outlined,
    );
    if (mounted) Navigator.pop(context);
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
    final bool isOwner = userId == widget.ownerId;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .snapshots(),
      builder: (context, requestSnapshot) {
        final requestData = requestSnapshot.data?.data() ?? <String, dynamic>{};
        final bool isFeatured = requestData['isFeatured'] == true;
        final Timestamp? featuredUntil = requestData['featuredUntil'] as Timestamp?;
        final bool isFeatureActive =
            isFeatured && featuredUntil != null && featuredUntil.toDate().isAfter(DateTime.now());

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
                ),
              if (!isOwner)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'report') {
                      await _reportRequest();
                    } else if (value == 'block') {
                      await _blockOwner();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem<String>(
                      value: 'report',
                      child: Text('Ilani Sikayet Et'),
                    ),
                    PopupMenuItem<String>(
                      value: 'block',
                      child: Text('Kullaniciyi Engelle'),
                    ),
                  ],
                ),
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
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.price} TL - ${widget.portion} porsiyon',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                          'Hazirlayan: ${widget.ownerName}',
                          style: const TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        children: isOwner
                            ? [
                                _buildActionCard(
                                  icon: Icons.star,
                                  title: 'One Cikar (50 kredi)',
                                  color: Colors.orange,
                                  onTap: () async {
                                    if (isFeatureActive) {
                                      await ActionFeedbackService.show(
                                        context,
                                        title: 'Bu ilan zaten one cikarilmis',
                                        message: 'Bu ilan zaten one cikarilmis durumda.',
                                        icon: Icons.verified_rounded,
                                      );
                                      return;
                                    }

                                    final success = await CreditService().performAction(
                                      userId: userId,
                                      cost: 50,
                                      actionName: 'feature',
                                      onSuccess: () async {
                                        await FirebaseFirestore.instance
                                            .collection('requests')
                                            .doc(widget.requestId)
                                            .update({
                                          'isFeatured': true,
                                          'featuredUntil': Timestamp.fromDate(
                                            DateTime.now().add(const Duration(days: 3)),
                                          ),
                                        });
                                      },
                                    );

                                    if (success && mounted) {
                                      await ActionFeedbackService.show(
                                        context,
                                        title: 'Ilan one cikarildi',
                                        message: 'Ilan one cikarildi.',
                                        icon: Icons.star_rounded,
                                      );
                                    }
                                  },
                                ),
                                _buildActionCard(
                                  icon: Icons.delete_outline,
                                  title: 'Ilani Sil',
                                  color: Colors.red,
                                  onTap: _deleteRequest,
                                ),
                              ]
                            : [
                                _buildActionCard(
                                  icon: Icons.chat,
                                  title: 'Mesaj Gonder\n(Ilk mesaj 10 kredi)',
                                  color: Colors.blue,
                                  onTap: _openChat,
                                ),
                                _buildActionCard(
                                  icon: Icons.shopping_bag,
                                  title: 'Siparis Ver',
                                  color: Colors.green,
                                  onTap: _openChat,
                                ),
                                _buildActionCard(
                                  icon: Icons.local_offer,
                                  title: 'Teklif Ver',
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
                ),
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
    VoidCallback? onTap,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
