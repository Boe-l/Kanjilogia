import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kanjilogia/pages/game_main.dart';
import 'package:kanjilogia/pages/settings.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'common/sharedpref.dart';
import 'pages/managepage.dart';
import 'l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'common/debg.dart';
//import 'package:kanjilogia/utils/fonts_windows.dart'; //FORWINDOWS, MAKE SURE TO ALSO CHANGE IT ON MAIN.DART
import 'package:kanjilogia/utils/fonts_web.dart'; // FORWEB, MAKE SURE TO ALSO CHANGE IT ON MAIN.DART

void main() {
  
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(Kanjilogia(key: kanjilogiaKey));
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

    await SharedPrefs().saveLocale(locale);

    setState(() {
      _locale = locale!;
    });
    Debg().info('locale: "$locale"');
  }

  Future<void> loadFont([String? fontname]) async {
    if (!kIsWeb) {
      try {
        setState(() {
          fontFamily = fontname ?? ''; // Garante que nunca seja nulo
        });

        if (fontname?.isNotEmpty ?? false) {
          await SharedPrefs().saveFontName(fontname!);
        }
      } catch (e) {
        // Em caso de erro, redefine a fonte para uma string vazia
        Debg().error('Error changing font: "$e"');
        setState(() {
          fontFamily = '';
        });
      }
    }
    if (kIsWeb) {
      try {
        await LocalFonts().loadFont(fontname.toString());

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
  late int selectedTime = 30;
  late TabController _tabController;
  List<TargetFocus> targets = [];
  @override
  void initState() {
    super.initState();
    kDebugMode
        ? Debg().setLoggingEnabled(true)
        : Debg().setLoggingEnabled(false);
    _tabController = TabController(length: 3, vsync: this);
    String? lastfont;

    void onstart() async {
      lastfont = await SharedPrefs().getFontName();
      widget.loadFont(lastfont.toString());
    }

    onstart();
    //testing load local fonts on web
    // List<FontMetadata> fonts = await LocalFonts().listFonts();
    //  for (var font in fonts) {
    //    print('Fonte: ${font.postscriptName}'); list fonts
    //  }
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   targets.add(TargetFocus(identify: "1", keyTarget: null, contents: [
    //     TargetContent(
    //       align: ContentAlign.bottom,
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: <Widget>[
    //           Text(
    //             AppLocalizations.of(context)!.tutorial1,
    //             style: TextStyle(
    //               fontWeight: FontWeight.bold,
    //               color: Colors.white,
    //               fontSize: 20.0,
    //             ),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.only(top: 10.0),
    //             child: Text(
    //               AppLocalizations.of(context)!.tutorial2,
    //               style: TextStyle(color: Colors.white),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ]));

    //   targets.add(TargetFocus(identify: "2", keyTarget: null, contents: [
    //     TargetContent(
    //       align: ContentAlign.top,
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: <Widget>[
    //           Text(
    //             AppLocalizations.of(context)!.tutorial3,
    //             style: TextStyle(
    //               fontWeight: FontWeight.bold,
    //               color: Colors.white,
    //               fontSize: 20.0,
    //             ),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.only(top: 10.0),
    //             child: Text(
    //               AppLocalizations.of(context)!.tutorial4,
    //               style: TextStyle(color: Colors.white),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ]));

    //   targets.add(TargetFocus(identify: "3", keyTarget: null, contents: [
    //     TargetContent(
    //       align: ContentAlign.top,
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: <Widget>[
    //           Text(
    //             AppLocalizations.of(context)!.tutorial5,
    //             style: TextStyle(
    //               fontWeight: FontWeight.bold,
    //               color: Colors.white,
    //               fontSize: 20.0,
    //             ),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.only(top: 10.0),
    //             child: Text(
    //               AppLocalizations.of(context)!.tutorial6,
    //               style: TextStyle(color: Colors.white),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ]));

    //   Future.delayed(Duration(seconds: 2), () async {
    //     bool isComplete = await SharedPrefs().isTutorialComplete();
    //     if (isComplete == false) {
    //       showTutorial();
    //     }
    //   });
    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void showTutorial() {
    try {
      TutorialCoachMark(
        targets: targets,
        colorShadow: Colors.red,
        textSkip: AppLocalizations.of(context)!.tutorial_skip,
        onClickTarget: (target) {},
        onClickTargetWithTapPosition: (target, tapDetails) {},
        onClickOverlay: (target) {},
        onSkip: () {
          SharedPrefs().saveTutorialComplete(true);
          return true;
        },
        onFinish: () async {
          await SharedPrefs().saveTutorialComplete(true);
        },
      ).show(context: context);
    } catch (e) {
      Debg().error(e as String);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Column(
          children: [
            // Conteúdo da página
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  GameMain(),
                  ManagerPage(),
                  SettingsPage(),
                ],
              ),
            ),
            // Abas na parte inferior
            Container(
              color: Color.fromARGB(255, 74, 32, 126),
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: [
                      Tab(
                          icon: Icon(Icons.play_arrow),
                          text: AppLocalizations.of(context)!.play),
                      Tab(
                          icon: Icon(Icons.file_copy_sharp),
                          text: AppLocalizations.of(context)!.files
                          // AppLocalizations.of(context)!.files
                          ),
                      Tab(
                          icon: Icon(Icons.settings_suggest_outlined),
                          text: AppLocalizations.of(context)!.settings),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
