import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kanjilogia/common/transition.dart';
import 'package:kanjilogia/common/database.dart';
import 'package:kanjilogia/common/debg.dart';
import 'package:kanjilogia/common/langstuff.dart';
import 'package:kanjilogia/common/sharedpref.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kanjilogia/pages/game_screen.dart';

class GameMain extends StatefulWidget {
  const GameMain({super.key});

  @override
  State<GameMain> createState() => GameMainState();
}

class GameMainState extends State<GameMain> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Map<String, Set<String>> _filteredJsonFiles = {};
  final ScrollController _scrollController = ScrollController();
  final List<String> _selectedFiles = [];
  final GlobalKey playButtonKey = GlobalKey();
  final GlobalKey grid3 = GlobalKey();
  final GlobalKey settingsKey = GlobalKey();
  final bool _showFloatingButtons = true;
  late int selectedTime = 30;

  Map<String, Set<String>> _jsonFiles = {};
  @override
  void initState() {
    super.initState();
    _loadJsonFiles();

    _searchController.addListener(_filterJsonFiles);

    SharedPrefs().getMaxTime().then((time) {
      setState(() {
        selectedTime = time;
      });
    });
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
        navigateWithCircularAnimation(context, GameScreen(data: data));
      }

      _selectedFiles.clear();
      _searchController.clear();
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    SizedBox(height: 32),
                    Text(
                      "Kanjilogia",
                      style: GoogleFonts.rampartOne(
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
                          hintText:
                              AppLocalizations.of(context)!.main_searchtooltip,
                          hintStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          filled: true,
                          fillColor: const Color.fromARGB(118, 104, 58, 183),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 109, 33, 223),
                                width: 1),
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
                                AppLocalizations.of(context)!.main_files_empty,
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
                                      crossAxisCount: screenWidth < 360 ? 2 : 3,
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
                                          duration:
                                              const Duration(milliseconds: 600),
                                          child: SlideAnimation(
                                            curve: Curves.decelerate,
                                            verticalOffset: 250,
                                            child: FadeInAnimation(
                                              duration: const Duration(
                                                  milliseconds: 1000),
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _toggleSelection(fileName),
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 250),
                                                  curve: Curves.easeInOutQuint,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                                alpha: 0.2),
                                                        spreadRadius: 2,
                                                        blurRadius: 10,
                                                        offset:
                                                            const Offset(0, 3),
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
                                                                          0.8), // cor mais escura para selecionado
                                                              const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      80,
                                                                      36,
                                                                      133)
                                                                  .withValues(
                                                                      alpha:
                                                                          0.8),
                                                            ]
                                                          : [
                                                              const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  67,
                                                                  19,
                                                                  138), // cor mais clara para não selecionado
                                                              const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      80,
                                                                      36,
                                                                      133)
                                                                  .withValues(
                                                                      alpha:
                                                                          0.4), // opacidade reduzida
                                                            ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? const Color
                                                              .fromARGB(
                                                              255,
                                                              109,
                                                              33,
                                                              223) // borda mais visível quando selecionado
                                                          : const Color
                                                                  .fromARGB(255,
                                                                  159, 7, 219)
                                                              .withValues(
                                                                  alpha:
                                                                      0.3), // borda mais suave quando não selecionado
                                                      width: isSelected
                                                          ? 2
                                                          : 1, // espessura da borda ajustada para maior destaque quando selecionado
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
                                                          textAlign:
                                                              TextAlign.center,
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
                                                                        360
                                                                    ? 14
                                                                    : 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            shadows: [
                                                              Shadow(
                                                                color: Colors
                                                                    .blueAccent,
                                                                blurRadius: 10,
                                                              ),
                                                            ],
                                                          ),
                                                          overflow: TextOverflow
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
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: AnimatedOpacity(
          opacity: _showFloatingButtons ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            ignoring: !_showFloatingButtons,
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
  }
}
