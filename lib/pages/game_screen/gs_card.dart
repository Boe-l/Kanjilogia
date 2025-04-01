import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';

import 'package:kanjilogia/common/theme.dart';
import 'package:kanjilogia/common/widget_transition.dart';

class GameScreenCard extends StatefulWidget {
  final Map<String, dynamic> words;
  final double fontSize;
  final int fontWeight;
  final Function(String) processAnswer;
  final ColorPalette colorPalette;

  const GameScreenCard({
    super.key,
    required this.words,
    this.fontSize = 16.0,
    this.fontWeight = 400,
    required this.processAnswer,
    required this.colorPalette,
  });

  @override
  GameScreenCardState createState() =>
      GameScreenCardState(processAnswer: processAnswer);
}

class GameScreenCardState extends State<GameScreenCard>
    with SingleTickerProviderStateMixin {
  GameScreenCardState({required this.processAnswer});
  final Function(String) processAnswer;

  bool _hasError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  Color _textColor = const Color.fromARGB(255, 255, 255, 255);
  int currentWidget = 0;
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
            _textColor = widget.colorPalette.text;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CircularRevealAnimationWidget(
      widget: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child:
            (widget.words['word'] != null && widget.words['word']!.isNotEmpty)
                ? CustomCard(
                    context: context,
                    hasError: _hasError,
                    shakeAnimation: _shakeAnimation,
                    shakeController: _shakeController,
                    textColor: _textColor,
                    widget: widget,
                    key: ValueKey(0),
                  )
                : Quiz(
                    processAnswer: processAnswer,
                    key: ValueKey(1), //
                    words: widget.words,
                  ),
      ),
    );
  }
}

class CustomCard extends StatefulWidget {
  const CustomCard({
    super.key,
    required this.widget,
    required this.shakeController,
    required this.hasError,
    required this.shakeAnimation,
    required this.textColor,
    required this.context,
  });

  final GameScreenCard widget;
  final AnimationController shakeController;
  final bool hasError;
  final Animation<double> shakeAnimation;
  final Color textColor;
  final BuildContext context;

  @override
  CustomCardState createState() => CustomCardState();
}

class CustomCardState extends State<CustomCard> {
  late AnimationController _shakeController;
  late bool _hasError;
  late Animation<double> _shakeAnimation;
  late Color _textColor;
  String _currentText = "";

  @override
  void initState() {
    super.initState();
    _shakeController = widget.shakeController;
    _hasError = widget.hasError;
    _shakeAnimation = widget.shakeAnimation;
    _textColor = widget.textColor;
    _currentText = widget.widget.words['word'] ?? '';
  }

  @override
  void didUpdateWidget(covariant CustomCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.hasError != widget.hasError) {
      setState(() {
        _hasError = widget.hasError;
      });
    }
    if (oldWidget.shakeAnimation != widget.shakeAnimation) {
      setState(() {
        _shakeAnimation = widget.shakeAnimation;
      });
    }
    if (oldWidget.textColor != widget.textColor) {
      setState(() {
        _textColor = widget.textColor;
      });
    }
    if (oldWidget.widget.words['word'] != widget.widget.words['word']) {
      setState(() {
        _currentText = widget.widget.words['word'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_hasError ? _shakeAnimation.value : 0, 0),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 50),
                    curve: Curves.easeInOut,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: widget.widget.fontSize /
                              (_currentText.length + 1) *
                              3,
                          fontWeight: FontWeight.values[
                              (widget.widget.fontWeight ~/ 100).clamp(0, 8)],
                          color: _textColor,
                        ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: OffsetText(
                        key: ValueKey(_currentText),
                        text: _formatText(_currentText, constraints.maxWidth),
                        duration: const Duration(milliseconds: 400),
                        type: AnimationType.letter,
                        slideType: SlideAnimationType.alternateTB,
                        textStyle: TextStyle(
                          fontSize: widget.widget.fontSize,
                          shadows: [
                            Shadow(
                              blurRadius: 8.0,
                              color: Colors.black.withValues(alpha: 0.5),
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class Quiz extends StatefulWidget {
  final Map<String, dynamic> words;
  final Function(String) processAnswer;

  const Quiz({super.key, required this.words, required this.processAnswer});

  @override
  QuizState createState() => QuizState(processAnswer: processAnswer);
}

class QuizState extends State<Quiz> with TickerProviderStateMixin {
  QuizState({required this.processAnswer});
  final Function(String) processAnswer;
  bool evaluate = false;
  bool selected = false;

  int perguntaAtual = 0;
  List<String?> respostasUsuario = List.filled(3, null);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 60, maxHeight: 100),
              child: Text(
                "${widget.words['question']}\n「${widget.words['mean']}」",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ...widget.words["alternatives"]!
                .split(',')
                .asMap()
                .entries
                .map<Widget>((entry) {
              int index = entry.key;
              String alternativa = entry.value.trim();

              return RadioListTile<String>(
                value: alternativa,
                groupValue: respostasUsuario[perguntaAtual],
                onChanged: evaluate
                    ? null
                    : (value) {
                        setState(() {
                          respostasUsuario[perguntaAtual] = value;
                          evaluate = true;
                          selected = true;
                          Future.delayed(Duration(seconds: 2), () {
                            String alternativaSelecionada =
                                ['A', 'B', 'C', 'D', 'E'][index];

                            processAnswer(alternativaSelecionada);

                            setState(() {
                              respostasUsuario[perguntaAtual] = null;
                              evaluate = false;
                              selected = false;
                            });
                          });
                        });
                      },
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${['A', 'B', 'C', 'D', 'E'][index]}. $alternativa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    const SizedBox(width: 8),
                    generateIcon(perguntaAtual, alternativa),
                  ],
                ),
                activeColor: Colors.grey,
                selectedTileColor:
                    respostasUsuario[perguntaAtual] == alternativa
                        ? const Color.fromARGB(36, 158, 158, 158)
                        : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                selected: respostasUsuario[perguntaAtual] == alternativa,
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget generateIcon(int perguntaAtual, String alternativa) {
    if (respostasUsuario[perguntaAtual] != null) {
      return Container(
        key: ValueKey(alternativa),
        child: Icon(
          alternativa == widget.words['correct']
              ? Icons.check_circle
              : Icons.cancel,
          color: alternativa == widget.words['correct']
              ? Colors.green
              : Colors.red,
          size: 30.0,
        ),
      );
    }

    return Container();
  }
}

String _formatText(String text, double maxWidth) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: TextStyle(fontSize: 16.0)),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);

  if (textPainter.didExceedMaxLines) {
    int breakIndex = text.indexOf(' ', (text.length / 2).floor());
    if (breakIndex == -1) breakIndex = text.length ~/ 2;
    return '${text.substring(0, breakIndex)}\n${text.substring(breakIndex)}';
  }
  return text;
}
