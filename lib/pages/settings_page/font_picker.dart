import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:kanjilogia/common/theme.dart';
import 'package:provider/provider.dart';

StatefulBuilder fontPicker(List<String> filteredFonts, List<String> fonts,
    Function(String selectedFont) onFontSelected) {
  late ColorPalette colorPalette;

  return StatefulBuilder(
    builder: (context, setState) {
      colorPalette = Provider.of<ColorPalette>(context, listen: false);

      void filterFonts(String query) {
        setState(() {
          filteredFonts = fonts
              .where((font) => font.toLowerCase().contains(query.toLowerCase()))
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
          child: SizedBox.expand(
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
                      ? Center(
                          child: Text(
                            'No matches.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
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
                                    contentPadding: const EdgeInsets.symmetric(
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
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: !kIsWeb
                                                ? Text(
                                                    '夢は見るものではなく、\n叶えるものだ。',
                                                    style: TextStyle(
                                                      fontFamily: fontName,
                                                      fontSize: 18,
                                                    ),
                                                  )
                                                : SizedBox.shrink(),
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
        ),
      );
    },
  );
}
