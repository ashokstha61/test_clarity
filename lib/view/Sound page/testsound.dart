//this file works perfectly fine for sound page with multiple sound selection and playback

import 'package:clarity/model/model.dart';
import 'package:clarity/new_firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../sound mixing page/relaxationmix test.dart';
import 'remix.dart';
import 'sound_tile.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();

  factory AudioManager() => _instance;

  AudioManager._internal();

  final Map<String, AudioPlayer> _players = {};
  bool _isPlaying = false;

  Future<void> syncPlayers(List<NewSoundModel> selectedSounds) async {
    // 1. Collect keys to remove (safe snapshot)
    final keysToRemove = _players.keys
        .where((key) => !selectedSounds.any((s) => s.title == key))
        .toList();

    // 2. Stop and dispose players first
    for (final key in keysToRemove) {
      final player = _players[key];
      if (player != null) {
        await player.pause();
        await player.dispose();
      }
    }

    // 3. Remove them AFTER loop to avoid concurrent modification
    for (final key in keysToRemove) {
      _players.remove(key);
    }

    // 4. Add or update selected
    for (final sound in selectedSounds) {
      final key = sound.title;
      if (!_players.containsKey(key)) {
        try {
          final player = AudioPlayer();
          await player.setAudioSource(
            AudioSource.uri(Uri.parse(sound.musicUrl)),
          );
          await player.setLoopMode(LoopMode.one);
          _players[key] = player;
          await player.play(); // auto-play
        } catch (e) {
          print("❌ Failed to initialize ${sound.title}: $e");
        }
      }
    }

    await adjustVolumes(selectedSounds);

    _isPlaying = _players.values.any((p) => p.playing);
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

  Future<void> playAll() async {
    await Future.wait(
      _players.values.map((p) async {
        if (!p.playing) {
          await p.play();
        }
      }),
    );
    _isPlaying = true;
  }

  Future<void> pauseAll() async {
    await Future.wait(
      _players.values.map((p) async {
        if (p.playing) {
          await p.pause();
        }
      }),
    );
    _isPlaying = false;
  }

  bool get isPlaying => _isPlaying;
}

class SoundPage extends StatefulWidget {
  const SoundPage({super.key});

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  final DatabaseService _firebaseService = DatabaseService();
  List<NewSoundModel> _sounds = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSounds();
  }

  Future<void> _loadSounds() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sounds = await _firebaseService.fetchSoundData();
      setState(() {
        _sounds = sounds;
        print(_sounds);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load sounds: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleSoundSelection(int index) {
    final sound = _sounds[index];
    if (sound.isSelected) {
      // Deselect
      setState(() {
        _sounds[index] = _sounds[index].copyWith(isSelected: false);
      });
    } else {
      // Select and ensure no duplicates
      if (!_sounds.any((s) => s.title == sound.title && s.isSelected)) {
        setState(() {
          _sounds[index] = _sounds[index].copyWith(isSelected: true);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${sound.title} is already selected')),
        );
        return;
      }
    }

    final selected = _sounds.where((s) => s.isSelected).toList();
    AudioManager().syncPlayers(selected);
  }

  Future<void> _playAllSelected() async {
    await AudioManager().playAll();
    setState(() {});
  }

  Future<void> _pauseAllSelected() async {
    await AudioManager().pauseAll();
    setState(() {});
  }

  bool _isAnySoundPlaying() {
    return AudioManager().isPlaying;
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
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSounds,
                child: const Text('Retry'),
              ),
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
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height:
                            MediaQuery.sizeOf(context).height - kToolbarHeight,
                        child: const Center(
                          child: Text(
                            'No sounds available',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _sounds.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            const Divider(height: 1),
                            SoundTile(
                              sound: _sounds[index],
                              onTap: () => _toggleSoundSelection(index),
                            ),
                            if (index == _sounds.length - 1)
                              const Divider(height: 1),
                          ],
                        );
                      },
                    ),
            ),
          ),
          if (selectedSounds.isNotEmpty)
            RelaxationMixBar(
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
                      ), // ✅ send full list
                    );
                  },
                );

                if (result != null) {
                  setState(() => _sounds = result);
                  final selected = _sounds.where((s) => s.isSelected).toList();
                  await AudioManager().syncPlayers(selected);
                }
              },

              onPlay: _playAllSelected,
              onPause: _pauseAllSelected,
              imagePath: 'assets/images/remix_image.png',
              soundCount: selectedSounds.length,
              isPlaying: _isAnySoundPlaying(),
            ),
        ],
      ),
    );
  }
}
