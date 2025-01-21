import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:rxdart/rxdart.dart';
import 'makehive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/services.dart';
import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'sharedpref.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'main.dart';

class ManagerPage extends StatefulWidget {
  const ManagerPage({super.key});

  @override
  ManagerPageState createState() => ManagerPageState();
}

class ManagerPageState extends State<ManagerPage>
    with SingleTickerProviderStateMixin {
  final List<String> _filenames = [];
  final List<Set<String>> _tags = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late AnimationController _animationController;
  int _maxTime = 60;
  final ValueNotifier<int> selectedTimeNotifier = ValueNotifier<int>(30);
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButtons = true;
  final Map<String, int> _wordCounts = {};
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<AnimatedFloatingActionButtonState> key =
      GlobalKey<AnimatedFloatingActionButtonState>();
  TextEditingController urlController = TextEditingController();
  final SharedPrefs _sharedPrefs = SharedPrefs();
  List<Map<String, dynamic>> _files = [];
  Map<String, Map<String, dynamic>> fileData = {};
  final BehaviorSubject<int> counterSubject = BehaviorSubject<int>.seeded(0);

  // bool _isTutorialComplete = false;
  Slider? slider;
  @override
  @override
  void initState() {
    super.initState(); 
    // Carregando dados iniciais
    _loadInitialData();

    // Configurando a barra de status
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    // Carregando os arquivos
    _loadFilenames();

    // Inicializando o controlador de animação
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Adicionando listener de rolagem
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

    // Usando addPostFrameCallback para garantir que as dependências do contexto sejam acessadas após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Aqui você pode chamar qualquer coisa que depende do BuildContext, como AppLocalizations
      // Exemplo:
      // String tutorialText = AppLocalizations.of(context)!.tutorial1;
      updateslider();
    });
  }

  void _onLanguageSelected(Locale locale) async {
    // Salva o idioma selecionado em SharedPreferences
    await SharedPrefs().saveLocale(locale);
    setState(() {
      kanjilogiaKey.currentState?.changeLanguage(locale);
    });
  }

  Future<void> showLanguageSelector(
    BuildContext context,
    List<Locale> supportedLocales,
    Function(Locale) onLanguageSelected,
  ) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.center, // Centraliza o conteúdo
          child: SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: 600), // Largura máxima ajustada para 550
              child: Dialog(
                backgroundColor: const Color.fromARGB(255, 56, 16, 115),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch,
                    },
                    scrollbars: false,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: supportedLocales.length,
                    itemBuilder: (context, index) {
                      final locale = supportedLocales[index];
                      final languageName =
                          _getLanguageName(locale); // Nome do idioma
                      final flag =
                          _getFlagPath(locale.toString()); // Emoji da bandeira

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: Material(
                          color: const Color.fromARGB(255, 74, 32, 126),
                          borderRadius: BorderRadius.circular(16),
                          elevation: 5, // Efeito de "floating"
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              onLanguageSelected(
                                  locale); // Chama a função ao selecionar
                              Navigator.of(context).pop(); // Fecha o popup
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Row(
                                children: [
                                  Image.asset(
                                    flag,
                                    width:
                                        30, // Ajusta o tamanho da imagem da bandeira
                                    height:
                                        30, // Ajusta a altura da imagem da bandeira
                                    fit: BoxFit
                                        .cover, // Garante que a imagem se ajuste ao espaço
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    languageName,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
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
        );
      },
    );
  }

  Future<void> _loadInitialData() async {
    // Carrega o status do tutorial, tempo máximo e arquivos
    // final tutorialComplete = await _sharedPrefs.isTutorialComplete();
    _maxTime = await _sharedPrefs.getMaxTime();
    final files = await _sharedPrefs.getFiles();
    slider = updateslider();
    setState(() {
      // _isTutorialComplete = tutorialComplete;

      _files = files;
    });
  }

  // Future<void> _toggleTutorialComplete() async {
  //   setState(() {
  //     _isTutorialComplete = !_isTutorialComplete;
  //   });
  //   await _sharedPrefs.saveTutorialComplete(_isTutorialComplete);
  // }

  Future<void> _updateMaxTime(int newMaxTime) async {
    setState(() {
      _maxTime = newMaxTime;
    });
    await _sharedPrefs.saveMaxTime(newMaxTime);
  }

  updateslider() {
    return Slider(
      value: _maxTime.toDouble(),
      min: 10,
      max: 60,
      divisions: 5,
      label: AppLocalizations.of(context)!.mp_slider_text(_maxTime),
      thumbColor: const Color.fromARGB(255, 101, 55, 156),
      onChanged: (newTime) {
        setState(() {
          _maxTime = newTime.toInt();
        });
        _updateMaxTime(_maxTime);
        slider = updateslider();
      },
    );
  }

  Future<void> _refreshFiles() async {
    final files = await _sharedPrefs.getFiles();
    setState(() {
      _files = files;
    });
  }

  Future<void> _loadFilenames() async {
    // Carrega os novos filenames e tags do banco de dados ou serviço
    final filenamesWithTags = await listFilenamesWithTags();

    // Evita duplicação limpando os dados antes de adicionar novos
    final newFilenames =
        filenamesWithTags.keys.toSet().difference(_filenames.toSet()).toList();
    final newTags =
        newFilenames.map((filename) => filenamesWithTags[filename]!).toList();

    final oldLength = _filenames.length;

    // Adiciona somente novos itens às listas locais
    _filenames.addAll(newFilenames);
    _tags.addAll(newTags);

    // Atualiza contagem de palavras para os novos arquivos
    for (String filename in newFilenames) {
      final words = await getWordsByFilenames([filename]);
      _wordCounts[filename] = words.length;
    }

    // Atualiza a AnimatedList apenas para os novos itens
    for (var i = oldLength; i < _filenames.length; i++) {
      _listKey.currentState?.insertItem(i);
    }

    // Notifica a interface sobre as mudanças
    setState(() {});
  }

  Future<void> _deleteFile(String filename) async {
    final index = _filenames.indexOf(filename);
    if (index != -1) {
      // Remove o item da AnimatedList com animação
      _listKey.currentState
          ?.removeItem(index, (context, animation) => Container());

      // Remove o item da lista interna após a animação

      _filenames.removeAt(index);
      _tags.removeAt(index);

      // Atualiza a base de dados
      await deleteFilename(filename);
    }
  }

  Future<void> showFilesPopup(BuildContext context) async {
    await _refreshFiles();
    List<Map<String, dynamic>> files = [];
    List<Map<String, dynamic>> filteredFiles = [];
    bool errorOccurred = false;

    // Buscar os arquivos usando getFiles()
    try {
      files = _files;
      filteredFiles = List.from(files);
    } catch (e) {
      errorOccurred = true;
    }
    void filterFiles(String query) {
      filteredFiles = files
          .where((file) =>
              file['name']?.toLowerCase().contains(query.toLowerCase()) ??
              false)
          .toList();

      // Atualiza a AnimatedList com animações
      setState(() {});
    }

    int wordCount(Map<String, dynamic> content) {
      // Verifica se a chave 'words' existe e se é uma lista, então retorna o tamanho dela
      if (content['words'] is List) {
        return (content['words'] as List).length;
      }
      return 0; // Caso não exista a chave ou não seja uma lista, retorna 0
    }

    Future<void> fetchAndSetFileData(List<Map<String, dynamic>> files) async {
      List<Future<void>> fetchTasks = [];
      final localization = AppLocalizations.of(context);
      for (var file in files) {
        final url = file['download_url'] ?? '';

        fetchTasks.add(
          // Requisição para pegar os dados de cada arquivo
          http.get(Uri.parse(url)).then((response) async {
            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              if (data['content']['tags'] != null &&
                  data['content']['tags'] is List) {
                List<String> tags =
                    (data['content']['tags'] as List).cast<String>();

                // Atualiza o fileData com tags, contagem de palavras e bandeira
                fileData[file['name']] = {
                  'tags': tags.isNotEmpty ? tags : [localization!.mp_no_tags],
                  'wordCount': wordCount(data['content']),
                  'flag': _getFlagPath(tags.isNotEmpty ? tags.first : ''),
                };
              }
            }
          }),
        );
      }

      // Espera todas as requisições terminarem
      await Future.wait(fetchTasks);
    }

    if (counterSubject.hasListener) {
      counterSubject.close(); // Feche o controlador existente
    }
    final StreamController<int> newController = StreamController<int>();
    counterSubject.addStream(newController.stream);

    await fetchAndSetFileData(filteredFiles);

    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Color.fromARGB(255, 56, 16, 115),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return StreamBuilder<int>(
            stream: counterSubject.stream,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              final counter = snapshot.data ?? 0;
              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                  },
                  scrollbars: false,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Barra de título com botão de fechar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              AppLocalizations.of(context)!.mp_available_files,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),

                      // Barra de pesquisa
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          onChanged: (value) {
                            newController.add(counter + 1);
                            filterFiles(
                                value); // Aplica o filtro enquanto o texto é digitado
                          },
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!
                                .main_searchtooltip,
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.elliptical(16, 16))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Conteúdo do modal
                      if (errorOccurred)
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            AppLocalizations.of(context)!.mp_error_file_load,
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      else if (filteredFiles.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                              AppLocalizations.of(context)!.mp_file_not_found),
                        )
                      else
                        Expanded(
                          child: AnimationLimiter(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(6),
                              itemCount: filteredFiles.length,
                              itemBuilder: (context, index) {
                                final file = filteredFiles[index];
                                final flagPath =
                                    fileData[file['name']]!['flag'] ?? '';

                                return AnimationConfiguration.staggeredList(
                                  position: index >= 0 &&
                                          index < filteredFiles.length
                                      ? index
                                      : -1, // Passa o índice para o configurador da animação
                                  duration: const Duration(milliseconds: 450),
                                  child: ScaleAnimation(
                                    duration: Duration(milliseconds: 400),
                                    child: FadeInAnimation(
                                      curve: Curves.decelerate,
                                      duration: Duration(milliseconds: 600),
                                      child: Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        color: const Color.fromARGB(
                                            255, 74, 32, 126),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        elevation: 4,
                                        child: ListTile(
                                          leading: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.asset(
                                              flagPath.isNotEmpty
                                                  ? flagPath
                                                  : 'default', // Placeholder
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          title: Text(
                                            file['name']
                                                    ?.replaceAll('.json', '') ??
                                                '',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          subtitle: Text(
                                            '${fileData[file['name']]!['tags'].isNotEmpty && fileData[file['name']]!['tags'][0].isNotEmpty ? '${AppLocalizations.of(context)!.tags}: ${fileData[file['name']]!['tags'][0] + ','}' : AppLocalizations.of(context)!.mp_error_file_load} ${fileData[file['name']]!['tags'].length > 1 && fileData[file['name']]!['tags'][1].isNotEmpty ? fileData[file['name']]!['tags'][1] + '.' : ''}\n'
                                            '${"${fileData[file['name']]!['wordCount']} ${AppLocalizations.of(context)!.words}"}',
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.download,
                                                color: Colors.white),
                                            onPressed: () async {
                                              final downloadUrl =
                                                  file['download_url'] ?? '';
                                              if (downloadUrl.isNotEmpty) {
                                                await _addFile(
                                                    true, downloadUrl);
                                              }
                                            },
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
                    ],
                  ),
                ),
              );
            });
      },
    ).whenComplete(() {
      // Fechar o StreamController ao fechar o modal
      newController.close();
    });
  }

  Future<void> _addFile(bool type, String? url) async {
    final localization = AppLocalizations.of(context);
    String code = '';
    if (!type) {
      // Local file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: true,
        withData: kIsWeb, // Incluye datos en la selección si estamos en la web
      );

      if (result != null && result.files.isNotEmpty) {
        try {
          for (final file in result.files) {
            if (kIsWeb) {
              // En la web, usamos bytes
              final fileBytes = file.bytes;
              if (fileBytes != null) {
                code = await addJsonToDatabase(jsonBytes: fileBytes);
              }
            } else {
              // En plataformas locales, usamos la ruta del archivo
              final filePath = file.path;
              if (filePath != null) {
                code = await addJsonToDatabase(jsonFilePath: filePath);
              }
            }
            if (code == '409') {
              _showToast(localization!.mp_error_file_exists, Colors.red);
            } else if (code == '500') {
              _showToast(localization!.mp_error_invalid_formatting, Colors.red);
            } else if (code == '0') {
              _showToast(localization!.mp_file_add_ok, Colors.green);
            } else {
              _showToast(localization!.mp_error_file_add, Colors.red);
            }
          }
          await _loadFilenames(); // Recarrega la lista sin duplicados
        } catch (e) {
          debugPrint(e as String);
        }
      }
    } else {
      if (url != null && url.isNotEmpty) {
        // Processar diretamente o URL fornecido
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final bytes = response.bodyBytes;
            code = await addJsonToDatabase(jsonBytes: bytes);
            await _loadFilenames();
            // Recarrega a lista sem duplicatas
            if (code == '409') {
              _showToast(localization!.mp_error_file_exists,
                  Colors.red);
            } else if (code == '500') {
              _showToast(
                  localization!.mp_error_invalid_formatting,
                  Colors.red);
            } else if (code == '0') {
              _showToast(
                  localization!.mp_file_add_ok, Colors.green);
            } else {
              _showToast(
                  localization!.mp_error_file_add, Colors.red);
            }
          } else {
            _showToast(
                '${localization!.mp_error_download} ${response.statusCode}',
                Colors.red);
          }
        } catch (e) {
          _showToast('${localization!.mp_error_download} $e',
              Colors.red);
        }
      }
    }
    if (type && (url == null || url.isEmpty)) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          FocusNode textFieldFocus = FocusNode();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            textFieldFocus.requestFocus();
          });
          urlController.clear();
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 49, 19, 94),
            title: Text(
              AppLocalizations.of(context)!.mp_url_tooltip,
              style: TextStyle(fontSize: 17),
            ),
            content: TextField(
              focusNode: textFieldFocus,
              controller: urlController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.mp_url_label,
                  hintText: AppLocalizations.of(context)!.mp_url_hint,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.paste),
                    onPressed: () async {
                      // Obter texto do clipboard
                      final ClipboardData? clipboardData =
                          await Clipboard.getData(Clipboard.kTextPlain);

                      if (clipboardData != null) {
                        // Atualizar o controlador com o texto colado
                        urlController.text = clipboardData.text!;
                      }
                    },
                  )),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.go_cancel),
              ),
              TextButton(
                onPressed: () async {
                  final url = urlController.text.trim();
                  Navigator.of(context).pop(); // Fecha o diálogo
                  if (url.isNotEmpty) {
                    try {
                      // Baixar arquivo a partir do URL
                      final response = await http.get(Uri.parse(url));
                      if (response.statusCode == 200) {
                        final bytes = response.bodyBytes;
                        code = await addJsonToDatabase(jsonBytes: bytes);
                        await _loadFilenames();
                        if (code == '409') {
                          _showToast(
                              localization!
                                  .mp_error_file_exists,
                              Colors.red);
                        } else if (code == '500') {
                          _showToast(
                              localization!
                                  .mp_error_invalid_formatting,
                              Colors.red);
                        } else if (code == '0') {
                          _showToast(
                              localization!.mp_file_add_ok,
                              Colors.green);
                        } else {
                          _showToast(
                              localization!.mp_error_file_add,
                              Colors.red);
                        }
                      } else {
                        _showToast(
                            '${localization!.mp_error_download} ${response.statusCode}',
                            Colors.red);
                      }
                    } catch (e) {
                      _showToast(
                          '${localization!.mp_error_download} $e',
                          Colors.red);
                    }
                  } else {
                    _showToast(
                        AppLocalizations.of(context)!.mp_url_empty, Colors.red);
                  }
                },
                child: Text(AppLocalizations.of(context)!.add),
              ),
            ],
          );
        },
      );
    }
  }

  void _showToast(String message, Color color) {
    showToast(
      message,
      context: context,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.scale,
      animDuration: const Duration(milliseconds: 600),
      duration: const Duration(seconds: 2),
      position: StyledToastPosition.center,
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
      backgroundColor: color,
      textStyle: const TextStyle(color: Colors.white, fontSize: 16),
    );
  }

  Widget float1() {
    return FloatingActionButton(
      onPressed: () => _addFile(true, ''),
      heroTag: "btn1",
      tooltip: AppLocalizations.of(context)!.mp_url_tooltip,
      child: Icon(Icons.add_link),
    );
  }

  Widget float2() {
    return FloatingActionButton(
      onPressed: () => _addFile(false, ''),
      heroTag: "btn2",
      tooltip: AppLocalizations.of(context)!.mp_local_file,
      child: Icon(Icons.add),
    );
  }

  Widget float3() {
    return FloatingActionButton(
      onPressed: () => showFilesPopup(context),
      heroTag: "btn3",
      tooltip: AppLocalizations.of(context)!.mp_github_file,
      child: Icon(Icons.web),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 56, 16, 115),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 550),
            child: Stack(children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          localization!.settings,
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                        Text(
                          localization.maxtimehint(_maxTime),
                          style: TextStyle(color: Colors.white),
                        ),
                        slider ?? SizedBox()
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _filenames.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.mp_addedfiles,
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
                                child: AnimatedList(
                                  controller: _scrollController,
                                  key: _listKey,
                                  initialItemCount: _filenames.length,
                                  itemBuilder: (context, index, animation) {
                                    if (index < 0 ||
                                        index >= _filenames.length ||
                                        index >= _tags.length) {
                                      return const SizedBox(); // Evita crashes ao acessar índices inválidos
                                    }

                                    final filename = _filenames[index];
                                    final tags = _tags[index].toList();

                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 450),
                                      child: SlideAnimation(
                                        verticalOffset: 0,
                                        horizontalOffset: 250,
                                        child: FadeInAnimation(
                                          curve: Curves.decelerate,
                                          duration:
                                              const Duration(milliseconds: 600),
                                          child: Card(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            color: const Color.fromARGB(
                                                255, 74, 32, 126),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            elevation: 4,
                                            child: ListTile(
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.asset(
                                                  _getFlagPath(tags.isNotEmpty
                                                      ? tags.first
                                                      : 'default'),
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              title: Text(
                                                filename,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              subtitle: Text(
                                                '${AppLocalizations.of(context)!.tags}: ${tags.join(', ')}.\n'
                                                '${_wordCounts.containsKey(filename) ? "${_wordCounts[filename]} ${AppLocalizations.of(context)!.words}" : AppLocalizations.of(context)!.loading}',
                                                style: const TextStyle(
                                                    color: Colors.white70),
                                              ),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.redAccent),
                                                onPressed: () =>
                                                    _deleteFile(filename),
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
              Positioned(
                bottom: 16,
                right: 16,
                child: AnimatedOpacity(
                  opacity: _showFloatingButtons ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: !_showFloatingButtons,
                    child: AnimatedFloatingActionButton(
                      tooltip: AppLocalizations.of(context)!.action_menu,
                      fabButtons: <Widget>[float1(), float3(), float2()],
                      key: key,
                      colorStartAnimation: const Color(0xFF6C5CE7),
                      colorEndAnimation: Colors.red,
                      animatedIconData: AnimatedIcons.menu_close,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: AnimatedOpacity(
                  opacity: _showFloatingButtons ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: !_showFloatingButtons,
                    child: FloatingActionButton(
                      heroTag: 'language',
                      onPressed: () => showLanguageSelector(
                        context,
                        [
                          Locale('ar'),
                          Locale('bn'),
                          Locale('de'),
                          Locale('en'),
                          Locale('es'),
                          Locale('fr'),
                          Locale('hi'),
                          Locale('it'),
                          Locale('ja'),
                          Locale('ko'),
                          Locale('pt'),
                          Locale('ru'),
                          Locale('tr'),
                          Locale('zh'),
                        ],
                        _onLanguageSelected,
                      ), //_startGame(context, selectedTime),
                      backgroundColor: Color(0xFF6C5CE7),
                      child: Icon(Icons.language),
                    ),
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }

  String _getFlagPath(String tags) {
    switch (tags.toLowerCase()) {
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

  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return 'العربية'; // Árabe
      case 'bn':
        return 'বাংলা'; // Bengali
      case 'de':
        return 'Deutsch'; // Alemão
      case 'en':
        return 'English'; // Inglês
      case 'es':
        return 'Español'; // Espanhol
      case 'fr':
        return 'Français'; // Francês
      case 'hi':
        return 'हिन्दी'; // Hindi
      case 'it':
        return 'Italiano'; // Italiano
      case 'ja':
        return '日本語'; // Japonês
      case 'jp':
        return '日本語'; // Japonês
      case 'ko':
        return '한국어'; // Coreano
      case 'pt':
        return 'Português'; // Português
      case 'ru':
        return 'Русский'; // Russo
      case 'tr':
        return 'Türkçe'; // Turco
      case 'zh':
        return '中文'; // Chinês
      default:
        return locale
            .languageCode; // Se o idioma não estiver na lista, retorna o código do idioma
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    counterSubject.close();
    super.dispose();
  }
}
