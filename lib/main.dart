import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'game_screen.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor:
          const Color.fromARGB(0, 0, 0, 0), // Cor transparente para ver o fundo
      statusBarIconBrightness:
          Brightness.dark, // Ícones escuros para Status Bar clara
    ),
  );
  runApp(Kanjilogia());
}

class PreferencesService {
  static const String _tutorialCompleteKey = 'tutorial_complete';
  static const String _maxTimeKey = 'max_time';

  /// Save the tutorial completion status
  Future<void> saveTutorialComplete(bool isComplete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompleteKey, isComplete);
  }

  /// Save the selected maximum time
  Future<void> saveMaxTime(int maxTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_maxTimeKey, maxTime);
  }

  /// Get the tutorial completion status
  Future<bool> isTutorialComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompleteKey) ?? false;
  }

  /// Get the saved maximum time
  Future<int> getMaxTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_maxTimeKey) ?? 29;
  }
}

class Kanjilogia extends StatelessWidget {
  const Kanjilogia({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MainMenu(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  List<String> _jsonFiles = [];
  List<String> _filteredJsonFiles = [];
  final List<String> _selectedFiles = [];
  final TextEditingController _searchController = TextEditingController();
  late int selectedTime = 30;
  late AnimationController _backgroundController;
  late Animation<Color?> _colorAnimation;
  final preferencesService = PreferencesService();

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
  // Branco puro

  @override
  void initState() {
    super.initState();
    _loadJsonFiles();
    _searchController.addListener(_filterJsonFiles);
    preferencesService.getMaxTime().then((time) {
      setState(() {
        selectedTime = time;
      });
    });
    // Configurando animação de fundo
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 56, 16, 115),
      end: const Color.fromARGB(255, 56, 16, 115),
    ).animate(_backgroundController);

    targets.add(TargetFocus(identify: "1", keyTarget: grid3, contents: [
      TargetContent(
          align: ContentAlign.bottom,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Como jogar.",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Selecione um ou mais items para jogar.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ))
    ]));
    targets.add(TargetFocus(identify: "2", keyTarget: playButtonKey, contents: [
      TargetContent(
          align: ContentAlign.top,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Começar jogo.",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Depois de selecionar os items para jogar, clique aqui para iniciar o jogo.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ))
    ]));
    targets.add(TargetFocus(identify: "3", keyTarget: settingsKey, contents: [
      TargetContent(
          align: ContentAlign.top,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Configurações do jogo.",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Clique aqui para alterar configurações como o tempo de resposta das perguntas.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ))
    ]));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(seconds: 2));
      bool isComplete = await preferencesService.isTutorialComplete();
      if (isComplete == false) {
        showTutorial();
      }
      await preferencesService.saveTutorialComplete(true);
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
    super.dispose();
  }

  Future<void> _loadJsonFiles() async {
    try {
      // Carregar o AssetManifest usando a nova API
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);

      // Filtrar os arquivos JSON da pasta 'assets/json'
      final jsonFiles = assetManifest
          .listAssets()
          .where((path) =>
              path.startsWith('assets/json/') && path.endsWith('.json'))
          .toList();

      setState(() {
        _jsonFiles = jsonFiles;
        _filteredJsonFiles = jsonFiles;
      });
    } catch (e) {
      // Tratar erros, se necessário
    }
  }

  void _filterJsonFiles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredJsonFiles = _jsonFiles
          .where((file) => file.split('/').last.toLowerCase().contains(query))
          .toList();
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
  } //Kanjilogia

  void _startGame(BuildContext context, selectedTime) async {
    if (_selectedFiles.isEmpty) {
      _showErrorDialog("Selecione ao menos um item para jogar.");
      return;
    }

    try {
      List<dynamic> finalJsonData =
          []; // Lista que vai armazenar os dados combinados

      // Iterar pelos arquivos selecionados
      for (String file in _selectedFiles) {
        final fileContents =
            await rootBundle.loadString(file); // Carregar conteúdo do arquivo
        final Map<String, dynamic> jsonData =
            json.decode(fileContents); // Decodificar o JSON como um mapa

        // Adicionar os valores do mapa na lista finalJsonData
        finalJsonData
            .add(jsonData); // Adiciona o objeto inteiro como um item na lista
      }

      // Preparando os dados para serem enviados para a próxima tela
      final data = {
        'selectedTime': selectedTime,
        'finalJsonData': finalJsonData,
      };

      // Navegar para a próxima tela passando os dados
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(data: data),
        ),
      );

      // Limpar a lista de arquivos selecionados
      _selectedFiles.clear();
    } catch (e) {
      // Em caso de erro, exibe uma mensagem de erro
      _showErrorDialog("Erro ao carregar os arquivos JSON: $e");
    }
  }

  void _showErrorDialog(String message) {
    showToast(
      message,
      context: context,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.scale,
      animDuration: Duration(milliseconds: 600),
      duration: Duration(seconds: 2), // Tempo para exibição
      position: StyledToastPosition.center, // Centraliza na tela
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
      backgroundColor: Colors.red.withOpacity(0.8), // Cor do fundo (opcional)
      textStyle: TextStyle(
          color: Colors.white, fontSize: 16), // Estilo do texto (opcional)
    );
  }

  Future<void> _settings(BuildContext context) async {
    // Tempo padrão inicial

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.5,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configurações',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Tempo máximo de resposta:',
                  style: TextStyle(fontSize: 16),
                ),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      children: [
                        Slider(
                          value: selectedTime.toDouble(),
                          min: 10,
                          max: 50,
                          divisions: 4, // Intervalo de 10 segundos
                          label: "$selectedTime segundos",
                          onChanged: (double value) {
                            setState(() {
                              selectedTime = value.toInt();
                            });
                            preferencesService.saveMaxTime(selectedTime);
                          },
                        ),
                        Text('$selectedTime segundos'),
                      ],
                    );
                  },
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancelar'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(selectedTime);
                      },
                      child: Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        // Use o tempo escolhido conforme necessário
      }
    });
  }

  void showTutorial() {
    TutorialCoachMark(
      targets: targets, // List<TargetFocus>
      colorShadow: Colors.red, // DEFAULT Colors.black
      // alignSkip: Alignment.bottomRight,
      // textSkip: "SKIP",
      // paddingFocus: 10,
      // opacityShadow: 0.8,
      onClickTarget: (target) {},
      onClickTargetWithTapPosition: (target, tapDetails) {},
      onClickOverlay: (target) {},
      onSkip: () {
        return true;
      },
      onFinish: () {},
    ).show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: AnimatedBuilder(
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
                              hintText: "Buscar...",
                              hintStyle: TextStyle(color: Colors.white),
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.white),
                              filled: false, // Para o fundo preenchido
                              fillColor: Colors.grey[800], // Cor do fundo

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    30), // Borda arredondada
                                borderSide: BorderSide(
                                    color: Colors.blue,
                                    width: 2), // Cor e largura da borda
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    30), // Borda arredondada
                                borderSide: BorderSide(
                                    color: Colors.blue,
                                    width:
                                        4), // Cor e largura da borda ao focar
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: _filteredJsonFiles.isEmpty
                              ? Center(
                                  child: Text(
                                    'Nenhum arquivo JSON encontrado.',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                )
                              : AnimationLimiter(
                                  child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context)
                                        .copyWith(
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
                                          final fileName =
                                              _filteredJsonFiles[index];
                                          final alias = fileName
                                              .split('/')
                                              .last
                                              .replaceAll('.json', '');
                                          final isSelected =
                                              _selectedFiles.contains(fileName);
                                          return MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: AnimationConfiguration
                                                .staggeredGrid(
                                              position: index,
                                              columnCount:
                                                  screenWidth < 320 ? 2 : 3,
                                              duration:
                                                  Duration(milliseconds: 600),
                                              child: SlideAnimation(
                                                curve: Curves.decelerate,
                                                verticalOffset: 250,
                                                child: FadeInAnimation(
                                                  duration: Duration(
                                                      milliseconds: 1000),
                                                  child: FutureBuilder<String>(
                                                    key: index == 2
                                                        ? grid3
                                                        : null,
                                                    future: rootBundle.loadString(
                                                        fileName), // Carregar JSON
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const Center(
                                                            child:
                                                                CircularProgressIndicator());
                                                      }

                                                      if (snapshot.hasError) {
                                                        // Não faz nada se houver erro
                                                        return SizedBox
                                                            .shrink(); // Retorna um widget vazio
                                                      } else if (!snapshot
                                                          .hasData) {
                                                        // Também não faz nada se não houver dados
                                                        return SizedBox
                                                            .shrink(); // Retorna um widget vazio
                                                      }

                                                      // Decodificar o JSON
                                                      final fileData = json
                                                          .decode(snapshot
                                                              .data!) as Map<
                                                          String, dynamic>;
                                                      final tags = fileData[
                                                                  'tags']
                                                              as List<
                                                                  dynamic>? ??
                                                          [];
                                                      final language =
                                                          tags.isNotEmpty
                                                              ? tags[0]
                                                              : 'unknown';

                                                      // Obter o caminho da bandeira
                                                      final flagAssetPath =
                                                          _getFlagAssetPath(
                                                              language);

                                                      // Calcular o tamanho ideal para a bandeira
                                                      final screenSize =
                                                          MediaQuery.of(context)
                                                              .size;
                                                      final flagSize = (screenSize
                                                                  .shortestSide *
                                                              0.12)
                                                          .clamp(36.0, 72.0);

                                                      return AnimationConfiguration
                                                          .staggeredGrid(
                                                        position: index,
                                                        columnCount:
                                                            _filteredJsonFiles
                                                                .length,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                        child: SlideAnimation(
                                                          verticalOffset: 50,
                                                          child:
                                                              FadeInAnimation(
                                                            delay:
                                                                const Duration(
                                                                    milliseconds:
                                                                        150),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () =>
                                                                  _toggleSelection(
                                                                      fileName),
                                                              child:
                                                                  AnimatedContainer(
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            250),
                                                                curve: Curves
                                                                    .easeInOutQuint,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.2),
                                                                      spreadRadius:
                                                                          2,
                                                                      blurRadius:
                                                                          10,
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              3),
                                                                    ),
                                                                  ],
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors:
                                                                        isSelected
                                                                            ? [
                                                                                const Color.fromARGB(255, 80, 36, 133).withOpacity(0.4),
                                                                                const Color.fromARGB(255, 80, 36, 133).withOpacity(0.1),
                                                                              ]
                                                                            : [
                                                                                const Color.fromARGB(255, 80, 36, 133),
                                                                                const Color.fromARGB(255, 80, 36, 133).withOpacity(0.4),
                                                                              ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                  ),
                                                                  border: Border.all(
                                                                      color: isSelected
                                                                          ? const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              47,
                                                                              3,
                                                                              68)
                                                                          : const Color.fromARGB(255, 159, 7, 219).withAlpha(
                                                                              0),
                                                                      width: isSelected
                                                                          ? 3
                                                                          : 1),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Image.asset(
                                                                      flagAssetPath,
                                                                      width:
                                                                          flagSize, // Tamanho dinâmico da largura
                                                                      height:
                                                                          flagSize, // Tamanho dinâmico da altura
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            8), // Espaçamento entre a bandeira e o texto
                                                                    Text(
                                                                      alias,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: isSelected
                                                                            ? const Color.fromARGB(
                                                                                255,
                                                                                255,
                                                                                255,
                                                                                255)
                                                                            : Colors.white.withAlpha(255),
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        shadows: [
                                                                          Shadow(
                                                                              color: Colors.blueAccent,
                                                                              blurRadius: 10),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
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
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: AnimatedOpacity(
                opacity: _showFloatingButtons ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring:
                      !_showFloatingButtons, // Ignora interações quando invisível
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botão de configurações à esquerda
                      FloatingActionButton(
                        key: settingsKey,
                        heroTag: 'settings',
                        onPressed: () {
                          // Ação do botão de configurações
                          _settings(context);
                        },
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.settings),
                      ),
                      SizedBox(
                        width: screenWidth * 0.186, // Espaço entre os botões
                      ),
                      // Botão de "Iniciar Jogo" com ícone de play
                      FloatingActionButton(
                        key: playButtonKey,
                        heroTag: 'play',
                        onPressed: () => _startGame(context, selectedTime),
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.play_arrow),
                      ),
                    ],
                  ),
                ),
              ));
        },
      ),
    );
  }
}

String _getFlagAssetPath(String language) {
  switch (language.toLowerCase()) {
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
      return 'assets/flags/default.png'; // Bandeira padrão
  }
}
