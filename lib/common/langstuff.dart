import 'package:flutter/material.dart';
import 'package:kanjilogia/common/sharedpref.dart';
import 'package:kanjilogia/common/theme.dart';
import 'package:kanjilogia/main.dart';
import 'package:kanjilogia/pages/settings_page/select_language.dart';
import 'package:provider/provider.dart';

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
    'hi': 'assets/flags/india.png',
  };

  static String getFlagPath(String tags) {
    return _flagMap[tags.toLowerCase().split(',').first] ??
        'assets/flags/default.png';
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
    ColorPalette colorPalette =
        Provider.of<ColorPalette>(context, listen: false);

    return showDialog(
      context: context,
      barrierDismissible: true,
      // isScrollControlled: true,
      // backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return languageSelector(colorPalette, context);
      },
    );
  }
}
