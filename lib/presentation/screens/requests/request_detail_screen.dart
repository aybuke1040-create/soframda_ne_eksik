import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_scope.dart';
import 'package:soframda_ne_eksik/presentation/screens/chat/chat_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/offers/send_offer_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/profile/profile_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/requests/create_request_screen.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/chat_service.dart';
import 'package:soframda_ne_eksik/services/credit_service.dart';
import 'package:soframda_ne_eksik/services/offer_service.dart';
import 'package:soframda_ne_eksik/services/paywall_service.dart';

class RequestDetailScreen extends StatelessWidget {
  final String requestId;
  final String ownerId;

  const RequestDetailScreen({
    super.key,
    required this.requestId,
    required this.ownerId,
  });

  Future<void> _deleteRequest(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(context.t('İlan silinsin mi?', 'Delete listing?')),
            content: Text(
              context.t('Bu ilan tamamen silinecek.', 'This listing will be deleted permanently.'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(context.t('Vazgeç', 'Cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(context.t('Sil', 'Delete')),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;
    await FirebaseFirestore.instance.collection('requests').doc(requestId).delete();
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _featureRequest(BuildContext context) async {
    final currentCredits = await CreditService().getUserCredits();
    if (!context.mounted) return;

    if (currentCredits < 50) {
      PaywallService.showInsufficientCreditsSheet(
        context,
        title: 'Öne çıkarmak için 50 kredi gerekiyor',
        message: 'İlanını daha fazla kişiye göstermek için kredi satın alıp hemen öne çıkarabilirsin.',
        buttonLabel: 'Kredi Satın Al',
        highlight: 'Öne çıkarma için kredi paketleri',
      );
      return;
    }

    final result = await CreditService().featureRequest(requestId);
    if (!context.mounted) return;

    if (result == FeatureRequestStatus.insufficientCredit) {
      PaywallService.showInsufficientCreditsSheet(
        context,
        title: 'Öne çıkarmak için 50 kredi gerekiyor',
        message: 'İlanını daha fazla kişiye göstermek için kredi satın alıp hemen öne çıkarabilirsin.',
        buttonLabel: 'Kredi Satın Al',
        highlight: 'Öne çıkarma için kredi paketleri',
      );
      return;
    }

    await ActionFeedbackService.show(
      context,
      title: result == FeatureRequestStatus.success
          ? context.t('İlan öne çıkarıldı', 'Listing featured')
          : result == FeatureRequestStatus.alreadyFeatured
              ? context.t('Bu ilan zaten öne çıkarılmış', 'This listing is already featured')
              : context.t('Öne çıkarma tamamlanamadı', 'Featuring could not be completed'),
      message: result == FeatureRequestStatus.success
          ? context.t(
              'İlanın daha görünür hale getirildi. Birkaç gün boyunca üst sıralarda gösterilecek.',
              'Your listing is now more visible and will appear higher for a few days.',
            )
          : result == FeatureRequestStatus.alreadyFeatured
              ? context.t(
                  'Bu ilan zaten öne çıkarılmış durumda. Ekstra bir işlem yapmana gerek yok.',
                  'This listing is already featured. No extra action is needed.',
                )
              : context.t(
                  'Şu anda öne çıkarma işlemi tamamlanamadı. Kısa süre sonra tekrar deneyebilirsin.',
                  'Featuring could not be completed right now. You can try again shortly.',
                ),
      icon: result == FeatureRequestStatus.success
          ? Icons.star_rounded
          : result == FeatureRequestStatus.alreadyFeatured
              ? Icons.verified_rounded
              : Icons.error_outline_rounded,
    );
  }

  Future<void> _openChat(BuildContext context, String targetOwnerId) async {
    if (targetOwnerId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('İlan sahibine ulaşılamadı.', 'The listing owner could not be reached.'))),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final chatId = await ChatService().createChatRoom(currentUser.uid, targetOwnerId, requestId);
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('Sohbet açılamadı: $e', 'Chat could not be opened: $e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final isOwner = user.uid == ownerId;

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('requests').doc(requestId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) {
            return Center(child: Text(context.t('İlan bulunamadı.', 'Listing not found.')));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final imageUrl = data['imageUrl'] as String? ?? '';
          final title = data['title'] as String? ?? '';
          final description = data['description'] as String? ?? '';
          final quantity = data['quantity'] as String? ?? '';
          final ownerName = ((data['ownerName'] as String?) ?? '').trim().isEmpty
              ? 'Kullanıcı'
              : (data['ownerName'] as String).trim();
          final isFeatured = data['isFeatured'] == true;
          final featuredUntil = data['featuredUntil'] as Timestamp?;
          final isFeatureActive = isFeatured && featuredUntil != null && featuredUntil.toDate().isAfter(DateTime.now());

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                title: Text(context.t('İlan Detayı', 'Listing Details')),
                flexibleSpace: FlexibleSpaceBar(
                  background: imageUrl.isEmpty
                      ? Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.room_service_outlined, size: 72, color: Colors.grey),
                        )
                      : (imageUrl.startsWith('assets/')
                          ? Image.asset(imageUrl, fit: BoxFit.cover)
                          : Image.network(imageUrl, fit: BoxFit.cover)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: ownerId.isEmpty ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => UserProfileScreen(userId: ownerId)),
                          );
                        },
                        child: Text(
                          'İlan sahibi: $ownerName',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade700, decoration: TextDecoration.underline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          description.trim().isEmpty
                              ? context.t('İlan sahibi burada henüz detay eklememiş.', 'The listing owner has not added details yet.')
                              : description,
                          style: const TextStyle(height: 1.5, fontSize: 15),
                        ),
                      ),
                      if (quantity.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(quantity, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                      ],
                      const SizedBox(height: 20),
                      Text(context.t('Aksiyonlar', 'Actions'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
                          child: Text(
                            context.t('Soruların varsa mesaj at, ben yaparım diyorsan hemen teklif ver.', 'If you have questions, send a message. If you can do it, send an offer right away.'),
                            style: const TextStyle(fontSize: 14, height: 1.45, color: Color(0xFF6B5232), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        children: isOwner
                            ? [
                                _actionCard(
                                  icon: Icons.edit_outlined,
                                  title: context.t('Düzenle', 'Edit'),
                                  color: const Color(0xFF2D7FF9),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => CreateRequestScreen(requestId: requestId)));
                                  },
                                ),
                                _actionCard(
                                  icon: Icons.star_outline,
                                  title: context.t('Öne Çıkar\n(50 kredi)', 'Feature\n(50 credits)'),
                                  color: Colors.orange,
                                  onTap: () async {
                                    if (isFeatureActive) {
                                      await ActionFeedbackService.show(
                                        context,
                                        title: 'Bu ilan zaten öne çıkarılmış',
                                        message: 'Bu ilan zaten öne çıkarılmış durumda. Ekstra bir işlem yapmana gerek yok.',
                                        icon: Icons.verified_rounded,
                                      );
                                      return;
                                    }
                                    await _featureRequest(context);
                                  },
                                ),
                                _actionCard(
                                  icon: Icons.delete_outline,
                                  title: context.t('İlanı Sil', 'Delete Listing'),
                                  color: Colors.red,
                                  onTap: () => _deleteRequest(context),
                                ),
                              ]
                            : [
                                _actionCard(
                                  icon: Icons.chat_bubble_outline,
                                  title: context.t('Mesaj Gönder\n(İlk mesaj 10 kredi)', 'Send Message\n(First message 10 credits)'),
                                  color: Colors.blue,
                                  onTap: () => _openChat(context, ownerId),
                                ),
                                _actionCard(
                                  icon: Icons.local_offer_outlined,
                                  title: context.t('Teklif Ver\n(5 kredi)', 'Send Offer\n(5 credits)'),
                                  color: const Color(0xFF1E8E5A),
                                  onTap: () async {
                                    final currentCredits = await CreditService().getUserCredits();
                                    if (!context.mounted) return;
                                    if (currentCredits < 5) {
                                      PaywallService.showInsufficientCreditsSheet(
                                        context,
                                        title: 'Teklif vermek için 5 kredi gerekiyor',
                                        message: 'Teklifini hemen gönderebilmek için önce kredi satın alabilir, sonra tek dokunuşla devam edebilirsin.',
                                        highlight: 'Teklif kredi paketleri',
                                      );
                                      return;
                                    }
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => SendOfferScreen(requestId: requestId, ownerId: ownerId)));
                                  },
                                ),
                              ],
                      ),
                      if (isOwner) ...[
                        const SizedBox(height: 24),
                        const Text('Gelen Teklifler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('offers').where('requestId', isEqualTo: requestId).snapshots(),
                          builder: (context, offerSnapshot) {
                            if (!offerSnapshot.hasData) {
                              return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                            }

                            final offers = [...offerSnapshot.data!.docs];
                            offers.sort((a, b) {
                              final aData = a.data() as Map<String, dynamic>;
                              final bData = b.data() as Map<String, dynamic>;
                              final aTime = aData['createdAt'];
                              final bTime = bData['createdAt'];
                              final aMs = aTime is Timestamp ? aTime.millisecondsSinceEpoch : 0;
                              final bMs = bTime is Timestamp ? bTime.millisecondsSinceEpoch : 0;
                              return bMs.compareTo(aMs);
                            });

                            if (offers.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(18)),
                                child: const Text('Henüz teklif gelmedi. İlanı öne çıkararak daha fazla görünürlük alabilirsin.'),
                              );
                            }

                            return Column(
                              children: offers.map((doc) {
                                final offer = doc.data() as Map<String, dynamic>;
                                final status = offer['status'] as String? ?? 'pending';
                                final price = offer['price'];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(price == null ? 'Fiyat belirtilmedi' : 'Teklif: TL $price', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                            const SizedBox(height: 4),
                                            Text('Durum: ${_statusLabel(status)}', style: TextStyle(color: Colors.grey.shade700)),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final senderId = (offer['senderId'] ?? '').toString();
                                          if (senderId.trim().isEmpty) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teklif sahibine ulaşılamadı.')));
                                            return;
                                          }
                                          try {
                                            final chatId = await ChatService().createChatRoom(user.uid, senderId, requestId);
                                            if (!context.mounted) return;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ChatScreen(
                                                  chatId: chatId,
                                                  initialRequestId: requestId,
                                                  initialOfferId: status == 'pending' ? doc.id : null,
                                                  initialOfferPrice: price is num ? price.toInt() : null,
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Teklif açılamadı: $e')));
                                          }
                                        },
                                        child: const Text('Teklifi İncele'),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
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

  static Widget _actionCard({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Kabul edildi';
      case 'rejected':
        return 'Reddedildi';
      case 'pending':
      default:
        return 'Bekliyor';
    }
  }
}
