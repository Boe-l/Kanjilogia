import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:kanjilogia/common/theme.dart';

class WindowButtons extends StatelessWidget {
  WindowButtons({super.key});

  final WindowButtonColors buttonColors = WindowButtonColors(
    iconNormal: ColorPalette().iconColor,
    mouseOver: ColorPalette().fillColor[1].withAlpha(200),
    mouseDown: ColorPalette().fillColor[1].withAlpha(100),
    iconMouseOver: const Color.fromARGB(255, 255, 255, 255),
    iconMouseDown: const Color.fromARGB(255, 255, 255, 255),
  );
  final WindowButtonColors closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color.fromARGB(255, 255, 255, 255),
    iconMouseOver: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Minimize(
          colors: buttonColors,
        ),
        Maximize(colors: buttonColors),
        Close(colors: closeButtonColors),
      ],
    );
  }
}

class Minimize extends WindowButton {
  Minimize({super.key, super.colors, VoidCallback? onPressed, bool? animate})
      : super(
            animate: animate ?? false,
            iconBuilder: (buttonContext) => Center(
                child: Icon(Icons.remove_rounded,
                    color: buttonContext.iconColor, size: 18.0)),
            onPressed: onPressed ?? () => appWindow.minimize());
}

class Maximize extends WindowButton {
  Maximize({super.key, super.colors, VoidCallback? onPressed, bool? animate})
      : super(
            animate: animate ?? false,
            iconBuilder: (buttonContext) => Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Icon(Icons.crop_square_outlined,
                      color: buttonContext.iconColor, size: 16.0),
                ),
            onPressed: onPressed ?? () => appWindow.maximizeOrRestore());
}

class Close extends WindowButton {
  Close(
      {super.key,
      WindowButtonColors? colors,
      VoidCallback? onPressed,
      bool? animate})
      : super(
            colors: colors ??
                WindowButtonColors(
                    mouseOver: Color(0xFFD32F2F),
                    mouseDown: Color(0xFFB71C1C),
                    iconNormal: Color(0xFF805306),
                    iconMouseOver: Color(0xFFFFFFFF)),
            animate: animate ?? false,
            iconBuilder: (buttonContext) => Icon(Icons.close_rounded,
                color: buttonContext.iconColor, size: 16.0),
            onPressed: onPressed ?? () => appWindow.close());
}
