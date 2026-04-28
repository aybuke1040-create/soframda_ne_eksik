import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/core/utils/request_visibility_utils.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/moderation_service.dart';

class MySentOffersScreen extends StatelessWidget {
  const MySentOffersScreen({super.key});

  Future<List<_SentOfferItem>> _loadVisibleOffers(
    List<QueryDocumentSnapshot> docs,
    Set<String> blockedUserIds,
  ) async {
    final items = <_SentOfferItem>[];

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final requestId = (data['requestId'] ?? '').toString();
      if (requestId.trim().isEmpty) {
        continue;
      }

      final requestSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .get();
      final requestData = requestSnapshot.data();

      if (!requestSnapshot.exists || !isRequestActiveForOffers(requestData)) {
        continue;
      }

      final requestOwnerId = (requestData?['ownerId'] ?? '').toString();
      if (blockedUserIds.contains(requestOwnerId)) {
        continue;
      }

      items.add(
        _SentOfferItem(
          offerDoc: doc,
          offerData: data,
          requestData: requestData,
        ),
      );
    }

    return items;
  }

  Future<void> _deleteOffer(
    BuildContext context,
    DocumentReference docRef,
    String status,
  ) async {
    if (status != 'pending') {
      await ActionFeedbackService.show(
        context,
        title: 'Teklif silinemez',
        message: 'Sadece bekleyen teklifler silinebilir.',
        icon: Icons.info_outline_rounded,
      );
      return;
    }

    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Teklif silinsin mi?'),
            content: const Text(
              'Bu bekleyen teklif kaldirilacak. Bu islem geri alinamaz.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Vazgec'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Sil'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    try {
      await docRef.delete();
      if (!context.mounted) {
        return;
      }
      await ActionFeedbackService.show(
        context,
        title: 'Teklif silindi',
        message: 'Teklif silindi.',
        icon: Icons.delete_outline_rounded,
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      await ActionFeedbackService.show(
        context,
        title: 'Teklif silinemedi',
        message: 'Teklif silinemedi: $e',
        icon: Icons.error_outline_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<Set<String>>(
      stream: ModerationService().watchBlockedUserIds(),
      builder: (context, blockedSnapshot) {
        final blockedUserIds = blockedSnapshot.data ?? const <String>{};

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('offers')
              .where('senderId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(
                child: Text('Henuz gonderdigin teklif yok.'),
              );
            }

            return FutureBuilder<List<_SentOfferItem>>(
              future: _loadVisibleOffers(docs, blockedUserIds),
              builder: (context, visibleSnapshot) {
                if (visibleSnapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Teklifler su anda yuklenemedi.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!visibleSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = visibleSnapshot.data!;

                if (items.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Gosterilebilecek teklif bulunamadi.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final doc = item.offerDoc;
                    final data = item.offerData;
                    final requestData = item.requestData;
                    final price = data['price'];
                    final status = (data['status'] as String? ?? 'pending');
                    final title = (requestData?['title'] as String?)?.trim();
                    final subtitle = _requestSubtitle(requestData);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE7E1D8)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        title: Text(
                          title == null || title.isEmpty
                              ? 'Ilan bilgisi bulunamadi'
                              : title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _StatusChip(
                                    label: _statusLabel(status),
                                    color: _statusColor(status),
                                  ),
                                  _StatusChip(
                                    label: price == null
                                        ? 'Fiyat belirtilmedi'
                                        : 'Teklifin: ₺$price',
                                    color: const Color(0xFF8B4A0F),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: status == 'pending'
                                ? Colors.red
                                : Colors.grey.shade400,
                          ),
                          onPressed: () => _deleteOffer(
                            context,
                            doc.reference,
                            status,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  static String _requestSubtitle(Map<String, dynamic>? requestData) {
    if (requestData == null) {
      return 'Ilana ait detaylar yuklenemedi.';
    }

    final pickup = (requestData['pickupAddress'] as String?)?.trim();
    final drop = (requestData['dropAddress'] as String?)?.trim();
    final quantity = (requestData['quantity'] as String?)?.trim();
    final category = (requestData['category'] as String?)?.trim();

    if (pickup != null && pickup.isNotEmpty && drop != null && drop.isNotEmpty) {
      return 'Alis: $pickup • Birak: $drop';
    }

    if (quantity != null && quantity.isNotEmpty) {
      return quantity;
    }

    if (category != null && category.isNotEmpty) {
      return category;
    }

    return 'Teklif verdigin ilan.';
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Kabul edildi';
      case 'rejected':
        return 'Reddedildi';
      default:
        return 'Bekliyor';
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

class _SentOfferItem {
  final QueryDocumentSnapshot offerDoc;
  final Map<String, dynamic> offerData;
  final Map<String, dynamic>? requestData;

  const _SentOfferItem({
    required this.offerDoc,
    required this.offerData,
    required this.requestData,
  });
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
