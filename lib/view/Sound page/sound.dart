import 'dart:async';
import 'package:clarity/model/model.dart';
import 'package:clarity/new_firebase_service.dart';
import 'package:flutter/material.dart';
import '../sound mixing page/fixedrelaxationmix.dart';
import 'AudioManager.dart';
import 'remix.dart';
import 'sound_tile.dart';

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
    _audioManager.selectedTitlesNotifier.addListener(() {
      final selectedTitles = _audioManager.selectedSoundTitles;
      setState(() {
        for (var sound in _sounds) {
          sound.isSelected = selectedTitles.contains(sound.title);
        }
      });
    });
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

    if (sound.isSelected) {
      final selected = _sounds.where((s) => s.isSelected).toList();
      _audioManager.ensurePlayers(selected);
      _audioManager.playSound(sound.title);
      _audioManager.playAll();
    } else {
      _audioManager.pauseSound(sound.title);
    }
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
                  },
                  onPlay: () async {
                    await _audioManager.playAll();
                  },
                  onPause: () async {
                    await _audioManager.pauseAll();
                  },
                  imagePath: 'assets/images/remix_image.png',
                  soundCount: selectedSounds.length,
                  isPlaying: isSoundPlaying,
                );
              },
            ),
        ],
      ),
    );
  }
}

