import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:clarity/model/sound_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class RelaxationMixPage extends StatefulWidget {
  const RelaxationMixPage({super.key});

  @override
  State<RelaxationMixPage> createState() => _RelaxationMixPageState();
}

class _RelaxationMixPageState extends State<RelaxationMixPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<AudioPlayer> _audioPlayers = [];
  final List<SoundData> _selectedSounds = [];
  final Map<int, StreamSubscription> _playerStateSubscriptions = {};

  bool _isGlobalPlaying = false;
  bool _isLoadingPlayback = false;
  List<SoundData> _recommendedSounds = [];
  bool _isLoadingRecommendedSounds = false;

  @override
  void initState() {
    super.initState();
    _initAudioSession();
    _fetchRecommendedSounds();
  }

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.mixWithOthers,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: false,
        ),
      );
    } catch (e) {
      debugPrint('Error configuring audio session: $e');
    }
  }

  Future<void> _fetchRecommendedSounds() async {
    setState(() {
      _isLoadingRecommendedSounds = true;
    });
    debugPrint('Fetching sounds from Firestore...');

    try {
      final snapshot = await _firestore.collection('SoundData').get();
      debugPrint('Successfully fetched ${snapshot.docs.length} sounds');

      if (mounted) {
        setState(() {
          _recommendedSounds = snapshot.docs.map((doc) {
            debugPrint('Sound data: ${doc.data()}');
            return SoundData.fromFirestore(doc);
          }).toList();
          _isLoadingRecommendedSounds = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching sounds: $e');
      if (mounted) {
        setState(() {
          _isLoadingRecommendedSounds = false;
        });
        _showErrorSnackBar('Failed to load recommended sounds');
      }
    }
  }

  void _addSoundToMix(SoundData sound) async {
    if (_selectedSounds.contains(sound)) return;

    try {
      // Create new audio player
      final player = AudioPlayer();
      final index = _selectedSounds.length;

      // Set up audio source and configuration
      await player.setAudioSource(
        AudioSource.uri(Uri.parse(sound.musicURL)),
        preload: true,
      );
      await player.setLoopMode(LoopMode.all);
      await player.setVolume(sound.volume);

      // Set up player state listener
      final subscription = player.playerStateStream.listen(
        (state) {
          if (state.processingState == ProcessingState.idle &&
              state.playing == false &&
              _isGlobalPlaying) {
            debugPrint('Player for ${sound.title} stopped unexpectedly');
          }
        },
        onError: (error) {
          debugPrint('Player error for ${sound.title}: $error');
          _showErrorSnackBar('Audio error occurred for ${sound.title}');
        },
      );

      setState(() {
        _selectedSounds.add(sound);
        _audioPlayers.add(player);
        _playerStateSubscriptions[index] = subscription;
      });

      // Auto-play logic: Start playing when we have at least one sound
      // If this is the first sound added, start playing it
      if (_selectedSounds.length == 1 && !_isGlobalPlaying) {
        await _playAllSounds();
      }
      // If we're already playing (adding 2nd, 3rd sound, etc.), start this new sound immediately
      else if (_isGlobalPlaying) {
        await player.play();
        await _adjustVolumes();
      }
    } catch (e) {
      debugPrint('Error adding sound ${sound.title}: $e');
      _showErrorSnackBar('Failed to add ${sound.title}');
    }
  }

  // Also modify the _removeSoundFromMix method to handle auto-stop when going back to 1 sound:

  void _removeSoundFromMix(int index) async {
    if (index >= _selectedSounds.length) return;

    try {
      // Cancel subscription and dispose player
      _playerStateSubscriptions[index]?.cancel();
      _playerStateSubscriptions.remove(index);

      await _audioPlayers[index].dispose();

      setState(() {
        _selectedSounds.removeAt(index);
        _audioPlayers.removeAt(index);
      });

      // Only stop playback if all sounds are removed
      if (_selectedSounds.length == 0 && _isGlobalPlaying) {
        await _pauseAllSounds();
      }
      // Adjust volumes for remaining sounds if we're still playing
      else if (_audioPlayers.isNotEmpty && _isGlobalPlaying) {
        await _adjustVolumes();
      }
    } catch (e) {
      debugPrint('Error removing sound at index $index: $e');
      _showErrorSnackBar('Failed to remove sound');
    }
  }

  Future<void> _adjustVolumes() async {
    final playerCount = _audioPlayers.length;
    if (playerCount == 0) return;

    // Calculate base volume adjustment to prevent clipping
    final baseAdjustment = playerCount > 1 ? 0.8 / playerCount : 1.0;

    for (int i = 0; i < _audioPlayers.length; i++) {
      try {
        final adjustedVolume = _selectedSounds[i].volume * baseAdjustment;
        await _audioPlayers[i].setVolume(adjustedVolume);
      } catch (e) {
        debugPrint('Error adjusting volume for player $i: $e');
      }
    }
  }

  Future<void> _updateSoundVolume(int index, double volume) async {
    if (index >= _selectedSounds.length) return;

    try {
      _selectedSounds[index].volume = volume;

      // Apply volume with adjustment for multiple sounds
      final playerCount = _audioPlayers.length;
      final baseAdjustment = playerCount > 1 ? 0.8 / playerCount : 1.0;
      final adjustedVolume = volume * baseAdjustment;

      await _audioPlayers[index].setVolume(adjustedVolume);
    } catch (e) {
      debugPrint('Error updating volume for sound at index $index: $e');
    }
  }

  Future<void> _playAllSounds() async {
    if (_selectedSounds.isEmpty || _isLoadingPlayback) return;

    // Only show loading indicator if it's taking too long
    bool showLoading = false;
    Timer? loadingTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoadingPlayback = true);
        showLoading = true;
      }
    });

    try {
      // Start all players simultaneously
      await Future.wait(_audioPlayers.map((player) => player.play()));

      // Adjust volumes for simultaneous playback
      await _adjustVolumes();

      // Cancel the loading timer if it hasn't fired yet
      loadingTimer.cancel();

      setState(() {
        _isGlobalPlaying = true;
        _isLoadingPlayback = false;
      });
    } catch (e) {
      debugPrint('Error playing all sounds: $e');
      // Cancel the loading timer if it hasn't fired yet
      loadingTimer.cancel();
      setState(() => _isLoadingPlayback = false);
      _showErrorSnackBar('Failed to play sounds');
    }
  }

  Future<void> _pauseAllSounds() async {
    if (_audioPlayers.isEmpty || _isLoadingPlayback) return;

    // Only show loading indicator if it's taking too long
    bool showLoading = false;
    Timer? loadingTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoadingPlayback = true);
        showLoading = true;
      }
    });

    try {
      await Future.wait(_audioPlayers.map((player) => player.pause()));

      // Cancel the loading timer if it hasn't fired yet
      loadingTimer.cancel();

      setState(() {
        _isGlobalPlaying = false;
        _isLoadingPlayback = false;
      });
    } catch (e) {
      debugPrint('Error pausing all sounds: $e');
      // Cancel the loading timer if it hasn't fired yet
      loadingTimer.cancel();
      setState(() => _isLoadingPlayback = false);
      _showErrorSnackBar('Failed to pause sounds');
    }
  }

  Future<void> _stopAllSounds() async {
    if (_audioPlayers.isEmpty) return;

    try {
      await Future.wait(_audioPlayers.map((player) => player.stop()));

      setState(() => _isGlobalPlaying = false);
    } catch (e) {
      debugPrint('Error stopping all sounds: $e');
      _showErrorSnackBar('Failed to stop sounds');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    for (final subscription in _playerStateSubscriptions.values) {
      subscription.cancel();
    }
    _playerStateSubscriptions.clear();

    // Dispose all players
    for (final player in _audioPlayers) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        title: const Text(
          'Your Relaxation Mix',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(18, 23, 42, 1),
      ),
      body: Container(
        color: const Color.fromRGBO(18, 23, 42, 1),
        child: Column(
          children: [
            // Status indicator
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recommended Sounds',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 16),

                    // Recommended sounds section
                    SizedBox(
                      height: 120,
                      child: _isLoadingRecommendedSounds
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _recommendedSounds
                                  .where((s) => !_selectedSounds.contains(s))
                                  .length,
                              itemBuilder: (context, index) {
                                final sound = _recommendedSounds
                                    .where((s) => !_selectedSounds.contains(s))
                                    .toList()[index];
                                return _buildRecommendedSoundButton(sound);
                              },
                            ),
                    ),

                    const SizedBox(height: 5),
                    const Text(
                      'Selected Sounds',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 16),

                    // Selected sounds section
                    Expanded(
                      child: _selectedSounds.isEmpty
                          ? const Center(
                              child: Text(
                                'No sounds selected\nTap on recommended sounds to add them',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _selectedSounds.length,
                              itemBuilder: (context, index) {
                                final sound = _selectedSounds[index];
                                return _buildSelectedSoundItem(sound, index);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Control panel
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(194, 194, 244, 244),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: Icons.timer_outlined,
                    label: 'Timer',
                    onPressed: () {
                      // Timer functionality
                      _showErrorSnackBar('Timer feature coming soon!');
                    },
                  ),
                  _buildPlaybackControls(),
                  _buildControlButton(
                    icon: Icons.favorite_border_outlined,
                    label: 'Save Mix',
                    onPressed: () {
                      // Save mix functionality
                      _showErrorSnackBar('Save mix feature coming soon!');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            radius: 24,
            child: IconButton(
              icon: Icon(icon, color: Colors.white),
              onPressed: onPressed,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 28,
          child: IconButton(
            icon: Icon(
              _isGlobalPlaying ? Icons.pause : Icons.play_arrow,
              size: 28,
              color: const Color.fromRGBO(18, 23, 42, 1),
            ),
            onPressed: _selectedSounds.isEmpty
                ? null
                : () async {
                    if (_isGlobalPlaying) {
                      await _pauseAllSounds();
                    } else {
                      await _playAllSounds();
                    }
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSoundButton(SoundData sound) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _addSoundToMix(sound),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(18, 23, 42, 1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal[50]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconImage(sound.icon, 40),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      sound.title.replaceAll('_', ' '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSoundItem(SoundData sound, int index) {
    return Card(
      color: const Color.fromRGBO(18, 23, 42, 1),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(18, 23, 42, 1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal[50]!),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(child: _buildIconImage(sound.icon, 36)),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(24, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const CircleBorder(),
                        backgroundColor: const Color.fromRGBO(92, 67, 108, 1),
                        elevation: 2,
                        side: const BorderSide(
                          color: Color.fromRGBO(92, 67, 108, 1),
                        ),
                      ),
                      onPressed: () => _removeSoundFromMix(index),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sound.title.replaceAll('_', ' '),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: sound.volume,
                          min: 0.0,
                          max: 1.0,
                          divisions: 20,
                          activeColor: const Color.fromRGBO(128, 128, 178, 1),
                          inactiveColor: const Color.fromRGBO(113, 109, 150, 1),
                          onChanged: (value) {
                            setState(() => sound.volume = value);
                            _updateSoundVolume(index, value);
                          },
                        ),
                      ),
                      Text(
                        '${(sound.volume * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconImage(String iconName, double size) {
    if (iconName.isEmpty) return _buildFallbackIcon(size);

    final assetPath = _getMatchingAssetPath(iconName);
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(size),
      );
    }

    return _buildFallbackIcon(size);
  }

  String? _getMatchingAssetPath(String iconName) {
    final cleanName = iconName.replaceAll(RegExp(r'\.png$'), '').toLowerCase();
    return 'assets/images/$cleanName.png';
  }

  Widget _buildFallbackIcon(double size) =>
      Icon(Icons.audiotrack, size: size * 0.7, color: Colors.white70);
}
