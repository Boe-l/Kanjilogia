import 'dart:async';
import 'dart:js_interop';
import 'dart:js_util';
import 'package:flutter/foundation.dart';
import 'package:kanjilogia/common/debg.dart';
import 'package:flutter/services.dart'; // For encoding bytes into Base64
/// Extension type for `Window`
extension type Window(JSObject _) implements JSObject {}

/// Extension type for `FontMetadata`
extension type FontMetadata(JSObject _) implements JSObject {
  external JSPromise<Blob> blob(); // Retrieves the font blob
  external String get postscriptName;
  external String get fullName;
  external String get family;
  external String get style;
}

@JS("Blob")
extension type Blob._(JSObject _) implements JSObject {
  external factory Blob(JSArray<JSArrayBuffer> blobParts, JSObject? options);

  /// Creates a Blob from a list of bytes
  factory Blob.fromBytes(List<int> bytes) {
    final data = Uint8List.fromList(bytes).buffer.toJS;
    return Blob([data].toJS, null);
  }

  external int get size; // Gets the size of the blob
  external JSPromise<JSArrayBuffer> arrayBuffer(); // Converts blob to bytes
}

/// Extension for accessing the `queryLocalFonts` method on `Window`
extension WindowExtensions on Window {
  external JSPromise<JSAny> queryLocalFonts([JSObject? options]);
}

/// Converts `JSPromise` to `Future`
Future<T> promiseToFuture<T extends JSAny>(JSPromise<T> promise) {
  final completer = Completer<T>();

  final resolve = allowInterop((result) {
    completer.complete(result as T);
  });

  final reject = allowInterop((error) {
    completer.completeError(error);
  });

  try {
    callMethod(promise, 'then', [resolve, reject]);
  } catch (e) {
    completer.completeError('Error calling method: $e');
  }

  return completer.future;
}

/// Class to manage local fonts
class LocalFonts {
  /// Lists available fonts, opcionalmente filtrando por nome
  Future<List<FontMetadata>> listFonts([String? fontname]) async {
    if (!kIsWeb) {
      Debg().error('LocalFonts only works on web platforms.');
      return [];
    }

    final options = jsify({
      'postscriptNames':
          fontname != null && fontname.isNotEmpty ? [fontname] : [],
    });

    try {
      final window = Window(globalThis as JSObject);
      final jsPromise = fontname != null && fontname.isNotEmpty
          ? window.queryLocalFonts(options) as JSPromise<JSObject>
          : window.queryLocalFonts() as JSPromise<JSObject>;

      final jsArray = await promiseToFuture(jsPromise);

      if (jsArray is! JSArray) {
        throw Exception('Result is not a JSArray.');
      }

      final fontsArray = jsArray.toDart;
      List<FontMetadata> fonts = [];

      for (var i = 0; i < fontsArray.length; i++) {
        final jsObject = fontsArray[i] as JSObject;

        // Convert JSObject to FontMetadata explicitly
        final font = FontMetadata(jsObject);
        if (fontname == null || font.postscriptName == fontname) {
          fonts.add(font);
        }
      }

      if (fonts.isEmpty) {
        Debg().info('Font "$fontname" not found.');
      }

      return fonts;
    } catch (e, stack) {
      Debg().error('Could not load local fonts: $e');
      Debg().error('Stack trace: $stack');
      return [];
    }
  }

  /// Loads a specific font and registers it with Flutter
  Future<void> loadFont(String fontname) async {
    if (!kIsWeb) {
      Debg().error('LocalFonts only works on web platforms.');
      return;
    }

    try {
      final fonts = await listFonts(fontname);
      if (fonts.isNotEmpty) {
        final font = fonts.first;

        Debg().info('Font "$fontname" found!');

        final blob = await font.blob().toDart;
        final fontBytes = await getBlobBytes(blob);
        Debg().info('Font bytes loaded: ${fontBytes.length} bytes');

        final fontLoader = FontLoader(fontname);
        fontLoader.addFont(Future.value(ByteData.sublistView(fontBytes)));
        await fontLoader.load();

        Debg().info('Font "$fontname" loaded!');
      } else {
        Debg().info('Font "$fontname" not found.');
      }
    } catch (e) {
      Debg().error('Could not load font: $e');
    }
  }

  /// Retrieves the bytes of a Blob
  Future<Uint8List> getBlobBytes(Blob blob) async {
    if (!kIsWeb) {
      Debg().error('LocalFonts only works on web platforms.');
      throw UnsupportedError('Blob operations are only supported on the web.');
    }

    try {
      final arrayBuffer = await promiseToFuture(blob.arrayBuffer());
      return Uint8List.view(arrayBuffer.toDart);
    } catch (e) {
      Debg().error('Failed to obtain blob bytes: $e');
      rethrow;
    }
  }
}//TODO: implement windows and mobile method 