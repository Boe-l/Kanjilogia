import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kanjilogia/common/debg.dart';
import 'package:kanjilogia/utils/discord_rpc.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> {
  List<Update> updates = [];
  Map<String, dynamic> fileContent = {};
  String userName = '';
  String userAvatarUrl = '';
  @override
  void initState() {
    super.initState();
    fetchData();

    // Garanta que a execução de updateActivity aconteça após a renderização do frame
    Provider.of<DiscordRichPresenceNotifier>(context, listen: false)
        .updateActivity(
      title: 'Viewing Feed',
      subtitle: 'Idle',
      imageDetails: 'Kanjilogia',
    );
  }

  void fetchData() async {
    final url = 'https://api.github.com/gists/1df9d4323d9ec27cbe79664e5440e00a';

    // Fazendo a requisição GET
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      fileContent = json.decode(data['files']['feed.json']['content']);
      final update = fileContent['updates'];
      userName = data['owner']['login'];
      userAvatarUrl = data['owner']['avatar_url'];
      for (var i = 0; i < update.length; i++) {
        final current = update[i];
        updates.add(Update(
          id: current['id'],
          title: current['title'],
          message: current['message'],
          date: current['date'],
          type: current['type'],
          importance: current['importance'],
          author: current['author'],
        ));
      }
      if (mounted) setState(() {});
    } else {
      Debg().error('Error loading Gist');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: updates.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: ListView.builder(
                  reverse: true,
                  itemCount: updates.length,
                  itemBuilder: (context, index) {
                    final update = updates[index];
                    return ListTile(
                      title: Text(
                        userName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(update.title),
                          Text(update.message),
                        ],
                      ),
                      leading: Image(image: NetworkImage(userAvatarUrl)),
                      isThreeLine: true,
                      trailing: Text(update.date),
                      onTap: () {},
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class Update {
  final int id;
  final String title;
  final String message;
  final String date;
  final String type;
  final String importance;
  final String author;

  Update({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    required this.importance,
    required this.author,
  });

  factory Update.fromJson(Map<String, dynamic> json) {
    return Update(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      date: json['date'],
      type: json['type'],
      importance: json['importance'],
      author: json['author'],
    );
  }
}
