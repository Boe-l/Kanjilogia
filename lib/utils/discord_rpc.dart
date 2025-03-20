import 'dart:io';

import 'package:discord_rich_presence/discord_rich_presence.dart';
import 'package:flutter/foundation.dart';
import 'package:kanjilogia/common/debg.dart';
import 'package:kanjilogia/common/sharedpref.dart';

class DiscordRichPresence {
  late Client client;
  bool isConnected = false;
  DateTime? _startTime;

  String title;
  String subtitle;
  String imageDetails;

  DiscordRichPresence({
    required this.title,
    required this.subtitle,
    required this.imageDetails,
  });

  Future<void> connect() async {
    if (isConnected) return;

    client = Client(clientId: '1180625493502992465'); // dont hack me pls 🤣
    await client.connect();
    isConnected = true;

    _startTime ??= DateTime.now();

    updateActivity();
  }

  Future<void> updateActivity({
    String? newTitle,
    String? newState,
    String? newDetails,
  }) async {
    if (!isConnected) return;

    if (newTitle != null) title = newTitle;
    if (newState != null) subtitle = newState;
    if (newDetails != null) imageDetails = newDetails;

    await client.setActivity(
      Activity(
        details: title,
        state: subtitle,
        name: 'minecraft',
        type: ActivityType.playing,
        timestamps: ActivityTimestamps(start: _startTime ?? DateTime.now()),
        assets: ActivityAssets(largeImage: 'icon-512', largeText: imageDetails),
        url: 'https://boe-l.github.io/Kanjilogia/',
      ),
    );
  }

  Future<void> disconnect() async {
    try {
      await client.disconnect();
      isConnected = false;
    } catch (e) {
      Debg().error("Erro ao desconectar: $e");
    }
  }
}

class DiscordRichPresenceNotifier extends ChangeNotifier {
  late DiscordRichPresence _discordRichPresence;
  bool _isConnected = false;
  bool _isRichPresenceEnabled = false; // Controle da preferência do usuário

  DiscordRichPresenceNotifier() {
    _loadRichPresencePreference();
    _discordRichPresence = DiscordRichPresence(
      title: 'On Main Menu',
      subtitle: 'Idle',
      imageDetails: 'Kanjilogia',
    );

    // Verifica se o sistema operacional é Windows antes de tentar conectar
    if (!kIsWeb && _isRichPresenceEnabled && Platform.isWindows) {
      connect();
    }
  }

  bool get isConnected => _isConnected;
  bool get isRichPresenceEnabled => _isRichPresenceEnabled;
  DiscordRichPresence get discordRichPresence => _discordRichPresence;

  // Carregar a preferência do usuário
  Future<void> _loadRichPresencePreference() async {
    // final prefs = await SharedPreferences.getInstance();
    _isRichPresenceEnabled = await SharedPrefs().getRPC(); // True por padrão
    notifyListeners();
  }

  // Salvar a preferência do usuário
  Future<void> _saveRichPresencePreference(bool value) async {
    // final prefs = await SharedPreferences.getInstance();
    await SharedPrefs().saveRPC(value);
  }

  Future<void> connect() async {
    if (!_isConnected) {
      await _discordRichPresence.connect();
      _isConnected = true;
      notifyListeners();
    }
  }

  Future<void> updateActivity({
    required String title,
    required String subtitle,
    required String imageDetails,
  }) async {
    if (_isConnected) {
      await _discordRichPresence.updateActivity(
        newTitle: title,
        newState: subtitle,
        newDetails: imageDetails,
      );
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    if (_isConnected) {
      await _discordRichPresence.disconnect();
      _isConnected = false;
      notifyListeners();
    }
  }

  // Ativar/desativar o Rich Presence
  Future<void> toggleRichPresence(bool value) async {
    _isRichPresenceEnabled = value;
    await _saveRichPresencePreference(value); // Salva a escolha do usuário
    notifyListeners();

    if (!kIsWeb && _isRichPresenceEnabled && Platform.isWindows) {
      connect();
    } else {
      disconnect();
    }
  }
}
