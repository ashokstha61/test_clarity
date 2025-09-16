import 'dart:async';
import 'package:clarity/model/model.dart';
import 'package:clarity/new_firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../sound mixing page/fixedrelaxationmix.dart';
import 'remix.dart';
import 'sound_tile.dart';

class AudioManager {
  final Map<String, AudioPlayer> _players = {};
  final Map<String, StreamSubscription<bool>> _subscriptions = {};
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);

  List<String> selectedSoundTitles = [];

  bool isSelected(String title) {
    return selectedSoundTitles.contains(title);
  }

  Future<void> syncPlayers(List<NewSoundModel> selectedSounds) async {
    selectedSoundTitles = selectedSounds.map((s) => s.title).toList();

    // Remove players not in selection
    final keysToRemove = _players.keys
        .where((key) => !selectedSounds.any((s) => s.title == key))
        .toList();

    for (final key in keysToRemove) {
      final player = _players.remove(key);
      if (player != null) {
        await player.pause();
        await player.dispose();
      }
      await _subscriptions[key]?.cancel();
      _subscriptions.remove(key);
    }

    // Add missing players in parallel
    final futures = selectedSounds.map((sound) async {
      final key = sound.title;
      if (!_players.containsKey(key)) {
        try {
          final player = AudioPlayer();
          _players[key] = player;

          // Setup audio source and loop mode
          await player.setAudioSource(AudioSource.uri(Uri.parse(sound.musicUrl)));
          await player.setLoopMode(LoopMode.one);

          // Listen to player state
          _subscriptions[key] = player.playingStream.listen((_) {
            _updatePlayingState();
          });

          // Auto-play
          await player.play();
        } catch (e) {
          debugPrint("❌ Failed to initialize ${sound.title}: $e");
        }
      }
    });

    // Wait for all players to finish initializing
    await Future.wait(futures);

    await adjustVolumes(selectedSounds);
    _updatePlayingState();
  }

  Future<void> adjustVolumes(List<NewSoundModel> selectedSounds) async {
    final count = _players.length;
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

  Future<void> removeSound(String title) async {
    final player = _players.remove(title);
    if (player != null) {
      await player.pause();
      await player.dispose();
    }
    await _subscriptions[title]?.cancel();
    _subscriptions.remove(title);
    _updatePlayingState();
  }

  void _updatePlayingState() {
    isPlayingNotifier.value = _players.values.any((p) => p.playing);
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

  Future<void> dispose() async {
    for (final sub in _subscriptions.values) {
      await sub.cancel();
    }
    _subscriptions.clear();

    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}


/// UI Page

class SoundPage extends StatefulWidget {
  const SoundPage({super.key});

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  final DatabaseService _firebaseService = DatabaseService();
  final AudioManager _audioManager = AudioManager(); // 👈 instance here

  static List<NewSoundModel>? _cachedSounds;
  List<NewSoundModel> _sounds = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (_cachedSounds != null) {
      _sounds = _cachedSounds!;
    } else {
      _loadSounds();
    }
  }

  @override
  void dispose() {
    _audioManager.dispose(); // 👈 clean up players
    super.dispose();
  }

  Future<void> _loadSounds() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sounds = await _firebaseService.fetchSoundData();
      for (var sound in sounds) {
        sound.isSelected = _audioManager.selectedSoundTitles.contains(sound.title);
      }
      _cachedSounds = sounds;

      setState(() {
        _sounds = sounds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load sounds: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleSoundSelection(int index) async {
    final sound = _sounds[index];
    setState(() {
      sound.isSelected = !sound.isSelected;
    });

    final selected = _sounds.where((s) => s.isSelected).toList();
    await _audioManager.syncPlayers(selected);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadSounds, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final selectedSounds = _sounds.where((s) => s.isSelected).toList();

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadSounds,
              child: _sounds.isEmpty
                  ? const Center(child: Text('No sounds available'))
                  : ListView.builder(
                itemCount: _sounds.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      SoundTile(
                        sound: _sounds[index],
                        onTap: () => _toggleSoundSelection(index),
                      ),
                      const Divider(height: 1),
                    ],
                  );
                },
              ),
            ),
          ),
          if (selectedSounds.isNotEmpty)
            ValueListenableBuilder<bool>(
              valueListenable: _audioManager.isPlayingNotifier,
              builder: (context, isPlaying, _) {
                return RelaxationMixBar(
                  onArrowTap: () async {
                    final result = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: RelaxationMixPage(
                            sounds: _sounds,
                            onSoundsChanged: (newSounds) {},
                          ),
                        );
                      },
                    );
                    if (result != null) {
                      setState(() => _sounds = result);
                      final selected = _sounds.where((s) => s.isSelected).toList();
                      await _audioManager.syncPlayers(selected);
                    }
                  },
                  onPlay: _audioManager.playAll,
                  onPause: _audioManager.pauseAll,
                  imagePath: 'assets/images/remix_image.png',
                  soundCount: selectedSounds.length,
                  isPlaying: isPlaying,
                );
              },
            ),
        ],
      ),
    );
  }
}

