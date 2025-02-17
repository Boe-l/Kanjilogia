import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kanjilogia/common/debg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kanjilogia/common/theme.dart';
import 'package:provider/provider.dart';

class LocalFonts {
  late ColorPalette colorPalette;

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
    colorPalette = Provider.of<ColorPalette>(context, listen: false);

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

        return StatefulBuilder(
          builder: (context, setState) {
            void filterFonts(String query) {
              setState(() {
                filteredFonts = fonts
                    .where((font) =>
                        font.toLowerCase().contains(query.toLowerCase()))
                    .toList();
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: colorPalette.background,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 570,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        style: const TextStyle(),
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.main_searchtooltip,
                          hintStyle: const TextStyle(),
                          prefixIcon: const Icon(
                            Icons.search,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: colorPalette.borderColor,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: colorPalette.focusedBorderColor,
                              width: 1.2,
                            ),
                          ),
                        ),
                        onChanged: filterFonts,
                      ),
                      const SizedBox(height: 16),
                      filteredFonts.isEmpty
                          ? SizedBox.shrink()
                          : Expanded(
                              child: ScrollConfiguration(
                                behavior:
                                    ScrollConfiguration.of(context).copyWith(
                                  dragDevices: {
                                    PointerDeviceKind.mouse,
                                    PointerDeviceKind.touch,
                                  },
                                  scrollbars: false,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredFonts.length,
                                  itemBuilder: (context, index) {
                                    final fontName = filteredFonts[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: colorPalette.fillColor[1],
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 12.0,
                                        ),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                fontName,
                                                style: TextStyle(
                                                  fontFamily: fontName,
                                                  fontSize: 18,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  '夢は見るものではなく、\n叶えるものだ。',
                                                  style: TextStyle(
                                                    fontFamily: fontName,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          onFontSelected(fontName);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
