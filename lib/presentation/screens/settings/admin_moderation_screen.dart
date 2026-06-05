import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/core/utils/text_utils.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';

class AdminModerationScreen extends StatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen> {
  String _statusFilter = 'open';
  final Set<String> _locallyHiddenReportIds = <String>{};

  Stream<QuerySnapshot<Map<String, dynamic>>> _reportsStream() {
    return FirebaseFirestore.instance
        .collection('moderation_reports')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  String _formatDate(dynamic value) {
    if (value is! Timestamp) {
      return 'Tarih bekleniyor';
    }

    final date = value.toDate();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.${date.year} $hour:$minute';
  }

  Future<void> _updateStatus(
    BuildContext context,
    String reportId,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('moderation_reports')
          .doc(reportId)
          .update({
        'status': status,
        'reviewedAt': FieldValue.serverTimestamp(),
      });

      if (mounted && _statusFilter != 'all' && status != _statusFilter) {
        setState(() {
          _locallyHiddenReportIds.add(reportId);
        });
      }

      if (!context.mounted) {
        return;
      }

      await ActionFeedbackService.show(
        context,
        title: 'Durum güncellendi',
        message: 'Şikayet kaydı "$status" olarak işaretlendi.',
        icon: Icons.check_circle_outline_rounded,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      await ActionFeedbackService.show(
        context,
        title: 'Güncelleme yapılamadı',
        message: 'Yetki veya bağlantı nedeniyle işlem tamamlanamadı.',
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Widget _filterChip(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _statusFilter == value,
      onSelected: (_) {
        setState(() {
          _statusFilter = value;
          _locallyHiddenReportIds.clear();
        });
      },
    );
  }

  Widget _detail(String label, String value) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF2C2520), height: 1.35),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: normalizeNotificationText(value)),
          ],
        ),
      ),
    );
  }

  Widget _reportCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final status = (data['status'] ?? 'open').toString();
    final contentType = (data['contentType'] ?? '').toString();
    final reason = (data['reason'] ?? '').toString();
    final details = (data['details'] ?? '').toString();
    final reporterId = (data['reporterId'] ?? '').toString();
    final targetUserId = (data['targetUserId'] ?? '').toString();
    final contentId = (data['contentId'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E1D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: status == 'open'
                      ? const Color(0xFFFFF1E3)
                      : const Color(0xFFEAF7EF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status == 'open' ? 'Açık' : status,
                  style: TextStyle(
                    color: status == 'open'
                        ? const Color(0xFFB96A22)
                        : const Color(0xFF247A3D),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(data['createdAt']),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reason.trim().isEmpty ? 'Sebep belirtilmedi' : reason,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          _detail('İçerik tipi', contentType),
          _detail('Açıklama', details),
          _detail('Şikayet eden', reporterId),
          _detail('Şikayet edilen', targetUserId),
          _detail('İçerik ID', contentId),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: status == 'reviewed'
                      ? null
                      : () => _updateStatus(context, doc.id, 'reviewed'),
                  child: const Text('İncelendi'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: status == 'resolved'
                      ? null
                      : () => _updateStatus(context, doc.id, 'resolved'),
                  child: const Text('Çözüldü'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Paneli'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _filterChip('open', 'Açık'),
                const SizedBox(width: 8),
                _filterChip('reviewed', 'İncelendi'),
                const SizedBox(width: 8),
                _filterChip('resolved', 'Çözüldü'),
                const SizedBox(width: 8),
                _filterChip('all', 'Tümü'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _reportsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Kayıtlar yüklenemedi. Admin yetkisini ve internet bağlantısını kontrol edin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  if (_locallyHiddenReportIds.contains(doc.id)) {
                    return false;
                  }
                  if (_statusFilter == 'all') {
                    return true;
                  }
                  final status = (doc.data()['status'] ?? 'open').toString();
                  return status == _statusFilter;
                }).toList();
                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Bu filtrede şikayet kaydı yok.'),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _reportCard(context, docs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
