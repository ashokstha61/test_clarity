// Fixed RelaxationMixPage - Key fixes applied

import 'package:clarity/model/model.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../Sound page/testsound.dart';
import 'slider.dart';
import 'timer_screen.dart';

class RelaxationMixPage extends StatefulWidget {
  final List<NewSoundModel> sounds;
  final Function(List<NewSoundModel>) onSoundsChanged;
  const RelaxationMixPage({
    super.key,
    required this.sounds,
    required this.onSoundsChanged,
  });

  @override
  State<RelaxationMixPage> createState() => _RelaxationMixPageState();
}

class _RelaxationMixPageState extends State<RelaxationMixPage> {
  List<NewSoundModel> _selectedSounds = [];
  List<NewSoundModel> _recommendedSounds = [];
  bool _isLoadingPlayback = false;
  final bool _isLoadingRecommendedSounds = false;
  bool showLoading = false;

  List<NewSoundModel> _buildUpdatedSounds() {
    return widget.sounds
        .map(
          (s) => s.copyWith(
            isSelected: _selectedSounds.any(
              (selected) => selected.title == s.title,
            ),
            // Preserve volume changes made in mix page
            volume: _selectedSounds
                .firstWhere(
                  (selected) => selected.title == s.title,
                  orElse: () => s,
                )
                .volume,
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedSounds.addAll(widget.sounds.where((s) => s.isSelected));
    _recommendedSounds = widget.sounds.where((s) => !s.isSelected).toList();

    AudioManager().syncPlayers(_selectedSounds);
  }

  void _addSoundToMix(NewSoundModel sound) async {
    if (_selectedSounds.any((s) => s.title == sound.title)) {
      _showErrorSnackBar('Sound already selected');
      return;
    }

    setState(() {
      _selectedSounds = List.from(_selectedSounds)..add(sound);
      _recommendedSounds.removeWhere((s) => s.title == sound.title);
    });

    await AudioManager().syncPlayers(List.from(_selectedSounds));
    widget.onSoundsChanged(_buildUpdatedSounds());
  }

  void _removeSoundFromMix(int index) async {
    if (index < 0 || index >= _selectedSounds.length) return;

    final removedSound = _selectedSounds[index];

    try {
      // First update UI to give immediate feedback
      setState(() {
        _selectedSounds = List.from(_selectedSounds)..removeAt(index);
        _recommendedSounds = List.from(_recommendedSounds)
          ..add(removedSound.copyWith(isSelected: false));
      });

      // Stop and remove the specific player
      await AudioManager().removeSound(removedSound.title);

      // Sync remaining sounds to ensure proper playback state
      if (_selectedSounds.isNotEmpty) {
        await AudioManager().syncPlayers(List.from(_selectedSounds));
      }
      widget.onSoundsChanged(_buildUpdatedSounds());
    } catch (e) {
      _showErrorSnackBar('Failed to remove sound: $e');
      // Revert UI changes on error
      setState(() {
        _selectedSounds = List.from(_selectedSounds)
          ..insert(index, removedSound);
        _recommendedSounds.removeWhere((s) => s.title == removedSound.title);
      });
    }
  }



  // FIX: Properly update volume by creating new list with updated sound
  Future<void> _updateSoundVolume(int index, double volume) async {
    if (index >= _selectedSounds.length) return;

    setState(() {
      // Create a new list with the updated sound
      _selectedSounds = List.from(_selectedSounds);
      _selectedSounds[index] = _selectedSounds[index].copyWith(volume: volume);
    });

    // Apply volume changes to audio players
    await AudioManager().adjustVolumes(_selectedSounds);
  }

  Future<void> _playAllSounds() async {
    if (_selectedSounds.isEmpty || _isLoadingPlayback) return;

    Timer? loadingTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoadingPlayback = true);
        showLoading = true;
      }
    });

    try {
      await AudioManager().playAll();

      loadingTimer.cancel();
      if (mounted) {
        setState(() {
          _isLoadingPlayback = false;
        });
      }
    } catch (e) {
      debugPrint('Error playing all sounds: $e');
      loadingTimer.cancel();
      setState(() => _isLoadingPlayback = false);
      _showErrorSnackBar('Failed to play sounds');
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 60,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () {
            final updated = _buildUpdatedSounds();
            Navigator.pop(context, updated);
          },
        ),
        toolbarHeight: 100,
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Your Relaxation Mix',
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(18, 23, 42, 1),
      ),
      body: Container(
        color: const Color.fromRGBO(18, 23, 42, 1),
        child: Column(
          children: [
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
                              itemCount: _recommendedSounds.length,
                              itemBuilder: (context, index) {
                                final sound = _recommendedSounds[index];
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TimerScreen(onTimerSelected: (Duration) {}),
                        ),
                      );
                    },
                  ),
                  _buildPlaybackControls(),
                  _buildControlButton(
                    icon: Icons.favorite_border_outlined,
                    label: 'Save Mix',
                    onPressed: () {
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
    return ValueListenableBuilder<bool>(
      valueListenable: AudioManager().isPlayingNotifier,
      builder: (context, isPlaying, _) {
        return CircleAvatar(
          backgroundColor: Colors.white,
          radius: 28,
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 28,
              color: const Color.fromRGBO(18, 23, 42, 1),
            ),
            onPressed: _selectedSounds.isEmpty
                ? null
                : () async {
                    if (isPlaying) {
                      await AudioManager().pauseAll();
                    } else {
                      await AudioManager().playAll();
                    }
                  },
          ),
        );
      },
    );
  }

  Widget _buildRecommendedSoundButton(NewSoundModel sound) {
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

  Widget _buildSelectedSoundItem(NewSoundModel sound, int index) {
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
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const CustomImageThumbShape(
                              imagePath: 'assets/images/thumb.png',
                              thumbRadius: 18,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 0,
                            ),
                            trackHeight: 4,
                            activeTrackColor: const Color.fromRGBO(
                              128,
                              128,
                              178,
                              1,
                            ),
                            inactiveTrackColor: const Color.fromRGBO(
                              113,
                              109,
                              150,
                              1,
                            ),
                          ),
                          child: Slider(
                            value: sound.volume.toDouble(),
                            min: 0.0,
                            max: 1.0,
                            onChanged: (value) {
                              // FIX: Use proper update method instead of direct modification
                              _updateSoundVolume(index, value);
                            },
                          ),
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
