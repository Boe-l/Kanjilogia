import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:kanjilogia/common/sharedpref.dart';
import 'package:kanjilogia/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void onLanguageSelected(Locale locale) async {
  await SharedPrefs().saveLocale(locale);
  kanjilogiaKey.currentState?.changeLanguage(locale);
  
}

final supportedLocales = [
  Locale('ar'),
  Locale('bn'),
  Locale('de'),
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('hi'),
  Locale('it'),
  Locale('ja'),
  Locale('ko'),
  Locale('pt'),
  Locale('ru'),
  Locale('tr'),
  Locale('zh'),
];

class LocaleUtils {
  static const Map<String, String> _flagMap = {
    'jp': 'assets/flags/japan.png',
    'ja': 'assets/flags/japan.png',
    'cn': 'assets/flags/china.png',
    'zh': 'assets/flags/china.png',
    'pt': 'assets/flags/brazil.png',
    'ko': 'assets/flags/southkorea.png',
    'en': 'assets/flags/usa.png',
    'es': 'assets/flags/spain.png',
    'ar': 'assets/flags/uae.png',
    'bn': 'assets/flags/bangladesh.png',
    'de': 'assets/flags/germany.png',
    'fr': 'assets/flags/france.png',
    'it': 'assets/flags/italy.png',
    'ru': 'assets/flags/russia.png',
    'tr': 'assets/flags/turkey.png',
  };

  static String getFlagPath(String tags) {
    return _flagMap[tags.toLowerCase()] ?? 'assets/flags/default.png';
  }

  static const Map<String, String> _languageMap = {
    'ar': 'العربية',
    'bn': 'বাংলা',
    'de': 'Deutsch',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'hi': 'हिन्दी',
    'it': 'Italiano',
    'ja': '日本語',
    'jp': '日本語',
    'ko': '한국어',
    'pt': 'Português',
    'ru': 'Русский',
    'tr': 'Türkçe',
    'zh': '中文',
  };

  static String getLanguageName(Locale locale) {
    return _languageMap[locale.languageCode] ?? locale.languageCode;
  }

  Future<void> showLanguageSelector(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 56, 16, 115),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 18),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 74, 32, 126),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.select_language,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(
                      color: Colors.white54,
                      height: 1,
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
                                color: const Color.fromARGB(255, 74, 32, 126),
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
                                            color: Colors.white,
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
                  top: 16,
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
    },
  );
}
}
