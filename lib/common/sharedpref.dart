import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'debg.dart';

class SharedPrefs {
  static const String _tutorialCompleteKey = 'tutorial_complete';
  static const String _maxTimeKey = 'max_time';
  static const String _cardFontSizeKey = 'card_font_size';
  static const String _cardFontWeightKey = 'card_font_weight';
  static const String _apiUrl =
  'https://api.github.com/repos/Boe-l/Kanjilogia/contents/assets/json?ref=source';
  static const String _cachedFilesKey = 'cachedFiles';
  static const String _lastFetchTimeKey = 'lastFetchTime';


  Future<void> saveTutorialComplete(bool isComplete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompleteKey, isComplete);
  }

  Future<bool> isTutorialComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompleteKey) ?? false;
  }

  Future<void> saveMaxTime(int maxTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_maxTimeKey, maxTime);
  }

  Future<void> saveCardFontSize(double cardFontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_cardFontSizeKey, cardFontSize);
  }

  Future<double> getCardFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_cardFontSizeKey) ?? 30.0;
  }

  // Função para salvar o locale
  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'locale',locale .languageCode); // Salva apenas o código de idioma, como 'en', 'ja', etc.
  }
  Future<void> saveFontName(String fontname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'fontname',fontname); 
  }
  Future<String?> getFontName() async {
    final prefs = await SharedPreferences.getInstance();
    String? fontname = prefs.getString('fontname') ??
        'default'; // Padrão 'en' caso não haja valor salvo
    return fontname; // Retorna o Locale com o código de idioma salvo
  }
// Função para carregar o locale
  Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('locale') ??
        'en'; // Padrão 'en' caso não haja valor salvo
    return Locale(
        languageCode); // Retorna o Locale com o código de idioma salvo
  }

  Future<void> saveCardFontWeight(int cardFontWeight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cardFontWeightKey, cardFontWeight);
  }

  Future<int> getCardFontWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cardFontWeightKey) ?? 800;
  }

  Future<int> getMaxTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_maxTimeKey) ?? 30;
  }

  Future<void> fetchAndSaveFiles() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cachedFilesKey, jsonEncode(data));

        final currentTime = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt(_lastFetchTimeKey, currentTime);

        Debg().info('Dados salvos no SharedPreferences.');
      } else {
        Debg().exception('Falha ao buscar arquivos');
      }
    } catch (e) {
      Debg().error('Erro ao buscar ou salvar os arquivos: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCachedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString(_cachedFilesKey);

    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(cachedData));
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> getFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final int? lastFetchTime = prefs.getInt(_lastFetchTimeKey);
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (lastFetchTime != null && currentTime - lastFetchTime < 15 * 60 * 1000) {
      Debg().info('Carregando dados do cache.');
      return await getCachedFiles();
    }

    await fetchAndSaveFiles();
    return await getCachedFiles();
  }
}
