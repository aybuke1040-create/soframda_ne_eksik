import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/presentation/widgets/floating_credit_animation.dart';

void showCreditAnimation(BuildContext context, String text) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (_) => Center(
      child: FloatingCreditAnimation(text: text),
    ),
  );
}
