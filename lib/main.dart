import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:kanjilogia/pages/settings.dart';
import 'pages/game_screen.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'common/sharedpref.dart';
import 'common/database.dart';
import 'pages/managepage.dart';
import 'l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'common/langstuff.dart';
import 'common/debg.dart';
import 'utils/fontsweb.dart' if (dart.library.io) 'utils/fonts_stub.dart';

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

  void changeLanguage([Locale? locale]) async {
    locale ??= await SharedPrefs().getLocale();

    await SharedPrefs().saveLocale(locale);

    setState(() {
      _locale = locale!;
    });
    Debg().info('locale: "$locale"');
  }

  String _fontFamily = '';

  Future<void> loadFont(String fontname) async {
    try {
      await LocalFonts().loadFont(fontname);

      setState(() {
        _fontFamily = fontname;
      });
    } catch (e) {
      Debg().error('Error changing font: "$e"');
      setState(() {
        _fontFamily = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontStyle =
        _fontFamily.isNotEmpty ? TextStyle(fontFamily: _fontFamily) : null;
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
  final Future<void> Function(String) loadFont;
  const MainMenu({
    super.key,
    required this.changeLanguage,
    required this.loadFont,
  });

  @override
  MainMenuState createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  Map<String, Set<String>> _jsonFiles = {};
  Map<String, Set<String>> _filteredJsonFiles = {};
  final List<String> _selectedFiles = [];
  final TextEditingController _searchController = TextEditingController();
  late int selectedTime = 30;
  late AnimationController _backgroundController;
  late Animation<Color?> _colorAnimation;
  late TabController _tabController;
  Map<String, dynamic> data = {
    'selectedTime': 1,
    'finalJsonData': [],
  };
  List<TargetFocus> targets = [];
  final GlobalKey playButtonKey = GlobalKey();
  final GlobalKey grid3 = GlobalKey();
  final GlobalKey settingsKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButtons = true;
  @override
  void initState() {
    super.initState();
    kDebugMode
        ? Debg().setLoggingEnabled(true)
        : Debg().setLoggingEnabled(false);
    //widget.loadFont('851zatsu');
    //testing load local fonts on web
    // List<FontMetadata> fonts = await LocalFonts().listFonts();
    //  for (var font in fonts) {
    //    print('Fonte: ${font.postscriptName}'); list fonts
    //  }
    _tabController = TabController(length: 3, vsync: this);
    _loadJsonFiles();
    _searchController.addListener(_filterJsonFiles);
    widget.changeLanguage();
    SharedPrefs().getMaxTime().then((time) {
      setState(() {
        selectedTime = time;
      });
    });
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          _loadJsonFiles();
        }
      }
    });

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 56, 16, 115),
      end: const Color.fromARGB(255, 56, 16, 115),
    ).animate(_backgroundController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      targets.add(TargetFocus(identify: "1", keyTarget: grid3, contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.tutorial1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  AppLocalizations.of(context)!.tutorial2,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ]));

      targets
          .add(TargetFocus(identify: "2", keyTarget: playButtonKey, contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.tutorial3,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  AppLocalizations.of(context)!.tutorial4,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ]));

      targets.add(TargetFocus(identify: "3", keyTarget: settingsKey, contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.tutorial5,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  AppLocalizations.of(context)!.tutorial6,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ]));

      Future.delayed(Duration(seconds: 2), () async {
        bool isComplete = await SharedPrefs().isTutorialComplete();
        if (isComplete == false) {
          showTutorial();
        }
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showFloatingButtons) {
          setState(() => _showFloatingButtons = false);
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showFloatingButtons) {
          setState(() => _showFloatingButtons = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _backgroundController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadJsonFiles() async {
    try {
      final jsonFiles = await listFilenamesWithTags();

      setState(() {
        _jsonFiles = jsonFiles;
        _filteredJsonFiles = jsonFiles;
      });
    } catch (e) {
      Debg().error(e as String);
    }
  }

  void _filterJsonFiles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredJsonFiles = Map.fromEntries(
        _jsonFiles.entries.where((entry) {
          return entry.key.toLowerCase().contains(query);
        }),
      );
    });
  }

  void _toggleSelection(String fileName) {
    setState(() {
      if (_selectedFiles.contains(fileName)) {
        _selectedFiles.remove(fileName);
      } else {
        _selectedFiles.add(fileName);
      }
    });
  }

  void _startGame(BuildContext context, selectedTime) async {
    final localization = AppLocalizations.of(context);
    if (_selectedFiles.isEmpty) {
      _showErrorDialog(localization!.dialogue1);
      return;
    }

    try {
      List<String> selectedFilesList = _selectedFiles;
      List<dynamic> finalWords = await getWordsByFilenames(selectedFilesList);

      if (finalWords.isEmpty) {
        if (mounted) {
          _showErrorDialog(localization!.gs_words_empty);
          Debg().warning(localization.gs_words_empty);
        }
        return;
      }

      final data = {
        'selectedTime': selectedTime,
        'finalJsonData': finalWords,
      };

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(data: data),
          ),
        );
      }

      _selectedFiles.clear();
    } catch (e) {
      Debg().error(e as String);
    }
  }

  void _showErrorDialog(String message) {
    showToast(
      message,
      context: context,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.scale,
      animDuration: Duration(milliseconds: 600),
      duration: Duration(seconds: 2),
      position: StyledToastPosition.center,
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
      backgroundColor: Colors.red.withValues(alpha: 0.8),
      textStyle: TextStyle(color: Colors.white, fontSize: 16),
    );
    Debg().warning(message);
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
    final screenWidth = MediaQuery.of(context).size.width;

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
                  main(screenWidth),
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

  AnimatedBuilder main(double screenWidth) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Scaffold(
            resizeToAvoidBottomInset: true,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _colorAnimation.value!,
                    const Color.fromARGB(255, 56, 16, 115)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      SizedBox(height: 26),
                      Text(
                        "Kanjilogia",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth < 600 ? 28 : 36,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.blueAccent,
                              blurRadius: 10,
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!
                                .main_searchtooltip,
                            hintStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.search, color: Colors.white),
                            filled: false,
                            fillColor: Colors.grey[800],
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                  color:
                                      const Color.fromARGB(255, 109, 33, 223),
                                  width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 109, 33, 223),
                                  width: 2),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: _filteredJsonFiles.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .main_files_empty,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              )
                            : AnimationLimiter(
                                child: ScrollConfiguration(
                                  behavior:
                                      ScrollConfiguration.of(context).copyWith(
                                    dragDevices: {
                                      PointerDeviceKind.mouse,
                                      PointerDeviceKind.touch,
                                    },
                                    scrollbars: false,
                                  ),
                                  child: AnimationLimiter(
                                    child: GridView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.all(16),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            screenWidth < 320 ? 2 : 3,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                      itemCount: _filteredJsonFiles.length,
                                      itemBuilder: (context, index) {
                                        final fileName = _filteredJsonFiles.keys
                                            .elementAt(index);

                                        final isSelected =
                                            _selectedFiles.contains(fileName);
                                        return MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: AnimationConfiguration
                                              .staggeredGrid(
                                            key: index == 0 ? grid3 : null,
                                            position: index,
                                            columnCount:
                                                screenWidth < 320 ? 2 : 3,
                                            duration: const Duration(
                                                milliseconds: 600),
                                            child: SlideAnimation(
                                              curve: Curves.decelerate,
                                              verticalOffset: 250,
                                              child: FadeInAnimation(
                                                duration: const Duration(
                                                    milliseconds: 1000),
                                                child: GestureDetector(
                                                  onTap: () => _toggleSelection(
                                                      fileName),
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 250),
                                                    curve:
                                                        Curves.easeInOutQuint,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withValues(
                                                                  alpha: 0.2),
                                                          spreadRadius: 2,
                                                          blurRadius: 10,
                                                          offset: const Offset(
                                                              0, 3),
                                                        ),
                                                      ],
                                                      gradient: LinearGradient(
                                                        colors: isSelected
                                                            ? [
                                                                const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        80,
                                                                        36,
                                                                        133)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.4),
                                                                const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        80,
                                                                        36,
                                                                        133)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.1),
                                                              ]
                                                            : [
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    80,
                                                                    36,
                                                                    133),
                                                                const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        80,
                                                                        36,
                                                                        133)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.4),
                                                              ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? const Color
                                                                .fromARGB(
                                                                255, 47, 3, 68)
                                                            : const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    159,
                                                                    7,
                                                                    219)
                                                                .withAlpha(0),
                                                        width:
                                                            isSelected ? 3 : 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Spacer(flex: 1),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Image.asset(
                                                            LocaleUtils.getFlagPath(
                                                                _filteredJsonFiles[
                                                                        fileName]!
                                                                    .first),
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            fileName,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: isSelected
                                                                  ? const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      255)
                                                                  : Colors.white
                                                                      .withAlpha(
                                                                          255),
                                                              fontSize:
                                                                  screenWidth <
                                                                          320
                                                                      ? 14
                                                                      : 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              shadows: [
                                                                Shadow(
                                                                  color: Colors
                                                                      .blueAccent,
                                                                  blurRadius:
                                                                      10,
                                                                ),
                                                              ],
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                        Spacer(flex: 1),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: AnimatedOpacity(
              opacity: _showFloatingButtons ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring:
                    !_showFloatingButtons, // Ignora interações quando invisível
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: const EdgeInsets.only(right: 16, bottom: 16),
                        child: FloatingActionButton(
                          key: playButtonKey,
                          heroTag: 'play',
                          onPressed: () => _startGame(context, selectedTime),
                          backgroundColor: Color(0xFF6C5CE7),
                          child: Icon(Icons.play_arrow),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ));
      },
    );
  }
}
