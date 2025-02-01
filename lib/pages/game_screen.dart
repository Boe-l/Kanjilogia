import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:kana_kit/kana_kit.dart';
import 'package:kanjilogia/common/langstuff.dart';
import 'package:kanjilogia/pages/custom_widgets/gs_card.dart';
import 'package:kanjilogia/pages/history_page.dart';
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
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _words = [];
  final List<String> _kanjisRespondidos = [];
  final Map<String, List<String>> correctItems = {};
  final Map<String, List<String>> errorItems = {};
  int _currentIndex = 0;
  int _score = 0;
  Timer? _timer;
  int _timeLeft = 60;
  bool _gameOver = false;
  List<String> answers = [];
  String attemptsString = '';
  final GlobalKey<CustomCardState> _customCardKey =
      GlobalKey<CustomCardState>();
  double fontSizeCard = 32.0;
  int fontWeightCard = 100;
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    super.initState();
    _loadWords();

    startTimer();
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

      _words = []; 

      
      for (var item in finalJsonData) {
        if (item.word.isNotEmpty) {
          
          
          var wordWithTags = <String, String>{
            'filename': item.filename,
            'word': item.word,
            'reading': item.reading,
            'mean': item.mean ?? '', 
            'tags': item.tags
                .join(', '), 
          };

          
          _words.add(wordWithTags);
        }
      } 

      
      if (_words.isEmpty) {
        Debg().warning('Words is empty????');
      } else {
        
        _words.shuffle(Random()); 
        _words = _words
            .toSet()
            .toList(); 
        _currentIndex = 0; 
      }
    });
  }

  void _restartGame() {
    setState(() {
      _gameOver = false;
      _currentIndex = 0;
      _score = 0;
      errorItems.clear();
      correctItems.clear();
      _kanjisRespondidos.clear();
      _timer?.cancel();
      Debg().info('Game restarted');
    });
    _loadWords(); 
    startTimer();
  }

  void startTimer() {
    SharedPrefs().getMaxTime().then((value) {
      setState(() {
        _timeLeft = value;
      });
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _processAnswer(""); 
      }
    });
  }

  void _processAnswer(String answer) {
    
    if (_currentIndex >= _words.length || _gameOver) {
      return; 
    }

    final currentWord = _words[_currentIndex];

    
    final List<String> possibleReadings =
        (currentWord["reading"] ?? "").split('；').map((e) => e.trim()).toList();

    
    String normalizeInput(String input) {
      String processed = input.replaceAll('nn', 'n-');

      String converted = kanaKit.toHiragana(processed);

      return converted.replaceAll('ー', '');
    }

    
    
    final userAnswerNormalized = normalizeInput(answer.trim());
    bool isCorrect;

    void handleIncorrectAnswer() {
      _controller.clear();
      setState(() {
        _customCardKey.currentState?.triggerErrorAnimation();
      });

      

      Debg().info('Resposta errada, aguardando nova tentativa...');
    }

    if (currentWord["tags"]!.contains('jp')) {
      isCorrect = possibleReadings.contains(userAnswerNormalized);
    } else {
      isCorrect = possibleReadings.contains(answer.trim());
    }

    Debg().info('correct answers: $possibleReadings');
    Debg().info('User answer: $userAnswerNormalized');
    Debg().info('Answer is correct: $isCorrect');

    answers.add(answer);
    attemptsString = answers.join(", ");
    
    setState(() {
      
      if (_currentIndex >= _words.length - 1) {
        _gameOver = true; 
        _controller.text = '';
        Future.microtask(() {
          if (!mounted) return;
          _showGameOverDialog(context, _restartGame, () {
            Navigator.pop(context); 
          });
          Debg().info('Game over');
        });
      } else {
        if (isCorrect) {
          _score++;
          _timer?.cancel();
          setState(() {});

          correctItems[currentWord["word"]!] = [
            currentWord["reading"]!,
            currentWord["mean"]!,
            currentWord["tags"]!,
            currentWord["filename"]!,
            attemptsString.isNotEmpty ? attemptsString : answer
          ];
          _kanjisRespondidos.add(currentWord["word"] ?? "");
          answers.clear();
          _moveToNextWord();
        }
        if (!isCorrect && answer.isNotEmpty) handleIncorrectAnswer();
        if (answer.isEmpty) {
          errorItems[currentWord["word"]!] = [
            currentWord["reading"]!,
            currentWord["mean"]!,
            currentWord["tags"]!,
            currentWord["filename"]!,
            attemptsString.isNotEmpty ? attemptsString : answer
          ];
          _kanjisRespondidos.add(currentWord["word"] ?? "");
          _timer?.cancel();
          answers.clear();
          _moveToNextWord();
        }
      }
    });
  }

  void _showGameOverDialog(
      BuildContext context, VoidCallback onRestart, VoidCallback onMainMenu) {
    final localization = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localization!.gs_game_ended2(_score)),
          content: Text(localization.gs_game_ended3),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                onRestart(); 
              },
              child: Text(localization.gs_game_restart),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                onMainMenu(); 
              },
              child: Text(localization.gs_go_main_menu),
            ),
            TextButton(
              onPressed: () {
                navigateWithCircularAnimation(
                  context,
                  History(
                    correctItems: correctItems,
                    incorrectItems: errorItems,
                  ),
                );
                
                
                
              },
              child: Text(localization.gs_open_history),
            )
          ],
        );
      },
    );
  }

  void _moveToNextWord() {
    _controller.clear();

    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++; 
      });

      startTimer();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final localization = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(localization!.gs_game_ended1),
            content: Text(localization.gs_points(_score)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _restartGame();
                },
                child: Text(localization.gs_game_restart),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localization.close),
              ),
            ],
          );
        },
      );
      _timer?.cancel(); 
    }
  }

  void _adjustFontSize(double delta) async {
    setState(() {
      fontSizeCard =
          (fontSizeCard + delta).clamp(24.0, 128.0); 
      SharedPrefs().saveCardFontSize(fontSizeCard);
    });
    Debg().info('Changed "word" font size: $fontSizeCard');
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

  void pauseTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel(); 
    }
  }

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  
                                  ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context)
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
                                            if (_words.isNotEmpty)
                                              GestureDetector(
                                                onTap: () => toggleFontWeight(),
                                                child: Listener(
                                                  onPointerSignal: (event) {
                                                    if (event
                                                        is PointerScrollEvent) {
                                                      
                                                      _adjustFontSize(
                                                          event.scrollDelta.dy >
                                                                  0
                                                              ? -2.0
                                                              : 2.0);
                                                    }
                                                  },
                                                  child: CustomCard(
                                                    key: _customCardKey,
                                                    text: _words[_currentIndex]
                                                            ["word"] ??
                                                        '',
                                                    fontSize: fontSizeCard,
                                                    fontWeight: fontWeightCard,
                                                    style: CardStyle.minimal,
                                                  ),
                                                ),
                                              ),
                                            SizedBox(height: 10),
                                          ],
                                        ),
                                      )),

                                  
                                ],
                              ),
                              Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (_kanjisRespondidos.isNotEmpty)
                                            Expanded(
                                                child: ListTile(
                                              title: Text(
                                                _kanjisRespondidos.last,
                                                style: TextStyle(
                                                  color: _kanjisRespondidos
                                                          .isNotEmpty 
                                                      ? (correctItems.containsKey(
                                                                  _kanjisRespondidos
                                                                      .last) 
                                                              ? Colors
                                                                  .green 
                                                              : errorItems.containsKey(
                                                                      _kanjisRespondidos
                                                                          .last) 
                                                                  ? Colors
                                                                      .redAccent 
                                                                  : Colors
                                                                      .grey 
                                                          )
                                                      : Colors
                                                          .grey, 
                                                  fontSize: (screenWidth * 0.05)
                                                      .clamp(20.0,
                                                          21.0), 
                                                ),
                                              ),
                                              subtitle: Text(
                                                "${_words.firstWhere((word) => word["word"] == _kanjisRespondidos.last, orElse: () => {
                                                      localization!.gs_mean:
                                                          "N/A",
                                                      localization.gs_reading:
                                                          "N/A"
                                                    })["mean"]} (${_words.firstWhere((word) => word["word"] == _kanjisRespondidos.last, orElse: () => {"reading": "N/A"})["reading"]})",
                                                style: TextStyle(
                                                  fontSize: (screenWidth * 0.05)
                                                      .clamp(5.0, 15.0),
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )),
                                          SizedBox(
                                            height:
                                                65, 
                                            child: _kanjisRespondidos.isNotEmpty
                                                ? IconButton(
                                                    icon: Icon(
                                                      Icons.history,
                                                      color: Colors.blueAccent,
                                                    ),
                                                    onPressed: () {
                                                      pauseTimer();
                                                      navigateWithCircularAnimation(
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
                                          textInputAction: TextInputAction
                                              .none, 
                                          controller: _controller,
                                          onSubmitted: (value) {
                                            _processAnswer(value);
                                          },
                                          decoration: InputDecoration(
                                            labelText:
                                                localization!.gs_search_tooltip,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            prefixIcon: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Image.asset(
                                                LocaleUtils.getFlagPath(_words[
                                                                _currentIndex]
                                                            .isNotEmpty &&
                                                        _words[_currentIndex]
                                                                ['tags'] !=
                                                            null
                                                    ? _words[_currentIndex]
                                                            ['tags']!
                                                        .split(',')[0]
                                                    : ''),
                                                width:
                                                    30, 
                                                height: 30,
                                              ),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(Icons.send,
                                                  color: Colors.blueAccent),
                                              onPressed: () => _processAnswer(
                                                  _controller.text),
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
                              Navigator.pop(
                                  context); 
                            },
                          ),
                          Text(
                            localization!.gs_points(_score),
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: _restartGame,
                            icon: Icon(Icons.restart_alt,
                                color: Colors.blueAccent),
                            tooltip: localization.gs_game_restart2,
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              "$_timeLeft",
                              style: TextStyle(
                                fontSize: fontSize * 1.4,
                                fontWeight: FontWeight.bold,
                                color: _timeLeft <= 5 && _timeLeft % 2 == 0
                                    ? Colors.red
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
