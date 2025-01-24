// lib/widgets/font_selector_dialog.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'fontsweb.dart'; // Importe o LocalFonts e FontMetadata

class FontSelectorDialog extends StatefulWidget {
  final Function(String) onFontSelected;

  const FontSelectorDialog({super.key, required this.onFontSelected});

  @override
  FontSelectorDialogState createState() => FontSelectorDialogState();
}

class FontSelectorDialogState extends State<FontSelectorDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Dialog(
            backgroundColor: const Color.fromARGB(255, 56, 16, 115),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 74, 32, 126),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Selecione uma Fonte',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(
                      color: Colors.white54,
                      height: 1,
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (query) {
                          setState(() {
                            _searchQuery = query; // Atualiza a pesquisa
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Pesquise por fonte...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<FontMetadata>>(
                        future: LocalFonts().listFonts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('Nenhuma fonte encontrada.'));
                          }

                          final fonts = snapshot.data!;
                          final filteredFonts = fonts
                              .where((font) => font.fullName.toLowerCase().contains(_searchQuery.toLowerCase()))
                              .toList();

                          return ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
                              scrollbars: false,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredFonts.length,
                              itemBuilder: (context, index) {
                                final font = filteredFonts[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                  child: Material(
                                    color: const Color.fromARGB(255, 74, 32, 126),
                                    borderRadius: BorderRadius.circular(16),
                                    elevation: 5,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        widget.onFontSelected(font.fullName); // Passa o nome da fonte
                                        Navigator.of(context).pop();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                        child: Text(
                                          font.fullName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        iconSize: 20,
                        padding: const EdgeInsets.all(8),
                        splashRadius: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
