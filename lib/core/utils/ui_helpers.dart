import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/presentation/widgets/floating_credit_animation.dart';

void showCreditAnimation(BuildContext context, String text) {
  final navigator = Navigator.of(context);
  late final DialogRoute<void> creditRoute;

  creditRoute = DialogRoute<void>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (_) => Center(
      child: FloatingCreditAnimation(
        text: text,
        onCompleted: () {
          // Only remove the credit animation's own route. A broadcast or
          // another startup dialog may have been pushed above it meanwhile.
          if (creditRoute.isActive) {
            navigator.removeRoute(creditRoute);
          }
        },
      ),
    ),
  );
  navigator.push(creditRoute);
}
