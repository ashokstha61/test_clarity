import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../model/model.dart';

bool isSoundPlaying = false;

class AudioManager {
  // Singleton
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final Map<String, AudioPlayer> _players = {};
  final Map<String, double> _volumeMap = {};
  final ValueNotifier<List<String>> selectedTitlesNotifier = ValueNotifier([]);
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);

  List<String> get selectedSoundTitles => selectedTitlesNotifier.value;

  bool isSelected(String title) => selectedSoundTitles.contains(title);

  void saveVolume(String title, double volume) {
    _volumeMap[title] = volume;
  }

  Future<void> ensurePlayers(List<NewSoundModel> sounds) async {
    // Remove players that are no longer in the sounds list
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
  }

  Future<void> onTapSound(List<NewSoundModel> sounds, NewSoundModel sound, bool isTrial) async {
    await ensurePlayers(sounds);

    final key = sound.title;
    final player = _players[key];
    if (player == null) {
      debugPrint("⚠️ Player not found for $key");
      return;
    }

    if (isTrial) {
      if (sound.isSelected) {
        await player.stop();
        sound.isSelected = false;
      } else {
        await player.seek(Duration.zero);
        await player.play();
        await player.setVolume(1.0);
        sound.isSelected = true;
      }
    } else {
      if (sound.isSelected) {
        await player.stop();
        sound.isSelected = false;
      } else {
        for (final other in sounds) {
          if (other.title != key && other.isSelected) {
            final otherPlayer = _players[other.title];
            if (otherPlayer != null) {
              await otherPlayer.stop();
            }
            other.isSelected = false;
          }
        }

        // await player.seek(Duration.zero);
        await player.play();
        await player.setVolume(1.0);
        sound.isSelected = true;
      }
    }
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

    // Restore saved volumes
    for (final sound in selectedSounds) {
      final savedVolume = getSavedVolume(
        sound.title,
        defaultValue: sound.volume.toDouble(),
      );
      sound.volume = savedVolume; // ✅ update model
      _volumeMap[sound.title] = savedVolume;
      await _players[sound.title]?.setVolume(savedVolume);
    }

    _updateSelectedTitles(selectedSounds);
    await adjustVolumes(selectedSounds);
  }

  double getSavedVolume(String title, {double defaultValue = 1.0}) {
    return _volumeMap[title] ?? defaultValue;
  }

  Future<void> playSound(String title) async {
    final player = _players[title];
    print(player);
    if (player != null && !player.playing) {
      await player.play();
    }
    isPlayingNotifier.value = true;
    isSoundPlaying = true;
  }

  Future<void> pauseSound(String title) async {
    final player = _players[title];
    if (player != null && player.playing) {
      await player.pause();
    }
  }

  Future<void> playAll() async {
    isPlayingNotifier.value = true;
    isSoundPlaying = true;
    await Future.wait(
      _players.values.map((p) async {
        if (!p.playing) await p.play();
      }),
    );
  }

  Future<void> pauseAll() async {
    await Future.wait(
      _players.values.map((p) async {
        if (p.playing) await p.pause();
      }),
    );
    isPlayingNotifier.value = false;
    isSoundPlaying = false;
  }

  /// Adjust volume based on number of playing sounds
  Future<void> adjustVolumes(List<NewSoundModel> selectedSounds) async {
    for (final s in selectedSounds) {
      final player = _players[s.title];
      if (player != null) {
        _volumeMap[s.title] = s.volume.toDouble();
        await player.setVolume(
          s.volume.toDouble(),
        ); // use the actual slider value
      }
    }
  }

  void _updateSelectedTitles(List<NewSoundModel> selectedSounds) {
    selectedTitlesNotifier.value = selectedSounds.map((s) => s.title).toList();

    debugPrint("Selected from sync: ${selectedTitlesNotifier.value}");
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    // selectedTitlesNotifier.dispose();
    // isPlayingNotifier.dispose();
  }
}
