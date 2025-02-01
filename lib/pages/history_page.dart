import 'dart:ui';


import 'package:flutter/material.dart';
import 'game_screen.dart';

class History extends StatefulWidget {
  const History(
      {super.key, required this.correctItems, required this.incorrectItems});
  final Map<String, List<String>> correctItems;
  final Map<String, List<String>> incorrectItems;

  @override
  HistoryPage createState() =>
      HistoryPage(correctItems: correctItems, incorrectItems: incorrectItems);
}

class HistoryPage extends State<History> with TickerProviderStateMixin {
  HistoryPage({required this.correctItems, required this.incorrectItems});
  final Map<String, List<String>> correctItems;
  final Map<String, List<String>> incorrectItems;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    onStart();
  }

  onStart() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 74, 32, 126),
          leading: SizedBox(), 
          flexibleSpace: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: kToolbarHeight / 2 - 24, 
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Histórico',
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
                    Correct(correctItems: correctItems),
                    Incorrect(incorrectItems: incorrectItems),
                  ],
                ),
              ),
            ),
            Container(
              color: Color.fromARGB(255, 74, 32, 126),
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: [
                      Tab(icon: Icon(Icons.check), text: 'Corretos'),
                      Tab(icon: Icon(Icons.close), text: 'Incorretos'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
    gameScreenKey.currentState?.startTimer();
  }
}

class Correct extends StatelessWidget {
  final Map<String, List<String>> correctItems;

  Correct({super.key, required this.correctItems});

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();

    
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    });

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: correctItems.isNotEmpty
                ? ListView.builder(
                    controller: _scrollController,
                    itemCount: correctItems.length,
                    itemBuilder: (context, index) {
                      
                      List<String> keys =
                          correctItems.keys.toList().reversed.toList();
                      String key = keys[index];
                      List<String> values = correctItems[key]!;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        color: const Color.fromARGB(255, 67, 19, 138),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: Image.asset(
                            'assets/flags/japan.png',
                            width: 50,
                            height: 50,
                          ),
                          title: Text(key,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '「${values[0]}」',
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
                                    word: key, values: values);
                              },
                            );
                          },
                        ),
                      );
                    },
                  )
                : Text('Os acertos aparecerão aqui.'),
          ),
        ),
      ),
    );
  }
}

class Incorrect extends StatelessWidget {
  final Map<String, List<String>> incorrectItems;

  const Incorrect({super.key, required this.incorrectItems});

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();

    
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    });

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: incorrectItems.isNotEmpty
                ? ListView.builder(
                    controller: _scrollController,
                    itemCount: incorrectItems.length,
                    itemBuilder: (context, index) {
                      
                      List<String> keys =
                          incorrectItems.keys.toList().reversed.toList();
                      String key = keys[index];
                      List<String> values = incorrectItems[key]!;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        color: const Color.fromARGB(255, 67, 19, 138),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: Image.asset(
                            'assets/flags/japan.png', 
                            width: 50,
                            height: 50,
                          ),
                          title: Text(key,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '「${values[0]}」',
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
                                    word: key, values: values);
                              },
                            );
                          },
                        ),
                      );
                    },
                  )
                : Text('Os erros aparecerão aqui.'),
          ),
        ),
      ),
    );
  }
}

class WordDetailsDialog extends StatelessWidget {
  final String word;
  final List<String> values;

  const WordDetailsDialog(
      {super.key, required this.word, required this.values});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromARGB(255, 63, 23, 97),
      content: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(word,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30)),
            Text(values[0],
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
            Text("Significado: ${values[1]}",
                style: TextStyle(fontWeight: FontWeight.w200)),
            if (values.length > 2)
              Text("Tags: ${values[2]}",
                  style: TextStyle(fontWeight: FontWeight.w200)),
            Text("Arquivo de origem: '${values[3]}'",
                style: TextStyle(fontWeight: FontWeight.w200)),
            Text("Suas respostas: '${values[4]}'",
                style: TextStyle(fontWeight: FontWeight.w200)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Fechar"),
        ),
      ],
    );
  }
}
