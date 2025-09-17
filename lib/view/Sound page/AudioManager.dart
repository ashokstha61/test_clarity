import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../model/model.dart';

class AudioManager {
  // Singleton
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final Map<String, AudioPlayer> _players = {};
  final ValueNotifier<List<String>> selectedTitlesNotifier = ValueNotifier([]);
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);

  List<String> get selectedSoundTitles => selectedTitlesNotifier.value;

  bool isSelected(String title) => selectedSoundTitles.contains(title);

  /// Create players only if they don't exist
  Future<void> ensurePlayers(List<NewSoundModel> sounds) async {
    final futures = sounds.map((sound) async {
      final key = sound.title;
      if (!_players.containsKey(key)) {
        try {
          final player = AudioPlayer();
          _players[key] = player;
          await player.setAudioSource(AudioSource.uri(Uri.parse(sound.musicUrl)));
          await player.setLoopMode(LoopMode.one);
          await player.setVolume(1);
        } catch (e) {
          debugPrint("❌ Failed to initialize ${sound.title}: $e");
        }
      }
    });

    await Future.wait(futures);
    // await adjustVolumes(sounds);
  }

  /// Sync players with current selection
  Future<void> syncPlayers(List<NewSoundModel> selectedSounds) async {
    // Dispose removed players
    final keysToRemove = _players.keys
        .where((key) => !selectedSounds.any((s) => s.title == key))
        .toList();

    for (final key in keysToRemove) {
      final player = _players.remove(key);
      await player?.dispose();
    }

    // Add new players
    for (final sound in selectedSounds) {
      if (!_players.containsKey(sound.title)) {
        final player = AudioPlayer();
        _players[sound.title] = player;
        await player.setAudioSource(AudioSource.uri(Uri.parse(sound.musicUrl)));
        await player.setLoopMode(LoopMode.one);
      }
    }

    _updateSelectedTitles(selectedSounds);
    await adjustVolumes(selectedSounds);
  }

  Future<void> playSound(String title) async {
    final player = _players[title];
    if (player != null && !player.playing) {
      await player.play();
      isPlayingNotifier.value = true;
    }
  }

  Future<void> pauseSound(String title) async {
    final player = _players[title];
    if (player != null && player.playing) {
      await player.pause();
      isPlayingNotifier.value = false;
    }
  }

  Future<void> playAll() async {
    await Future.wait(_players.values.map((p) async {
      if (!p.playing) await p.play();
    }));
    isPlayingNotifier.value = true;
  }

  Future<void> pauseAll() async {
    await Future.wait(_players.values.map((p) async {
      if (p.playing) await p.pause();
    }));
    isPlayingNotifier.value = false;
  }

  /// Adjust volume based on number of playing sounds
  Future<void> adjustVolumes(List<NewSoundModel> selectedSounds) async {
    final count = selectedSounds.length;
    if (count == 0) return;

    final baseAdjustment = count > 1 ? 0.8 / count : 1.0;

    for (final sound in selectedSounds) {
      final player = _players[sound.title];
      if (player != null) {
        final adjustedVolume = sound.volume * baseAdjustment;
        await player.setVolume(adjustedVolume);
      }
    }
  }

  void _updateSelectedTitles(List<NewSoundModel> selectedSounds) {
    selectedTitlesNotifier.value =
        selectedSounds.map((s) => s.title).toList();

    debugPrint("Selected from sync: ${selectedTitlesNotifier.value}");
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    selectedTitlesNotifier.dispose();
    isPlayingNotifier.dispose();
  }
}
