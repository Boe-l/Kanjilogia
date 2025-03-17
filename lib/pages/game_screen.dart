import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:kanjilogia/common/langstuff.dart';
import 'package:kanjilogia/common/theme.dart';
import 'package:kanjilogia/pages/game_screen/game_over.dart';
import 'package:kanjilogia/pages/game_screen/last_word.dart';
import 'package:kanjilogia/pages/game_screen/timer.dart';
import 'package:kanjilogia/pages/custom_widgets/windows_buttons.dart';
import 'package:kanjilogia/pages/game_screen/gs_card.dart';
import 'package:kanjilogia/pages/game_screen/process_answer.dart';
import 'package:kanjilogia/pages/history_page.dart';
import 'package:kanjilogia/utils/discord_rpc.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../common/sharedpref.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kanjilogia/common/debg.dart';
import 'package:kanjilogia/common/transition.dart';
import 'package:flutter_popup/flutter_popup.dart';

final GlobalKey<GameScreenState> gameScreenKey = GlobalKey<GameScreenState>();

class GameScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const GameScreen({super.key, required this.data});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> gameitems = [];
  List<String> pastItems = [];
  Map<String, List<dynamic>> correctItems = {};
  Map<String, List<dynamic>> errorItems = {};
  int currentIndex = 0;
  int score = 0;
  bool isGameOver = false;
  bool romaji = false;
  bool animateBg = false;
  List<String> answers = [];
  String attemptsString = '';
  Timer? _timer;
  AnswerProcessor? _answerProcessor;

  final int _timeLeft = 60;
  late ValueNotifier<int> timeLeftNotifier;
  bool _timeIsPaused = false;

  final GlobalKey<GameScreenCardState> _customCardKey =
      GlobalKey<GameScreenCardState>();
  final ValueNotifier<double> fontSizeCard = ValueNotifier(24.0);
  final ValueNotifier<double> recentFontSize = ValueNotifier(24.0);
  int fontWeightCard = 100;
  FocusNode focusNode = FocusNode();
  late AnimationController _animationController;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    super.initState();
    timeLeftNotifier = ValueNotifier<int>(_timeLeft);
    Provider.of<DiscordRichPresenceNotifier>(context, listen: false)
        .updateActivity(
      title: 'In Game',
      subtitle: 'Score: 0',
      imageDetails: 'Kanjilogia',
    );
    _loadWords();
    SharedPrefs().getMaxTime().then((value) {
      timeLeftNotifier.value = value;
      startTimer();
    });
    SharedPrefs().getCardFontSize().then((value) {
      setState(() {
        fontSizeCard.value = value;
      });
    });
    SharedPrefs().getRecentFontSize().then((value) {
      setState(() {
        recentFontSize.value = value;
      });
    });
    SharedPrefs().getCardFontWeight().then((value) {
      setState(() {
        fontWeightCard = value;
      });
    });
    SharedPrefs().getRomaji().then((value) {
      setState(() {
        romaji = value;
      });
    });
    SharedPrefs().getAnimateBg().then((value) {
      setAnimateBg(value);
    });
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 15),
    );
    if (!animateBg) {
      _animationController.stop();
    }
  }

  void setRomaji(bool a) async {
    setState(() {
      romaji = a;
    });
    await SharedPrefs().saveRomaji(a);
  }

  void setAnimateBg(bool b) async {
    setState(() {
      animateBg = b;
    });
    if (animateBg) {
      _animationController.repeat(); // Inicia a animação
    } else {
      _animationController.stop(); // Pausa a animação
    }
    await SharedPrefs().saveAnimateBg(b);
  }

  void changeTime(int time) async {
    timeLeftNotifier.value = time;
    await SharedPrefs().saveMaxTime(time);
    setState(() {});
    startTimer();
  }

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
    Provider.of<DiscordRichPresenceNotifier>(context, listen: false)
        .updateActivity(
      title: 'In Game',
      subtitle: 'Score: $score',
      imageDetails:
          '${gameitems.length} Total Items, ${gameitems.length - pastItems.length} Left.',
    );
    setState(() {});
  }

  void _adjustCardFontSize(double delta) async {
    fontSizeCard.value = (fontSizeCard.value + delta).clamp(24.0, 128.0);
    SharedPrefs().saveCardFontSize(fontSizeCard.value);
  }

  void _adjustRecentFontSize(double delta) async {
    recentFontSize.value = (recentFontSize.value + delta).clamp(24.0, 128.0);
    SharedPrefs().saveRecentFontSize(recentFontSize.value);
  }

  void toggleFontWeight(int weight) async {
    setState(() {
      fontWeightCard = weight;

      SharedPrefs().saveCardFontWeight(fontWeightCard);
      Debg().info('Changed "word" font weight: $fontWeightCard');
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    _animationController.dispose();
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
            _adjustCardFontSize(0.7);
          } else if (details.scale < 1) {
            _adjustCardFontSize(-0.7);
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              // Positioned.fill(
              //   top: 2,
              //   child: RepaintBoundary(
              //     child: CustomPaint(
              //       painter: CharacterBackgroundPainter(
              //           seed: bgparameters['seed'],
              //           enableFlip: bgparameters['flip'],
              //           enableRotation: bgparameters['rotation'],
              //           minFontSize: bgparameters['minFontSize'],
              //           maxFontSize: bgparameters['maxFontSize'],
              //           colorPalette: colorPalette),
              //     ),
              //   ),
              // ),
              Lottie.asset('assets/lottie/1.json',
                  repeat: false,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity),
              Align(
                alignment: Alignment.centerLeft,
                child: Lottie.asset('assets/lottie/2.json',
                    repeat: animateBg,
                    controller: _animationController,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.5),
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
                                        child: SingleChildScrollView(
                                          reverse: true,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (gameitems.isNotEmpty)
                                                Listener(
                                                  onPointerSignal: (event) {
                                                    if (event
                                                        is PointerScrollEvent) {
                                                      _adjustCardFontSize(
                                                          event.scrollDelta.dy >
                                                                  0
                                                              ? -7.0
                                                              : 7.0);
                                                    }
                                                  },
                                                  child: isGameOver
                                                      ? GameOverWidget(
                                                          restart: _restartGame,
                                                          correctItems:
                                                              correctItems,
                                                          errorItems:
                                                              errorItems)
                                                      : ValueListenableBuilder<
                                                              double>(
                                                          valueListenable:
                                                              fontSizeCard,
                                                          builder: (context,
                                                              fontSize, child) {
                                                            return GameScreenCard(
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
                                                                  fontSize,
                                                              fontWeight:
                                                                  fontWeightCard,
                                                            );
                                                          }),
                                                ),
                                              SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      GestureDetector(
                                        onScaleUpdate: (details) {
                                          if (details.scale > 1) {
                                            _adjustRecentFontSize(0.2);
                                          } else if (details.scale < 1) {
                                            _adjustRecentFontSize(-0.2);
                                          }
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                if (pastItems.isNotEmpty)
                                                  Expanded(
                                                      child: Listener(
                                                    onPointerSignal: (event) {
                                                      if (event
                                                          is PointerScrollEvent) {
                                                        _adjustRecentFontSize(
                                                            event.scrollDelta
                                                                        .dy >
                                                                    0
                                                                ? -7.0
                                                                : 7.0);
                                                      }
                                                    },
                                                    child:
                                                        ValueListenableBuilder<
                                                                double>(
                                                            valueListenable:
                                                                recentFontSize,
                                                            builder: (context,
                                                                fontSize,
                                                                child) {
                                                              return LastWord(
                                                                  fontSize:
                                                                      recentFontSize
                                                                          .value,
                                                                  isRomaji:
                                                                      romaji,
                                                                  pastItems:
                                                                      pastItems,
                                                                  correctItems:
                                                                      correctItems,
                                                                  errorItems:
                                                                      errorItems,
                                                                  screenWidth:
                                                                      screenWidth,
                                                                  words:
                                                                      gameitems,
                                                                  localization:
                                                                      localization);
                                                            }),
                                                  )),
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
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  prefixIcon: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                      LocaleUtils.getFlagPath(gameitems[
                                                                      currentIndex]
                                                                  .isNotEmpty &&
                                                              gameitems[currentIndex]
                                                                      [
                                                                      'tags'] !=
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
                              CustomPopup(
                                arrowColor:
                                    const Color.fromARGB(255, 45, 35, 70),
                                barrierColor:
                                    Colors.green.withValues(alpha: 0.1),
                                backgroundColor:
                                    const Color.fromARGB(255, 45, 35, 70),
                                content: PopUp(
                                  changeAnimateBg: (bool a) => setAnimateBg(a),
                                  changeRomaji: (bool b) => setRomaji(b),
                                  animateBg: animateBg,
                                  romaji: romaji,
                                  fontWeight: fontWeightCard,
                                  changeTime: (int time) => changeTime(time),
                                  changeFontWeight: (int weight) =>
                                      toggleFontWeight(weight),
                                ),
                                child: Tooltip(
                                  message: 'Configurações', //TODO
                                  child: Icon(
                                    Icons.settings,
                                    color: Colors.white70,
                                  ),
                                ),
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

class PopUp extends StatefulWidget {
  final Function(int) changeFontWeight;
  final Function(int) changeTime;
  final Function(bool) changeRomaji;
  final Function(bool) changeAnimateBg;
  final int fontWeight; // Torne isso 'final'
  final bool romaji;
  final bool animateBg;

  const PopUp({
    super.key,
    required this.changeFontWeight,
    required this.changeTime,
    required this.romaji,
    required this.animateBg,
    required this.fontWeight, // Torne isso 'final'
    required this.changeRomaji,
    required this.changeAnimateBg,
  });

  @override
  State<PopUp> createState() => _PopUpState();
}

class _PopUpState extends State<PopUp> {
  double selectedTime = 30.0;
  late bool animateBackground;
  late bool romaji;
  late int weight;
  @override
  void initState() {
    super.initState();
    romaji = widget.romaji;
    weight = widget.fontWeight;
    animateBackground = widget.animateBg;

    start();
  }

  // A função agora atualiza o estado após o valor ser carregado
  void start() async {
    final value = await SharedPrefs().getMaxTime();
    setState(() {
      selectedTime = value.toDouble(); // Agora você atualiza o estado
    });
  }

  void _setFontWeight(double c) {
    setState(() {
      weight = c.toInt();
      widget.changeFontWeight(c.toInt());
    });
  }

  void _setTime(double value) {
    setState(() {
      selectedTime = value;
      widget.changeTime(value.toInt());
    });
  }

  void _setAnimate(bool value) {
    setState(() {
      animateBackground = value;
    });
    widget.changeAnimateBg(value);
  }

  void _setRomaji(bool value) {
    setState(() {
      romaji = value;
    });
    widget.changeRomaji(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 280, maxWidth: 320),
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Animated Background', //TODO
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: animateBackground,
                onChanged: (value) => _setAnimate(value),
              )
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Show Romaji', //TODO
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Switch(value: romaji, onChanged: (value) => _setRomaji(value)),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Font Weight', //TODO
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _setFontWeight(300),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 97, 76, 151),
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12.0),
                      side: weight == 300
                          ? BorderSide(color: Colors.white, width: 2)
                          : BorderSide.none,
                    ),
                    child: Text('300'),
                  ),
                  ElevatedButton(
                    onPressed: () => _setFontWeight(600),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 97, 76, 151),
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12.0),
                      side: weight == 600
                          ? BorderSide(color: Colors.white, width: 2)
                          : BorderSide.none,
                    ),
                    child: Text('600'),
                  ),
                  ElevatedButton(
                    onPressed: () => _setFontWeight(900),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 97, 76, 151),
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12.0),
                      side: weight == 900
                          ? BorderSide(color: Colors.white, width: 2)
                          : BorderSide.none,
                    ),
                    child: Text('900'),
                  ),
                ],
              )
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Max Time', //TODO
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: selectedTime,
                min: 10,
                max: 60,
                divisions: 5,
                label: '${selectedTime.toInt()}',
                onChanged: (value) => _setTime(value),
              )
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}
