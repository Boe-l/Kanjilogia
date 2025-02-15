import 'dart:math';
import 'package:flutter/material.dart';

class CircularRevealAnimationWidget extends StatefulWidget {
  final Widget widget;

  const CircularRevealAnimationWidget({super.key, required this.widget});

  @override
  CircularRevealAnimationWidgetState createState() =>
      CircularRevealAnimationWidgetState();
}

class CircularRevealAnimationWidgetState
    extends State<CircularRevealAnimationWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            ClipPath(
              clipper: CircularRevealClipper(_animation.value),
              child: widget.widget,
            ),
          ],
        );
      },
    );
  }
}

class CircularRevealClipper extends CustomClipper<Path> {
  final double progress;

  CircularRevealClipper(this.progress);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        progress * sqrt(size.width * size.width + size.height * size.height);
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(CircularRevealClipper oldClipper) =>
      progress != oldClipper.progress;
}
