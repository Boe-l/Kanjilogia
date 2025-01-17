import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:idb_shim/idb_browser.dart'; // Para a Web

import 'package:isar/isar.dart'; // Para dispositivos móveis e desktop

part 'makehive.g.dart'; // Certifique-se de que o arquivo gerado estará aqui

const String _objectStoreName = 'words';

// Criação de um modelo de dados
@Collection()
class Word {
  Id id = Isar.autoIncrement;
  late String word;
  late String reading;
  late String mean;
  late List<String> tags; // Lista de tags para cada palavra
  late String filename; // Armazenar o nome do arquivo associado
}
Isar? _isarInstance;
// Função para obter a instância do banco de dados
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

Future<dynamic> getDbInstance() async {
  
    // Se for Web, usar IndexedDB com idb_shim
    final dbFactory = getIdbFactory()?.open(
      'wordDatabase',
      version: 1,
      onUpgradeNeeded: (e) {
        final db = e.database;
        db.createObjectStore('words', keyPath: 'filename');
      },
    );
    return dbFactory;

    
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
// Função para adicionar palavras ao banco de dados
Future<String> addJsonToDatabase(
    {String? jsonFilePath, Uint8List? jsonBytes}) async {
  if (jsonFilePath == null && jsonBytes == null) {
    return '400'; // Nenhum dado fornecido
  }

  String jsonString;

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
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    if (!jsonData.containsKey('filename') || jsonData['filename'] is! String) {
      return '400'; // Formato do JSON incorreto: falta 'filename'
    }

    final filename = jsonData['filename'] as String;

    if (!jsonData.containsKey('content') ||
        jsonData['content'] is! Map<String, dynamic>) {
      return '400'; // Formato do JSON incorreto: falta 'content'
    }

    final content = jsonData['content'] as Map<String, dynamic>;
    final tags = content['tags'] as List<dynamic>;
    final wordsJson = content['words'] as List<dynamic>;

    // Obtém a instância do banco de dados
    
    final allValid = wordsJson.every((word) => validateJson(word));

    if (!allValid) {
      return '500';
    }

    if (kIsWeb) {
      final db = await getDbInstance();
      final txn = db.transaction('words', idbModeReadWrite);
      final store = txn.objectStore('words');
      final result = await store.getAll();

      for (final item in result) {
        if (item['filename'].contains(filename)) {
          return '409';
        }
      }
      //verificar se o arquivo ja existe na db

      await store.put({
        'filename': filename,
        'content': content,
      });
      await txn.completed;
    } else {
      // Se for outras plataformas, usar Isar
      final isar = await getIsarInstance();
      final existingFile =
          await isar.words.filter().filenameEqualTo(filename).findFirst();
      if (existingFile != null) {
        return '409'; // Conflito: arquivo já existe
      }

      await isar.writeTxn(() async {
        for (final wordJson in wordsJson) {
          if (wordJson is Map<String, dynamic>) {
            final word = Word()
              ..word = wordJson['word']
              ..reading = wordJson['reading']
              ..mean = wordJson['mean']
              ..tags = tags.cast<String>()
              ..filename = filename;
            await isar.words.put(word);
          }
        }
      });
    }

    return '0'; // Sucesso
  } catch (e) {
    print('Erro ao processar o arquivo JSON: $e');
    return '500'; // Erro interno
  }
}

// Lista todos os filenames distintos no banco de dados
// Lista todos os filenames distintos no banco de dados
Future<Map<String, Set<String>>> listFilenamesWithTags() async {
  

  if (kIsWeb) {
    final db = await getDbInstance();
    // Para Web, usar IndexedDB
    final txn = db.transaction('words', idbModeReadOnly);
    final store = txn.objectStore('words');
    final result = await store.getAll();
    await txn.completed;

    final Map<String, Set<String>> filenamesWithTags = {};
    for (final item in result) {
      final filename = item['filename'];
      final tags = item['content']['tags'];
      filenamesWithTags[filename] = Set<String>.from(tags);
    }

    return filenamesWithTags;
  } else {
    // Para outras plataformas, usar Isar
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
  }
}

// Apaga todas as entradas relacionadas a um filename específico
Future<String> deleteFilename(String filename) async {
  

  if (kIsWeb) {
    final db = await getDbInstance();
    final txn = db.transaction('words', idbModeReadWrite);
    final store = txn.objectStore('words');
    await store.delete(filename);
    await txn.completed;
    return 'Arquivo deletado com sucesso';
  } else {
    final isar = await getIsarInstance();
    final result = await isar.writeTxn(() async {
      final deletedCount =
          await isar.words.filter().filenameEqualTo(filename).deleteAll();
      return deletedCount > 0
          ? "Arquivo deletado com sucesso"
          : "Nenhuma entrada encontrada";
    });
    return result;
  }
}

Future<List<Word>> getWordsByFilenames(List<String> filenames) async {
  try {
    if (kIsWeb) {
      // Usar IndexedDB para Web
      final db = await getDbInstance();
      final txn = db.transaction(_objectStoreName, idbModeReadOnly);
      final store = txn.objectStore(_objectStoreName);
      List<Word> results = [];

      for (final filename in filenames) {
        final object = await store.getObject(filename);
        if (object != null) {
          final content = object['content'] as Map<String, dynamic>;
          final wordsJson = content['words'] as List<dynamic>;
          for (final wordJson in wordsJson) {
            if (wordJson is Map<String, dynamic>) {
              final word = Word()
                ..word = wordJson['word']
                ..reading = wordJson['reading']
                ..mean = wordJson['mean']
                ..tags = content['tags'].cast<String>()
                ..filename = filename;
              results.add(word);
            }
          }
        }
      }
      await txn.completed;
      return results;
    } else {
      // Usar Isar para outras plataformas
      final isar = await getIsarInstance();
      final results = <Word>[];

      for (final filename in filenames) {
        final words =
            await isar.words.filter().filenameEqualTo(filename).findAll();
        results.addAll(words);
      }

      return results;
    }
  } catch (e) {
    print('Erro ao buscar palavras para os filenames: $e');
    return [];
  }
}

Future<String> exportWordsToJson(
    List<String> filenames, String outputPath) async {
  try {
    List<Word> words;
    if (kIsWeb) {
      // Usar IndexedDB para Web
      final db = await getDbInstance();
      final txn = db.transaction(_objectStoreName, idbModeReadOnly);
      final store = txn.objectStore(_objectStoreName);
      words = [];

      for (final filename in filenames) {
        final object = await store.getObject(filename);
        if (object != null) {
          final content = object['content'] as Map<String, dynamic>;
          final wordsJson = content['words'] as List<dynamic>;
          for (final wordJson in wordsJson) {
            if (wordJson is Map<String, dynamic>) {
              final word = Word()
                ..word = wordJson['word']
                ..reading = wordJson['reading']
                ..mean = wordJson['mean']
                ..tags = content['tags'].cast<String>()
                ..filename = filename;
              words.add(word);
            }
          }
        }
      }
      await txn.completed;
    } else {
      // Usar Isar para outras plataformas
      words = await getWordsByFilenames(filenames);
    }

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
