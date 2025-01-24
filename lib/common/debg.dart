import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class Debg {
  static final Debg _instance = Debg._internal();

  bool _isLoggingEnabled = true;

  Debg._internal();

  factory Debg() {
    return _instance;
  }

  void setLoggingEnabled(bool enabled) {
    _isLoggingEnabled = enabled;
  }

  void log(String message, int debugType) async {
    if (!_isLoggingEnabled) return;

    if (debugType < 0 || debugType > 5) {
      debugPrint("[ERROR] Invalid debug type: $debugType");
      return;
    }

    final debugTypeEnum = DebugType.values[debugType];
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = "[$timestamp] [${debugTypeEnum.name.toUpperCase()}] $message";

    if (kReleaseMode) {
      if (!kIsWeb) {
        await _saveLogToFile(logMessage);
      } else {
        debugPrint(logMessage);
      }
    } else {
      debugPrint(logMessage);
    }
  }

  Future<void> _saveLogToFile(String logMessage) async {
    try {
      final directory = await getApplicationDocumentsDirectory(); // Usará AppData\Local no Windows
      final date = DateTime.now();
      final fileName = "log_${date.year}-${date.month}-${date.day}.txt";
      final logFile = File('${directory.path}/$fileName');
      await logFile.writeAsString('$logMessage\n', mode: FileMode.append);
    } catch (e) {
      debugPrint("[ERROR] Failed to write log: $e");
    }
  }

  void info(String message) => log(message, 0);
  void warning(String message) => log(message, 1);
  void error(String message) => log(message, 2);
  void critical(String message) => log(message, 3);
  void exception(String message) => log(message, 4);
}

enum DebugType {
  info,      // 0
  warning,   // 1
  error,     // 2
  critical,  // 3
  exception, // 4
}
