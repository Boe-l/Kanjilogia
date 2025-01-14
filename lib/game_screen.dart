import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:kana_kit/kana_kit.dart';
class GameScreen extends StatefulWidget {
  // Recebe o jsonData como parâmetro no construtor do GameScreen
  final Map<String, dynamic> data;

  const GameScreen({super.key, required this.data});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
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
  int _timeLeft = 10;
  bool _gameOver = false;
  Color _borderColor = Colors.blueAccent; // Cor inicial da borda
  final double _borderWidth = 6;
  @override
  void initState() {
    super.initState();
    _loadWords();
    _focusInput();
  }
  static const kanaKit = KanaKit();
  void _focusInput() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (!_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  void _loadWords() {
  final Map<String, dynamic> data = widget.data;

  setState(() {
    final List<dynamic> finalJsonData = data['finalJsonData'] ?? [];

    // Combina todos os mapas em um único mapa (mesclando as palavras de todos os arquivos)
    _words = [];

    for (var item in finalJsonData) {
      if (item is Map<String, dynamic> && item.containsKey('words')) {
        // Recupera as tags associadas ao arquivo
        List<dynamic> tags = item['tags'] ?? [];

        // Aqui fazemos um cast de cada palavra para Map<String, String> e associamos com as tags
        List<dynamic> wordsList = item['words'] ?? [];
        for (var wordItem in wordsList) {
          if (wordItem is Map<String, dynamic>) {
            // Convertendo os valores para Map<String, String> e adicionando as tags
            var wordWithTags = Map<String, String>.from(wordItem);
            wordWithTags['tags'] = tags.join(', ');  // Adiciona as tags como uma string concatenada

            // Adiciona a palavra com as tags
            _words.add(wordWithTags);
          }
        }
      }
    }

    // Embaralhar as palavras
    _words.shuffle(Random());

    // Remover duplicatas
    _words = _words.toSet().toList();

    // Resetar o índice
    _currentIndex = 0;
  });

  if (_words.isEmpty) {
    setState(() {
      _feedback = "Nenhuma palavra disponível!";
    });
  } else {
    _startTimer();
  }
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
    _focusInput();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timeLeft = widget.data['selectedTime']);
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
  // Verifica se o jogo terminou
  if (_currentIndex >= _words.length || _gameOver) {
    return; // Evita processar respostas após o término do jogo
  }

  _timer?.cancel();
  final currentWord = _words[_currentIndex];

  // Divide as pronúncias em uma lista
  final List<String> possibleReadings =
      (currentWord["reading"] ?? "").split('~').map((e) => e.trim()).toList();


    final userAnswerInHiragana = kanaKit.toHiragana(answer.trim());
    bool isCorrect; // Declarar a variável fora do bloco if-else

    if (currentWord["tags"]!.contains('japanese') && !currentWord["tags"]!.contains('hiragana')) {
      isCorrect = possibleReadings.contains(userAnswerInHiragana);
    } else {
      isCorrect = possibleReadings.contains(answer.trim());
    }

  

  // Processa a resposta
  setState(() {
    if (isCorrect) {
      _score++;
      _borderColor = Colors.green;
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
      _feedback = "Jogo Finalizado!";
      _controller.text = '';
      Future.microtask(() {
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
    showDialog(
      context: context,
      barrierDismissible:
          false, // Impede que o diálogo seja fechado ao clicar fora
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Jogo Finalizado    \n$_score pontos"),
          content:
              Text("Parabéns por concluir o jogo! O que deseja fazer agora?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo de "Game Over"
                onRestart(); // Chama a função de reiniciar
              },
              child: Text("Reiniciar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo de "Game Over"
                onMainMenu(); // Chama a função para ir ao menu principal
              },
              child: Text("Voltar ao Menu Principal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo de "Game Over"
                _viewHistory(context,
                    true); // Chama o histórico imediatamente após fechar o diálogo
              },
              child: Text("Ver Historico"),
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
      _focusInput();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Jogo Finalizado!"),
            content: Text("Você marcou $_score pontos."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _restartGame();
                },
                child: Text("Reiniciar"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Fechar"),
              ),
            ],
          );
        },
      );
      _timer?.cancel(); // Cancela o timer quando o jogo termina
    }
  }

  void _viewHistory(BuildContext context, bool gameOver) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
              Text(title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 8),
              if (items.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
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
                        "Copiar todos $title",
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  ],
                )
              else
                Text("Nenhum $title registrado.",
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
              "Histórico de Respostas",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSection(
                  "Acertos",
                  correctItems,
                  Colors.green,
                  (entry) => copyToClipboard(
                      entry, "Entrada copiada para a área de transferência!"),
                  () {
                    final text = correctItems
                        .map((word) =>
                            "${word['word']} - ${word['reading']} (${word['mean']})")
                        .join("\n");
                    copyToClipboard(text,
                        "Todos os acertos copiados para a área de transferência!");
                  },
                ),
                SizedBox(height: 16),
                buildSection(
                  "Erros",
                  errorItems,
                  Colors.red,
                  (entry) => copyToClipboard(
                      entry, "Entrada copiada para a área de transferência!"),
                  () {
                    final text = errorItems
                        .map((word) =>
                            "${word['word']} - ${word['reading']} (${word['mean']})")
                        .join("\n");
                    copyToClipboard(text,
                        "Todos os erros copiados para a área de transferência!");
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
                child: Text("Fechar", style: TextStyle(fontSize: 16)),
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
                child: Text("Voltar", style: TextStyle(fontSize: 16)),
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

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width * 0.06;
    fontSize = fontSize.clamp(16.0, 30.0);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Evitar que o teclado perca o foco ao tocar fora do campo de texto
          FocusScope.of(context).requestFocus(FocusNode());
        },
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
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.touch,
                            },
                            scrollbars: false,
                          ),
                          child: SingleChildScrollView(
                            reverse: true,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_words.isNotEmpty)
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    width: screenWidth.clamp(100.0,
                                        230.0), // Limita o tamanho entre 100 e 230
                                    height: screenWidth.clamp(100.0,
                                        230.0), // Usa o mesmo limite que o width
                                    constraints: BoxConstraints(
                                      maxWidth: screenWidth *
                                          0.4, // Tamanho máximo do card
                                      maxHeight: screenWidth *
                                          0.4, // Altura máxima do card
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(90),
                                      border: Border.all(
                                        color: _borderColor,
                                        width: _borderWidth,
                                      ),
                                    ),
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: const Color.fromARGB(
                                              0, 180, 18, 18),
                                          width: 0,
                                        ),
                                        borderRadius: BorderRadius.circular(90),
                                      ),
                                      surfaceTintColor:
                                          Color.fromARGB(0, 0, 0, 0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Text(
                                            _words[_currentIndex]["word"] ??
                                                "",
                                            style: TextStyle(
                                              fontSize: (screenWidth * 0.15)
                                                      .clamp(24.0, 64.0) /
                                                  (_words[_currentIndex]
                                                              ["word"]
                                                          ?.length ??
                                                      1),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
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
                              ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: screenWidth * 0.8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (_kanjisRespondidos.isNotEmpty)
                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            _kanjisRespondidos.last,
                                            style: TextStyle(
                                              color: errorItems.any((error) =>
                                                      error["word"] ==
                                                      _kanjisRespondidos.last)
                                                  ? Colors.redAccent
                                                  : Colors.green,
                                            fontSize: (screenWidth * 0.05).clamp(20.0, 40.0),),
                                          ),
                                          subtitle: Text(
                                            "${_words.firstWhere((word) => word["word"] == _kanjisRespondidos.last, orElse: () => {
                                                  "significado": "N/A",
                                                  "leitura": "N/A"
                                                })["mean"]} (${_words.firstWhere((word) => word["word"] == _kanjisRespondidos.last, orElse: () => {"reading": "N/A"})["reading"]})",
                                            style: TextStyle(
                                                fontSize: (screenWidth * 0.05).clamp(5.0, 15.0),
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
                                              onPressed: () => _viewHistory(
                                                  context, _gameOver),
                                              tooltip: 'Ver Histórico Completo',
                                            )
                                          : null, // Deixa o espaço vazio, mas preservado
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth: screenWidth * 0.8),
                                  child: TextField(
                                    autofocus: true,
                                    textInputAction: TextInputAction.none,
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    onSubmitted: (value) =>
                                        _processAnswer(value),
                                    decoration: InputDecoration(
                                      labelText: 'Escreva a leitura',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.send,
                                            color: Colors.blueAccent),
                                        onPressed: () =>
                                            _processAnswer(_controller.text),
                                      ),
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
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context); // Voltar para a tela anterior
                    },
                  ),
                  Text(
                    "$_score Pontos",
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _restartGame,
                    icon: Icon(Icons.restart_alt, color: Colors.blueAccent),
                    tooltip: 'Reiniciar Jogo',
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
    );
  }
}
