import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kanjilogia/common/debg.dart';
import 'package:kanjilogia/pages/settings_page/font_picker.dart';

class LocalFonts {
  static const _channel = MethodChannel('kanjilogia/fonts');

  Future<List<String>> listFonts() async {
    if (!Platform.isWindows) return [];
    try {
      final fonts = await _channel.invokeMethod<List<dynamic>>('fonts');

      return fonts
              ?.cast<String>()
              .where((font) => !font.startsWith('@'))
              .toList() ??
          [];
    } on PlatformException catch (e) {
      Debg().error("listFonts(fonts_windows) error: ${e.toString()}");

      return [];
    }
  }

  String loadFont(String fontname) {
    return '';
  }

  Future<void> showFontPickerPopup({
    required BuildContext context,
    required Function(String selectedFont) onFontSelected,
  }) async {
    List<String> fonts = [];
    if (!Platform.isWindows) return;

    try {
      fonts = await LocalFonts().listFonts();
    } catch (e) {
      Debg().error("showFontPickerPopup(fonts_windows) error: ${e.toString()}");
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        List<String> filteredFonts = List.from(fonts);

        return fontPicker(filteredFonts, fonts, onFontSelected);
      },
    );
  }
}
