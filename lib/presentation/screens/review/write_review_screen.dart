import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class WriteReviewScreen extends StatefulWidget {
  final String requestId;
  final String targetUserId;

  const WriteReviewScreen({
    super.key,
    required this.requestId,
    required this.targetUserId,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  double rating = 5;
  final commentController = TextEditingController();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  bool isSubmitting = false;

  Future<void> submitReview() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final callable = _functions.httpsCallable('submitReview');
      await callable.call({
        'requestId': widget.requestId,
        'toUserId': widget.targetUserId,
        'isOwnerReview': false,
        'rating': rating,
        'comment': commentController.text.trim(),
      });

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
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
      appBar: AppBar(
        title: const Text("Yorum Yaz"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Kac yildiz veriyorsunuz?",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
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
            Text(
              "${rating.toStringAsFixed(1)} *",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: "Yorum yaz...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitReview,
                child: Text(isSubmitting ? "Gonderiliyor..." : "Gonder"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
