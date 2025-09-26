import 'dart:ui' as ui;
import 'package:clarity/model/model.dart';
import 'package:clarity/theme.dart';
import 'package:clarity/view/Sound%20page/sound.dart';
import 'package:clarity/view/favourite/favouratemanager.dart';

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
  final bool _isLoadingRecommendedSounds = false;
  bool showLoading = false;
  ui.Image? thumbImg;

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
    _recommendedSounds = widget.sounds.where((s) => !s.isSelected).toList();

    CustomImageThumbShape.loadImage('assets/images/thumb.png').then((img) {
      setState(() {
        thumbImg = img;
      });
    });
  }

  Future<void> _saveMix() async {
    // 1. Validate selected sounds
    if (_selectedSounds.isEmpty) {
      _showErrorSnackBar('Please select at least one sound to save.');
      return;
    }

    // 2. Ask for mix name
    String? mixName = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Column(
            children: [
              Text(
                'Name Your Mix',
                style: TextStyle(
                  fontSize: 20,
                  color: ThemeHelper.textColor(context),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a name for your sound mix',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeHelper.textColor(context),
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'My Sleep Mix',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              filled: true,
              fillColor: ThemeHelper.textFieldFillColor(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          actionsAlignment:
              MainAxisAlignment.spaceEvenly, // evenly spaced buttons
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'Montserrat',
                  fontSize: 14.sp,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'Montserrat',
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (!mounted) return;

    if (mixName == null || mixName.isEmpty) {
      return;
    }

    // 3. Collect selected sound filepaths
    final selectedSoundskoTitle = _selectedSounds.map((s) => s.title).toList();

    // // 4. Create a new mix model
    // final mix = NewSoundModel(
    //   title: mixName,
    //   icon: 'default_icon',
    //   filepath: "mix_$mixName",
    //   musicUrl: "",
    //   isSelected: false,
    //   isFav: true,
    //   isNew: true,
    //   isLocked: false,
    //   volume: 1.0,
    //   mixFilePaths: filepaths, // 👈 your saved sounds
    // );

    // 5. Save using your FavoritesManager
    FavoriteManager.instance.addFavorite(mixName, selectedSoundskoTitle);

    await showDialog(
      context: context,
      barrierDismissible: false, // must tap OK
      builder: (context) => AlertDialog(
        title: Text(
          "Sound saved",
          textAlign: TextAlign.center, // ✅ center align
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: ThemeHelper.textColor(context),
          ),
        ),
        content: Text(
          "Your customized mix has been saved to your favorites.",
          textAlign: TextAlign.center, // ✅ center align
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: ThemeHelper.textColor(context),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center, // ✅ center button
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // close only on OK
            child: const Text(
              "OK",
              style: TextStyle(
                color: Colors.blue,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSoundToMix(NewSoundModel sound) async {
    if (_selectedSounds.any((s) => s.title == sound.title)) {
      _showErrorSnackBar('Sound already selected');
      return;
    }

    // Check trial mode restrictions
    if (!isTrial && _selectedSounds.isNotEmpty) {
      // In non-trial mode, only one sound can be selected at a time
      // Remove all currently selected sounds first
      for (final selectedSound in List.from(_selectedSounds)) {
        await _removeSoundFromMixInternal(selectedSound, false);
      }
    }

    // Ensure new sounds start with a reasonable volume (say 0.8)
    final normalizedSound = sound.copyWith(
      volume: sound.volume > 0 ? sound.volume : 0.8,
      isSelected: true,
    );

    setState(() {
      _recommendedSounds.removeWhere((s) => s.title == normalizedSound.title);
      _selectedSounds.add(normalizedSound);
    });

    if (_selectedSounds.isNotEmpty) {
      setState(() {
        isSoundPlaying = true;
      });
    }

    // Update the main sounds list
    final allSounds = _buildUpdatedSounds();

    // Use AudioManager to handle the selection properly
    await _audioManager.toggleSoundSelection(
      allSounds,
      normalizedSound,
      isTrial,
    );

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
    await _removeSoundFromMixInternal(sound, true);
    widget.onSoundsChanged(_buildUpdatedSounds());
  }

  Future<void> _removeSoundFromMixInternal(
    NewSoundModel sound,
    bool updateCallback,
  ) async {
    try {
      setState(() {
        _selectedSounds.removeWhere((s) => s.title == sound.title);

        // find original index in the full sounds list
        final originalIndex = widget.sounds.indexWhere(
          (s) => s.title == sound.title,
        );

        if (originalIndex != -1) {
          // insert back into recommendedSounds at the right position
          final insertIndex = _recommendedSounds.indexWhere(
            (s) => widget.sounds.indexOf(s) > originalIndex,
          );

          if (insertIndex == -1) {
            _recommendedSounds.add(sound.copyWith(isSelected: false));
          } else {
            _recommendedSounds.insert(
              insertIndex,
              sound.copyWith(isSelected: false),
            );
          }
        }
      });

      if (_selectedSounds.isEmpty) {
        setState(() {
          isSoundPlaying = false;
        });
      }

      _audioManager.pauseSound(sound.title);
      _audioManager.saveVolume(sound.title, 1.0); // Reset to default volume
      await _audioManager.syncPlayers(_selectedSounds);

      if (updateCallback) {
        widget.onSoundsChanged(_buildUpdatedSounds());
      }
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leadingWidth: 60,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: ThemeHelper.textTitle(context),
            size: 35,
          ),
          onPressed: () {
            final updated = _buildUpdatedSounds();
            Navigator.pop(context, updated);
          },
        ),
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Text(
                'Your Relaxation Mix',
                style: TextStyle(
                  color: ThemeHelper.textTitle(context),
                  fontSize: 25,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        // backgroundColor:  Color.fromRGBO(18, 23, 42, 1),
      ),
      body: Container(
        // color: const Color.fromRGBO(18, 23, 42, 1),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended Sounds',
                      style: TextStyle(
                        fontSize: 20,
                        color: ThemeHelper.textTitle(context),
                        fontFamily: 'Montserrat',
                      ),
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
                                return _buildRecommendedSoundButton(
                                  sound,
                                  isTrial: isTrial,
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Selected Sounds',
                      style: TextStyle(
                        fontSize: 20,
                        color: ThemeHelper.textTitle(context),
                        fontFamily: 'Montserrat',
                      ),
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
              padding: EdgeInsets.all(16.0.sp),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    leading: 32.w,
                  ),
                  _buildPlaybackControls(),
                  _buildControlButton(
                    imagePath: "assets/images/saveMix.png",
                    label: 'Save Mix',
                    onPressed: _saveMix,
                    leading: 25.w,
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
    required double leading,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            height: 110.h,
            width: 110.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black38, // shadow color
                  blurRadius: 5,
                  spreadRadius: -20, // spread of the shadow
                  offset: Offset(-6.2, -5.7), // position of the shadow
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover, // fills circle without transparent space
              ),
            ),
          ),
        ),

        Positioned(
          top: 90,
          left: leading,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return ValueListenableBuilder<bool>(
      valueListenable: _audioManager.isPlayingNotifier,
      builder: (context, isPlaying, _) {
        return Column(
          children: [
            SizedBox(height: 25.h),
            IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Image.asset(
                isSoundPlaying
                    ? "assets/images/pause.png"
                    : "assets/images/play.png",
                height: 25.sp,
                width: 25.sp,
              ),
              onPressed: _selectedSounds.isEmpty
                  ? null
                  : () async {
                      if (isSoundPlaying) {
                        await AudioManager().pauseAll();
                      } else {
                        await AudioManager().playAll();
                      }
                    },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendedSoundButton(
    NewSoundModel sound, {
    required bool isTrial,
  }) {
    bool locked = false;
    print("isTrial: $isTrial");

    if (!isTrial) {
      locked = sound.isLocked;
      print("locked: $locked");
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: locked ? null : () => _addSoundToMix(sound),
            child: Opacity(
              opacity: locked ? 0.4 : 1.0, // dim if locked
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Color.fromARGB(255, 62, 86, 145),
                    width: 2.w,
                  ),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeHelper.textTitle(context),
                          overflow: TextOverflow.ellipsis,
                          fontFamily: 'Montserrat',
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
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
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Color.fromARGB(255, 51, 61, 108),
                width: 2.w,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: _buildIconImage(sound.icon, 24)),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.sp),
                  child: Text(
                    sound.title.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeHelper.textTitle(context),
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                SizedBox(
                  width: double.infinity,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: CustomImageThumbShape(
                        thumbRadius: 18.h,
                        thumbImage: thumbImg,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 0,
                      ),
                      trackHeight: 10.h,
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
    // final cleanName = iconName.replaceAll(RegExp(r'\.png), '');
    return 'assets/images/$iconName.png';
  }

  Widget _buildFallbackIcon(double size) =>
      Icon(Icons.audiotrack, size: size * 0.7, color: Colors.white70);
}
