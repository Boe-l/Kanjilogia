import 'package:flutter/material.dart';
import 'package:kanjilogia/common/theme.dart';
import 'package:provider/provider.dart';

class TimerWidget extends StatelessWidget {
  final double fontSize;
  final ValueNotifier<int> timeLeftNotifier;

  const TimerWidget({
    super.key,
    required this.fontSize,
    required this.timeLeftNotifier,
  });

  @override
  Widget build(BuildContext context) {
    ColorPalette colorPalette = Provider.of<ColorPalette>(context);

    return SizedBox(
      width: 60,
      child: ValueListenableBuilder<int>(
        valueListenable: timeLeftNotifier,
        builder: (context, timeLeft, child) {
          return AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 1, end: 1.1).animate(
                      CurvedAnimation(
                          parent: animation, curve: Curves.easeInOut),
                    ),
                    child: child,
                  ),
                );
              },
              child: Text(
                "$timeLeft",
                key: ValueKey<int>(timeLeft),
                style: TextStyle(
                  fontSize: fontSize * 1.1,
                  fontWeight: FontWeight.bold,
                  color: timeLeft <= 5 ? Colors.redAccent : colorPalette.text,
                  shadows: [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ));
        },
      ),
    );
  }
}
