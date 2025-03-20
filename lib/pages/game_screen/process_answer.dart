import 'package:flutter/material.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:kanjilogia/pages/game_screen/gs_card.dart';

class AnswerProcessor {
  final List<Map<String, dynamic>> words;
  final VoidCallback restartTimer;
  static const kanaKit = KanaKit();
  final VoidCallback restartGame;
  final GlobalKey<GameScreenCardState> _customCardKey;

  final BuildContext context;

  int currentIndex;
  int score;
  bool gameOver;
  List<String> answers = [];
  String attemptsString = "";
  Map<String, List<dynamic>> correctItems = {};
  Map<String, List<dynamic>> errorItems = {};
  List<String> respondidos = [];

  AnswerProcessor({
    required this.words,
    required this.gameOver,
    required this.restartTimer,
    required this.restartGame,
    required GlobalKey<GameScreenCardState> customCardKey,
    required this.context,
    required this.currentIndex,
    required this.score,
  }) : _customCardKey = customCardKey;

  void processAnswer(String answer) {
    if (currentIndex >= words.length) return;
    bool isCorrect = false;
    final currentWord = words[currentIndex];
    if (currentWord['word'] != null && currentWord['word'].isNotEmpty) {
      final possibleReadings = (currentWord["reading"] ?? "");
      final userAnswerNormalized = _normalizeInput(answer.trim());
      isCorrect = currentWord["tags"]!.contains('jp')
          ? possibleReadings.contains(userAnswerNormalized)
          : possibleReadings.contains(answer.trim());

      answers.add(answer);
      attemptsString = answers.join(", ");

      _handleAnswer(isCorrect, answer, currentWord);
    } else {
      final List<dynamic> alternatives = currentWord['alternatives']
              ?.split(',')
              .map((e) => e.replaceAll(' ', ''))
              .toList() ??
          [];

      final List<String> letters = [
        'A',
        'B',
        'C',
        'D',
        'E',
      ];

      final Map<String, String> labeledAlternatives = {
        for (int i = 0; i < alternatives.length && i < letters.length; i++)
          letters[i]: alternatives[i]
      };
      if (labeledAlternatives.containsKey(answer.toUpperCase())) {
        if (labeledAlternatives[answer.toUpperCase()] ==
            currentWord['correct']) {
          isCorrect = true;
        } else {
          isCorrect = false;
          answer = '';
        }
      }

      _handleAnswer(isCorrect, answer, currentWord);
    }
  }

  String _normalizeInput(String input) {
    return kanaKit.toHiragana(input.replaceAll('nn', 'n-')).replaceAll('ー', '');
  }

  void _handleAnswer(
      bool isCorrect, String answer, Map<String, dynamic> currentWord) {
    if (isCorrect) {
      score++;
      restartTimer();
      if (currentWord['word'] != null && currentWord['word'].isNotEmpty) {
        correctItems[currentWord["word"]!] =
            _buildItemList(currentWord, answer);
        respondidos.add(currentWord["word"] ?? "");
      } else {
        correctItems[currentWord["question"]!] =
            _buildItemList(currentWord, answer);
        respondidos.add(currentWord["question"] ?? "");
      }
      answers.clear();
      _moveToNextWord();
    } else if (answer.isNotEmpty) {
      _triggerError();
    } else {
      if (currentWord['word'] != null && currentWord['word'].isNotEmpty) {
        errorItems[currentWord["word"]!] = _buildItemList(currentWord, answer);
        respondidos.add(currentWord["word"] ?? "");
      } else {
        errorItems[currentWord["question"]!] =
            _buildItemList(currentWord, answer);
        respondidos.add(currentWord["question"] ?? "");
      }
      restartTimer();
      answers.clear();

      _moveToNextWord();
    }
  }

  List<dynamic> _buildItemList(Map<String, dynamic> word, String answer) {
    if (word['word'] != null && word['word'].isNotEmpty) {
      return [
        word["reading"],
        word["mean"]!,
        word["tags"]!,
        word["filename"]!,
        attemptsString.isNotEmpty ? attemptsString : answer
      ];
    } else {
      return [
        word["filename"]!,
        word["question"]!,
        word["mean"]!,
        word["tags"]!,
        word["alternatives"]!,
        word["correct"]!
      ];
    }
  }

  void _triggerError() {
    _customCardKey.currentState?.triggerErrorAnimation();
  }

  void _moveToNextWord() {
    if (currentIndex < words.length - 1) {
      currentIndex++;
      restartTimer();
    } else {
      gameOver = true;
    }
  }

  Map<String, List<dynamic>> get getCorrectItems => correctItems;
  Map<String, List<dynamic>> get getErrorItems => errorItems;
  List<String> get getkanjisRespondidos => respondidos;
  int get getCurrentIndex => currentIndex;
  int get getScore => score;
  bool get getGameOver => gameOver;
}
