import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/moderation_service.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  DateTime _resolveBlockedAt(Map<String, dynamic> data) {
    final timestamp = data['blockedAt'] ?? data['createdAt'];
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Widget build(BuildContext context) {
    final moderationService = ModerationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engelledi\u011fim kullan\u0131c\u0131lar'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: moderationService.watchBlockedUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Engellenen kullan\u0131c\u0131lar y\u00fcklenemedi. '
                  'L\u00fctfen tekrar deneyin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = [...snapshot.data!.docs]
            ..sort((a, b) {
              final aDate = _resolveBlockedAt(a.data());
              final bDate = _resolveBlockedAt(b.data());
              return bDate.compareTo(aDate);
            });

          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  '\u015eu anda engelledi\u011fin bir kullan\u0131c\u0131 yok.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final targetUserId =
                  (data['targetUserId'] ?? data['blockedUserId'] ?? '')
                      .toString();
              final targetName = (
                data['targetName'] ??
                data['targetDisplayName'] ??
                data['blockedUserName'] ??
                data['blockedDisplayName'] ??
                _fallbackValue(targetUserId, 'Kullan\u0131c\u0131')
              ).toString();
              final reason = (data['reason'] ?? '').toString();
              final blockedAt = _resolveBlockedAt(data);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE7E1D8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      targetName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    if (reason.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Engelleme nedeni: $reason',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Engellendi: '
                      '${blockedAt.day.toString().padLeft(2, '0')}.'
                      '${blockedAt.month.toString().padLeft(2, '0')}.'
                      '${blockedAt.year}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await moderationService.unblockUser(
                            targetUserId: targetUserId,
                          );
                          if (!context.mounted) {
                            return;
                          }
                          await ActionFeedbackService.show(
                            context,
                            title: 'Engel kald\u0131r\u0131ld\u0131',
                            message:
                                '$targetName tekrar g\u00f6r\u00fcn\u00fcr hale getirildi.',
                            icon: Icons.person_add_alt_1_rounded,
                          );
                        },
                        child: const Text('Engeli Kald\u0131r'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _fallbackValue(String value, String fallback) {
    return value.trim().isEmpty ? fallback : value;
  }
}
