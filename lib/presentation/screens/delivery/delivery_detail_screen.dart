import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_scope.dart';
import 'package:soframda_ne_eksik/core/utils/date_format_utils.dart';
import 'package:soframda_ne_eksik/presentation/screens/chat/chat_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/delivery/create_delivery_request_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/offers/send_offer_screen.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/chat_service.dart';
import 'package:soframda_ne_eksik/services/credit_service.dart';
import 'package:soframda_ne_eksik/services/moderation_service.dart';
import 'package:soframda_ne_eksik/services/paywall_service.dart';
import 'package:soframda_ne_eksik/services/request_delete_service.dart';

class DeliveryDetailScreen extends StatelessWidget {
  final String requestId;

  const DeliveryDetailScreen({super.key, required this.requestId});

  Future<String?> _pickModerationReason(BuildContext context) async {
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

  Future<void> _reportRequest(
      BuildContext context, String ownerId, String title) async {
    final reason = await _pickModerationReason(context);
    if (reason == null) return;

    await ModerationService().reportRequest(
      requestId: requestId,
      ownerId: ownerId,
      reason: reason,
      metadata: {
        'surface': 'delivery_detail',
        'title': title,
      },
    );

    if (!context.mounted) return;
    await ActionFeedbackService.show(
      context,
      title: 'Sikayet alindi',
      message:
          'Bildirim alindi. Moderasyon ekibimiz en gec 24 saat icinde inceleyecek.',
      icon: Icons.flag_outlined,
    );
  }

  Future<void> _blockOwner(BuildContext context, String ownerId) async {
    await ModerationService().blockUser(
      targetUserId: ownerId,
      reason: 'Tasima ilaninda kullanici engellendi',
      metadata: {
        'surface': 'delivery_detail',
        'requestId': requestId,
      },
    );

    if (!context.mounted) return;
    await ActionFeedbackService.show(
      context,
      title: 'Kullanici engellendi',
      message:
          'Bu kullanicinin ilanlari ve iletisimleri artik sana gosterilmeyecek.',
      icon: Icons.block_outlined,
    );
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _deleteRequest(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(context.t('Ä°lan silinsin mi?', 'Delete listing?')),
            content: Text(
              context.t(
                'Bu taÅŸÄ±ma ilanÄ± tamamen silinecek.',
                'This delivery listing will be deleted permanently.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(context.t('VazgeÃ§', 'Cancel')),
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
    await RequestDeleteService().deleteRequest(requestId);
    if (!context.mounted) return;
    Navigator.pop(context);
    await ActionFeedbackService.show(
      context,
      title: context.t('Ä°lan silindi', 'Listing deleted'),
      message: context.t(
        'TaÅŸÄ±ma ilanÄ±n ve iliÅŸkili kayÄ±tlar kaldÄ±rÄ±ldÄ±.',
        'Your delivery listing and related records were removed.',
      ),
      icon: Icons.delete_outline_rounded,
    );
  }

  Future<void> _featureRequest(BuildContext context) async {
    final currentCredits = await CreditService().getUserCredits();
    if (!context.mounted) return;

    if (currentCredits < 50) {
      PaywallService.showInsufficientCreditsSheet(
        context,
        title: 'Ã–ne Ã§Ä±karmak iÃ§in 50 kredi gerekiyor',
        message:
            'TaÅŸÄ±ma ilanÄ±nÄ± daha fazla kiÅŸiye gÃ¶stermek iÃ§in kredi satÄ±n alÄ±p hemen Ã¶ne Ã§Ä±karabilirsin.',
        buttonLabel: 'Kredi SatÄ±n Al',
        highlight: 'Ã–ne Ã§Ä±karma iÃ§in kredi paketleri',
      );
      return;
    }

    final result = await CreditService().featureRequest(requestId);
    if (!context.mounted) return;

    if (result == FeatureRequestStatus.insufficientCredit) {
      PaywallService.showInsufficientCreditsSheet(
        context,
        title: 'Ã–ne Ã§Ä±karmak iÃ§in 50 kredi gerekiyor',
        message:
            'TaÅŸÄ±ma ilanÄ±nÄ± daha fazla kiÅŸiye gÃ¶stermek iÃ§in kredi satÄ±n alÄ±p hemen Ã¶ne Ã§Ä±karabilirsin.',
        buttonLabel: 'Kredi SatÄ±n Al',
        highlight: 'Ã–ne Ã§Ä±karma iÃ§in kredi paketleri',
      );
      return;
    }

    await ActionFeedbackService.show(
      context,
      title: result == FeatureRequestStatus.success
          ? context.t('Ä°lan Ã¶ne Ã§Ä±karÄ±ldÄ±', 'Listing featured')
          : result == FeatureRequestStatus.alreadyFeatured
              ? context.t('Bu ilan zaten Ã¶ne Ã§Ä±karÄ±lmÄ±ÅŸ',
                  'This listing is already featured')
              : context.t('Ã–ne Ã§Ä±karma tamamlanamadÄ±',
                  'Featuring could not be completed'),
      message: result == FeatureRequestStatus.success
          ? context.t(
              'Ä°lanÄ±n daha gÃ¶rÃ¼nÃ¼r hale getirildi. BirkaÃ§ gÃ¼n boyunca Ã¼st sÄ±ralarda gÃ¶sterilecek.',
              'Your listing is now more visible and will appear higher for a few days.',
            )
          : result == FeatureRequestStatus.alreadyFeatured
              ? context.t(
                  'Bu ilan zaten Ã¶ne Ã§Ä±karÄ±lmÄ±ÅŸ durumda. Ekstra bir iÅŸlem yapmana gerek yok.',
                  'This listing is already featured. No extra action is needed.',
                )
              : context.t(
                  'Åu anda Ã¶ne Ã§Ä±karma iÅŸlemi tamamlanamadÄ±. KÄ±sa sÃ¼re sonra tekrar deneyebilirsin.',
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
      await ActionFeedbackService.show(
        context,
        title: context.t('Ä°lan sahibine ulaÅŸÄ±lamadÄ±', 'Owner unavailable'),
        message: context.t(
          'Ä°lan sahibine ulaÅŸÄ±lamadÄ±.',
          'The listing owner could not be reached.',
        ),
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final chatId =
          await ChatService().createChatRoom(currentUserId, ownerId, requestId);
      if (!context.mounted) return;
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)));
    } catch (e) {
      if (!context.mounted) return;
      await ActionFeedbackService.show(
        context,
        title: context.t('Sohbet aÃ§Ä±lamadÄ±', 'Chat could not be opened'),
        message: context.t(
          'Sohbet aÃ§Ä±lamadÄ±: $e',
          'Chat could not be opened: $e',
        ),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
                title: Text(context.t('TaÅŸÄ±ma Ä°lanÄ±', 'Delivery Listing'))),
            body: Center(
                child: Text(
                    context.t('Ä°lan bulunamadÄ±.', 'Listing not found.'))),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final ownerId = data['ownerId'] as String? ?? '';
        final isOwner = ownerId == currentUserId;
        final imageUrl = data['imageUrl'] as String? ?? '';
        final description = data['description'] as String? ?? '';
        final publishedDate = formatPublishedDate(data['createdAt']);
        final isFeatured = data['isFeatured'] == true;
        final featuredUntil = data['featuredUntil'] as Timestamp?;
        final isFeatureActive = isFeatured &&
            featuredUntil != null &&
            featuredUntil.toDate().isAfter(DateTime.now());

        return Scaffold(
          appBar: AppBar(
            title: Text(context.t('TaÅŸÄ±ma Ä°lanÄ±', 'Delivery Listing')),
            actions: [
              if (!isOwner)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'report') {
                      await _reportRequest(
                          context, ownerId, (data['title'] ?? '').toString());
                    } else if (value == 'block') {
                      await _blockOwner(context, ownerId);
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageUrl.isEmpty
                      ? Container(
                          height: 220,
                          color: Colors.grey[300],
                          child: const Center(
                              child: Icon(Icons.local_shipping, size: 60)),
                        )
                      : Image.network(imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((data['title'] ?? '').toString(),
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(context.t(
                            'AlÄ±ÅŸ: ${data['pickupAddress'] ?? '-'}',
                            'Pickup: ${data['pickupAddress'] ?? '-'}')),
                        Text(context.t('BÄ±rak: ${data['dropAddress'] ?? '-'}',
                            'Drop-off: ${data['dropAddress'] ?? '-'}')),
                        if (publishedDate != null)
                          Text('Yayın tarihi: $publishedDate'),
                        if ((data['deliveryTime'] ?? '').toString().isNotEmpty)
                          Text(context.t('Zaman: ${data['deliveryTime']}',
                              'Time: ${data['deliveryTime']}')),
                        if (description.trim().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(context.t('AÃ§Ä±klama', 'Description'),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(description),
                        ],
                        const SizedBox(height: 18),
                        Text(context.t('Aksiyonlar', 'Actions'),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        if (!isOwner) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F3EA),
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFEADBC4)),
                            ),
                            child: Text(
                              context.t(
                                  'SorularÄ±n varsa mesaj at, ben yaparÄ±m diyorsan hemen teklif ver.',
                                  'If you have questions, send a message. If you can do it, send an offer right away.'),
                              style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: Color(0xFF6B5232),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: isOwner
                              ? [
                                  _btn(context.t('DÃ¼zenle', 'Edit'),
                                      onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                CreateDeliveryRequestScreen(
                                                    requestId: requestId)));
                                  }),
                                  _btn(
                                      context.t(
                                          'Ä°lanÄ± Sil', 'Delete Listing'),
                                      onTap: () => _deleteRequest(context)),
                                  _btn(context.t('Ã–ne Ã‡Ä±kar', 'Feature'),
                                      onTap: () async {
                                    if (isFeatureActive) {
                                      await ActionFeedbackService.show(
                                        context,
                                        title:
                                            'Bu ilan zaten Ã¶ne Ã§Ä±karÄ±lmÄ±ÅŸ',
                                        message:
                                            'Bu ilan zaten Ã¶ne Ã§Ä±karÄ±lmÄ±ÅŸ durumda. Ekstra bir iÅŸlem yapmana gerek yok.',
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
                                          'Mesaj GÃ¶nder\n(Ä°lk mesaj 10 kredi)',
                                          'Send Message\n(First message 10 credits)'),
                                      onTap: () => _openChat(context, ownerId)),
                                  _btn(
                                      context.t('Teklif Ver (10 kredi)',
                                          'Send Offer (10 credits)'),
                                      onTap: () async {
                                    final currentCredits =
                                        await CreditService().getUserCredits();
                                    if (!context.mounted) return;
                                    if (currentCredits < 10) {
                                      PaywallService
                                          .showInsufficientCreditsSheet(
                                        context,
                                        title:
                                            'Teklif vermek iÃ§in 10 kredi gerekiyor',
                                        message:
                                            'Teklifini hemen gÃ¶nderebilmek iÃ§in Ã¶nce kredi satÄ±n alabilir, sonra tek dokunuÅŸla devam edebilirsin.',
                                        highlight: 'Teklif kredi paketleri',
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => SendOfferScreen(
                                                requestId: requestId,
                                                ownerId: ownerId,
                                                offerCreditCost: 10)));
                                  }),
                                ],
                        ),
                        if (isOwner) ...[
                          const SizedBox(height: 24),
                          Text(context.t('Gelen Teklifler', 'Incoming Offers'),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('offers')
                                .where('requestId', isEqualTo: requestId)
                                .snapshots(),
                            builder: (context, offerSnapshot) {
                              if (!offerSnapshot.hasData) {
                                return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator());
                              }

                              final offers = [...offerSnapshot.data!.docs];
                              offers.sort((a, b) {
                                final aData = a.data() as Map<String, dynamic>;
                                final bData = b.data() as Map<String, dynamic>;
                                final aTime = aData['createdAt'];
                                final bTime = bData['createdAt'];
                                final aMs = aTime is Timestamp
                                    ? aTime.millisecondsSinceEpoch
                                    : 0;
                                final bMs = bTime is Timestamp
                                    ? bTime.millisecondsSinceEpoch
                                    : 0;
                                return bMs.compareTo(aMs);
                              });

                              if (offers.isEmpty)
                                return Text(context.t(
                                    'HenÃ¼z teklif yok.', 'No offers yet.'));

                              return Column(
                                children: offers.map((doc) {
                                  final offer =
                                      doc.data() as Map<String, dynamic>;
                                  final price = offer['price'];
                                  final status =
                                      offer['status'] as String? ?? 'pending';

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  price == null
                                                      ? 'Fiyat belirtilmedi'
                                                      : 'Teklif: TL $price',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              const SizedBox(height: 4),
                                              Text('Durum: ${_status(status)}'),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            final senderId =
                                                (offer['senderId'] ?? '')
                                                    .toString();
                                            if (senderId.trim().isEmpty) {
                                              if (!context.mounted) return;
                                              await ActionFeedbackService.show(
                                                context,
                                                title:
                                                    'Teklif sahibi bulunamadÄ±',
                                                message:
                                                    'Teklif sahibine ulaÅŸÄ±lamadÄ±.',
                                                icon:
                                                    Icons.error_outline_rounded,
                                              );
                                              return;
                                            }

                                            try {
                                              final chatId = await ChatService()
                                                  .createChatRoom(currentUserId,
                                                      senderId, requestId);
                                              if (!context.mounted) return;
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ChatScreen(
                                                    chatId: chatId,
                                                    initialRequestId: requestId,
                                                    initialOfferId:
                                                        status == 'pending'
                                                            ? doc.id
                                                            : null,
                                                    initialOfferPrice:
                                                        price is num
                                                            ? price.toInt()
                                                            : null,
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              await ActionFeedbackService.show(
                                                context,
                                                title: 'Teklif aÃ§Ä±lamadÄ±',
                                                message:
                                                    'Teklif aÃ§Ä±lamadÄ±: $e',
                                                icon:
                                                    Icons.error_outline_rounded,
                                              );
                                            }
                                          },
                                          child: const Text('Teklifi Ä°ncele'),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _btn(String text, {VoidCallback? onTap}) =>
      ElevatedButton(onPressed: onTap, child: Text(text));

  static String _status(String value) {
    switch (value) {
      case 'accepted':
        return 'Kabul edildi';
      case 'rejected':
        return 'Reddedildi';
      default:
        return 'Bekliyor';
    }
  }
}
