import 'package:flutter/material.dart';

class GradientAnimatedBorderDecoration extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final double strokeWidth;
  final double blurRadius;
  final BorderRadius borderRadius;
  final bool showBlur;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;

  const GradientAnimatedBorderDecoration({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFFFF4545),
      Color(0xFF00FF99),
      Color(0xFF006AFF),
      Color(0xFFFF0095),
      Color(0xFFFF4545),
    ],
    this.duration = const Duration(seconds: 3),
    this.strokeWidth = 5,
    this.blurRadius = 15,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.showBlur = true,
    this.width = 300,
    this.height = 200,
    this.padding = const EdgeInsets.all(1),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: Curves.linear,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: showBlur
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: blurRadius,
                  spreadRadius: 2,
                ),
              ]
            : [],
        border: Border.all(color: Colors.transparent, width: strokeWidth),
      ),
      child: CustomPaint(
        painter: _GradientBorderPainter(
          progress:
              1.0, // Assume que o progresso final é 1 para o efeito contínuo
          colors: colors,
          strokeWidth: strokeWidth,
          blurRadius: blurRadius,
          borderRadius: borderRadius,
          showBlur: showBlur,
        ),
        child: Container(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final double strokeWidth;
  final double blurRadius;
  final BorderRadius borderRadius;
  final bool showBlur;

  _GradientBorderPainter({
    required this.progress,
    required this.colors,
    required this.strokeWidth,
    required this.blurRadius,
    required this.borderRadius,
    required this.showBlur,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final gradient = SweepGradient(
      colors: colors,
      stops:
          List.generate(colors.length, (index) => index / (colors.length - 1)),
      startAngle: 0,
      endAngle: 2 * 3.141592653589793,
      transform: GradientRotation(progress * 2 * 3.141592653589793),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, borderRadius.topLeft));

    canvas.drawPath(path, paint);

    if (showBlur) {
      final blurPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

      canvas.drawPath(path, blurPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
