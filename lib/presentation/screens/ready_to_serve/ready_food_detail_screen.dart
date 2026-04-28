import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soframda_ne_eksik/presentation/screens/chat/chat_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/profile/profile_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/requests/create_request_screen.dart';
import 'package:soframda_ne_eksik/presentation/widgets/floating_credit_animation.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/chat_service.dart';
import 'package:soframda_ne_eksik/services/credit_service.dart';
import 'package:soframda_ne_eksik/services/moderation_service.dart';
import 'package:soframda_ne_eksik/services/paywall_service.dart';
import 'package:soframda_ne_eksik/services/profile_completion_guard.dart';
import 'package:soframda_ne_eksik/services/request_delete_service.dart';

class ReadyFoodDetailScreen extends StatefulWidget {
  final String requestId;

  const ReadyFoodDetailScreen({super.key, required this.requestId});

  @override
  State<ReadyFoodDetailScreen> createState() => _ReadyFoodDetailScreenState();
}

class _ReadyFoodDetailScreenState extends State<ReadyFoodDetailScreen> {
  final _chatService = ChatService();
  final _creditService = CreditService();
  bool _isPlacingOrder = false;

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<Map<String, dynamic>?> _getUser(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> _featureRequest(String requestId) async {
    final result = await _creditService.featureRequest(requestId);

    if (!mounted) return;

    if (result == FeatureRequestStatus.success) {
      HapticFeedback.mediumImpact();
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (_) => const Center(
          child: FloatingCreditAnimation(text: '-50'),
        ),
      );
    }

    if (result == FeatureRequestStatus.insufficientCredit) {
      PaywallService.showInsufficientCreditsSheet(
        context,
        title: 'Öne çıkarmak için 50 kredi gerekiyor',
        message:
            'İlanını daha fazla kişiye göstermek için kredi satın alıp hemen öne çıkarabilirsin.',
        buttonLabel: 'Kredi Satın Al',
        highlight: 'Öne çıkarma için kredi paketleri',
      );
      return;
    }

    await ActionFeedbackService.show(
      context,
      title: result == FeatureRequestStatus.success
          ? 'İlan öne çıkarıldı'
          : result == FeatureRequestStatus.alreadyFeatured
              ? 'Bu ilan zaten öne çıkarılmış'
              : 'Öne çıkarma tamamlanamadı',
      message: result == FeatureRequestStatus.success
          ? 'İlanın daha görünür hale getirildi. Birkaç gün boyunca üst sıralarda gösterilecek.'
          : result == FeatureRequestStatus.alreadyFeatured
              ? 'Bu ilan zaten öne çıkarılmış durumda. Ekstra bir işlem yapmana gerek yok.'
              : 'Şu anda öne çıkarma işlemi tamamlanamadı. Kısa süre sonra tekrar deneyebilirsin.',
      icon: result == FeatureRequestStatus.success
          ? Icons.star_rounded
          : result == FeatureRequestStatus.alreadyFeatured
              ? Icons.verified_rounded
              : Icons.error_outline_rounded,
    );
  }

  Future<void> _deleteRequest() async {
    await RequestDeleteService().deleteRequest(widget.requestId);

    if (!mounted) return;

    Navigator.pop(context);
    await ActionFeedbackService.show(
      context,
      title: 'İlan silindi',
      message: 'Hazır yemek ilanın ve ilişkili kayıtlar kaldırıldı.',
      icon: Icons.delete_outline_rounded,
    );
  }

  Future<void> _openChat(String ownerId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;

    if (!await ProfileCompletionGuard.ensureDisplayNameReady(context)) return;

    try {
      final chatId = await _chatService.createChatRoom(
        currentUserId,
        ownerId,
        widget.requestId,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)),
      );
    } catch (e) {
      if (!mounted) return;
      await ActionFeedbackService.show(
        context,
        title: 'Sohbet açılamadı',
        message: 'Sohbet açılamadı: $e',
        icon: Icons.error_outline_rounded,
      );
    }
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

  Future<void> _reportRequest(String ownerId, String title) async {
    final reason = await _pickModerationReason();
    if (reason == null) return;

    await ModerationService().reportRequest(
      requestId: widget.requestId,
      ownerId: ownerId,
      reason: reason,
      metadata: {
        'surface': 'ready_food_detail',
        'title': title,
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

  Future<void> _blockOwner(String ownerId) async {
    await ModerationService().blockUser(
      targetUserId: ownerId,
      reason: 'Hazir yemek ilaninda kullanici engellendi',
      metadata: {
        'surface': 'ready_food_detail',
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

  Future<void> _placeOrder({
    required String requestId,
    required String ownerId,
    required String title,
  }) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null || ownerId.trim().isEmpty) return;
    if (!await ProfileCompletionGuard.ensureDisplayNameReady(context)) return;
    if (_isPlacingOrder) return;

    setState(() => _isPlacingOrder = true);

    try {
      await ActionFeedbackService.show(
        context,
        title: 'Sipariş hazırlanıyor',
        message:
            'Sipariş hazırlanıyor, lütfen bekleyin. Seni hemen sohbet ekranına yönlendiriyoruz.',
        icon: Icons.shopping_bag_outlined,
      );

      final success = await PaywallService.checkAndExecute(
        context: context,
        requiredCredits: 5,
        onSuccess: () async {
          await _creditService.useCredits(5);

          try {
            await FirebaseFirestore.instance
                .collection('requests')
                .doc(requestId)
                .collection('orders')
                .doc(currentUserId)
                .set({
              'buyerId': currentUserId,
              'status': 'pending',
              'title': title,
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true)).timeout(const Duration(seconds: 12));
          } catch (_) {
            // Sipariş kaydı oluşmasa bile kullanıcıyı sohbete al.
          }
        },
      );

      if (!mounted || !success) return;

      final chatId = await _chatService.createChatRoom(
        currentUserId,
        ownerId,
        requestId,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            initialDraftText: 'Sipariş vermek istiyorum.',
          ),
        ),
      );

      unawaited(
        _chatService.sendMessage(
          chatId: chatId,
          text: 'Sipariş vermek istiyorum.',
          senderId: currentUserId,
        ).catchError((_) {}),
      );
    } catch (e) {
      if (!mounted) return;
      await ActionFeedbackService.show(
        context,
        title: 'Sipariş başlatılamadı',
        message: 'Sipariş başlatılamadı: $e',
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: (onTap == null ? Colors.grey : color).withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: (onTap == null ? Colors.grey : color).withOpacity(0.18),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              Icon(icon, color: onTap == null ? Colors.grey : color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onTap == null ? Colors.grey : color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF8B6B3F)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text('İlan bulunamadı'));
          }

          final data = snapshot.data!.data() ?? <String, dynamic>{};
          final ownerId = (data['ownerId'] ?? '').toString();
          final title = (data['title'] ?? 'Hazır Yemek').toString();
          final description = (data['description'] ?? '').toString();
          final imageUrl = (data['imageUrl'] ?? '').toString();
          final ownerName = (data['ownerName'] ?? 'Kullanıcı').toString();
          final price = (data['price'] ?? '').toString();
          final portion = (data['portion'] ?? '').toString();
          final isOwner = ownerId.isNotEmpty && ownerId == _currentUserId;
          final isFeatured = data['isFeatured'] == true;
          final featuredUntil = data['featuredUntil'] as Timestamp?;
          final isFeatureActive = isFeatured &&
              featuredUntil != null &&
              featuredUntil.toDate().isAfter(DateTime.now());

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                actions: [
                  if (!isOwner)
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'report') {
                          await _reportRequest(ownerId, title);
                        } else if (value == 'block') {
                          await _blockOwner(ownerId);
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
                flexibleSpace: FlexibleSpaceBar(
                  background: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFFF6EDE1),
                          child: const Center(
                            child: Icon(Icons.fastfood, size: 72, color: Color(0xFFB97328)),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (isFeatureActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB97328).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Öne Çıkan İlan',
                                style: TextStyle(
                                  color: Color(0xFFB97328),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _infoRow(Icons.person_outline, 'İlan sahibi', ownerName),
                      const SizedBox(height: 8),
                      if (price.isNotEmpty) ...[
                        _infoRow(Icons.payments_outlined, 'Fiyat', '$price TL'),
                        const SizedBox(height: 8),
                      ],
                      if (portion.isNotEmpty) ...[
                        _infoRow(Icons.restaurant_outlined, 'Porsiyon', portion),
                        const SizedBox(height: 8),
                      ],
                      FutureBuilder<Map<String, dynamic>?>(
                        future: ownerId.isEmpty ? Future.value(null) : _getUser(ownerId),
                        builder: (context, userSnapshot) {
                          final userData = userSnapshot.data ?? {};
                          final bio = (userData['bio'] ?? '').toString().trim();
                          final hasBio = bio.isNotEmpty;

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8, bottom: 18),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F3EA),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFEADBC4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'İlan sahibi',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hasBio
                                      ? bio
                                      : 'İlan sahibi burada henüz detay eklememiş.',
                                  style: const TextStyle(fontSize: 14, height: 1.45),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: OutlinedButton.icon(
                                    onPressed: ownerId.isEmpty
                                        ? null
                                        : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => UserProfileScreen(userId: ownerId),
                                              ),
                                            );
                                          },
                                    icon: const Icon(Icons.person_outline),
                                    label: const Text('Profili Gör'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (description.isNotEmpty) ...[
                        const Text(
                          'Açıklama',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                        const SizedBox(height: 22),
                      ],
                      const Text(
                        'Aksiyonlar',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      if (!isOwner) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F3EA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEADBC4)),
                          ),
                          child: const Text(
                            'Soruların varsa mesaj at, kararın ise sipariş ver.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: Color(0xFF6B5232),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        children: isOwner
                            ? [
                                _actionCard(
                                  icon: Icons.edit_outlined,
                                  title: 'Düzenle',
                                  color: Colors.blue,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CreateRequestScreen(
                                          requestId: widget.requestId,
                                          isReady: true,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _actionCard(
                                  icon: Icons.auto_awesome,
                                  title: 'Öne Çıkar',
                                  color: const Color(0xFFB97328),
                                  onTap: () {
                                    if (isFeatureActive) {
                                      unawaited(
                                        ActionFeedbackService.show(
                                          context,
                                          title: 'Bu ilan zaten öne çıkarılmış',
                                          message:
                                              'Bu ilan zaten öne çıkarılmış durumda. Ekstra bir işlem yapmana gerek yok.',
                                          icon: Icons.verified_rounded,
                                        ),
                                      );
                                      return;
                                    }
                                    _featureRequest(widget.requestId);
                                  },
                                ),
                                _actionCard(
                                  icon: Icons.delete_outline,
                                  title: 'İlanı Sil',
                                  color: Colors.red,
                                  onTap: _deleteRequest,
                                ),
                              ]
                            : [
                                _actionCard(
                                  icon: Icons.chat_bubble_outline,
                                  title: 'Mesaj Gönder\n(İlk mesaj 10 kredi)',
                                  color: const Color(0xFF5B7BE3),
                                  onTap: ownerId.isEmpty ? null : () => _openChat(ownerId),
                                ),
                                _actionCard(
                                  icon: Icons.shopping_bag_outlined,
                                  title: _isPlacingOrder
                                      ? 'Sipariş Hazırlanıyor'
                                      : 'Sipariş Ver\n(5 kredi)',
                                  color: const Color(0xFF2E8B57),
                                  isLoading: _isPlacingOrder,
                                  onTap: ownerId.isEmpty || _isPlacingOrder
                                      ? null
                                      : () => _placeOrder(
                                            requestId: widget.requestId,
                                            ownerId: ownerId,
                                            title: title,
                                          ),
                                ),
                              ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
