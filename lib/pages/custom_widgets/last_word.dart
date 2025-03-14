import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class LastWord extends StatefulWidget {
  final List<String> pastItems;
  final Map<String, List<dynamic>> correctItems;
  final Map<String, List<dynamic>> errorItems;
  final double screenWidth;
  final List<Map<String, dynamic>> words;
  final AppLocalizations? localization;

  const LastWord({
    super.key,
    required this.pastItems,
    required this.correctItems,
    required this.errorItems,
    required this.screenWidth,
    required this.words,
    required this.localization,
  });

  @override
  LastWordState createState() => LastWordState();
}

class LastWordState extends State<LastWord> {
  Map<String, dynamic>? wordData;
  List reading = [];
  String meaning = '';

  void _processLastWord() {
    String lastItem = widget.pastItems.isNotEmpty ? widget.pastItems.last : "";

    if (widget.words.isNotEmpty && widget.words.last['word'] != null) {
      wordData = widget.words.firstWhere(
        (word) => word["word"] == lastItem,
        orElse: () => {},
      );
      meaning = wordData!["mean"] ?? "N/A";
      reading = [wordData!["reading"] ?? "N/A"];
    } else {
      wordData = widget.words.firstWhere(
        (word) => word["question"] == lastItem,
        orElse: () => {},
      );
      meaning = '';
      reading = [wordData!["correct"] ?? "N/A"];
    }
  }

  @override
  Widget build(BuildContext context) {
    _processLastWord();

    Color textColor = widget.pastItems.isNotEmpty
        ? (widget.correctItems.containsKey(widget.pastItems.last)
            ? Colors.green
            : widget.errorItems.containsKey(widget.pastItems.last)
                ? Colors.redAccent
                : Colors.grey)
        : Colors.grey;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.pastItems.isNotEmpty ? widget.pastItems.last : "",
              key: ValueKey(
                  widget.pastItems.isNotEmpty ? widget.pastItems.last : ""),
              style: TextStyle(
                color: textColor,
                fontSize: (widget.screenWidth * 0.05).clamp(20.0, 21.0),
              ),
            ),
          ),
        ),
        subtitle: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: ScaleText(
                duration: Duration(milliseconds: 300),
                key: ValueKey("$meaning ($reading)"),
                text: "$meaning ${reading.join(', ')}",
                type: AnimationType.word,
                textStyle: TextStyle(
                  fontSize: (widget.screenWidth * 0.05).clamp(5.0, 15.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
