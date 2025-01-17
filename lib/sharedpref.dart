import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String _tutorialCompleteKey = 'tutorial_complete';
  static const String _maxTimeKey = 'max_time';

  /// Save the tutorial completion status
  Future<void> saveTutorialComplete(bool isComplete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompleteKey, isComplete);
  }
  Future<bool> isTutorialComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompleteKey) ?? false;
  }
  /// Save the selected maximum time
  Future<void> saveMaxTime(int maxTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_maxTimeKey, maxTime);
  }

  /// Get the tutorial completion status
  

  /// Get the saved maximum time
  Future<int> getMaxTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_maxTimeKey) ?? 30;
  }
  static const String _apiUrl =
      'https://api.github.com/repos/Boe-l/Kanjilogia/contents/assets/json?ref=source';
  static const String _cachedFilesKey = 'cachedFiles';
  static const String _lastFetchTimeKey = 'lastFetchTime';

  // Método para buscar e salvar os arquivos no SharedPreferences
  Future<void> fetchAndSaveFiles() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Salvar os dados no SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cachedFilesKey, jsonEncode(data));

        // Atualizar o horário da última requisição
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt(_lastFetchTimeKey, currentTime);

        print('Dados salvos no SharedPreferences.');
      } else {
        throw Exception('Falha ao buscar arquivos');
      }
    } catch (e) {
      print('Erro ao buscar ou salvar os arquivos: $e');
    }
  }

  // Método para recuperar os arquivos salvos no cache
  Future<List<Map<String, dynamic>>> getCachedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString(_cachedFilesKey);

    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(cachedData));
    }

    return [];
  }

  // Método para obter os arquivos, verificando o cache e, se necessário, atualizando
  Future<List<Map<String, dynamic>>> getFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final int? lastFetchTime = prefs.getInt(_lastFetchTimeKey);
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Verificar se os dados são válidos ou se precisam ser atualizados
    if (lastFetchTime != null && currentTime - lastFetchTime < 15 * 60 * 1000) {
      print('Carregando dados do cache.');
      return await getCachedFiles();
    }

    // Fazer uma nova requisição e salvar os dados
    await fetchAndSaveFiles();
    return await getCachedFiles();
  }
}
