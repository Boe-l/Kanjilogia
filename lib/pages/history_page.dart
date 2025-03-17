import 'dart:io';
import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kanjilogia/utils/discord_rpc.dart';
import 'package:provider/provider.dart';

import 'package:kanjilogia/common/langstuff.dart';
import 'package:kanjilogia/common/theme.dart';
import 'package:kanjilogia/pages/custom_widgets/windows_buttons.dart';

class History extends StatefulWidget {
  const History(
      {super.key, required this.correctItems, required this.incorrectItems});
  final Map<String, List<dynamic>> correctItems;
  final Map<String, List<dynamic>> incorrectItems;

  @override
  HistoryPage createState() =>
      HistoryPage(correctItems: correctItems, incorrectItems: incorrectItems);
}

class HistoryPage extends State<History> with TickerProviderStateMixin {
  HistoryPage({required this.correctItems, required this.incorrectItems});
  final Map<String, List<dynamic>> correctItems;
  final Map<String, List<dynamic>> incorrectItems;
  late TabController _tabController;
  late ColorPalette colorPalette;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Provider.of<DiscordRichPresenceNotifier>(context, listen: false)
        .updateActivity(
      title: 'Browsing history',
      subtitle: 'Checking answers',
      imageDetails: 'Kanjilogia',
    );
    onStart();
  }

  onStart() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    colorPalette = Provider.of<ColorPalette>(context);

    return SafeArea(
      top: false,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: colorPalette.background,
            appBar: AppBar(
              toolbarHeight: 50,
              backgroundColor: colorPalette.fillColor[0],
              leading: SizedBox.shrink(),
              flexibleSpace: Center(
                child: Stack(
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 600,
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon:
                                    Icon(Icons.arrow_back, color: Colors.white),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                AppLocalizations.of(context)!.gs_history,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
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
                                    WindowButtons()
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.touch
                      },
                      scrollbars: false,
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Correct(
                          correctItems: correctItems,
                          colorPalette: colorPalette,
                        ),
                        Incorrect(
                            incorrectItems: incorrectItems,
                            colorPalette: colorPalette),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: colorPalette.fillColor[0].withValues(alpha: 0.7),
                  child: Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: colorPalette.button,
                        labelColor: colorPalette.iconColor,
                        unselectedLabelColor: Colors.white70,
                        tabs: [
                          Tab(
                              icon: Icon(
                                Icons.check,
                                color: colorPalette.iconColor,
                              ),
                              text: AppLocalizations.of(context)!.hp_correct),
                          Tab(
                              icon: Icon(
                                Icons.close,
                                color: colorPalette.iconColor,
                              ),
                              text: AppLocalizations.of(context)!.hp_incorrect),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class Correct extends StatelessWidget {
  final ColorPalette colorPalette;
  final Map<String, List<dynamic>> correctItems;

  const Correct({
    super.key,
    required this.colorPalette,
    required this.correctItems,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(0.0);
      }
    });

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorPalette.background,
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: correctItems.isNotEmpty
                ? ListView.builder(
                    controller: scrollController,
                    itemCount: correctItems.length,
                    itemBuilder: (context, index) {
                      List<String> keys =
                          correctItems.keys.toList().reversed.toList();

                      String key = keys[index];
                      List<dynamic> values = [];
                      int quantidade = correctItems[key]?.length ?? 0;

                      if (quantidade < 6) {
                        values = correctItems[key]!;
                      } else {
                        values = [
                          [''],
                          correctItems[key]![5],
                          correctItems[key]![3],
                          correctItems[key]![0],
                          '',
                        ];
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        color: colorPalette.fillColor[1],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: Image.asset(
                            LocaleUtils.getFlagPath(values[2]),
                            width: 50,
                            height: 50,
                          ),
                          title: Text(key,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (values[0][0].isNotEmpty)
                                Text(
                                  '「${values[0].join('、 ')}」',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              Text(values[1]),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return WordDetailsDialog(
                                    colorPalette: colorPalette,
                                    word: key,
                                    values: values);
                              },
                            );
                          },
                        ),
                      );
                    },
                  )
                : Text(
                    AppLocalizations.of(context)!.hp_correct_appear_here,
                  ),
          ),
        ),
      ),
    );
  }
}

class Incorrect extends StatelessWidget {
  final ColorPalette colorPalette;
  final Map<String, List<dynamic>> incorrectItems;

  const Incorrect({
    super.key,
    required this.colorPalette,
    required this.incorrectItems,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(0.0);
      }
    });

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorPalette.background,
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: incorrectItems.isNotEmpty
                ? ListView.builder(
                    controller: scrollController,
                    itemCount: incorrectItems.length,
                    itemBuilder: (context, index) {
                      List<String> keys =
                          incorrectItems.keys.toList().reversed.toList();
                      String key = keys[index];
                      int quantidade = incorrectItems[key]?.length ?? 0;
                      List<dynamic> values = [];
                      if (quantidade < 6) {
                        values = incorrectItems[key]!;
                      } else {
                        values = [
                          [''],
                          incorrectItems[key]![5],
                          incorrectItems[key]![3],
                          incorrectItems[key]![0],
                          '',
                        ];
                      }
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        color: colorPalette.fillColor[1],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: Image.asset(
                            LocaleUtils.getFlagPath(values[2]),
                            width: 50,
                            height: 50,
                          ),
                          title: Text(key,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (values[0][0].isNotEmpty)
                                Text(
                                  '「${values[0].join('、 ')}」',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              Text(values[1]),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return WordDetailsDialog(
                                  word: key,
                                  values: values,
                                  colorPalette: colorPalette,
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  )
                : Text(
                    AppLocalizations.of(context)!.hp_error_appear_here,
                  ),
          ),
        ),
      ),
    );
  }
}

class WordDetailsDialog extends StatelessWidget {
  final String word;
  final List<dynamic> values;
  final ColorPalette colorPalette;

  const WordDetailsDialog(
      {super.key,
      required this.word,
      required this.values,
      required this.colorPalette});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: colorPalette.fillColor[0],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 250, maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: colorPalette.text,
                  ),
                ),
                SizedBox(height: 8),
                if (values[0][0].isNotEmpty)
                  Text(
                    '「${values[0].toString().replaceAll('[', '').replaceAll(']', '')}」',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      color: colorPalette.text,
                    ),
                  ),
                SizedBox(height: 12),
                Text(
                  "${AppLocalizations.of(context)!.hp_pop_meaning} ${values[1]}",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 12),
                if (values.length > 2)
                  Text(
                    "${AppLocalizations.of(context)!.tags}: ${values[2]}",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                SizedBox(height: 12),
                Text(
                  "${AppLocalizations.of(context)!.hp_pop_file_origin} '${values[3]}'",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 12),
                if (values[4].isNotEmpty)
                  Text(
                    "${AppLocalizations.of(context)!.hp_pop_user_answers} '${values[4]}'",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: colorPalette.borderColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Fechar",
                      style: TextStyle(
                        color: colorPalette.text,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
