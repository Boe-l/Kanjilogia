import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kanjilogia/common/langstuff.dart';
import 'package:kanjilogia/common/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

SafeArea languageSelector(ColorPalette colorPalette, BuildContext context) {
  return SafeArea(
    child: Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: colorPalette.background,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  decoration: BoxDecoration(
                    color: colorPalette.fillColor[0],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.select_language,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(
                  color: Colors.white54,
                  height: 6,
                  thickness: 1,
                ),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.touch
                      },
                      scrollbars: false,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: supportedLocales.length,
                      itemBuilder: (context, index) {
                        final locale = supportedLocales[index];
                        final languageName =
                            LocaleUtils.getLanguageName(locale);
                        final flag = LocaleUtils.getFlagPath(
                          locale.toString(),
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 8),
                          child: Material(
                            color: colorPalette.fillColor[1],
                            borderRadius: BorderRadius.circular(16),
                            elevation: 5,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                onLanguageSelected(locale);
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      flag,
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      languageName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 8,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    iconSize: 20,
                    padding: const EdgeInsets.all(8),
                    splashRadius: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
