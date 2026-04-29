import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/presentation/screens/review/create_review_screen.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/request_completion_service.dart';

class MyJobsScreen extends StatelessWidget {
  MyJobsScreen({super.key});

  final RequestCompletionService _completionService = RequestCompletionService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Benim \u0130\u015flerim'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('acceptedUserId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['requestType'] != 'recipe';
          }).toList();

          if (docs.isEmpty) {
            return const Center(
              child: Text('Hen\u00fcz tamamlanan ya da \u00fcstlendi\u011fin i\u015f yok'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final imageUrl = data['imageUrl'] ?? '';

              return _PreviewCard(
                title: title,
                imageUrl: imageUrl,
                fallbackIcon: Icons.work_outline,
                onTap: () {
                  _showJobDetails(
                    context: context,
                    data: data,
                    requestId: docs[index].id,
                    currentUserId: user!.uid,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showJobDetails({
    required BuildContext context,
    required Map<String, dynamic> data,
    required String requestId,
    required String currentUserId,
  }) {
    final status = data['status'] ?? 'open';
    final ownerCompleted = data['ownerCompleted'] == true;
    final workerCompleted = data['workerCompleted'] == true;
    final reviewByWorker = data['reviewByWorker'] == true;
    final ownerId = data['ownerId'] as String? ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if ((data['pickupAddress'] ?? '').toString().isNotEmpty ||
                    (data['dropAddress'] ?? '').toString().isNotEmpty)
                  Text(
                    '${data['pickupAddress'] ?? '-'} -> ${data['dropAddress'] ?? '-'}',
                  ),
                if ((data['description'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(data['description']),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _statusBadge(status),
                    _miniInfo(
                      workerCompleted
                          ? 'Sen tamamland\u0131 dedin'
                          : 'Senin onay\u0131n bekleniyor',
                    ),
                    _miniInfo(
                      ownerCompleted
                          ? '\u0130lan sahibi onaylad\u0131'
                          : '\u0130lan sahibi hen\u00fcz onaylamad\u0131',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (status == 'in_progress' && !workerCompleted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final result = await _completionService.markCompleted(
                          requestId: requestId,
                          currentUserId: currentUserId,
                          isOwner: false,
                        );
                        if (!context.mounted) {
                          return;
                        }

                        if (result['completed'] == true && !reviewByWorker) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateReviewScreen(
                                toUserId: ownerId,
                                requestId: requestId,
                                isOwnerReview: false,
                              ),
                            ),
                          );
                          return;
                        }

                        await ActionFeedbackService.show(
                          context,
                          title: result['completed'] == true
                              ? 'İş tamamlandı'
                              : 'Onay bekleniyor',
                          message: result['completed'] == true
                              ? 'İş tamamlandı. Yorum ekranı açılıyor.'
                              : 'İlan sahibinin tamamlandı onayı bekleniyor.',
                          icon: Icons.check_circle_outline_rounded,
                        );
                      },
                      child: const Text('Tamamland\u0131 De'),
                    ),
                  ),
                if (status == 'completed' && !reviewByWorker)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateReviewScreen(
                              toUserId: ownerId,
                              requestId: requestId,
                              isOwnerReview: false,
                            ),
                          ),
                        );
                      },
                      child: const Text('Yorum Yap'),
                    ),
                  ),
                if (status == 'completed' && reviewByWorker)
                  const Text('Bu i\u015f i\u00e7in yorumunu yapt\u0131n.'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    String label = status;
    Color color = Colors.orange;

    if (status == 'completed') {
      label = 'Tamamlandı';
      color = Colors.green;
    } else if (status == 'in_progress') {
      label = 'Devam ediyor';
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _miniInfo(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _PreviewCard({
    required this.title,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: imageUrl.toString().isEmpty
                    ? Container(
                        color: Colors.grey.shade200,
                        child: Icon(fallbackIcon, size: 42),
                      )
                    : _buildImage(imageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, fit: BoxFit.cover);
    }
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    }
    return Container(
      color: Colors.grey.shade200,
      child: Icon(fallbackIcon, size: 42),
    );
  }
}
