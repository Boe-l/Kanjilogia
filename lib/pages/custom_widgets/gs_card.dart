import 'package:flutter/material.dart';

enum CardStyle { rounded, flat, outlined, shadowed, minimal }

class CustomCard extends StatefulWidget {
  final String text;
  final double fontSize;
  final int fontWeight;
  final CardStyle style;

  const CustomCard({
    super.key, // Adiciona a key aqui
    required this.text,
    this.fontSize = 16.0,
    this.fontWeight = 400,
    this.style = CardStyle.rounded,
  }); // Passa a key para o StatefulWidget

  @override
  CustomCardState createState() => CustomCardState();
}

class CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  bool _hasError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  Color _textColor = const Color.fromARGB(255, 255, 255, 255);

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4, end: 2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 2, end: 0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void triggerErrorAnimation() {
    setState(() {
      _hasError = true;
      _textColor = Colors.red;
    });

    _shakeController.forward(from: 0).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _hasError = false;
            _textColor = const Color.fromARGB(255, 255, 255, 255);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: _getPadding(widget.style).add(const EdgeInsets.all(8.0)),
            decoration: BoxDecoration(
              color: _getBackgroundColor(widget.style),
              borderRadius:
                  BorderRadius.circular(_getBorderRadius(widget.style)),
              border: Border.all(
                color: _getBorderColor(widget.style),
                width: _getBorderWidth(widget.style),
              ),
              boxShadow: _getShadow(widget.style),
            ),
            constraints: const BoxConstraints(minWidth: 50, minHeight: 30),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.decelerate,
              child: Center(
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_hasError ? _shakeAnimation.value : 0, 0),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: widget.fontSize /
                                  (widget.text.length + 1) *
                                  3,
                              fontWeight: FontWeight.values[
                                  (widget.fontWeight ~/ 100).clamp(0, 8)],
                              color: _textColor,
                            ),
                        child: Text(
                          _formatText(widget.text, constraints.maxWidth),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

double _getBorderRadius(CardStyle style) {
  switch (style) {
    case CardStyle.rounded:
      return 90;
    case CardStyle.minimal:
      return 0;
    default:
      return 8;
  }
}

double _getBorderWidth(CardStyle style) {
  return (style == CardStyle.outlined) ? 2 : 0;
}

Color _getBorderColor(CardStyle style) {
  return (style == CardStyle.outlined) ? Colors.black : Colors.transparent;
}

Color _getBackgroundColor(CardStyle style) {
  switch (style) {
    case CardStyle.shadowed:
      return Colors.grey[200]!;
    case CardStyle.minimal:
      return Colors.transparent;
    default:
      return Colors.transparent;
  }
}

List<BoxShadow> _getShadow(CardStyle style) {
  if (style == CardStyle.shadowed) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: .2),
        blurRadius: 10,
        spreadRadius: 2,
        offset: const Offset(4, 4),
      ),
    ];
  }
  return [];
}

EdgeInsets _getPadding(CardStyle style) {
  switch (style) {
    case CardStyle.minimal:
      return const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0);
    case CardStyle.flat:
      return const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0);
    default:
      return const EdgeInsets.all(16.0);
  }
}

String _formatText(String text, double maxWidth) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: TextStyle(fontSize: 16.0)),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);

  if (textPainter.didExceedMaxLines) {
    // Se o texto ultrapassar o tamanho máximo, forçar quebra de linha após um espaço
    int breakIndex = text.indexOf(' ', (text.length / 2).floor());
    if (breakIndex == -1) breakIndex = text.length ~/ 2;
    return '${text.substring(0, breakIndex)}\n${text.substring(breakIndex)}';
  }
  return text;
}
