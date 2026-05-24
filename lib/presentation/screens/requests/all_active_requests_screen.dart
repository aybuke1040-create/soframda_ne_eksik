import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/core/utils/request_visibility_utils.dart';
import 'package:soframda_ne_eksik/presentation/screens/delivery/delivery_detail_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/design/design_detail_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/ready_to_serve/ready_food_detail_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/requests/request_detail_screen.dart';
import 'package:soframda_ne_eksik/presentation/widgets/food_request_card.dart';
import 'package:soframda_ne_eksik/services/moderation_service.dart';

class AllActiveRequestsScreen extends StatelessWidget {
  final int? previewLimit;
  final bool embedded;

  const AllActiveRequestsScreen({
    super.key,
    this.previewLimit,
    this.embedded = false,
  });

  int _gridColumnCount(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width > size.height && size.shortestSide < 600) {
      return 4;
    }
    if (size.shortestSide >= 600) {
      return 3;
    }
    return 2;
  }

  double _gridAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width > size.height && size.shortestSide < 600) {
      return 1;
    }
    if (size.shortestSide >= 600) {
      return 0.94;
    }
    return 0.84;
  }

  DateTime _createdAt(Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    if (createdAt is Timestamp) {
      return createdAt.toDate();
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _requestType(Map<String, dynamic> data) {
    return (data['requestType'] ?? data['type'] ?? '').toString();
  }

  IconData _fallbackIcon(String type) {
    switch (type) {
      case 'delivery':
        return Icons.local_shipping_outlined;
      case 'design':
        return Icons.design_services_outlined;
      case 'food_request':
        return Icons.room_service_outlined;
      case 'ready_food':
        return Icons.restaurant_outlined;
      default:
        return Icons.campaign_outlined;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'delivery':
        return 'Taşıma';
      case 'design':
        return 'Dizayn';
      case 'food_request':
        return 'Teklif';
      case 'ready_food':
        return 'Hazır yemek';
      default:
        return 'İlan';
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'delivery':
        return const Color(0xFF2D7FF9);
      case 'design':
        return const Color(0xFF7C3AED);
      case 'food_request':
        return const Color(0xFFE67E22);
      case 'ready_food':
        return const Color(0xFF2E9B57);
      default:
        return const Color(0xFF6A5A45);
    }
  }

  void _openDetail(BuildContext context, Map<String, dynamic> item) {
    final id = item['id'] as String;
    final ownerId = (item['ownerId'] ?? '').toString();
    final type = _requestType(item);

    Widget page;
    switch (type) {
      case 'delivery':
        page = DeliveryDetailScreen(requestId: id);
        break;
      case 'design':
        page = DesignDetailScreen(requestId: id);
        break;
      case 'ready_food':
        page = ReadyFoodDetailScreen(requestId: id);
        break;
      case 'food_request':
      default:
        page = RequestDetailScreen(requestId: id, ownerId: ownerId);
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Map<String, dynamic> _cardData(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String currentUserId,
  ) {
    final data = doc.data();
    final type = _requestType(data);
    final ownerId = (data['ownerId'] ?? '').toString();
    final title = (data['title'] ?? data['description'] ?? '').toString();
    final ownerName = (data['ownerName'] ?? data['userName'] ?? '').toString();
    final subtitle = [
      (data['quantity'] ?? '').toString(),
      (data['deliveryTime'] ?? '').toString(),
      (data['category'] ?? '').toString(),
    ].where((value) => value.trim().isNotEmpty).join(' • ');

    return {
      'id': doc.id,
      ...data,
      'title': title.isEmpty ? _typeLabel(type) : title,
      'ownerId': ownerId,
      'userName': ownerName,
      'ownerName': ownerName,
      'subtitle': subtitle,
      'isMine': ownerId.isNotEmpty && ownerId == currentUserId,
    };
  }

  Widget _buildGrid(BuildContext context, List<Map<String, dynamic>> items) {
    return GridView.builder(
      shrinkWrap: embedded,
      physics: embedded
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      padding:
          EdgeInsets.fromLTRB(16, embedded ? 8 : 16, 16, embedded ? 24 : 100),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridColumnCount(context),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: _gridAspectRatio(context),
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final type = _requestType(item);
        final subtitle = (item['subtitle'] ?? '').toString();

        return FoodRequestCard(
          request: item,
          showActions: false,
          subtitle: subtitle,
          trailingLabel: item['isMine'] == true ? 'Senin ilan' : null,
          trailingLabelColor:
              item['isMine'] == true ? Colors.green : const Color(0xFFE67E22),
          fallbackIcon: _fallbackIcon(type),
          topRightBadge: _typeLabel(type),
          topRightBadgeColor: _typeColor(type),
          onTap: () => _openDetail(context, item),
        );
      },
    );
  }

  Widget _content(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<Set<String>>(
      stream: ModerationService().watchBlockedUserIds(),
      builder: (context, blockedSnapshot) {
        final blockedUserIds = blockedSnapshot.data ?? const <String>{};

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('requests')
              .where('status', isEqualTo: 'open')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('İlanlar yüklenirken bir hata oluştu.'),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snapshot.data!.docs
                .where((doc) {
                  final data = doc.data();
                  final ownerId = (data['ownerId'] ?? '').toString();
                  return isRequestVisibleForPublic(data) &&
                      !blockedUserIds.contains(ownerId);
                })
                .map((doc) => _cardData(doc, currentUserId))
                .toList()
              ..sort((a, b) => _createdAt(b).compareTo(_createdAt(a)));

            final visibleItems = previewLimit == null
                ? items
                : items.take(previewLimit!).toList();

            if (visibleItems.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Şu anda açık ilan yok.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return _buildGrid(context, visibleItems);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (embedded) {
      return _content(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Aktif İlanlar'),
      ),
      body: _content(context),
    );
  }
}
