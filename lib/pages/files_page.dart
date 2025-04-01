import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:kanjilogia/common/debg.dart';
import 'package:kanjilogia/common/theme.dart';
import 'package:kanjilogia/utils/discord_rpc.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../common/database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/services.dart';
import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import '../common/sharedpref.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../common/langstuff.dart';

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
  late ColorPalette colorPalette;
  Slider? slider;
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    Provider.of<DiscordRichPresenceNotifier>(context, listen: false)
        .updateActivity(
      title: 'Browsing Files',
      subtitle: 'Viewing files list',
      imageDetails: 'Kanjilogia',
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

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  Future<void> _refreshFiles() async {
    final files = await _sharedPrefs.getFiles();
    setState(() {
      _files = files;
    });
  }

  Future<void> _loadFilenames() async {
    final filenamesWithTags = await listFilenamesWithTags();

    final newFilenames =
        filenamesWithTags.keys.toSet().difference(_filenames.toSet()).toList();
    final newTags =
        newFilenames.map((filename) => filenamesWithTags[filename]!).toList();

    final oldLength = _filenames.length;

    _filenames.addAll(newFilenames);
    _tags.addAll(newTags);

    for (String filename in newFilenames) {
      final fileContent = await getContentsByFilenames([filename]);
      num totalWords = 0;

      if (fileContent[0]['words'].isNotEmpty) {
        totalWords += fileContent[0]['words'].length;
      }

      if (fileContent[0]['grammarQuestions'].isNotEmpty) {
        totalWords += fileContent[0]['grammarQuestions'].length;
      }

      _wordCounts[filename] = totalWords.toInt();
    }

    for (var i = oldLength; i < _filenames.length; i++) {
      _listKey.currentState?.insertItem(i);
    }

    if (mounted) setState(() {});
  }

  Future<void> _deleteFile(String filename) async {
    final index = _filenames.indexOf(filename);
    if (index != -1) {
      _listKey.currentState
          ?.removeItem(index, (context, animation) => Container());

      _filenames.removeAt(index);
      _tags.removeAt(index);

      if (_filenames.length < 6 && !_showFloatingButtons) {
        setState(() {
          _showFloatingButtons = true;
        });
      }
      if (_filenames.isEmpty) {
        setState(() {});
      }
      await deleteFilename(filename);
    }
  }

  Future<void> showFilesPopup(BuildContext context) async {
    await _refreshFiles();
    List<Map<String, dynamic>> files = [];
    List<Map<String, dynamic>> filteredFiles = [];
    bool errorOccurred = false;

    try {
      files = _files;
      filteredFiles = List.from(files);
    } catch (e) {
      Debg().error("showFilesPopup error: ${e.toString()}");

      errorOccurred = true;
    }
    void filterFiles(String query) {
      filteredFiles = files
          .where((file) =>
              file['name']?.toLowerCase().contains(query.toLowerCase()) ??
              false)
          .toList();

      setState(() {});
    }

    int wordCount(Map<String, dynamic> content) {
      num totalWords = 0;

      if (content['words'] != null && content['words'] is List) {
        totalWords += content['words'].length;
      }

      if (content['grammarQuestions'] != null &&
          content['grammarQuestions'] is List) {
        totalWords += content['grammarQuestions'].length;
      }

      return totalWords.toInt();
    }

    Future<void> fetchAndSetFileData(List<Map<String, dynamic>> files) async {
      List<Future<void>> fetchTasks = [];
      final localization = AppLocalizations.of(context);
      try {
        for (var file in files) {
          final url = file['download_url'] ?? '';

          fetchTasks.add(
            http.get(Uri.parse(url)).then((response) async {
              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                if (data['tags'] != null && data['tags'] is List) {
                  List<String> tags =
                      (data['tags'] as List).whereType<String>().toList();

                  fileData[file['name']] = {
                    'tags':
                        (tags.isNotEmpty) ? tags : [localization!.mp_no_tags],
                    'wordCount': wordCount(data),
                    'flag': LocaleUtils.getFlagPath(
                        (tags.isNotEmpty) ? tags.first : ''),
                  };
                }
              }
            }),
          );
        }
      } catch (e) {
        Debg().exception(e.toString());
      }

      await Future.wait(fetchTasks);
    }

    if (counterSubject.hasListener) {
      counterSubject.close();
    }
    final StreamController<int> newController = StreamController<int>();
    counterSubject.addStream(newController.stream);

    await fetchAndSetFileData(filteredFiles);
    if (!context.mounted) return;
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: colorPalette.background,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            TextField(
                              onChanged: (value) {
                                newController.add(counter + 1);
                                filterFiles(value);
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      if (errorOccurred)
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            AppLocalizations.of(context)!.mp_error_file_load,
                            style: TextStyle(color: colorPalette.error),
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
                                final tags =
                                    fileData[file['name']]!['tags'] ?? '';

                                return AnimationConfiguration.staggeredList(
                                  position:
                                      index >= 0 && index < filteredFiles.length
                                          ? index
                                          : -1,
                                  duration: const Duration(milliseconds: 450),
                                  child: ScaleAnimation(
                                    duration: Duration(milliseconds: 400),
                                    child: FadeInAnimation(
                                      curve: Curves.decelerate,
                                      duration: Duration(milliseconds: 600),
                                      child: Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        color: colorPalette.fillColor[1],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        elevation: 4,
                                        child: ListTile(
                                          leading: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Primeira bandeira
                                              Image.asset(
                                                LocaleUtils.getFlagPath(
                                                    tags.isNotEmpty
                                                        ? tags.first
                                                        : 'default'),
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              ),
                                              if (tags.length > 1)
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Image.asset(
                                                    LocaleUtils.getFlagPath(
                                                        tags.elementAt(1)),
                                                    width: 25,
                                                    height: 25,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          title: Text(
                                            file['name']
                                                    ?.replaceAll('.json', '') ??
                                                '',
                                            style: const TextStyle(),
                                          ),
                                          subtitle: Text(
                                            '${fileData[file['name']]!['tags'].isNotEmpty && fileData[file['name']]!['tags'][0].isNotEmpty ? '${AppLocalizations.of(context)!.tags}: ${fileData[file['name']]!['tags'][0] + ','}' : AppLocalizations.of(context)!.mp_error_file_load} ${fileData[file['name']]!['tags'].length > 1 && fileData[file['name']]!['tags'][1].isNotEmpty ? fileData[file['name']]!['tags'][1] + '.' : ''}\n'
                                            '${"${fileData[file['name']]!['wordCount']} ${AppLocalizations.of(context)!.words}"}',
                                            style: const TextStyle(),
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(
                                              Icons.download,
                                            ),
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
      newController.close();
    });
  }

  Future<void> _addFile(bool type, String? url) async {
    final localization = AppLocalizations.of(context);
    String code = '';
    if (!type) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: true,
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        try {
          for (final file in result.files) {
            if (kIsWeb) {
              final fileBytes = file.bytes;
              if (fileBytes != null) {
                code = await addJsonToDatabase(jsonBytes: fileBytes);
              }
            } else {
              final filePath = file.path;
              if (filePath != null) {
                code = await addJsonToDatabase(jsonFilePath: filePath);
              }
            }
            if (code == '409') {
              _showToast(
                  localization!.mp_error_file_exists, colorPalette.error);
            } else if (code == '500') {
              _showToast(localization!.mp_error_invalid_formatting,
                  colorPalette.error);
            } else if (code == '0') {
              _showToast(localization!.mp_file_add_ok, Colors.green);
            } else {
              _showToast(localization!.mp_error_file_add, colorPalette.error);
            }
          }
          await _loadFilenames();
        } catch (e) {
          Debg().error("_addFile $type, $url error: ${e.toString()}");
        }
      }
    } else {
      if (url != null && url.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final bytes = response.bodyBytes;
            code = await addJsonToDatabase(jsonBytes: bytes);
            await _loadFilenames();

            if (code == '409') {
              _showToast(
                  localization!.mp_error_file_exists, colorPalette.error);
            } else if (code == '500') {
              _showToast(localization!.mp_error_invalid_formatting,
                  colorPalette.error);
            } else if (code == '0') {
              _showToast(localization!.mp_file_add_ok, Colors.green);
            } else {
              _showToast(localization!.mp_error_file_add, colorPalette.error);
            }
          } else {
            _showToast(
                '${localization!.mp_error_download} ${response.statusCode}',
                colorPalette.error);
          }
        } catch (e) {
          Debg().error("_addFile $type, $url error: ${e.toString()}");

          _showToast(
              '${localization!.mp_error_download} $e', colorPalette.error);
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
            backgroundColor: colorPalette.background,
            title: Text(
              AppLocalizations.of(context)!.mp_url_tooltip,
              style: TextStyle(fontSize: 17),
            ),
            content: TextField(
              focusNode: textFieldFocus,
              controller: urlController,
              decoration: InputDecoration(
                  labelStyle: TextStyle(color: colorPalette.text),
                  labelText: AppLocalizations.of(context)!.mp_url_label,
                  hintStyle: TextStyle(color: colorPalette.text),
                  hintText: AppLocalizations.of(context)!.mp_url_hint,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.paste),
                    onPressed: () async {
                      final ClipboardData? clipboardData =
                          await Clipboard.getData(Clipboard.kTextPlain);

                      if (clipboardData != null) {
                        urlController.text = clipboardData.text!;
                      }
                    },
                  )),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)!.go_cancel,
                  style: TextStyle(color: colorPalette.text),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final url = urlController.text.trim();
                  Navigator.of(context).pop();
                  if (url.isNotEmpty) {
                    try {
                      final response = await http.get(Uri.parse(url));
                      if (response.statusCode == 200) {
                        final bytes = response.bodyBytes;
                        code = await addJsonToDatabase(jsonBytes: bytes);
                        await _loadFilenames();
                        if (code == '409') {
                          _showToast(localization!.mp_error_file_exists,
                              colorPalette.error);
                        } else if (code == '500') {
                          _showToast(localization!.mp_error_invalid_formatting,
                              colorPalette.error);
                        } else if (code == '0') {
                          _showToast(
                              localization!.mp_file_add_ok, Colors.green);
                        } else {
                          _showToast(localization!.mp_error_file_add,
                              colorPalette.error);
                        }
                      } else {
                        _showToast(
                            '${localization!.mp_error_download} ${response.statusCode}',
                            colorPalette.error);
                      }
                    } catch (e) {
                      Debg()
                          .error("_addFile $type, $url error: ${e.toString()}");

                      _showToast('${localization!.mp_error_download} $e',
                          colorPalette.error);
                    }
                  } else {
                    _showToast(AppLocalizations.of(context)!.mp_url_empty,
                        colorPalette.error);
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.add,
                  style: TextStyle(color: colorPalette.text),
                ),
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
      textStyle: const TextStyle(fontSize: 16),
    );
  }

  Widget float1() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
          margin: const EdgeInsets.only(right: 8.0),
          decoration: BoxDecoration(
            color: colorPalette.fillColor[0],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            AppLocalizations.of(context)!.mp_url_tooltip,
            style: TextStyle(
              fontSize: 14,
              color: colorPalette.text,
            ),
          ),
        ),
        FloatingActionButton(
          backgroundColor: colorPalette.fillColor[1],
          onPressed: () => _addFile(true, ''),
          heroTag: "btn1",
          child: Icon(Icons.add_link, color: colorPalette.iconColor),
        ),
      ],
    );
  }

  Widget float2() {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        margin: const EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          color: colorPalette.fillColor[0],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          AppLocalizations.of(context)!.mp_local_file,
          style: TextStyle(
            fontSize: 14,
            color: colorPalette.text,
          ),
        ),
      ),
      FloatingActionButton(
          onPressed: () => _addFile(false, ''),
          heroTag: "btn2",
          backgroundColor: colorPalette.fillColor[1],
          child: Icon(Icons.add, color: colorPalette.iconColor)),
    ]);
  }

  Widget float3() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
          margin: const EdgeInsets.only(right: 8.0),
          decoration: BoxDecoration(
            color: colorPalette.fillColor[0],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            AppLocalizations.of(context)!.mp_github_file,
            style: TextStyle(
              color: colorPalette.text,
              fontSize: 14,
            ),
          ),
        ),
        FloatingActionButton(
          onPressed: () => showFilesPopup(context),
          heroTag: "btn3",
          backgroundColor: colorPalette.fillColor[1],
          child: Icon(
            Icons.web,
            color: colorPalette.iconColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return files(context, localization);
  }

  Widget files(BuildContext context, AppLocalizations? localization) {
    colorPalette = Provider.of<ColorPalette>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 56, 16, 115),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 550),
            child: Stack(children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 1, 8, 8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.manage_files,
                          style: GoogleFonts.rampartOne(
                            color: colorPalette.text,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: colorPalette.highlight,
                                blurRadius: 10,
                              )
                            ],
                          ),
                        ),
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
                                style: TextStyle(fontSize: 18),
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
                                      return const SizedBox();
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
                                            color: colorPalette.fillColor[1]
                                                .withValues(alpha: 0.9),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            elevation: 4,
                                            child: ListTile(
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    // Primeira bandeira
                                                    Image.asset(
                                                      LocaleUtils.getFlagPath(
                                                          tags.isNotEmpty
                                                              ? tags.first
                                                              : 'default'),
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    if (tags.length > 1)
                                                      Positioned(
                                                        bottom: 0,
                                                        right: 0,
                                                        child: Image.asset(
                                                          LocaleUtils
                                                              .getFlagPath(tags
                                                                  .elementAt(
                                                                      1)),
                                                          width: 25,
                                                          height: 25,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              title: Text(
                                                filename,
                                                style: const TextStyle(),
                                              ),
                                              subtitle: Text(
                                                '${AppLocalizations.of(context)!.tags}: ${tags.join(', ')}.\n'
                                                '${_wordCounts.containsKey(filename) ? "${_wordCounts[filename]} ${AppLocalizations.of(context)!.words}" : AppLocalizations.of(context)!.loading}',
                                                style: const TextStyle(),
                                              ),
                                              trailing: IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: colorPalette.error),
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
                      colorStartAnimation: colorPalette.fillColor[1],
                      colorEndAnimation: colorPalette.errorBorderColor,
                      animatedIconData: AnimatedIcons.menu_close,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    counterSubject.close();
    super.dispose();
  }
}
