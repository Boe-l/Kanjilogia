import 'dart:async';
import 'dart:js_interop';
import 'dart:js_util';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kanjilogia/common/debg.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  Future<List<FontMetadata>> listFontsmain([String? fontname]) async {
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

      if (!jsArray.isA<JSArray>()) {
        throw Exception('Result is not a JSArray.');
      }

      final fontsArray = jsArray as List;
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

  Future<List<String>> listFonts() async {
    try {
      final fonts = await listFontsmain();
      return fonts.map((font) => font.postscriptName).toList();
    } catch (e) {
      Debg().error("Erro ao carregar as fontes: $e");
      return []; // Retorna uma lista vazia em caso de erro
    }
  }

  Future<void> loadFont(String fontname) async {
    if (!kIsWeb) {
      Debg().error('LocalFonts only works on web platforms.');
      return;
    }
    fontname = fontname.replaceAll(' ', '-');
    try {
      final fonts = await listFontsmain(fontname);
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
        return;
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

  Future<void> showFontPickerPopup({
    required BuildContext context,
    required Function(String selectedFont) onFontSelected,
  }) async {
    List<String> fonts = [];

    try {
      fonts = await LocalFonts().listFonts();
    } catch (e) {
      Debg().error("Erro ao carregar fontes: $e");
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        List<String> filteredFonts = List.from(fonts);

        return StatefulBuilder(
          builder: (context, setState) {
            void filterFonts(String query) {
              setState(() {
                filteredFonts = fonts
                    .where((font) =>
                        font.toLowerCase().contains(query.toLowerCase()))
                    .toList();
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Color.fromRGBO(56, 16, 115, 1),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 570,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.main_searchtooltip,
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 109, 33, 223),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 109, 33, 223),
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: filterFonts,
                      ),
                      const SizedBox(height: 16),
                      filteredFonts.isEmpty
                          ?  Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  AppLocalizations.of(context)!.fonts_not_available,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          : Expanded(
                              child: ScrollConfiguration(
                                behavior:
                                    ScrollConfiguration.of(context).copyWith(
                                  dragDevices: {
                                    PointerDeviceKind.mouse,
                                    PointerDeviceKind.touch,
                                  },
                                  scrollbars: false,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredFonts.length,
                                  itemBuilder: (context, index) {
                                    final fontName = filteredFonts[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: const Color.fromARGB(
                                            255, 67, 19, 138),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 12.0,
                                        ),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Nome da fonte ajustado com FittedBox
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                fontName,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: fontName,
                                                  fontSize: 18,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          onFontSelected(fontName);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
