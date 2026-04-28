import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/moderation_service.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moderationService = ModerationService();

    return Scaffold(
      appBar: AppBar(title: const Text('Engelledigim kullanicilar')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: moderationService.watchBlockedUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Su anda engelledigin bir kullanici yok.',
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
              final targetUserId = (data['targetUserId'] ?? '').toString();
              final targetName = (data['targetName'] ?? 'Kullanici').toString();
              final reason = (data['reason'] ?? '').toString();

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
                            title: 'Engel kaldirildi',
                            message:
                                '$targetName tekrar gorunur hale getirildi.',
                            icon: Icons.person_add_alt_1_rounded,
                          );
                        },
                        child: const Text('Engeli Kaldir'),
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
}
