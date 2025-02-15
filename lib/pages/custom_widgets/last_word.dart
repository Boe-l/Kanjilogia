import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class LastWord extends StatelessWidget {
  final List<String> pastItems;
  final Map<String, List<dynamic>> correctItems;
  final Map<String, List<dynamic>> errorItems;
  final double screenWidth;
  final List<Map<String, dynamic>> words;
  final AppLocalizations? localization;
  Map<String, dynamic>? wordData;
  List reading = [];
  String meaning = '';
  LastWord({
    super.key,
    required this.pastItems,
    required this.correctItems,
    required this.errorItems,
    required this.screenWidth,
    required this.words,
    required this.localization,
  });

  @override
  Widget build(BuildContext context) {
    String lastItem = pastItems.isNotEmpty ? pastItems.last : "";
    if (words.last['word'] != null && words.last['word'].isNotEmpty) {
      wordData = words.firstWhere(
        (word) => word["word"] == lastItem,
        orElse: () => {},
      );
      meaning = wordData!["mean"] ?? "N/A";
      reading = [wordData!["reading"] ?? "N/A"];
    } else {
      wordData = words.firstWhere(
        (word) => word["question"] == lastItem,
        orElse: () => {},
      );
      meaning = '';
      reading = [wordData!["correct"] ?? "N/A"];
    }

    Color textColor = pastItems.isNotEmpty
        ? (correctItems.containsKey(lastItem)
            ? Colors.green
            : errorItems.containsKey(lastItem)
                ? Colors.redAccent
                : Colors.grey)
        : Colors.grey;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: ListTile(
        contentPadding: EdgeInsets.zero, // Remove o padding interno do ListTile
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Align(
            alignment:
                Alignment.centerLeft, // Garante que o texto fique à esquerda
            child: Text(
              lastItem,
              key: ValueKey(lastItem),
              style: TextStyle(
                color: textColor,
                fontSize: (screenWidth * 0.05).clamp(20.0, 21.0),
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
              alignment: Alignment.centerLeft, // Alinha o OffsetText à esquerda
              child: ScaleText(
                duration: Duration(milliseconds: 300),
                key: ValueKey("$meaning ($reading)"),
                text: "$meaning ${reading.join(', ')}",
                type: AnimationType.word,
                // slideType: SlideAnimationType.alternateTB,
                textStyle: TextStyle(
                  fontSize: (screenWidth * 0.05).clamp(5.0, 15.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
