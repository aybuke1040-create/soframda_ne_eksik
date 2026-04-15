import 'package:flutter/material.dart';

class FloatingCreditAnimation extends StatefulWidget {
  final String text;

  const FloatingCreditAnimation({super.key, required this.text});

  @override
  State<FloatingCreditAnimation> createState() =>
      _FloatingCreditAnimationState();
}

class _FloatingCreditAnimationState extends State<FloatingCreditAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    animation = Tween<double>(begin: 0, end: -60).animate(controller);

    controller.forward();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: Opacity(
            opacity: 1 - controller.value,
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
