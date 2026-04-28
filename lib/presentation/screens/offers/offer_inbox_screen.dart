import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/core/utils/request_visibility_utils.dart';
import 'package:soframda_ne_eksik/presentation/screens/chat/chat_screen.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/chat_service.dart';
import 'package:soframda_ne_eksik/services/moderation_service.dart';

class OfferInboxScreen extends StatelessWidget {
  const OfferInboxScreen({super.key});

  Future<List<_ReceivedOfferGroup>> _loadVisibleOfferGroups(
    List<MapEntry<String, List<QueryDocumentSnapshot>>> entries,
    Set<String> blockedUserIds,
  ) async {
    final groups = <_ReceivedOfferGroup>[];

    for (final entry in entries) {
      final requestId = entry.key;
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

      final visibleOffers = entry.value.where((offerDoc) {
        final offerData = offerDoc.data() as Map<String, dynamic>;
        final senderId = (offerData['senderId'] ?? '').toString();
        return !blockedUserIds.contains(senderId);
      }).toList();

      if (visibleOffers.isEmpty) {
        continue;
      }

      groups.add(
        _ReceivedOfferGroup(
          requestId: requestId,
          offers: visibleOffers,
          requestData: requestData,
        ),
      );
    }

    return groups;
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
              .where('requestOwnerId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
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

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final offers = [...snapshot.data!.docs];
            offers.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aTime = aData['createdAt'];
              final bTime = bData['createdAt'];
              final aMs =
                  aTime is Timestamp ? aTime.millisecondsSinceEpoch : 0;
              final bMs =
                  bTime is Timestamp ? bTime.millisecondsSinceEpoch : 0;
              return bMs.compareTo(aMs);
            });

            if (offers.isEmpty) {
              return const Center(
                child: Text('Henuz aldigin teklif yok.'),
              );
            }

            final grouped = <String, List<QueryDocumentSnapshot>>{};
            for (final doc in offers) {
              final data = doc.data() as Map<String, dynamic>;
              final requestId = (data['requestId'] ?? '').toString();
              if (requestId.isEmpty) {
                continue;
              }
              grouped.putIfAbsent(requestId, () => []).add(doc);
            }

            if (grouped.isEmpty) {
              return const Center(
                child: Text('Gosterilebilecek teklif bulunamadi.'),
              );
            }

            final entries = grouped.entries.toList();

            return FutureBuilder<List<_ReceivedOfferGroup>>(
              future: _loadVisibleOfferGroups(entries, blockedUserIds),
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

                final groups = visibleSnapshot.data!;

                if (groups.isEmpty) {
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
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final requestId = group.requestId;
                    final requestOffers = group.offers;
                    final requestData = group.requestData;
                    final title = (requestData?['title'] as String?)?.trim();
                    final subtitle = _requestSubtitle(requestData);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
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
                      child: ExpansionTile(
                        tilePadding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                          child: Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                        children: requestOffers.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final status =
                              (data['status'] as String? ?? 'pending');
                          final price = data['price'];
                          final senderId = (data['senderId'] ?? '').toString();

                          return FutureBuilder<
                              DocumentSnapshot<Map<String, dynamic>>?>(
                            future: senderId.isEmpty
                                ? Future.value(null)
                                : FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(senderId)
                                    .get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.hasError) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F7F3),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFEAE3D8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Teklif sahibi bilgisi yuklenemedi.',
                                  ),
                                );
                              }

                              final userData = userSnapshot.data?.data();
                              final senderName = senderId.isEmpty
                                  ? 'Teklif sahibi bulunamadi'
                                  : (userData?['name'] as String?)?.trim() ??
                                      'Teklif sahibi';

                              return Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F7F3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFEAE3D8),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            senderName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        _OfferStatusChip(
                                          label: _statusLabel(status),
                                          color: _statusColor(status),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      price == null
                                          ? 'Fiyat belirtilmedi'
                                          : 'Teklif: ₺$price',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (senderId.trim().isEmpty) {
                                            await ActionFeedbackService.show(
                                              context,
                                              title:
                                                  'Teklif sahibi bulunamadı',
                                              message:
                                                  'Teklif sahibine ulaşılamadı.',
                                              icon: Icons
                                                  .error_outline_rounded,
                                            );
                                            return;
                                          }

                                          try {
                                            final chatId = await ChatService()
                                                .createChatRoom(
                                              userId,
                                              senderId,
                                              requestId,
                                            );

                                            if (!context.mounted) {
                                              return;
                                            }

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
                                            if (!context.mounted) {
                                              return;
                                            }
                                            await ActionFeedbackService.show(
                                              context,
                                              title: 'Sohbet açılamadı',
                                              message:
                                                  'Sohbet açılamadı: $e',
                                              icon:
                                                  Icons.error_outline_rounded,
                                            );
                                          }
                                        },
                                        child: Text(
                                          status == 'pending'
                                              ? 'Teklifi İncele'
                                              : 'Sohbeti Aç',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }).toList(),
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
      return 'İlana ait detaylar yüklenemedi.';
    }

    final pickup = (requestData['pickupAddress'] as String?)?.trim();
    final drop = (requestData['dropAddress'] as String?)?.trim();
    final quantity = (requestData['quantity'] as String?)?.trim();
    final date = (requestData['date'] as String?)?.trim();

    if (pickup != null && pickup.isNotEmpty && drop != null && drop.isNotEmpty) {
      return 'Alış: $pickup • Bırak: $drop';
    }

    if (quantity != null && quantity.isNotEmpty) {
      return quantity;
    }

    if (date != null && date.isNotEmpty) {
      return date;
    }

    return 'Bu ilana gelen teklifler.';
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

class _ReceivedOfferGroup {
  final String requestId;
  final List<QueryDocumentSnapshot> offers;
  final Map<String, dynamic>? requestData;

  const _ReceivedOfferGroup({
    required this.requestId,
    required this.offers,
    required this.requestData,
  });
}

class _OfferStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _OfferStatusChip({
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
