import 'dart:io';
import 'dart:ui';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kanjilogia/common/langstuff.dart';
import 'package:kanjilogia/common/theme.dart';
import 'package:kanjilogia/pages/custom_widgets/windows_buttons.dart';
import 'package:kanjilogia/pages/custom_widgets/bg_painter.dart';
import 'package:kanjilogia/pages/feed.dart';
import 'package:kanjilogia/pages/game_main.dart';
import 'package:kanjilogia/pages/settings_page.dart';
import 'package:kanjilogia/utils/discord_rpc.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'common/sharedpref.dart';
import 'pages/files_page.dart';
import 'l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'common/debg.dart';
import 'package:kanjilogia/utils/fonts_windows.dart';
// import 'package:kanjilogia/utils/fonts_web.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ColorPalette()),
        ChangeNotifierProvider(
            create: (context) => DiscordRichPresenceNotifier()),
      ],
      child: Kanjilogia(key: kanjilogiaKey),
    ),
  );
  doWhenWindowReady(() {
    if (!Platform.isWindows) return;
    const initialSize = Size(600, 600);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
    appWindow.maximize();
  });
}

final GlobalKey<KanjilogiaState> kanjilogiaKey = GlobalKey<KanjilogiaState>();

class Kanjilogia extends StatefulWidget {
  const Kanjilogia({super.key});

  @override
  KanjilogiaState createState() => KanjilogiaState();
}

class KanjilogiaState extends State<Kanjilogia> {
  Locale _locale = Locale('en');
  String? fontFamily = 'Default';
  void changeLanguage([Locale? locale]) async {
    locale ??= await SharedPrefs().getLocale();

    setState(() {
      _locale = locale!;
    });
    await SharedPrefs().saveLocale(locale);
    Debg().info('locale: "$locale"');
  }

  Future<void> loadFont([String? fontname]) async {
    if (!kIsWeb) {
      try {
        setState(() {
          fontFamily = fontname ?? '';
        });

        if (fontname?.isNotEmpty ?? false) {
          await SharedPrefs().saveFontName(fontname!);
        }
      } catch (e) {
        Debg().error('Error changing font: "$e"');
        setState(() {
          fontFamily = '';
        });
      }
    }
    if (kIsWeb) {
      try {
        LocalFonts().loadFont(fontname.toString());

        setState(() {
          fontFamily = fontname;
        });
        SharedPrefs().saveFontName(fontname.toString());
      } catch (e) {
        Debg().error('Error changing font: "$e"');
        setState(() {
          fontFamily = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    final fontStyle =
        fontFamily!.isNotEmpty ? TextStyle(fontFamily: fontFamily) : null;
    return MaterialApp(
      title: 'Kanjilogia - 漢字ロギア',
      theme: ThemeData(
          brightness: Brightness.dark,
          textTheme: TextTheme(
            bodyLarge: fontStyle,
            bodyMedium: fontStyle,
            bodySmall: fontStyle,
            displayLarge: fontStyle,
            displayMedium: fontStyle,
            displaySmall: fontStyle,
            headlineLarge: fontStyle,
            headlineMedium: fontStyle,
            headlineSmall: fontStyle,
            labelLarge: fontStyle,
            labelMedium: fontStyle,
            labelSmall: fontStyle,
            titleLarge: fontStyle,
            titleMedium: fontStyle,
            titleSmall: fontStyle,
          )),
      home: MainMenu(
        changeLanguage: changeLanguage,
        loadFont: loadFont,
      ),
      debugShowCheckedModeBanner: false,
      supportedLocales: L10n.all,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
    );
  }
}

class MainMenu extends StatefulWidget {
  final Function([Locale?]) changeLanguage;
  final Future<void> Function(String?) loadFont;
  const MainMenu({
    super.key,
    required this.changeLanguage,
    required this.loadFont,
  });

  @override
  MainMenuState createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  final borderColor = Color(0xFF805306);
  late int selectedTime = 30;
  late TabController _tabController;
  List<TargetFocus> targets = [];
  // late DiscordRichPresence discord;

  @override
  void initState() {
    super.initState();
    kDebugMode
        ? Debg().setLoggingEnabled(true)
        : Debg().setLoggingEnabled(false);
    _tabController = TabController(length: 4, vsync: this);
    String? lastfont;

    void onstart() async {
      widget
          .changeLanguage(); // starts the app with the last language or default(english) if none

      lastfont = await SharedPrefs().getFontName();
      widget.loadFont(lastfont.toString());

      setState(() {});
      await SharedPrefs().isTutorialComplete().then(
        (value) async {
          if (value == false && mounted) {
            await LocaleUtils().showLanguageSelector(
                context); // show language picker (first run)
            SharedPrefs().saveTutorialComplete(true);
          }
        },
      );
      await SharedPrefs().getRPC().then(
        (value) async {
          if (value && mounted) {
            Provider.of<DiscordRichPresenceNotifier>(context, listen: false)
                .toggleRichPresence(value);
          }
        },
      );
    }

    onstart();
  }

  @override
  void dispose() {
    // discord.disconnect();

    _tabController.dispose();
    super.dispose();
  }

  // void showTutorial() {
  //   try {
  //     LocaleUtils().showLanguageSelector(context);

  //     TutorialCoachMark(
  //       targets: targets,
  //       colorShadow: Colors.red,
  //       textSkip: AppLocalizations.of(context)!.tutorial_skip,
  //       onClickTarget: (target) {},
  //       onClickTargetWithTapPosition: (target, tapDetails) {},
  //       onClickOverlay: (target) {},
  //       onSkip: () {
  //         SharedPrefs().saveTutorialComplete(true);
  //         return true;
  //       },
  //       onFinish: () async {
  //         await SharedPrefs().saveTutorialComplete(true);
  //       },
  //     ).show(context: context);
  //   } catch (e) {
  //     Debg().error("Show tutorial error: ${e.toString()}");
  //   }
  // }

  final Map<String, dynamic> bgparameters = {
    "seed": 11234236,
    "flip": true,
    "rotation": true,
    "minFontSize": 16.0,
    "maxFontSize": 60.0,
    "blurX": 3.0,
    'blurY': 3.0
  };

  @override
  Widget build(BuildContext context) {
    ColorPalette colorPalette = Provider.of<ColorPalette>(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        body: WindowBorder(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: CharacterBackgroundPainter(
                        seed: bgparameters['seed'],
                        enableFlip: bgparameters['flip'],
                        enableRotation: bgparameters['rotation'],
                        minFontSize: bgparameters['minFontSize'],
                        maxFontSize: bgparameters['maxFontSize'],
                        colorPalette: colorPalette),
                  ),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: bgparameters['blurX'],
                      sigmaY: bgparameters['blurY']),
                  child: Container(
                    color: colorPalette.background.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Column(
                children: [
                  !kIsWeb && Platform.isWindows
                      ? WindowTitleBarBox(
                          child: SizedBox(
                            child: Row(
                              children: [
                                Expanded(child: MoveWindow()),
                                WindowButtons(),
                              ],
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.touch,
                        },
                        scrollbars: false,
                      ),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          GameMain(),
                          ManagerPage(),
                          SettingsPage(),
                          FeedPage(),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: colorPalette.background.withValues(alpha: 0.7),
                    child: Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 600),
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: colorPalette.button,
                          labelColor: colorPalette.text,
                          unselectedLabelColor: Colors.white70,
                          tabs: [
                            Tab(
                              icon: Icon(
                                Icons.play_arrow,
                              ),
                              text: AppLocalizations.of(context)!.play,
                            ),
                            Tab(
                                icon: Icon(Icons.file_copy_sharp),
                                text: AppLocalizations.of(context)!.files),
                            Tab(
                                icon: Icon(Icons.settings_suggest_outlined),
                                text: AppLocalizations.of(context)!.settings),
                            Tab(icon: Icon(Icons.rss_feed), text: 'Feed')
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
