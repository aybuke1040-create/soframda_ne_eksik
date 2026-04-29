import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';

class CreateReviewScreen extends StatefulWidget {
  final String toUserId;
  final String requestId;
  final bool isOwnerReview;

  const CreateReviewScreen({
    super.key,
    required this.toUserId,
    required this.requestId,
    required this.isOwnerReview,
  });

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  double rating = 5;
  final commentController = TextEditingController();
  bool isSubmitting = false;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> submitReview() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final callable = _functions.httpsCallable('submitReview');
      await callable.call({
        'requestId': widget.requestId,
        'toUserId': widget.toUserId,
        'isOwnerReview': widget.isOwnerReview,
        'rating': rating,
        'comment': commentController.text.trim(),
      });

      if (!mounted) {
        return;
      }
      await ActionFeedbackService.show(
        context,
        title: 'Yorum kaydedildi',
        message: 'Puanın ve yorumun kaydedildi.',
        icon: Icons.star_rounded,
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }
      await ActionFeedbackService.show(
        context,
        title: 'Yorum gönderilemedi',
        message: 'Yorum gönderilemedi: $e',
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yorum Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.isOwnerReview
                  ? 'Karşı tarafın emeğini puanlayıp kısa bir yorum bırakabilirsin.'
                  : 'İlan sahibiyle deneyimini puanlayıp kısa bir yorum bırakabilirsin.',
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: rating.toString(),
              onChanged: (value) {
                setState(() {
                  rating = value;
                });
              },
            ),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'İstersen birkaç cümle de ekleyebilirsin',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSubmitting ? null : submitReview,
              child: Text(isSubmitting ? 'Gönderiliyor...' : 'Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}
