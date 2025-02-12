import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kanjilogia/common/langstuff.dart';
import 'package:kanjilogia/common/sharedpref.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kanjilogia/main.dart';
import 'dart:io' show Platform;
import 'package:kanjilogia/utils/fonts_windows.dart'; 
// import 'package:kanjilogia/utils/fonts_web.dart'; 


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final isWindowsOrWeb = kIsWeb || Platform.isWindows;
  int _maxTime = 60;
  List<String> fonts = [];
  Future<void> _getMaxTime() async {
    final maxTime = await SharedPrefs().getMaxTime();
    setState(() {
      _maxTime = maxTime;
    });
    localinfo = await getcurrentlocale();
    if (isWindowsOrWeb) {
      fonts = await LocalFonts().listFonts();
    }
    setState(() {});
  }

  Future<void> _updateMaxTime(int time) async {
    await SharedPrefs().saveMaxTime(time);
  }

  Future<void> _changeFont() async {
    if (!kIsWeb) {
      await LocalFonts().showFontPickerPopup(
          context: context,
          onFontSelected: (selectedFont) {
            kanjilogiaKey.currentState?.loadFont(selectedFont);
          });
    }
    if (kIsWeb) {
      if (!mounted) return;
      await LocalFonts().showFontPickerPopup(
          context: context,
          onFontSelected: (selectedFont) {
            kanjilogiaKey.currentState?.loadFont(selectedFont);
          });
    }
  }

  Future getcurrentlocale() async {
    Locale locale = await SharedPrefs().getLocale();
    final flag = LocaleUtils.getFlagPath(locale.toString());
    final langname = LocaleUtils.getLanguageName(locale);
    return [flag, langname];
  }

  List localinfo = [];
  @override
  void initState() {
    super.initState();
    _getMaxTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 56, 16, 115),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,0),
            child: ListView(
              children: [
                Center(
                    child: Text(
                  'Manage Settings',
                  style: GoogleFonts.rampartOne(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.blueAccent,
                        blurRadius: 10,
                      )
                    ],
                  ),
                )),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 67, 19, 138),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.maxtimehint(_maxTime),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTickMarkColor:
                              Colors.transparent, 
                          inactiveTickMarkColor: Colors
                              .transparent, 
                          overlayColor:
                              Colors.transparent, 
                          thumbColor: const Color.fromARGB(
                              255, 98, 49, 172), 
                          activeTrackColor: const Color.fromARGB(
                              255, 152, 99, 233), 
                          inactiveTrackColor: Colors.grey, 
                          valueIndicatorTextStyle: TextStyle(
                            color: Colors
                                .white, 
                          ),
                          valueIndicatorColor: const Color.fromARGB(255, 98, 49,
                              172), 
                        ),
                        child: Slider(
                          value: _maxTime.toDouble(),
                          min: 10,
                          max: 60,
                          divisions: 5,
                          label: AppLocalizations.of(context)!
                              .mp_slider_text(_maxTime),
                          activeColor: const Color.fromARGB(255, 152, 99, 233),
                          thumbColor: const Color.fromARGB(255, 98, 49, 172),
                          onChanged: (newTime) {
                            setState(() {
                              _maxTime = newTime.toInt();
                            });
                            _updateMaxTime(_maxTime);
                          },
                        ),
                      )
                    ],
                  ),
                ),
                isWindowsOrWeb
                    ? Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 67, 19, 138),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.font_download,
                            color: Colors.white,
                            size: 32,
                          ),
                          title: Text(
                            kanjilogiaKey.currentState?.fontFamily ??
                                'Default Font',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          subtitle: Text(
                            fonts.isNotEmpty
                                ? AppLocalizations.of(context)!
                                    .fonts_count(fonts.length)
                                : "Could not load fonts",
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(Icons.chevron_right,
                              color: Colors.white70),
                          onTap: _changeFont,
                        ))
                    : SizedBox.shrink(),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 67, 19, 138),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        localinfo.isNotEmpty
                            ? localinfo[0]
                            : LocaleUtils.getFlagPath(''),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      '${AppLocalizations.of(context)!.settings_language}:',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    subtitle: Text(
                      localinfo.isNotEmpty ? localinfo[1] : 'Null',
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.white70),
                    onTap: () async {
                      await LocaleUtils().showLanguageSelector(context);
                      localinfo = await getcurrentlocale();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
