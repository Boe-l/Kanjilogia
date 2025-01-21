import 'dart:async';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:kana_kit/kana_kit.dart';
import 'sharedpref.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class GameScreen extends StatefulWidget {
  // Recebe o jsonData como parâmetro no construtor do GameScreen
  final Map<String, dynamic> data;

  const GameScreen({super.key, required this.data});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, String>> _words = [];
  final List<String> _kanjisRespondidos = [];
  final List<Map<String, String>> correctItems = [];
  final List<Map<String, String>> errorItems = [];
  int _currentIndex = 0;
  int _score = 0;
  String _feedback = "";
  Timer? _timer;
  int _timeLeft = 60;
  bool _gameOver = false;
  Color _borderColor = Colors.blueAccent; // Cor inicial da borda
  final double _borderWidth = 6;
  double fontSizeCard = 32.0;
  int fontWeightCard = 100;
  
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    super.initState();
    _loadWords();

    _startTimer();
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
      // Recupera os dados passados para o widget
      final List<dynamic> finalJsonData = data['finalJsonData'] ?? [];

      _words = []; // Inicializa a lista de palavras

      // Itera pelos dados JSON para combinar as palavras com suas tags
      for (var item in finalJsonData) {
        if (item.word.isNotEmpty) {
          // Verifica se o item é do tipo Word
          // Cria um mapa para associar os valores e as tags
          var wordWithTags = <String, String>{
            'word': item.word,
            'reading': item.reading,
            'mean': item.mean ?? '', // Usa uma string vazia se mean for nulo
            'tags': item.tags
                .join(', '), // Converte a lista de tags para uma string
          };

          // Adiciona o mapa à lista de palavras
          _words.add(wordWithTags);
        }
      } //diànyǐng

      // Verifica se há palavras carregadas
      if (_words.isEmpty) {
        _feedback = AppLocalizations.of(context)!.gs_words_empty;
      } else {
        // Se existirem palavras, embaralha e remove duplicatas
        _words.shuffle(Random()); // Embaralha as palavras
        _words = _words
            .toSet()
            .toList(); // Remove duplicatas convertendo para Set e de volta para lista
        _currentIndex = 0; // Reseta o índice atual
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
      _feedback = "";

      // Recarrega as palavras
    });
    _loadWords(); // Recarrega e embaralha as palavras
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    SharedPrefs().getMaxTime().then((value) {
      setState(() {
        _timeLeft = value;
      });
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _processAnswer(""); // Timeout
      }
    });
  }

  void _processAnswer(String answer) {
    final localization = AppLocalizations.of(context);
    // Verifica se o jogo terminou
    if (_currentIndex >= _words.length || _gameOver) {
      return; // Evita processar respostas após o término do jogo
    }

    _timer?.cancel();
    final currentWord = _words[_currentIndex];

    // Divide as pronúncias em uma lista
    final List<String> possibleReadings =
        (currentWord["reading"] ?? "").split('；').map((e) => e.trim()).toList();

    final userAnswerInHiragana = kanaKit.toHiragana(answer.trim());
    bool isCorrect; // Declarar a variável fora do bloco if-else

    if (currentWord["tags"]!.contains('jp')) {
      isCorrect = possibleReadings.contains(userAnswerInHiragana);
    } else {
      isCorrect = possibleReadings.contains(answer.trim());
    } //diànyǐnɡ
    //diànyǐnɡ

    // Processa a resposta
    setState(() {
      if (isCorrect) {
        _score++;

        setState(() {
          _borderColor = Colors.green;
        });
        correctItems.add(currentWord);
      } else {
        errorItems.add(currentWord);
        _borderColor = Colors.redAccent;
      }
      _kanjisRespondidos.add(currentWord["word"] ?? "");
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _borderColor = Colors.blueAccent; // Reseta a cor da borda para azul
        });
      });

      // Verifica se é a última palavra
      if (_currentIndex >= _words.length - 1) {
        _gameOver = true; // Marca o jogo como finalizado
        _feedback = localization!.gs_game_ended1;
        _controller.text = '';
        Future.microtask(() {
          if (!mounted) return;
          _showGameOverDialog(context, _restartGame, () {
            Navigator.pop(context); // Voltar para o menu principal
          });
        });
      } else {
        _moveToNextWord();
      }
    });
  }

  void _showGameOverDialog(
      BuildContext context, VoidCallback onRestart, VoidCallback onMainMenu) {
        final localization = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible:
          false, // Impede que o diálogo seja fechado ao clicar fora
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localization!.gs_game_ended2(_score)),
          content: Text(localization.gs_game_ended3),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo de "Game Over"
                onRestart(); // Chama a função de reiniciar
              },
              child: Text(localization.gs_game_restart),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo de "Game Over"
                onMainMenu(); // Chama a função para ir ao menu principal
              },
              child: Text(localization.gs_go_main_menu),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo de "Game Over"
                _viewHistory(context,
                    true); // Chama o histórico imediatamente após fechar o diálogo
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
        _currentIndex++; // Avança para a próxima palavra
        _feedback = ""; // Limpa o feedback
      });

      _startTimer();
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
      _timer?.cancel(); // Cancela o timer quando o jogo termina
    }
  }

  void _viewHistory(BuildContext context, bool gameOver) {
    final localization = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // Função auxiliar para criar blocos de acertos/erros
        Widget buildSection(
          String title,
          List<Map<String, String>> items,
          Color color,
          Function(String) onCopyIndividual,
          Function() onCopyAll,
        ) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title == localization!.gs_history_correct
                    ? localization.gs_history_correct
                    : localization.gs_history_mistake,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              if (items.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: items.map((word) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    "${word['word']} - ${word['reading']} (${word['mean']})",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.copy, size: 20),
                                onPressed: () => onCopyIndividual(
                                    "${word['word']} - ${word['reading']} (${word['mean']})"),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onCopyAll,
                      icon: Icon(Icons.copy, size: 16),
                      label: Text(
                        title == localization.gs_history_correct
                            ? localization.gs_history_correct
                            : localization.gs_history_mistake,
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  ],
                )
              else
                Text(
                    localization.gs_score2(
                      title == localization.gs_history_correct
                          ? localization.gs_history_correct
                          : localization.gs_history_mistake,
                    ),
                    style:
                        TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            ],
          );
        }

        // Funções de cópia
        void copyToClipboard(String text, String message) {
          Clipboard.setData(ClipboardData(text: text));
          showToast(message,
              context: context,
              animation: StyledToastAnimation.scale,
              reverseAnimation: StyledToastAnimation.scale,
              animDuration: Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              reverseCurve: Curves.linear);
        }

        return AlertDialog(
          title: Center(
            child: Text(
              localization!.gs_history,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSection(
                  localization.gs_history_correct,
                  correctItems,
                  Colors.green,
                  (entry) => copyToClipboard(
                      entry, localization.gs_history_copy_single),
                  () {
                    final text = correctItems
                        .map((word) =>
                            "${word['word']} - ${word['reading']} (${word['mean']})")
                        .join("\n");
                    copyToClipboard(text,
                        localization.gs_history_copy_all_correct);
                  },
                ),
                SizedBox(height: 16),
                buildSection(
                  localization.gs_history_mistake,
                  errorItems,
                  Colors.red,
                  (entry) => copyToClipboard(
                      entry, localization.gs_history_copy_single),
                  () {
                    final text = errorItems
                        .map((word) =>
                            "${word['word']} - ${word['reading']} (${word['mean']})")
                        .join("\n");
                    copyToClipboard(text,
                        localization.gs_history_copy_all_mistake);
                  },
                ),
              ],
            ),
          ),
          actions: [
            if (!gameOver)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(localization.close, style: TextStyle(fontSize: 16)),
              ),
            if (gameOver)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showGameOverDialog(
                    context,
                    _restartGame,
                    _goToMainMenu,
                  );
                },
                child: Text(localization.go_back, style: TextStyle(fontSize: 16)),
              ),
          ],
        );
      },
    );
  }

  void _goToMainMenu() {
    Navigator.of(context)
        .pushReplacementNamed('/'); // Navega para o menu principal
  }

  void _adjustFontSize(double delta) async {
    setState(() {
      fontSizeCard =
          (fontSizeCard + delta).clamp(24.0, 64.0); // Limita entre 16 e 64
      SharedPrefs().saveCardFontSize(fontSizeCard);
    });
  }

  void toggleFontWeight() async {
    setState(() {
      // Incrementa o valor do fontWeight
      fontWeightCard += 300;

      // Se exceder 800, volta para 100
      if (fontWeightCard > 900) {
        fontWeightCard = 300;
      }
      SharedPrefs().saveCardFontWeight(fontWeightCard);
    });
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
          // Ajuste de tamanho da fonte via gestos de pinça no celular
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
                    // Conteúdo principal do jogo
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double screenWidth = constraints.maxWidth;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Corpo do jogo
                              ScrollConfiguration(
                                  behavior:
                                      ScrollConfiguration.of(context).copyWith(
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
                                          AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            width: screenWidth.clamp(100.0,
                                                230.0), // Limita o tamanho entre 100 e 230
                                            height: screenWidth.clamp(100.0,
                                                230.0), // Usa o mesmo limite que o width
                                            constraints: BoxConstraints(
                                              maxWidth: (fontSizeCard * 4).clamp(
                                                  136,
                                                  256), // Tamanho máximo do card
                                              maxHeight: (fontSizeCard * 4).clamp(
                                                  136,
                                                  256), // Altura máxima do card
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(90),
                                              border: Border.all(
                                                color: _borderColor,
                                                width: _borderWidth,
                                              ),
                                            ),
                                            child: GestureDetector(
                                              onTap: () => toggleFontWeight(),
                                              child: Listener(
                                                onPointerSignal: (event) {
                                                  if (event
                                                      is PointerScrollEvent) {
                                                    // Ajuste com base no scroll do mouse
                                                    _adjustFontSize(
                                                        event.scrollDelta.dy > 0
                                                            ? -2.0
                                                            : 2.0);
                                                  }
                                                },
                                                child: Card(
                                                  elevation: 4,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                      color:
                                                          const Color.fromARGB(
                                                              0, 180, 18, 18),
                                                      width: 0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            90),
                                                  ),
                                                  surfaceTintColor:
                                                      Color.fromARGB(
                                                          0, 0, 0, 0),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Center(
                                                        child: Text(
                                                      // Adiciona a quebra de linha automaticamente após 5 caracteres
                                                      (_words[_currentIndex][
                                                                          "word"] ??
                                                                      "")
                                                                  .length >
                                                              5
                                                          ? '${(_words[_currentIndex]["word"] ?? "").substring(0, 5)}\n${(_words[_currentIndex]["word"] ?? "").substring(5)}'
                                                          : (_words[_currentIndex]
                                                                  ["word"] ??
                                                              ""),
                                                      style: TextStyle(
                                                        fontSize: fontSizeCard /
                                                            (_words[_currentIndex]
                                                                        ["word"]
                                                                    ?.length ??
                                                                0) *
                                                            2,
                                                        fontWeight: FontWeight
                                                                .values[
                                                            fontWeightCard ~/
                                                                    100 -
                                                                1],
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        Text(
                                          _feedback,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.red,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  )),

                              // Controles de interação com o jogo
                              Stack(
                                children: [
                                  Column(
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
                                                        ? (correctItems.any((item) =>
                                                                    item[
                                                                        "word"] ==
                                                                    _kanjisRespondidos
                                                                        .last)
                                                                ? Colors
                                                                    .green // Kanji está em correctItems
                                                                : errorItems.any((item) =>
                                                                        item[
                                                                            "word"] ==
                                                                        _kanjisRespondidos
                                                                            .last)
                                                                    ? Colors
                                                                        .redAccent // Kanji está em errorItems
                                                                    : Colors
                                                                        .grey // Caso o kanji não esteja em nenhuma das duas listas
                                                            )
                                                        : Colors
                                                            .grey, // Caso _kanjisRespondidos esteja vazio

                                                    fontSize:
                                                        (screenWidth * 0.05)
                                                            .clamp(20.0, 21.0),
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "${_words.firstWhere((word) => word["word"] == _kanjisRespondidos.last, orElse: () => {
                                                        localization!.gs_mean: "N/A",
                                                        localization.gs_reading: "N/A"
                                                      })["mean"]} (${_words.firstWhere((word) => word["word"] == _kanjisRespondidos.last, orElse: () => {"reading": "N/A"})["reading"]})",
                                                  style: TextStyle(
                                                      fontSize:
                                                          (screenWidth * 0.05)
                                                              .clamp(5.0, 15.0),
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                          SizedBox(
                                            height:
                                                65, // Define uma altura fixa para o espaço do botão
                                            child: _kanjisRespondidos.isNotEmpty
                                                ? IconButton(
                                                    icon: Icon(
                                                      Icons.history,
                                                      color: Colors.blueAccent,
                                                    ),
                                                    onPressed: () =>
                                                        _viewHistory(
                                                            context, _gameOver),
                                                    tooltip:
                                                        localization!.gs_see_full_history,
                                                  )
                                                : null, // Deixa o espaço vazio, mas preservado
                                          ),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: TextField(
                                          autofocus: true,
                                          textInputAction: TextInputAction.none,
                                          controller: _controller,
                                          focusNode: _focusNode,
                                          onSubmitted: (value) =>
                                              _processAnswer(value),
                                          decoration: InputDecoration(
                                            labelText: localization!.gs_search_tooltip,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            prefixIcon: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Image.asset(
                                                _getFlagPath(_words[
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
                                                    30, // Definindo o tamanho da imagem
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
                                  // Outros widgets do Stack podem ser adicionados aqui
                                ],
                              )
                            ],
                          );
                        },
                      ),
                    ),

                    // Botões fixos no topo da tela
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
                                  context); // Voltar para a tela anterior
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

String _getFlagPath(String tags) {
  switch (tags.toLowerCase()) {
    case 'jp':
      return 'assets/flags/japan.png';
    case 'cn':
      return 'assets/flags/china.png';
    case 'pt':
      return 'assets/flags/brazil.png';
    case 'ko':
      return 'assets/flags/southkorea.png';
    case 'en':
      return 'assets/flags/usa.png';
    case 'es':
      return 'assets/flags/spain.png';
    default:
      return 'assets/flags/default.png';
  }
}
