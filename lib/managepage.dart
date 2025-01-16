import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'makehive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/services.dart';
import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'main.dart';

class ManagerPage extends StatefulWidget {
  @override
  _ManagerPageState createState() => _ManagerPageState();
}

class CustomSlider extends StatelessWidget {
  final ValueNotifier<int> notifier;
  final Function(int) onTimeChanged;

  CustomSlider({
    required this.notifier,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (context, selectedTime, child) {
        return Slider(
          value: selectedTime.toDouble(),
          min: 10,
          max: 60,
          divisions: 5,
          label: "$selectedTime Segundos",
          thumbColor: const Color.fromARGB(255, 101, 55, 156),
          onChanged: (newTime) {
            notifier.value = newTime.toInt();
            onTimeChanged(newTime.toInt());
          },
        );
      },
    );
  }
}

class _ManagerPageState extends State<ManagerPage>
    with SingleTickerProviderStateMixin {
  List<String> _filenames = [];
  List<Set<String>> _tags = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late AnimationController _animationController;
  int _selectedTime = 30;
  final ValueNotifier<int> selectedTimeNotifier = ValueNotifier<int>(30);
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButtons = true;
  Map<String, int> _wordCounts = {};
  final GlobalKey<AnimatedFloatingActionButtonState> key =
      GlobalKey<AnimatedFloatingActionButtonState>();
  @override
  void initState() {
    super.initState();
    PreferencesService().getMaxTime().then((value) {
      setState(() {
        _selectedTime = value;
      });
    });
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    _loadFilenames();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

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

  Future<void> _loadFilenames() async {
    final filenames = await listFilenamesWithTags();
    final oldLength = _filenames.length;

    // Adiciona os itens aos dados locais
    _filenames.addAll(filenames.keys.toList());
    _tags.addAll(filenames.values.toList());
    for (String filename in _filenames) {
      final words = await getWordsByFilenames([filename]);
      setState(() {
        _wordCounts[filename] = words.length;
      });
    }
    // Atualiza a AnimatedList
    for (var i = oldLength; i < _filenames.length; i++) {
      _listKey.currentState?.insertItem(i);
    }
    setState(() {});
  }

  Future<void> _deleteFile(String filename) async {
    final index = _filenames.indexOf(filename);
    if (index != -1) {
      // Remove o item da AnimatedList com animação
      _listKey.currentState
          ?.removeItem(index, (context, animation) => Spacer());

      // Remove o item da lista interna após a animação

      _filenames.removeAt(index);
      _tags.removeAt(index);

      // Atualiza a base de dados
      await deleteFilename(filename);
    }
  }

  Future<void> _addFile(bool type) async {
  if (!type) {
    // Local file picker
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      try {
        for (final file in result.files) {
          final filePath = file.path;
          if (filePath != null) {
            await addJsonToDatabase(jsonFilePath: filePath);
          }
        }
        await _loadFilenames();
        _showToast("Arquivos adicionados com sucesso!", Colors.green);
      } catch (e) {
        _showToast('Erro ao adicionar os arquivos: $e', Colors.red);
      }
    }
  } else {
    // URL-based file picker
    final TextEditingController urlController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Arquivo por URL'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              labelText: 'Insira o URL do arquivo JSON',
              hintText: 'https://exemplo.com/arquivo.json',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
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
                      await addJsonToDatabase(jsonBytes: bytes);
                      await _loadFilenames();
                      _showToast("Arquivo adicionado com sucesso!", Colors.green);
                    } else {
                      _showToast(
                          'Erro ao baixar o arquivo. Código: ${response.statusCode}',
                          Colors.red);
                    }
                  } catch (e) {
                    _showToast('Erro ao processar o URL: $e', Colors.red);
                  }
                } else {
                  _showToast('URL inválido ou vazio!', Colors.red);
                }
              },
              child: const Text('Adicionar'),
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
    return Container(
      child: FloatingActionButton(
        onPressed: () => _addFile(true),
        heroTag: "btn1",
        tooltip: 'Adicionar arquivos por url.',
        child: Icon(Icons.add_link),
      ),
    );
  }

  Widget float2() {
    return Container(
      child: FloatingActionButton(
        onPressed: () => _addFile(false),
        heroTag: "btn2",
        tooltip: 'Adicionar arquivos locais.',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 56, 16, 115),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 550),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                      const Text(
                        'Configurações',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      Text(
                        'Tempo de resposta: $_selectedTime segundos',
                        style: TextStyle(color: Colors.white),
                      ),
                      Slider(
                        value: _selectedTime.toDouble(),
                        min: 10,
                        max: 60,
                        divisions: 5,
                        label: "$_selectedTime Segundos",
                        thumbColor: const Color.fromARGB(255, 101, 55, 156),
                        onChanged: (newTime) {
                          setState(() {
                            _selectedTime = newTime.toInt();
                            PreferencesService().saveMaxTime(_selectedTime);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _filenames.isEmpty
                        ? const Center(
                            child: Text(
                              'Os arquivos adicionados aparecerão aqui...',
                              style: TextStyle(color: Colors.white),
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
                                    duration: const Duration(milliseconds: 450),
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
                                              'Tags: ${tags.join(', ')}\n'
                                              '${_wordCounts.containsKey(filename) ? "${_wordCounts[filename]} palavras" : "Carregando..."}',
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
          ),
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _showFloatingButtons ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !_showFloatingButtons,
          child: AnimatedFloatingActionButton(
              //Fab list
              fabButtons: <Widget>[float1(), float2()],
              key: key,
              colorStartAnimation: Colors.blue,
              colorEndAnimation: Colors.red,
              animatedIconData: AnimatedIcons.menu_close //To principal button
              ),
        ),
      ),
    );
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

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
