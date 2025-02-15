// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kanjilogia/common/theme.dart';

import 'package:kanjilogia/common/transition.dart';
import 'package:kanjilogia/common/widget_transition.dart';
import 'package:kanjilogia/pages/history_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class GameOverWidget extends StatefulWidget {
  final Function() restart;
  final Map<String, List<dynamic>> correctItems;
  final Map<String, List<dynamic>> errorItems;
  const GameOverWidget({
    super.key,
    required this.restart,
    required this.correctItems,
    required this.errorItems,
  });

  @override
  GameOverWidgetState createState() => GameOverWidgetState(
      restart: restart, correctItems: correctItems, errorItems: errorItems);
}

class GameOverWidgetState extends State<GameOverWidget> {
  final Function() restart;
  final Map<String, List<dynamic>> correctItems;
  final Map<String, List<dynamic>> errorItems;
  bool isHovered1 = false;
  bool isHovered2 = false;
  bool isHovered3 = false;
  GameOverWidgetState(
      {required this.restart,
      required this.correctItems,
      required this.errorItems});

  @override
  Widget build(BuildContext context) {
    ColorPalette colorPalette = Provider.of<ColorPalette>(context);

    final List<VoidCallback> buttonActions = [
      () => restart(),
      () => navigateWithCircularAnimation(
            context,
            History(correctItems: correctItems, incorrectItems: errorItems),
          ),
      () => Navigator.pop(context),
    ];
    final List<String> buttonLabels = [
      AppLocalizations.of(context)!.gs_game_restart2,
      AppLocalizations.of(context)!.gs_open_history,
      AppLocalizations.of(context)!.gs_go_main_menu,
    ];
    return LayoutBuilder(builder: (context, constraints) {
      return Center(
        child: CircularRevealAnimationWidget(
          widget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.gs_game_ended1,
                style: GoogleFonts.rampartOne(
                    fontSize: 34, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 32),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double buttonWidth =
                        constraints.maxWidth * 0.8; // 80% da largura disponível
                    double buttonHeight =
                        buttonWidth * 0.15; // Mantemos proporção

                    return Column(
                      children: [
                        for (var i = 0; i < 3; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: SizedBox(
                              width: buttonWidth,
                              height: buttonHeight,
                              child: MouseRegion(
                                onEnter: (_) =>
                                    setState(() => _hoverStates[i] = true),
                                onExit: (_) =>
                                    setState(() => _hoverStates[i] = false),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  height: _hoverStates[i]
                                      ? buttonHeight * 1.2
                                      : buttonHeight,
                                  width: _hoverStates[i]
                                      ? buttonWidth * 1.1
                                      : buttonWidth,
                                  child: ElevatedButton(
                                    onPressed: buttonActions[i],
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          colorPalette.fillColor[0],
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: colorPalette.borderColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      padding:
                                          EdgeInsets.all(buttonHeight * 0.2),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            buttonLabels[i],
                                            style: GoogleFonts.rampartOne(
                                                fontSize: buttonHeight *
                                                    0.35, // Proporcional ao botão
                                                fontWeight: FontWeight.w800,
                                                color: colorPalette.text),
                                          ),
                                        ),
                                        SizedBox(width: buttonHeight * 0.15),
                                        TweenAnimationBuilder<double>(
                                          duration: Duration(milliseconds: 200),
                                          tween: Tween<double>(
                                            begin: _hoverStates[i]
                                                ? buttonHeight * 0.5
                                                : buttonHeight * 0.45,
                                            end: _hoverStates[i]
                                                ? buttonHeight * 0.7
                                                : buttonHeight * 0.5,
                                          ),
                                          builder: (context, size, child) {
                                            return Icon(
                                              _buttonIcons[i],
                                              color: colorPalette.iconColor,
                                              size: size,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  final List<bool> _hoverStates = [false, false, false];

  final List<IconData> _buttonIcons = [
    Icons.restart_alt_outlined,
    Icons.history_outlined,
    Icons.home_outlined,
  ];
}
