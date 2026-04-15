import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/services/rating_service.dart';

class RatingDialog extends StatefulWidget {
  final String userId;

  const RatingDialog({super.key, required this.userId});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double rating = 5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Puan Ver"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Text("Puan: ${rating.toStringAsFixed(1)}"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await RatingService().submitRating(
              userId: widget.userId,
              rating: rating,
            );

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Puan verildi ⭐")),
            );
          },
          child: const Text("Gönder"),
        )
      ],
    );
  }
}
