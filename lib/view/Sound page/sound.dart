import 'dart:async';
import 'package:clarity/model/model.dart';
import 'package:clarity/new_firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../model/usermodel.dart';
import '../sound mixing page/fixedrelaxationmix.dart';
import 'AudioManager.dart';
import 'remix.dart';
import 'sound_tile.dart';

bool _trialDialogShown = false;
bool isTrial = true;

class SoundPage extends StatefulWidget {
  const SoundPage({super.key});

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  final DatabaseService _firebaseService = DatabaseService();
  final AudioManager _audioManager = AudioManager(); // 👈 instance here

  static List<NewSoundModel>? _cachedSounds;
  late final UserModel userData;
  List<NewSoundModel> _sounds = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _freeTrialTimer;

  @override
  void initState() {
    super.initState();
    if (_cachedSounds != null) {
      _sounds = _cachedSounds!;
    } else {
      _loadSounds();
    }

    // Listen to audio manager selection changes
    _audioManager.selectedTitlesNotifier.addListener(_onSelectionChanged);
    loadUserInfo();
  }

  void _onSelectionChanged() {
    final selectedTitles = _audioManager.selectedSoundTitles;
    if (mounted) {
      setState(() {
        for (var sound in _sounds) {
          sound.isSelected = selectedTitles.contains(sound.title);
        }
      });
    }
  }

  @override
  void dispose() {
    _audioManager.selectedTitlesNotifier.removeListener(_onSelectionChanged);
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
        sound.isSelected = _audioManager.selectedSoundTitles.contains(
          sound.title,
        );
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

    // Use the updated method that handles trial/non-trial logic
    await _audioManager.toggleSoundSelection(_sounds, sound, isTrial);

    // The state will be updated automatically via the listener
    // setState(() {
    //  if(sound.isSelected) {
    //    sound.isSelected = false;
    //  } else {
    //    sound.isSelected = true;
    //  }
    // }); // Trigger rebuild to reflect changes
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
                  ? const Center(child: Text('No sounds available'))
                  : ListView.builder(
                itemCount: _sounds.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      SoundTile(
                        sound: _sounds[index],
                        onTap: () => _toggleSoundSelection(index),
                        isTrail: isTrial,
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
                    final result = await showModalBottomSheet<List<NewSoundModel>>(
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
                            sounds: List.from(_sounds), // Pass a copy of current sounds
                            onSoundsChanged: (newSounds) {
                              // This callback will be called when sounds change in mix page
                              if (mounted) {
                                setState(() {
                                  _sounds = newSounds;
                                });
                              }
                            },
                          ),
                        );
                      },
                    );

                    // If result is returned, update the sounds
                    if (result != null && mounted) {
                      setState(() {
                        _sounds = result;
                      });
                    }
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

  Future<void> loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        userData = UserModel.fromMap(doc.data()!);
        startFreeTrialCheck(userData);
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  void startFreeTrialCheck(UserModel user) {
    print("trialEndDate");
    _checkFreeTrialStatus(user);

    // Cancel any existing timer
    _freeTrialTimer?.cancel();

    // Check every minute
    _freeTrialTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (isTrial) {
        _checkFreeTrialStatus(user);
      }
    });
  }

  void stopFreeTrialCheck() {
    _freeTrialTimer?.cancel();
    _freeTrialTimer = null;
  }

  void _checkFreeTrialStatus(UserModel user) {
    final now = DateTime.now();
    final trialEndDate = user.creationDate?.add(const Duration(days: 7));
    print(now.toString());
    print(trialEndDate.toString());

    if (now.isAfter(trialEndDate!) || now.isAtSameMomentAs(trialEndDate)) {
      setState(() {
        isTrial = false;
        print("Trail is over ");
      });

      if (!_trialDialogShown) {
        _trialDialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Free Trial Ended'),
            content: const Text('You have completed our 7-day free trail'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Upgrade'),
              ),
            ],
          ),
        );
      }
    }
  }
}