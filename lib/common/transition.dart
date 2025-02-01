import 'dart:math';
import 'package:flutter/material.dart';

void navigateWithCircularAnimation(BuildContext context, Widget page) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration(milliseconds: 800),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          children: [
            // Desenha a borda do círculo
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CircularBorderPainter(animation.value),
                  child: Container(),
                );
              },
            ),
            // Aplica a transição de revelação circular
            ClipPath(
              clipper: CircularRevealClipper(animation.value),
              child: child,
            ),
          ],
        );
      },
    ),
  );
}

// Clipper para revelar a nova tela com um círculo crescente
class CircularRevealClipper extends CustomClipper<Path> {
  final double progress;

  CircularRevealClipper(this.progress);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = progress * sqrt(size.width * size.width + size.height * size.height);
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(CircularRevealClipper oldClipper) => progress != oldClipper.progress;
}

// Painter para desenhar a borda do círculo animado
class CircularBorderPainter extends CustomPainter {
  final double progress;

  CircularBorderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = progress * sqrt(size.width * size.width + size.height * size.height);

    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 94, 6, 105) // Cor da borda
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0; // Espessura da borda

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CircularBorderPainter oldDelegate) => progress != oldDelegate.progress;
}
