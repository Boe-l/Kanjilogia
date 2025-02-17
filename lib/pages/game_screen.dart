import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:kana_kit/kana_kit.dart';
import 'package:kanjilogia/common/langstuff.dart';
import 'package:kanjilogia/common/theme.dart';
import 'package:kanjilogia/pages/custom_widgets/bg_painter.dart';
import 'package:kanjilogia/pages/custom_widgets/game_over.dart';
import 'package:kanjilogia/pages/custom_widgets/last_word.dart';
import 'package:kanjilogia/pages/custom_widgets/timer.dart';
import 'package:kanjilogia/pages/custom_widgets/windows_buttons.dart';
import 'package:kanjilogia/pages/custom_widgets/gs_card.dart';
import 'package:kanjilogia/pages/game_screen/process_answer.dart';
import 'package:kanjilogia/pages/history_page.dart';
import 'package:provider/provider.dart';
import '../common/sharedpref.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kanjilogia/common/debg.dart';
import 'package:kanjilogia/common/transition.dart';

final GlobalKey<GameScreenState> gameScreenKey = GlobalKey<GameScreenState>();

class GameScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const GameScreen({super.key, required this.data});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  final TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> gameitems = [];
  List<String> pastItems = [];
  Map<String, List<dynamic>> correctItems = {};
  Map<String, List<dynamic>> errorItems = {};
  int currentIndex = 0;
  int score = 0;
  bool isGameOver = false;
  List<String> answers = [];
  String attemptsString = '';
  Timer? _timer;
  AnswerProcessor? _answerProcessor;

  final int _timeLeft = 60;
  late ValueNotifier<int> timeLeftNotifier;
  bool _timeIsPaused = false;

  final GlobalKey<GameScreenCardState> _customCardKey =
      GlobalKey<GameScreenCardState>();
  double fontSizeCard = 32.0;
  int fontWeightCard = 100;
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    super.initState();
    timeLeftNotifier = ValueNotifier<int>(_timeLeft);
    _loadWords();

    SharedPrefs().getMaxTime().then((value) {
      timeLeftNotifier.value = value;
      startTimer();
    });
    SharedPrefs().getCardFontSize().then((value) {
      setState(() {
        fontSizeCard = value;
      });
    });
    SharedPrefs().getCardFontWeight().then((value) {
      setState(() {
        fontWeightCard = value;
      });
    });
  }

  static const kanaKit = KanaKit();

  void _loadWords() {
    final Map<String, dynamic> data = widget.data;

    setState(() {
      final List<dynamic> finalJsonData = data['finalJsonData'] ?? [];

      gameitems = [];

      for (var item in finalJsonData) {
        if (item['words'] != null && (item['words'] as List).isNotEmpty) {
          for (var word in item['words']) {
            var wordWithTags = <String, dynamic>{
              'filename': item['filename'],
              'word': word['word'],
              'mean': word['mean'] ?? '',
              'reading': word['reading'],
              'tags': (item['tags'] as List).join(', '),
            };

            gameitems.add(wordWithTags);
          }
        } else if (item['grammarQuestions'] != null &&
            (item['grammarQuestions'] as List).isNotEmpty) {
          for (var question in item['grammarQuestions']) {
            var alternatives =
                List<String>.from(question['alternatives'] as List);
            alternatives.shuffle();

            var grammarWithTags = <String, String>{
              'filename': item['filename'],
              'question': question['question'],
              'mean': question['mean'] ?? '',
              'tags': (item['tags'] as List).join(', '),
              'alternatives': alternatives.join(', '),
              'correct': question['correct'] ?? '',
            };

            gameitems.add(grammarWithTags);
          }
        }
      }

      if (gameitems.isEmpty) {
        Debg().warning('Words is empty????');
      } else {
        gameitems.shuffle(Random());
        gameitems = gameitems.toSet().toList();
        currentIndex = 0;
      }
    });
  }

  void _restartGame() {
    isGameOver = false;
    currentIndex = 0;
    score = 0;
    errorItems.clear();
    correctItems.clear();
    pastItems.clear();
    Debg().info('Game restarted');
    _loadWords();
    _answerProcessor = AnswerProcessor(
      gameOver: isGameOver,
      words: gameitems,
      score: score,
      currentIndex: currentIndex,
      restartTimer: restartTimer,
      restartGame: _restartGame,
      customCardKey: _customCardKey,
      context: context,
    );
    setState(() {});
    restartTimer();
  }

  void startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_timeIsPaused && timeLeftNotifier.value > 0) {
        timeLeftNotifier.value--;
        if (isGameOver) _timeIsPaused = true;
      } else if (timeLeftNotifier.value == 0) {
        _processAnswer("");
        timer.cancel();
      }
    });
  }

  void pauseTimer() {
    _timeIsPaused = true;
  }

  void resumeTimer() {
    _timeIsPaused = false;
  }

  void restartTimer() {
    _timer?.cancel();

    SharedPrefs().getMaxTime().then((value) {
      timeLeftNotifier.value = value;
      _timeIsPaused = false;
      startTimer();
    });
  }

  void _processAnswer(String answer) {
    controller.clear();
    _answerProcessor ??= AnswerProcessor(
      gameOver: isGameOver,
      words: gameitems,
      score: score,
      currentIndex: currentIndex,
      restartTimer: restartTimer,
      restartGame: _restartGame,
      customCardKey: _customCardKey,
      context: context,
    );

    _answerProcessor?.processAnswer(answer);
    correctItems = _answerProcessor!.getCorrectItems;
    errorItems = _answerProcessor!.getErrorItems;
    pastItems = _answerProcessor!.getkanjisRespondidos;
    currentIndex = _answerProcessor!.getCurrentIndex;
    score = _answerProcessor!.getScore;
    isGameOver = _answerProcessor!.getGameOver;
    setState(() {});
  }

  void _adjustFontSize(double delta) async {
    setState(() {
      fontSizeCard = (fontSizeCard + delta).clamp(24.0, 128.0);
      SharedPrefs().saveCardFontSize(fontSizeCard);
    });
  }

  void toggleFontWeight() async {
    setState(() {
      fontWeightCard += 300;

      if (fontWeightCard > 900) {
        fontWeightCard = 300;
      }
      SharedPrefs().saveCardFontWeight(fontWeightCard);
      Debg().info('Changed "word" font weight: $fontWeightCard');
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    _timer?.cancel();
    timeLeftNotifier.dispose();
    super.dispose();
  }

  final Map<String, dynamic> bgparameters = {
    "seed": 11234236,
    "flip": true,
    "rotation": true,
    "minFontSize": 16.0,
    "maxFontSize": 60.0,
    "blurX": 4.0,
    'blurY': 4.0
  };
  @override
  Widget build(BuildContext context) {
    ColorPalette colorPalette = Provider.of<ColorPalette>(context);

    final localization = AppLocalizations.of(context);
    double fontSize = MediaQuery.of(context).size.width * 0.06;
    fontSize = fontSize.clamp(16.0, 30.0);
    return SafeArea(
      top: false,
      bottom: false,
      child: GestureDetector(
        onScaleUpdate: (details) {
          if (details.scale > 1) {
            _adjustFontSize(0.2);
          } else if (details.scale < 1) {
            _adjustFontSize(-0.2);
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                top: 2,
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
                    color: colorPalette.background.withValues(alpha: 0.6),
                  ),
                ),
              ),
              !kIsWeb && Platform.isWindows
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 1, 0),
                      child: WindowTitleBarBox(
                        child: SizedBox(
                          child: Row(
                            children: [
                              Expanded(child: MoveWindow()),
                              WindowButtons(),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: GestureDetector(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double screenWidth = constraints.maxWidth;

                              return Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ScrollConfiguration(
                                        behavior:
                                            ScrollConfiguration.of(context)
                                                .copyWith(
                                          dragDevices: {
                                            PointerDeviceKind.mouse,
                                            PointerDeviceKind.touch,
                                          },
                                          scrollbars: false,
                                        ),
                                        child: GestureDetector(
                                            onTap: () => toggleFontWeight(),
                                            child: Listener(
                                              onPointerSignal: (event) {
                                                if (event
                                                    is PointerScrollEvent) {
                                                  _adjustFontSize(
                                                      event.scrollDelta.dy > 0
                                                          ? -2.0
                                                          : 2.0);
                                                }
                                              },
                                              child: SingleChildScrollView(
                                                reverse: true,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    if (gameitems.isNotEmpty)
                                                      Listener(
                                                        onPointerSignal:
                                                            (event) {
                                                          if (event
                                                              is PointerScrollEvent) {
                                                            _adjustFontSize(
                                                                event.scrollDelta
                                                                            .dy >
                                                                        0
                                                                    ? -2.0
                                                                    : 2.0);
                                                          }
                                                        },
                                                        child: isGameOver
                                                            ? GameOverWidget(
                                                                restart:
                                                                    _restartGame,
                                                                correctItems:
                                                                    correctItems,
                                                                errorItems:
                                                                    errorItems)
                                                            : GameScreenCard(
                                                                colorPalette:
                                                                    colorPalette,
                                                                processAnswer: (String
                                                                        answer) =>
                                                                    _processAnswer(
                                                                        answer),
                                                                key:
                                                                    _customCardKey,
                                                                words: gameitems[
                                                                    currentIndex],
                                                                fontSize:
                                                                    fontSizeCard,
                                                                fontWeight:
                                                                    fontWeightCard,
                                                              ),
                                                      ),
                                                    SizedBox(height: 10),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      )
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (pastItems.isNotEmpty)
                                                Expanded(
                                                    child: LastWord(
                                                        pastItems: pastItems,
                                                        correctItems:
                                                            correctItems,
                                                        errorItems: errorItems,
                                                        screenWidth:
                                                            screenWidth,
                                                        words: gameitems,
                                                        localization:
                                                            localization)),
                                              SizedBox(
                                                height: 65,
                                                child: pastItems.isNotEmpty
                                                    ? IconButton(
                                                        icon: Icon(
                                                          Icons.history,
                                                          color: colorPalette
                                                              .iconColor,
                                                        ),
                                                        onPressed: () {
                                                          pauseTimer();
                                                          navigateWithCircularAnimation(
                                                            onComplete:
                                                                resumeTimer,
                                                            context,
                                                            History(
                                                              correctItems:
                                                                  correctItems,
                                                              incorrectItems:
                                                                  errorItems,
                                                            ),
                                                          );
                                                        },
                                                        tooltip: localization!
                                                            .gs_see_full_history,
                                                      )
                                                    : null,
                                              ),
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: TextField(
                                              focusNode: focusNode,
                                              textInputAction:
                                                  TextInputAction.none,
                                              controller: controller,
                                              onSubmitted: (value) {
                                                _processAnswer(value);
                                              },
                                              decoration: InputDecoration(
                                                labelText: localization!
                                                    .gs_search_tooltip,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                prefixIcon: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Image.asset(
                                                    LocaleUtils.getFlagPath(gameitems[
                                                                    currentIndex]
                                                                .isNotEmpty &&
                                                            gameitems[currentIndex]
                                                                    ['tags'] !=
                                                                null
                                                        ? gameitems[
                                                                currentIndex]
                                                            ['tags']
                                                        : ''),
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: Icon(Icons.send,
                                                      color: colorPalette
                                                          .iconColor),
                                                  onPressed: () =>
                                                      _processAnswer(
                                                          controller.text),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 30,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              Text(
                                localization!.gs_points(score),
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: _restartGame,
                                icon: Icon(Icons.restart_alt,
                                    color: colorPalette.iconColor),
                                tooltip: localization.gs_game_restart2,
                              ),
                              TimerWidget(
                                fontSize: fontSize,
                                timeLeftNotifier: timeLeftNotifier,
                              )
                            ],
                          ),
                        ),
                      ],
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
}
