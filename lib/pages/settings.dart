import 'package:flutter/material.dart';
import 'package:kanjilogia/common/langstuff.dart';
import 'package:kanjilogia/common/sharedpref.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _maxTime = 60;

  Future<void> _getMaxTime() async {
    final maxTime = await SharedPrefs().getMaxTime();
    setState(() {
      _maxTime = maxTime;
    });
    localinfo = await getcurrentlocale();
  }

  Future<void> _updateMaxTime(int time) async {
    await SharedPrefs().saveMaxTime(time);
  }

  void _changeFont() {
//TODO: change fonts
  }

  Future getcurrentlocale() async {
    Locale locale = await SharedPrefs().getLocale();
    final flag = LocaleUtils.getFlagPath(locale.toString());
    final langname = LocaleUtils.getLanguageName(locale);
    return [flag, langname];
  }

  List localinfo = [];
  @override
  void initState() {
    super.initState();
    _getMaxTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 56, 16, 115), // Fundo roxo mais escuro
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: ListView(
            children: [
              // Seção Tempo de Resposta
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                      255, 67, 19, 138), // Roxo intermediário
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer, // Ícone de relógio
                          color:
                              Colors.white70, // Cor para combinar com o texto
                          size: 18, // Tamanho do ícone
                        ),
                        const SizedBox(
                            width: 8), // Espaço entre o ícone e o texto
                        Text(
                          AppLocalizations.of(context)!.maxtimehint(_maxTime),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _maxTime.toDouble(),
                      min: 10,
                      max: 60,
                      divisions: 5,
                      label: AppLocalizations.of(context)!
                          .mp_slider_text(_maxTime),
                      activeColor: const Color.fromARGB(255, 152, 99, 233),
                      thumbColor: const Color.fromARGB(255, 98, 49, 172),
                      onChanged: (newTime) {
                        setState(() {
                          _maxTime = newTime.toInt();
                        });
                        _updateMaxTime(_maxTime);
                      },
                    ),
                  ],
                ),
              ),

              // Seção Fonte
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 67, 19, 138),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.font_download,
                    color: Colors.white,
                    size: 32,
                  ),
                  title: const Text(
                    'KaiTi',//Current font name
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  subtitle:  Text(
                    AppLocalizations.of(context)!
                          .fonts_count('297'),
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.white70),
                  onTap: _changeFont,
                ),
              ),

              // Seção Idioma
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                      255, 67, 19, 138), // Roxo intermediário
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      localinfo.isNotEmpty
                          ? localinfo[0]
                          : LocaleUtils.getFlagPath(
                              ''), // Substitua pelo caminho da bandeira
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    '${AppLocalizations.of(context)!.settings_language}:',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  subtitle: Text(
                    localinfo.isNotEmpty
                        ? localinfo[1]
                        : 'Null', // Substitua pelo idioma real
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.white70),
                  onTap: () async {
                    await LocaleUtils().showLanguageSelector(context);
                    localinfo = await getcurrentlocale();
                  },
                ),
              ),
              // Container(
              //     margin:
              //         const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       color: const Color.fromARGB(
              //           255, 67, 19, 138), // Roxo intermediário
              //       borderRadius: BorderRadius.circular(12),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.2),
              //           blurRadius: 8,
              //           offset: const Offset(0, 4),
              //         ),
              //       ],
              //     ),
              //     child: ListTile(

              //       title: Text(
              //         'Placeholder',
              //         style: TextStyle(color: Colors.white, fontSize: 16),
              //       ),
              //       subtitle: Text(
              //         'Placeholder', // Substitua pelo idioma real
              //         style: TextStyle(color: Colors.white70),
              //       ),
              //       trailing:
              //           const Icon(Icons.chevron_right, color: Colors.white70),
              //       onTap: () async {
              //         await LocaleUtils().showLanguageSelector(context);
              //           localinfo = await getcurrentlocale();

              //       },
              //     ),
              //   ),
              // // Container(
              //     margin:
              //         const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       color: const Color.fromARGB(
              //           255, 67, 19, 138), // Roxo intermediário
              //       borderRadius: BorderRadius.circular(12),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.2),
              //           blurRadius: 8,
              //           offset: const Offset(0, 4),
              //         ),
              //       ],
              //     ),
              //     child: ListTile(

              //       title: Text(
              //         'Placeholder',
              //         style: TextStyle(color: Colors.white, fontSize: 16),
              //       ),
              //       subtitle: Text(
              //         'Placeholder', // Substitua pelo idioma real
              //         style: TextStyle(color: Colors.white70),
              //       ),
              //       trailing:
              //           const Icon(Icons.chevron_right, color: Colors.white70),
              //       onTap: () async {
              //         await LocaleUtils().showLanguageSelector(context);
              //           localinfo = await getcurrentlocale();

              //       },
              //     ),
              //   ),
              // Container(
              //     margin:
              //         const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       color: const Color.fromARGB(
              //           255, 67, 19, 138), // Roxo intermediário
              //       borderRadius: BorderRadius.circular(12),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.2),
              //           blurRadius: 8,
              //           offset: const Offset(0, 4),
              //         ),
              //       ],
              //     ),
              //     child: ListTile(

              //       title: Text(
              //         'Placeholder',
              //         style: TextStyle(color: Colors.white, fontSize: 16),
              //       ),
              //       subtitle: Text(
              //         'Placeholder', // Substitua pelo idioma real
              //         style: TextStyle(color: Colors.white70),
              //       ),
              //       trailing:
              //           const Icon(Icons.chevron_right, color: Colors.white70),
              //       onTap: () async {
              //         await LocaleUtils().showLanguageSelector(context);
              //           localinfo = await getcurrentlocale();

              //       },
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
