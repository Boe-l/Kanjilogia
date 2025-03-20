import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'package:kana_kit/kana_kit.dart';
import 'package:kanjilogia/common/debg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WordData {
  final String word;
  final String reading;
  final List<String> englishDefinitions;
  final List<String> partsOfSpeech;
  final List<String> tags;
  final String? dbpediaLink;
  final List<Map<String, dynamic>> links;

  WordData({
    required this.word,
    required this.reading,
    required this.englishDefinitions,
    required this.partsOfSpeech,
    required this.tags,
    this.dbpediaLink,
    required this.links,
  });

  factory WordData.fromJson(Map<String, dynamic> json) {
    return WordData(
      word: json['japanese'][0]['word'],
      reading: json['japanese'][0]['reading'] ?? '',
      englishDefinitions:
          List<String>.from(json['senses'][0]['english_definitions'] ?? []),
      partsOfSpeech: List<String>.from(json['parts_of_speech'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      dbpediaLink: json['dbpedia_link'],
      links: List<Map<String, dynamic>>.from(json['links'] ?? []),
    );
  }
}

class WordDetailsWidget extends StatefulWidget {
  final String word;
  final bool isRomaji;
  const WordDetailsWidget(
      {super.key, required this.word, required this.isRomaji});

  @override
  WordDetailsWidgetState createState() => WordDetailsWidgetState();
}

class WordDetailsWidgetState extends State<WordDetailsWidget> {
  late AudioPlayer player = AudioPlayer();
  final ValueNotifier<bool> _isHovered = ValueNotifier(false);
  late Future<List<WordData>> wordDataFuture;
  static const kanaKit = KanaKit();

  Future<List<WordData>> fetchWordData(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('https://jisho.org/api/v1/search/words?keyword=$keyword'),
        headers: {
          'Origin': 'https://boe-l.github.io/Kanjilogia/',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        var wordInfos = jsonResponse['data'];

        List<WordData> wordDataList = [];
        for (var wordInfo in wordInfos) {
          wordDataList.add(WordData.fromJson(wordInfo));
        }

        return wordDataList;
      } else {
        throw Exception('Falha ao carregar dados');
      }
    } catch (e) {
      throw Exception('Erro ao buscar os dados: $e');
    }
  }

  Future<void> _launchURL() async {
    final url = 'https://jisho.org/search/${widget.word}';

    Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Não foi possível abrir o URL: $url';
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<String> fetchAudioLink(String word, String kana) async {
    final url = 'https://jisho.org/word/$word';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      return '404';
    }

    BeautifulSoup soup = BeautifulSoup(response.body);

    var audioElement = soup.find('audio', id: 'audio_$word:$kana');

    var sourceElement = audioElement?.find('source');
    if (sourceElement == null) {
      return '404';
    }

    String audioUrl = sourceElement.attributes['src'] ?? '';
    return audioUrl.isNotEmpty ? 'https:$audioUrl' : '404';
  }

  Future<void> playAudio(String kanji, String kana) async {
    String url = await fetchAudioLink(kanji, kana);
    if (url == '404' && mounted) {
      Debg().error('Audio 404: $url');

      showToast(
        AppLocalizations.of(context)!.gs_dict_no_audio,
        context: context,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.scale,
        animDuration: const Duration(milliseconds: 600),
        duration: const Duration(seconds: 2),
        position: StyledToastPosition.center,
        curve: Curves.elasticOut,
        reverseCurve: Curves.linear,
        backgroundColor: Colors.red,
        textStyle: const TextStyle(fontSize: 16),
      );
      return;
    }

    await player.play(UrlSource(url));
  }

  @override
  void initState() {
    player = AudioPlayer();
    fetchWordData(widget.word);
    wordDataFuture = fetchWordData(widget.word);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        scrollbars: false,
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: 300, maxWidth: 300),
        child: FutureBuilder<List<WordData>>(
          future: wordDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.gs_dict_error_loading,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text(
                AppLocalizations.of(context)!.gs_dict_empty,
              ));
            } else {
              var wordDataList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: wordDataList.length,
                  itemBuilder: (context, index) {
                    var wordInfo = wordDataList[index];
                    var relevantDefinition =
                        wordInfo.englishDefinitions.isNotEmpty
                            ? '${wordInfo.englishDefinitions.join(', ')}.'
                            : AppLocalizations.of(context)!.gs_dict_empty;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    playAudio(
                                        wordInfo.word, wordInfo.reading.trim());
                                  },
                                  child: Tooltip(
                                    message: AppLocalizations.of(context)!
                                        .gs_dict_play_audio,
                                    child: Text(
                                      wordInfo.word,
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              if (index == 0)
                                MouseRegion(
                                  onEnter: (_) => _isHovered.value = true,
                                  onExit: (_) => _isHovered.value = false,
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      _launchURL();
                                    },
                                    child: Tooltip(
                                      message: AppLocalizations.of(context)!
                                          .gs_dict_open_jisho,
                                      child: SizedBox(
                                        height: 45,
                                        width: 45,
                                        child: Center(
                                          child: ValueListenableBuilder<bool>(
                                            valueListenable: _isHovered,
                                            builder:
                                                (context, isHovered, child) {
                                              return AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 200),
                                                curve: Curves.easeInOut,
                                                height: isHovered ? 45 : 40,
                                                width: isHovered ? 45 : 40,
                                                child: child,
                                              );
                                            },
                                            child: Image.asset(
                                              'assets/icon/Jisho.png',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                          Text(
                            widget.isRomaji
                                ? '「${kanaKit.toRomaji(wordInfo.reading)}」'
                                : '「${wordInfo.reading}」',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            relevantDefinition,
                            style: TextStyle(fontSize: 16),
                          ),
                          Divider(),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
