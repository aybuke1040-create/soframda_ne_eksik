import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MySentOffersScreen extends StatelessWidget {
  const MySentOffersScreen({super.key});

  Future<void> _deleteOffer(
    BuildContext context,
    DocumentReference docRef,
    String status,
  ) async {
    if (status != 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sadece bekleyen teklifler silinebilir.'),
        ),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Teklif silinsin mi?'),
            content: const Text(
              'Bu bekleyen teklif kaldırılacak. Bu işlem geri alınamaz.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Vazgeç'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teklif silindi.')),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Teklif silinemedi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

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

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final requestId = data['requestId'] as String? ?? '';
            final price = data['price'];
            final status = (data['status'] as String? ?? 'pending');

            return FutureBuilder<DocumentSnapshot?>(
              future: requestId.trim().isEmpty
                  ? Future.value(null)
                  : FirebaseFirestore.instance
                      .collection('requests')
                      .doc(requestId)
                      .get(),
              builder: (context, requestSnapshot) {
                final requestData = requestSnapshot.data?.data()
                    as Map<String, dynamic>?;
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
                      title == null || title.isEmpty ? 'Ilan bilgisi bulunamadi' : title,
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
                                label: price == null ? 'Fiyat belirtilmedi' : 'Teklifin: ₺$price',
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
