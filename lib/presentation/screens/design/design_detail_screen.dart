import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_scope.dart';
import 'package:soframda_ne_eksik/presentation/screens/chat/chat_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/design/create_design_request_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/offers/send_offer_screen.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/chat_service.dart';
import 'package:soframda_ne_eksik/services/credit_service.dart';
import 'package:soframda_ne_eksik/services/offer_service.dart';
import 'package:soframda_ne_eksik/services/paywall_service.dart';

class DesignDetailScreen extends StatelessWidget {
  final String requestId;

  const DesignDetailScreen({super.key, required this.requestId});

  Future<void> _deleteRequest(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(context.t('İlan silinsin mi?', 'Delete listing?')),
            content: Text(
              context.t(
                'Bu organizasyon ilanı tamamen silinecek.',
                'This event listing will be deleted permanently.',
              ),
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
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _featureRequest(BuildContext context) async {
    final currentCredits = await CreditService().getUserCredits();
    if (!context.mounted) return;

    if (currentCredits < 50) {
      PaywallService.showInsufficientCreditsSheet(
        context,
        title: 'Öne çıkarmak için 50 kredi gerekiyor',
        message:
            'Organizasyon ilanını daha fazla kişiye göstermek için kredi satın alıp hemen öne çıkarabilirsin.',
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
        message:
            'Organizasyon ilanını daha fazla kişiye göstermek için kredi satın alıp hemen öne çıkarabilirsin.',
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

  Future<void> _openChat(BuildContext context, String ownerId) async {
    if (ownerId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('İlan sahibine ulaşılamadı.', 'The listing owner could not be reached.'))),
      );
      return;
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final chatId = await ChatService().createChatRoom(currentUserId, ownerId, requestId);
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('Sohbet açılamadı: $e', 'Chat could not be opened: $e'))),
      );
    }
  }

  Widget _btn(String text, {VoidCallback? onTap}) {
    return ElevatedButton(onPressed: onTap, child: Text(text));
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Organizasyon İlanı', 'Event Listing'))),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('requests').doc(requestId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return Center(child: Text(context.t('İlan bulunamadı.', 'Listing not found.')));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final ownerId = data['ownerId'] as String? ?? '';
          final isOwner = ownerId == currentUserId;
          final imageUrl = data['imageUrl'] as String? ?? '';
          final isFeatured = data['isFeatured'] == true;
          final featuredUntil = data['featuredUntil'] as Timestamp?;
          final isFeatureActive = isFeatured &&
              featuredUntil != null &&
              featuredUntil.toDate().isAfter(DateTime.now());

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageUrl.isEmpty
                      ? Container(
                          height: 220,
                          color: Colors.grey[300],
                          child: const Icon(Icons.event, size: 60),
                        )
                      : Image.network(
                          imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (data['title'] ?? '').toString(),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text('${data['guestCount'] ?? 0} kişi'),
                        Text('${data['location'] ?? '-'}'),
                        Text('${data['date'] ?? '-'}'),
                        const SizedBox(height: 10),
                        Text(data['description'] ?? ''),
                        const SizedBox(height: 18),
                        Text(
                          context.t('Aksiyonlar', 'Actions'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                            child: Text(
                              context.t(
                                'Soruların varsa mesaj at, ben yaparım diyorsan hemen teklif ver.',
                                'If you have questions, send a message. If you can do it, send an offer right away.',
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: Color(0xFF6B5232),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: isOwner
                              ? [
                                  _btn(context.t('Düzenle', 'Edit'), onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CreateDesignRequestScreen(requestId: requestId),
                                      ),
                                    );
                                  }),
                                  _btn(context.t('İlanı Sil', 'Delete Listing'), onTap: () {
                                    _deleteRequest(context);
                                  }),
                                  _btn(context.t('Öne Çıkar', 'Feature'), onTap: () async {
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
                                  }),
                                ]
                              : [
                                  _btn(
                                    context.t(
                                      'Mesaj Gönder\n(İlk mesaj 10 kredi)',
                                      'Send Message\n(First message 10 credits)',
                                    ),
                                    onTap: () => _openChat(context, ownerId),
                                  ),
                                  _btn(
                                    context.t('Teklif Ver (5 kredi)', 'Send Offer (5 credits)'),
                                    onTap: () async {
                                      final currentCredits = await CreditService().getUserCredits();
                                      if (!context.mounted) return;

                                      if (currentCredits < 5) {
                                        PaywallService.showInsufficientCreditsSheet(
                                          context,
                                          title: 'Teklif vermek için 5 kredi gerekiyor',
                                          message:
                                              'Teklifini hemen gönderebilmek için önce kredi satın alabilir, sonra tek dokunuşla devam edebilirsin.',
                                          highlight: 'Teklif kredi paketleri',
                                        );
                                        return;
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SendOfferScreen(requestId: requestId, ownerId: ownerId),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                        ),
                        if (isOwner) ...[
                          const SizedBox(height: 24),
                          Text(
                            context.t('Gelen Teklifler', 'Incoming Offers'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('offers')
                                .where('requestId', isEqualTo: requestId)
                                .snapshots(),
                            builder: (context, offerSnapshot) {
                              if (!offerSnapshot.hasData) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
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
                                return Text(context.t('Henüz teklif yok.', 'No offers yet.'));
                              }

                              return Column(
                                children: offers.map((doc) {
                                  final offer = doc.data() as Map<String, dynamic>;
                                  final status = offer['status'] as String? ?? 'pending';
                                  final price = offer['price'];
                                  return ListTile(
                                    title: Text(price == null ? 'Fiyat belirtilmedi' : 'Teklif: TL $price'),
                                    subtitle: Text('Durum: $status'),
                                    trailing: TextButton(
                                      onPressed: () async {
                                        final senderId = offer['senderId'] as String? ?? '';
                                        if (senderId.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Teklif sahibine ulaşılamadı.')),
                                          );
                                          return;
                                        }

                                        final chatId = await ChatService().createChatRoom(
                                          currentUserId,
                                          senderId,
                                          requestId,
                                        );

                                        if (!context.mounted) return;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ChatScreen(
                                              chatId: chatId,
                                              initialRequestId: requestId,
                                              initialOfferId: doc.id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Teklifi İncele'),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
