// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kanjilogia/common/theme.dart';

void navigateWithCircularAnimation(BuildContext context, Widget page,
    {VoidCallback? onComplete}) {
  ColorPalette colorPalette = Provider.of<ColorPalette>(context, listen: false);

  final screenSize = MediaQuery.of(context).size;
  final shortestSide = screenSize.shortestSide;
  final durationMs = (shortestSide * 2).clamp(800, 2000).toInt();

  Navigator.of(context)
      .push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration(milliseconds: durationMs),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CircularBorderPainter(animation.value,
                      colorPalette: colorPalette),
                  child: Container(),
                );
              },
            ),
            ClipPath(
              clipper: CircularRevealClipper(animation.value),
              child: child,
            ),
          ],
        );
      },
    ),
  )
      .then((_) {
    if (onComplete != null) {
      onComplete();
    }
  });
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

class CircularBorderPainter extends CustomPainter {
  final double progress;
  ColorPalette colorPalette;

  CircularBorderPainter(this.progress, {required this.colorPalette});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        progress * sqrt(size.width * size.width + size.height * size.height);

    final Paint paint = Paint()
      ..color = colorPalette.highlight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CircularBorderPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
