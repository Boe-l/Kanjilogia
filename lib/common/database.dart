import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:kanjilogia/common/debg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:idb_shim/idb_browser.dart';

import 'package:isar/isar.dart';

part 'database.g.dart';

const String _objectStoreName = 'content';

@Collection()
class Content {
  Id id = Isar.autoIncrement;
  late String filename;
  late List<String> tags;
  late List<Word> words;
  late List<GrammarQuestion> grammarQuestions;

  Content();

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content()
      ..filename = json['filename'] ?? ''
      ..tags = List<String>.from(json['tags'] ?? [])
      ..words = (json['words'] as List<dynamic>?)
              ?.map((e) => Word.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..grammarQuestions = (json['grammarQuestions'] as List<dynamic>?)
              ?.map((e) => GrammarQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'tags': tags,
      'words': words.map((e) => e.toJson()).toList(),
      'grammarQuestions': grammarQuestions.map((e) => e.toJson()).toList(),
    };
  }
}

@Embedded()
class Word {
  late String word;
  late List<String> reading;
  late String mean;
  late String filename;

  Word();

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word()
      ..word = json['word'] ?? ''
      ..reading = List<String>.from(json['reading'] ?? [])
      ..mean = json['mean'] ?? ''
      ..filename = json['filename'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'reading': reading,
      'mean': mean,
      'filename': filename,
    };
  }
}

@Embedded()
class GrammarQuestion {
  late String question;
  late String mean;
  late List<String> alternatives;
  late String correct;

  GrammarQuestion();

  factory GrammarQuestion.fromJson(Map<String, dynamic> json) {
    return GrammarQuestion()
      ..question = json['question'] ?? ''
      ..mean = json['mean'] ?? ''
      ..alternatives = List<String>.from(json['alternatives'] ?? [])
      ..correct = json['correct'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'mean': mean,
      'alternatives': alternatives,
      'correct': correct,
    };
  }
}

Isar? _isarInstance;
Future<Isar> getIsarInstance() async {
  if (_isarInstance != null) {
    return _isarInstance!;
  }

  try {
    final dir = await getApplicationDocumentsDirectory();

    _isarInstance = await Isar.open(
      [ContentSchema],
      directory: dir.path,
    );
  } catch (e) {
    Debg().error("getIsarInstance error: ${e.toString()}");

    rethrow;
  }

  return _isarInstance!;
}

Future<dynamic> getDbInstance() async {
  final dbFactory = getIdbFactory()?.open(
    'contentDatabase',
    version: 1,
    onUpgradeNeeded: (e) {
      final db = e.database;
      db.createObjectStore(_objectStoreName, keyPath: 'filename');
    },
  );
  return dbFactory;
}

bool validateWordJson(Map<String, dynamic> wordJson) {
  if (!wordJson.containsKey('word') ||
      !wordJson.containsKey('reading') ||
      !wordJson.containsKey('mean')) {
    return false;
  }

  if (wordJson['word'] is! String) return false;
  if (wordJson['reading'] is! List ||
      !(wordJson['reading'] as List).every((r) => r is String)) {
    return false;
  }
  if (wordJson['mean'] is! String) return false;

  return true;
}

Future<String> addJsonToDatabase(
    {String? jsonFilePath, Uint8List? jsonBytes}) async {
  Debg().info(
      "Trying to add json file, ['path': ${jsonFilePath != null ? "'true'" : "'false'"}, 'bytes': ${jsonBytes != null ? "'true'" : "'false'"}]");

  String jsonString;

  if (jsonFilePath != null) {
    final file = File(jsonFilePath);
    jsonString = await file.readAsString(encoding: utf8);
  } else if (jsonBytes != null) {
    jsonString = utf8.decode(jsonBytes);
  } else {
    Debg().error("Could not add file, null path, null bytes.");

    return '400';
  }

  String corrigirTexto(String texto) {
    return texto
        .replaceAll('ɡ', 'g')
        .replaceAll('ʌ', 'a')
        .replaceAll('ŋ', 'ng')
        .replaceAll('ʃ', 'x')
        .replaceAll('ç', 'c')
        .replaceAll('ø', 'o')
        .replaceAll('ñ', 'n')
        .replaceAll('ł', 'l')
        .replaceAll('å', 'a')
        .replaceAll('æ', 'ae')
        .replaceAll('œ', 'oe')
        .replaceAll('€', 'euro')
        .replaceAll('™', 'tm')
        .replaceAll('©', 'c');
  }

  try {
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    if (!jsonData.containsKey('filename') || jsonData['filename'] is! String) {
      Debg().error("Could not add file, invalid formatting.");

      return '400';
    }

    final filename = jsonData['filename'] as String;

    final content = jsonData;
    final tags = content['tags'] as List<dynamic>? ?? [];
    final wordsJson = content['words'] as List<dynamic>? ?? [];
    final grammarQuestionsJson =
        content['grammarQuestions'] as List<dynamic>? ?? [];

    if (wordsJson.isNotEmpty) {
      for (var wordJson in wordsJson) {
        if (wordJson is Map<String, dynamic>) {
          if (wordJson.containsKey('word')) {
            wordJson['word'] = corrigirTexto(wordJson['word'] ?? '');
          }

          if (wordJson.containsKey('reading') && wordJson['reading'] is List) {
            List<String> readings = List<String>.from(wordJson['reading']);
            for (int i = 0; i < readings.length; i++) {
              readings[i] = corrigirTexto(readings[i]);
            }
            wordJson['reading'] = readings;
          }
        }
      }
    }

    final allValid = wordsJson.every(
        (word) => word is Map<String, dynamic> && validateWordJson(word));

    if (!allValid) {
      Debg().error("Could not add file, invalid formatting.");

      return '500';
    }

    List<Word> words = [];
    if (kIsWeb) {
      final db = await getDbInstance();
      final txn = db.transaction(_objectStoreName, idbModeReadWrite);
      final store = txn.objectStore(_objectStoreName);
      final result = await store.getAll();

      for (final item in result) {
        if (item['filename'].contains(filename)) {
          Debg()
              .error("Could not add file, file with same name already exists.");

          return '409';
        }
      }

      List<Map<String, dynamic>> wordsList = [];
      List<Map<String, dynamic>> grammarQuestionsList = [];

      for (var wordJson in wordsJson) {
        if (wordJson is Map<String, dynamic>) {
          wordsList.add({
            'word': wordJson['word'] ?? '',
            'reading': List<String>.from(wordJson['reading'] ?? []),
            'mean': wordJson['mean'] ?? '',
            'filename': filename,
          });
        }
      }

      if (grammarQuestionsJson.isNotEmpty) {
        for (var questionJson in grammarQuestionsJson) {
          if (questionJson is Map<String, dynamic>) {
            grammarQuestionsList.add({
              'question': questionJson['question'] ?? '',
              'mean': questionJson['mean'] ?? '',
              'alternatives':
                  List<String>.from(questionJson['alternatives'] ?? []),
              'correct': questionJson['correct'] ?? '',
            });
          }
        }
      }

      final content = {
        'filename': filename,
        'tags': List<String>.from(tags),
        'words': wordsList,
        'grammarQuestions': grammarQuestionsList,
      };

      await store.put(content);
      await txn.completed;
    } else {
      final isar = await getIsarInstance();
      final existingFile =
          await isar.contents.filter().filenameEqualTo(filename).findFirst();
      if (existingFile != null) {
        Debg().error("Could not add file, file with same name already exists.");

        return '409';
      }

      await isar.writeTxn(() async {
        for (var wordJson in wordsJson) {
          if (wordJson is Map<String, dynamic>) {
            final word = Word()
              ..word = wordJson['word'] ?? ''
              ..reading = List<String>.from(wordJson['reading'] ?? [])
              ..mean = wordJson['mean'] ?? ''
              ..filename = filename;

            words.add(word);
          }
        }

        List<GrammarQuestion> grammarQuestions = [];

        if (grammarQuestionsJson.isNotEmpty) {
          for (var questionJson in grammarQuestionsJson) {
            if (questionJson is Map<String, dynamic>) {
              final question = GrammarQuestion()
                ..question = questionJson['question'] ?? ''
                ..mean = questionJson['mean'] ?? ''
                ..alternatives =
                    List<String>.from(questionJson['alternatives'] ?? [])
                ..correct = questionJson['correct'] ?? '';
              grammarQuestions.add(question);
            }
          }
        }

        final content = Content()
          ..filename = filename
          ..tags = List<String>.from(tags)
          ..words = words
          ..grammarQuestions = grammarQuestions;

        await isar.contents.put(content);
      });
    }

    Debg().info("File added successfully.");
    return '0';
  } catch (e) {
    Debg().error("addJsonToDatabase error: ${e.toString()}");
    return '500';
  }
}

Future<Map<String, Set<String>>> listFilenamesWithTags() async {
  if (kIsWeb) {
    final db = await getDbInstance();
    final txn = db.transaction(_objectStoreName, idbModeReadOnly);
    final store = txn.objectStore(_objectStoreName);
    final result = await store.getAll();
    await txn.completed;

    final Map<String, Set<String>> filenamesWithTags = {};
    for (final item in result) {
      final filename = item['filename'];
      final tags = item['tags'] ?? [];

      filenamesWithTags[filename] = Set<String>.from(tags);
    }

    return filenamesWithTags;
  } else {
    final isar = await getIsarInstance();

    final allContents = await isar.contents.where().findAll();

    final Map<String, Set<String>> filenamesWithTags = {};

    for (var content in allContents) {
      if (!filenamesWithTags.containsKey(content.filename)) {
        filenamesWithTags[content.filename] = {};
      }
      for (var tag in content.tags) {
        filenamesWithTags[content.filename]!.add(tag);
      }
    }

    return filenamesWithTags;
  }
}

Future<String> deleteFilename(String filename) async {
  if (kIsWeb) {
    final db = await getDbInstance();
    final txn = db.transaction(_objectStoreName, idbModeReadWrite);
    final store = txn.objectStore(_objectStoreName);
    await store.delete(filename);
    await txn.completed;
    return 'Arquivo deletado com sucesso';
  } else {
    final isar = await getIsarInstance();

    final result = await isar.writeTxn(() async {
      final deletedCount =
          await isar.contents.filter().filenameEqualTo(filename).deleteAll();

      return deletedCount > 0
          ? "Arquivo deletado com sucesso"
          : "Nenhuma entrada encontrada";
    });

    return result;
  }
}

Future<List<Map<String, dynamic>>> getContentsByFilenames(
    List<String> filenames) async {
  try {
    if (kIsWeb) {
      final db = await getDbInstance();
      final txn = db.transaction(_objectStoreName, idbModeReadOnly);
      final store = txn.objectStore(_objectStoreName);
      List<Map<String, dynamic>> results = [];

      for (final filename in filenames) {
        final object = await store.getObject(filename);
        if (object != null) {
          results.add(object);
        }
      }

      await txn.completed;
      return results;
    } else {
      final isar = await getIsarInstance();
      final results = <Map<String, dynamic>>[];

      for (final filename in filenames) {
        final contents =
            await isar.contents.filter().filenameEqualTo(filename).findAll();

        for (final content in contents) {
          results.add(content.toJson());
        }
      }

      return results;
    }
  } catch (e) {
    Debg().error("getContentsByFilenames error: ${e.toString()}");

    return [];
  }
}
