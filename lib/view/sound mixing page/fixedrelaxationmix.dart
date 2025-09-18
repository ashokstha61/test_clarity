import 'package:clarity/model/model.dart';
import 'package:clarity/view/favourite/favouratepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'global_timer.dart';
import '../Sound page/AudioManager.dart';
import 'slider.dart';
import 'timer_screen.dart';
import 'timer_test.dart';

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
  final AudioManager _audioManager = AudioManager();
  // bool _isLoadingPlayback = false;
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
    _selectedSounds = widget.sounds
        .where((s) => s.isSelected)
        .map(
          (s) => s.copyWith(
            volume: _audioManager.getSavedVolume(
              s.title,
              defaultValue: s.volume.toDouble(),
            ),
          ),
        )
        .toList();
    // _selectedSounds.addAll(widget.sounds.where((s) => s.isSelected));
    _recommendedSounds = widget.sounds.where((s) => !s.isSelected).toList();
  }

  // Future<void> _addSoundToMix(NewSoundModel sound) async {
  //   if (_selectedSounds.any((s) => s.title == sound.title)) {
  //     _showErrorSnackBar('Sound already selected');
  //     return;
  //   }

  //   setState(() {
  //     _recommendedSounds.removeWhere((s) => s.title == sound.title);
  //     _selectedSounds.add(sound);
  //   });

  //   // Sync players: create missing players
  //   await _audioManager.syncPlayers(_selectedSounds);

  //   // Play the newly added sound
  //   _audioManager.playSound(sound.title);

  //   widget.onSoundsChanged(_buildUpdatedSounds());
  // }
  Future<void> _addSoundToMix(NewSoundModel sound) async {
    if (_selectedSounds.any((s) => s.title == sound.title)) {
      _showErrorSnackBar('Sound already selected');
      return;
    }

    // Ensure new sounds start with a reasonable volume (say 0.8)
    final normalizedSound = sound.copyWith(
      volume: sound.volume > 0 ? sound.volume : 0.8,
    );

    setState(() {
      _recommendedSounds.removeWhere((s) => s.title == normalizedSound.title);
      _selectedSounds.add(normalizedSound);
    });

    // Sync players: create missing players
    await _audioManager.syncPlayers(_selectedSounds);

    // Apply correct volume right away
    await _audioManager.adjustVolumes(_selectedSounds);
    _audioManager.saveVolume(
      normalizedSound.title,
      normalizedSound.volume.toDouble(),
    );

    // Play the newly added sound
    _audioManager.playSound(normalizedSound.title);

    widget.onSoundsChanged(_buildUpdatedSounds());
  }

  Future<void> _removeSoundFromMix(NewSoundModel sound) async {
    try {
      setState(() {
        _recommendedSounds.add(sound);
        _selectedSounds.removeWhere((s) => s.title == sound.title);
      });

      _audioManager.pauseSound(sound.title);
      _audioManager.saveVolume(sound.title, 1.0); // Reset to default volume
      await _audioManager.syncPlayers(_selectedSounds);

      widget.onSoundsChanged(_buildUpdatedSounds());
    } catch (e) {
      _showErrorSnackBar('Failed to remove sound: $e');
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
    _audioManager.saveVolume(_selectedSounds[index].title, volume);

    // Apply volume changes to audio players
    await _audioManager.adjustVolumes(_selectedSounds);
    widget.onSoundsChanged(_buildUpdatedSounds());
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
              height: 150,
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(200, 200, 251, 1),
                    Color.fromRGBO(45, 45, 105, 1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                color: const Color.fromARGB(194, 194, 244, 244),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 1).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildControlButton(
                    imagePath: "assets/images/timer_button.png",
                    label: 'Timer',
                    onPressed: () {
                      if (globalTimer.isRunning && globalTimer.remaining > 0) {
                        // Timer already running → go back to same timer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CircularTimerScreen(
                              duration: globalTimer.remaining > 0
                                  ? globalTimer.remaining
                                  : (globalTimer.duration ?? 0),
                              soundCount: _selectedSounds.length,
                            ),
                          ),
                        );
                      } else {
                        // Start a fresh timer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TimerScreen(soundCount: _selectedSounds.length),
                          ),
                        );
                      }
                    },
                  ),
                  _buildPlaybackControls(),
                  _buildControlButton(
                    imagePath: "assets/images/saveMix.png",
                    label: 'Save Mix',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Favouratepage(),
                        ),
                      );
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
    required String imagePath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60.w,
          height: 60.h,
          child: ClipOval(
            child: IconButton(
              icon: Image.asset(
                imagePath,
                height: 100.h,
                width: 100.h,
                fit: BoxFit.cover,
              ),

              onPressed: onPressed,
              padding: EdgeInsets.zero,
            ),
          ),
        ),

        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return ValueListenableBuilder<bool>(
      valueListenable: _audioManager.isPlayingNotifier,
      builder: (context, isPlaying, _) {
        return IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Image.asset(
            isPlaying ? "assets/images/pause.png" : "assets/images/play.png",
            height: 25.sp,
            width: 25.sp,
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
                borderRadius: BorderRadius.circular(5),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(18, 23, 42, 1),
              borderRadius: BorderRadius.circular(5),
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
                    onPressed: () => _removeSoundFromMix(sound),
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
                          activeTrackColor: Color.fromRGBO(128, 128, 178, 1),
                          inactiveTrackColor: Color.fromRGBO(113, 109, 150, 1),
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
