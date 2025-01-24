import 'package:flutter/foundation.dart'; // Para o kIsWeb

/// Stub para plataformas não web
class LocalFonts {
  Future<List<dynamic>> listFonts([String? fontname]) async {
    debugPrint('LocalFonts is not supported on this platform.');
    return [];
  }

  Future<void> loadFont(String fontname) async {
    debugPrint('LocalFonts is not supported on this platform.');
  }
}
