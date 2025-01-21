import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'game_screen.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'sharedpref.dart';
import 'makehive.dart';
import 'managepage.dart';
import 'l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(Kanjilogia(key: kanjilogiaKey));
}

final GlobalKey<KanjilogiaState> kanjilogiaKey = GlobalKey<KanjilogiaState>();

class Kanjilogia extends StatefulWidget {
  const Kanjilogia({Key? key}) : super(key: key);

  @override
  KanjilogiaState createState() => KanjilogiaState();
}

class KanjilogiaState extends State<Kanjilogia> {
  Locale _locale = Locale('en'); // Locale inicial

  void changeLanguage([Locale? locale]) async {
    // Verifica se o 'locale' é nulo. Caso seja, busca nos SharedPreferences.
    locale ??= await SharedPrefs().getLocale();

    // Salva o locale nos SharedPreferences, se fornecido explicitamente.
    if (locale != null) {
      await SharedPrefs().saveLocale(locale);
    }
    // Atualiza o estado com o novo 'locale'.
    setState(() {
      _locale = locale!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanjilogia - 漢字ロギア',
      theme: ThemeData.dark(),
      home: MainMenu(changeLanguage: changeLanguage),
      debugShowCheckedModeBanner: false,
      supportedLocales: L10n.all,
      locale: _locale, // Usando o _locale atualizado
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
  const MainMenu({super.key, required this.changeLanguage});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  Map<String, Set<String>> _jsonFiles =
      {}; // Para armazenar filenames e suas tags
  Map<String, Set<String>> _filteredJsonFiles = {};
  final List<String> _selectedFiles = [];
  final TextEditingController _searchController = TextEditingController();
  late int selectedTime = 30;
  late AnimationController _backgroundController;
  late Animation<Color?> _colorAnimation;

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
    widget.changeLanguage();
    SharedPrefs().getMaxTime().then((time) {
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

    // Usando addPostFrameCallback para garantir que o contexto estará disponível
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Agora podemos usar o contexto com segurança
      targets.add(TargetFocus(identify: "1", keyTarget: grid3, contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Container(
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
        ),
      ]));

      targets
          .add(TargetFocus(identify: "2", keyTarget: playButtonKey, contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Container(
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
        ),
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
        ),
      ]));

      // Verificar o tutorial e exibir conforme necessário
      Future.delayed(Duration(seconds: 2), () async {
        bool isComplete = await SharedPrefs().isTutorialComplete();
        if (isComplete == false) {
          showTutorial();
        }
        await SharedPrefs().saveTutorialComplete(true);
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
    super.dispose();
  }

  // Variáveis para armazenar chaves e tags separadas

  Future<void> _loadJsonFiles() async {
    try {
      // Obtendo os dados com os filenames e tags
      final jsonFiles = await listFilenamesWithTags();

      // Preenchendo as listas com os dados obtidos

      setState(() {
        // Aqui estamos atualizando a interface com as listas de dados
        _jsonFiles = jsonFiles;
        _filteredJsonFiles = jsonFiles;
      });
    } catch (e) {
      // Tratar erros
      print('Erro ao carregar arquivos JSON: $e');
    }
  }

  void _filterJsonFiles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      // Filtrando o mapa de _jsonFiles com base no filename
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
  } //Kanjilogia

  void _startGame(BuildContext context, selectedTime) async {
    if (_selectedFiles.isEmpty) {
      _showErrorDialog(AppLocalizations.of(context)!.dialogue1);
      return;
    }

    try {
      // Chamar a função getWordsByFilenames com os arquivos selecionados
      List<String> selectedFilesList =
          _selectedFiles; // Ou qualquer outro critério para os nomes de arquivos
      List<dynamic> finalWords = await getWordsByFilenames(selectedFilesList);

      if (finalWords.isEmpty) {
        _showErrorDialog(AppLocalizations.of(context)!.gs_words_empty);
        return;
      }

      // Preparando os dados para serem enviados para a próxima tela
      final data = {
        'selectedTime': selectedTime,
        'finalJsonData': finalWords, // Dados das palavras retornadas
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
      _showErrorDialog("${AppLocalizations.of(context)!.tutorial1} $e");
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

  void showTutorial() {
    TutorialCoachMark(
      targets: targets, // List<TargetFocus>
      colorShadow: Colors.red, // DEFAULT Colors.black
      // alignSkip: Alignment.bottomRight,
      textSkip: AppLocalizations.of(context)!.tutorial_skip,
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
      top: false,
      child: Main(screenWidth),
    );
  }

  AnimatedBuilder Main(double screenWidth) {
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
                              borderRadius: BorderRadius.circular(
                                  20), // Borda arredondada
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 109, 33, 223),
                                  width: 2), // Cor e largura da borda ao focar
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
                                                              .withOpacity(0.2),
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
                                                                    .withOpacity(
                                                                        0.4),
                                                                const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        80,
                                                                        36,
                                                                        133)
                                                                    .withOpacity(
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
                                                                    .withOpacity(
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
                                                        Spacer(
                                                            flex:
                                                                1), // Faz a bandeira não ficar tão próxima do topo

                                                        Expanded(
                                                          flex: 5,
                                                          child: Image.asset(
                                                            _getFlagAssetPath(
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
                        //_settings(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManagerPage()),
                        ).then((_) {
                          _loadJsonFiles();
                        });
                      },
                      backgroundColor: const Color(0xFF6C5CE7),
                      child: Icon(Icons.settings),
                    ),
                    SizedBox(
                      width: screenWidth * 0.186, // Espaço entre os botões
                    ),
                    FloatingActionButton(
                      key: playButtonKey,
                      heroTag: 'play',
                      onPressed: () => _startGame(context, selectedTime),
                      backgroundColor: Color(0xFF6C5CE7),
                      child: Icon(Icons.play_arrow),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}

String _getFlagAssetPath(String language) {
  switch (language.toLowerCase()) {
    case 'jp':
        return 'assets/flags/japan.png';
      case 'ja':
        return 'assets/flags/japan.png';
      case 'cn':
        return 'assets/flags/china.png';
      case 'zh':
        return 'assets/flags/china.png';
      case 'pt':
        return 'assets/flags/brazil.png';
      case 'ko':
        return 'assets/flags/southkorea.png';
      case 'en':
        return 'assets/flags/usa.png';
      case 'es':
        return 'assets/flags/spain.png';
      case 'ar':
        return 'assets/flags/uae.png';
      case 'bn':
        return 'assets/flags/bangladesh.png';
      case 'de':
        return 'assets/flags/germany.png';
      case 'fr':
        return 'assets/flags/france.png';
      case 'it':
        return 'assets/flags/italy.png';
      case 'ru':
        return 'assets/flags/russia.png';
      case 'tr':
        return 'assets/flags/turkey.png';
      default:
        return 'assets/flags/default.png';
  }
}
