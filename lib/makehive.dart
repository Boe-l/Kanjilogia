import 'dart:convert';
import 'dart:io';
import 'package:isar/isar.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

part 'makehive.g.dart'; // Certifique-se de que o arquivo gerado estará aqui

@collection
class Word {
  Id id = Isar.autoIncrement;
  late String word;
  late String reading;
  late String mean;
  late List<String> tags; // Lista de tags para cada palavra
  late String filename; // Armazenar o nome do arquivo associado
}

// Inicializa o banco de dados e retorna uma instância do Isar
Isar? _isarInstance; // Variável estática para armazenar a instância

Future<Isar> getIsarInstance() async {
  if (_isarInstance != null) {
    // Se já existe uma instância aberta, retorna a mesma
    return _isarInstance!;
  }

  final dir = await getApplicationDocumentsDirectory();
  _isarInstance = await Isar.open(
    [WordSchema],
    directory: dir.path,
  );

  return _isarInstance!;
}
bool validateJson(Map<String, dynamic> json) {
  return json.containsKey('word') &&
      json.containsKey('reading') &&
      json.containsKey('mean') &&
      json['word'] is String &&
      json['reading'] is String &&
      json['mean'] is String;
}
// Adiciona um arquivo JSON formatado ao banco de dados
Future<String> addJsonToDatabase({String? jsonFilePath, Uint8List? jsonBytes}) async {
  if (jsonFilePath == null && jsonBytes == null) {
    return '400'; // Nenhum dado fornecido
  }

  String jsonString;

  // Lê o conteúdo do JSON de acordo com a origem fornecida
  if (jsonFilePath != null) {
    final file = File(jsonFilePath);

    if (!await file.exists()) {
      return '404'; // Arquivo não encontrado
    }

    jsonString = await file.readAsString(encoding: utf8);
  } else if (jsonBytes != null) {
    jsonString = utf8.decode(jsonBytes);
  } else {
    return '400'; // Nenhum dado válido fornecido
  }

  try {
    // Decodifica o JSON
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    // Validações do JSON principal
    if (!jsonData.containsKey('filename') || jsonData['filename'] is! String) {
      return '400'; // Formato do JSON incorreto: falta 'filename'
    }

    final filename = jsonData['filename'] as String;

    if (!jsonData.containsKey('content') || jsonData['content'] is! Map<String, dynamic>) {
      return '400'; // Formato do JSON incorreto: falta 'content'
    }

    final content = jsonData['content'] as Map<String, dynamic>;
    final tags = content['tags'] as List<dynamic>;
    final wordsJson = content['words'] as List<dynamic>;

    // Obtem a instância do Isar
    final isar = await getIsarInstance();

    // Verifica duplicação no banco de dados
    final existingFile = await isar.words.filter().filenameEqualTo(filename).findFirst();
    if (existingFile != null) {
      return '409'; // Conflito: arquivo já existe
    }

    // Validação e inserção de palavras
    await isar.writeTxn(() async {
      for (final wordJson in wordsJson) {
        if (wordJson is Map<String, dynamic> && validateJson(wordJson)) {
          final word = Word()
            ..word = wordJson['word']
            ..reading = wordJson['reading']
            ..mean = wordJson['mean']
            ..tags = tags.cast<String>()
            ..filename = filename;

          await isar.words.put(word);
        } else {
          print("Entrada inválida ignorada: $wordJson");
        }
      }
    });

    return '0'; // Sucesso
  } catch (e) {
    print('Erro ao processar o arquivo JSON: $e');
    return '500'; // Erro interno
  }
}



// Lista todos os filenames distintos no banco de dados
Future<Map<String, Set<String>>> listFilenamesWithTags() async {
  try {
    final isar = await getIsarInstance();

    // Obtém todas as palavras diretamente
    final allWords = await isar.words.where().findAll();

    // Agrupa tags por filename
    final Map<String, Set<String>> filenamesWithTags = {};

    for (var word in allWords) {
      if (!filenamesWithTags.containsKey(word.filename)) {
        filenamesWithTags[word.filename] = {};
      }
      filenamesWithTags[word.filename]!.addAll(word.tags);
    }

    return filenamesWithTags;
  } catch (e) {
    print('Erro ao listar filenames: $e');
    return {};
  }
}


// Apaga todas as entradas relacionadas a um filename específico
Future<String> deleteFilename(String filename) async {
  try {
    final isar = await getIsarInstance();
    final result = await isar.writeTxn(() async {
      final deletedCount = await isar.words.filter().filenameEqualTo(filename).deleteAll();
      return deletedCount > 0
          ? "Todas as $deletedCount entradas relacionadas ao filename '$filename' foram apagadas."
          : "Nenhuma entrada encontrada para o filename '$filename'.";
    });
    return result;
  } catch (e) {
    print('Erro ao deletar entradas para o filename $filename: $e');
    return '500'; // Erro interno ao tentar deletar
  }
}

// Retorna todas as palavras associadas a um ou mais filenames
Future<List<Word>> getWordsByFilenames(List<String> filenames) async {
  try {
    final isar = await getIsarInstance();
    final results = <Word>[];

    for (final filename in filenames) {
      final words = await isar.words.filter().filenameEqualTo(filename).findAll();
      results.addAll(words);
    }

    return results;
  } catch (e) {
    print('Erro ao buscar palavras para os filenames: $e');
    return [];
  }
}

// Exporta os dados de um ou mais filenames como JSON
Future<String> exportWordsToJson(List<String> filenames, String outputPath) async {
  try {
    final words = await getWordsByFilenames(filenames);

    final groupedWords = <String, dynamic>{};
    for (final filename in filenames) {
      groupedWords[filename] = words
          .where((word) => word.filename == filename)
          .map((word) => {
                'word': word.word,
                'reading': word.reading,
                'mean': word.mean,
                'tags': word.tags,
              })
          .toList();
    }

    final jsonString = jsonEncode(groupedWords);
    final file = File(outputPath);
    await file.writeAsString(jsonString);
    return "Dados exportados para $outputPath.";
  } catch (e) {
    print('Erro ao exportar dados para JSON: $e');
    return '500'; // Erro interno ao exportar
  }
} 