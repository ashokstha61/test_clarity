import 'package:audioplayers/audioplayers.dart';
import 'package:clarity/model/sound_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RelaxationMixPage extends StatefulWidget {
  const RelaxationMixPage({super.key});

  @override
  State<RelaxationMixPage> createState() => _RelaxationMixPageState();
}

class _RelaxationMixPageState extends State<RelaxationMixPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<AudioPlayer> _audioPlayers = [];
  final List<SoundData> _selectedSounds = [];
  bool _isGlobalPlaying = false;
  List<SoundData> _recommendedSounds = [];
  bool _isLoadingRecommendedSounds = false;
  // bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayers();
    _fetchRecommendedSounds();
  }

  void _setupAudioPlayers() {
    for (var player in _audioPlayers) {
      player.onPlayerComplete.listen((event) {
        final index = _audioPlayers.indexOf(player);
        if (index != -1 && _isGlobalPlaying) {
          player.play(UrlSource(_selectedSounds[index].musicURL));
        }
      });
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
            debugPrint('Sound data: ${doc.data()}'); // Print each sound's data
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
      }
    }
  }

  // Future<void> _fetchRecommendedSounds() async {
  //   try {
  //     final snapshot = await _firestore.collection('SoundData').get();
  //     if (mounted) {
  //       setState(() {
  //         _recommendedSounds = snapshot.docs
  //             .map((doc) => SoundData.fromFirestore(doc))
  //             .toList();
  //         _isLoadingRecommendedSounds = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         _isLoadingRecommendedSounds = false;
  //       });
  //     }
  //     debugPrint('Error fetching sounds: $e');
  //   }
  // }

  @override
  void dispose() {
    for (var player in _audioPlayers) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.keyboard_arrow_down, color: Colors.white),

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
                      child: ListView.builder(
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
                    Expanded(
                      child: _selectedSounds.isEmpty
                          ? const Center(
                              child: Text(
                                'No sounds selected',
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
                      /* Timer functionality */
                    },
                  ),
                  _buildPlaybackControls(),
                  _buildControlButton(
                    icon: Icons.favorite_border_outlined,
                    label: 'Save Mix',
                    onPressed: () {
                      /* Save mix functionality */
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

  // Playback controls widget
  Widget _buildPlaybackControls() {
    // Only show controls if sounds are selected

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: Icon(
              _isGlobalPlaying ? Icons.pause : Icons.play_arrow,
              size: 24,
              color: const Color.fromRGBO(18, 23, 42, 1),
            ),
            onPressed: () async {
              if (_isGlobalPlaying) {
                await _pauseAllSounds();
              } else {
                await _playAllSounds();
              }
              setState(() => _isGlobalPlaying = !_isGlobalPlaying);
            },
          ),
        ),
        // const SizedBox(width: 16),
        // CircleAvatar(
        //   backgroundColor: Colors.white,
        //   child: IconButton(
        //     icon: const Icon(
        //       Icons.stop,
        //       size: 24,
        //       color: Color.fromRGBO(18, 23, 42, 1),
        //     ),
        //     onPressed: () async {
        //       await _stopAllSounds();
        //       setState(() => _isGlobalPlaying = false);
        //     },
        //   ),
        // ),
      ],
    );
  }

  // Widget _buildRecommendedSoundButton(SoundData sound) {
  //   // Don't show if sound is already selected
  //   if (_selectedSounds.contains(sound)) {
  //     return const SizedBox.shrink();
  //   }

  //   return Padding(
  //     padding: const EdgeInsets.only(right: 16.0),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         InkWell(
  //           onTap: () {
  //             setState(() {
  //               _selectedSounds.add(sound);
  //               final player = AudioPlayer();
  //               player.onPlayerComplete.listen((_) {
  //                 if (_isGlobalPlaying) {
  //                   player.play(UrlSource(sound.musicURL));
  //                 }
  //               });
  //               _audioPlayers.add(player);
  //             });
  //           },
  //           child: Container(
  //             width: 80,
  //             height: 80,
  //             decoration: BoxDecoration(
  //               color: const Color.fromRGBO(18, 23, 42, 1),
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(color: Colors.teal[50]!),
  //             ),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 _buildSoundImage(sound, 40),
  //                 const SizedBox(height: 8),
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 4),
  //                   child: Text(
  //                     sound.title.replaceAll('_', ' '),
  //                     style: const TextStyle(
  //                       fontSize: 12,
  //                       color: Colors.white,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                     maxLines: 1,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildRecommendedSoundButton(SoundData sound) {
  //   // Don't show if sound is already selected
  //   if (_selectedSounds.contains(sound)) {
  //     return const SizedBox.shrink();
  //   }

  //   return Padding(
  //     padding: const EdgeInsets.only(right: 16.0),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         InkWell(
  //           onTap: () {
  //             setState(() {
  //               _selectedSounds.add(sound);
  //               final player = AudioPlayer();
  //               player.onPlayerComplete.listen((_) {
  //                 if (_isGlobalPlaying) {
  //                   player.play(UrlSource(sound.musicURL));
  //                 }
  //               });
  //               _audioPlayers.add(player);
  //             });
  //           },
  //           child: Container(
  //             width: 80,
  //             height: 80,
  //             decoration: BoxDecoration(
  //               color: const Color.fromRGBO(18, 23, 42, 1),
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(color: Colors.teal[50]!),
  //             ),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 // Use the icon field here instead of filepath
  //                 _buildSoundImage(
  //                   sound.icon,
  //                   40,
  //                 ), // Changed from sound.filepath to sound.icon
  //                 const SizedBox(height: 8),
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 4),
  //                   child: Text(
  //                     sound.title.replaceAll('_', ' '),
  //                     style: const TextStyle(
  //                       fontSize: 12,
  //                       color: Colors.white,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                     maxLines: 1,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildRecommendedSoundButton(SoundData sound) {
    debugPrint('Building button for sound: ${sound.title}');
    debugPrint('Icon name from Firestore: ${sound.icon}');
    debugPrint('Music URL: ${sound.musicURL}');

    // Don't show if sound is already selected
    if (_selectedSounds.contains(sound)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _selectedSounds.add(sound);
                final player = AudioPlayer();
                player.onPlayerComplete.listen((_) {
                  if (_isGlobalPlaying) {
                    player.play(UrlSource(sound.musicURL));
                  }
                });
                _audioPlayers.add(player);
              });
            },
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
                  // Use the icon from Firestore to find matching asset
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

  Widget _buildIconImage(String iconName, double size) {
    if (iconName.isEmpty) return _buildFallbackIcon(size);
    // Get the matching asset path
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
                        padding: EdgeInsets.zero, // Remove default padding
                        minimumSize: Size(24, 24), // Set minimum button size
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const CircleBorder(), // Circular button
                        backgroundColor: const Color.fromRGBO(
                          92,
                          67,
                          108,
                          1,
                        ), // Match container color
                        elevation: 2, // Slight shadow
                        side: BorderSide(
                          color: Color.fromRGBO(92, 67, 108, 1),
                        ), // Border color
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedSounds.removeAt(index);
                          _audioPlayers[index].dispose();
                          _audioPlayers.removeAt(index);
                        });
                      },
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
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Slider(
                    value: sound.volume,
                    min: 0.0,
                    max: 1.0,
                    activeColor: Color.fromRGBO(128, 128, 178, 1),
                    inactiveColor: const Color.fromRGBO(113, 109, 150, 1),
                    onChanged: (value) {
                      _audioPlayers[index].setVolume(value);
                      setState(() => sound.volume = value);
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

  String? _getMatchingAssetPath(String iconName) {
    debugPrint('Looking for asset matching icon name: $iconName');
    // Clean the icon name (remove special characters, make lowercase)
    final cleanName = iconName
        .replaceAll(RegExp(r'\.png$'), '') // Remove .png if present
        .toLowerCase();
    debugPrint('Cleaned icon name: $cleanName');
    // Map all possible icon names to asset paths
    // const assetMap = {
    //   'guitar': 'assets/images/guitar_icon.png',
    //   'keyboard': 'assets/images/keyboard_icon.png',
    //   'leaves': 'assets/images/leaves_icon.png',
    //   'baby_lullaby': 'assets/images/baby_lullaby_icon.png',
    //   'piano': 'assets/images/piano_icon.png',
    //   'rain': 'assets/images/rain_icon.png',
    //   'thunder': 'assets/images/thunder_icon.png',
    //   'snow': 'assets/images/snow_icon.png',
    //   'forest': 'assets/images/forest_icon.png',
    //   'wave': 'assets/images/waves_icon.png',
    //   'spa': 'assets/images/spa_icon.png',
    //   'sensory': 'assets/images/sensory_icon.png',
    //   'sunset': 'assets/images/sunset_icon.png',
    //   'birds': 'assets/images/birds_icon.png',
    //   'breeze': 'assets/images/breeze_icon.png',
    //   'fireplace': 'assets/images/fireplace_icon.png',
    //   'hearts': 'assets/images/hearts_icon.png',
    //   'mountain': 'assets/images/mountains_icon.png',
    //   'mountains': 'assets/images/mountains_icon.png',
    //   'oceans': 'assets/images/ocean_icon.png',
    //   'streams': 'assets/images/streams_icon.png',
    //   'sunrise': 'assets/images/sunrise_icon.png',
    //   // Add all other mappings
    // };

    // // Try exact match first
    // if (assetMap.containsKey(cleanName)) {
    //   debugPrint('Found exact match: ${assetMap[cleanName]}');
    //   return assetMap[cleanName];
    // }

    // // Try partial matches if needed
    // for (final key in assetMap.keys) {
    //   if (cleanName.contains(key)) {
    //     debugPrint('Found partial match: $key -> ${assetMap[key]}');
    //     return assetMap[key];
    //   }
    // }

    return 'assets/images/$cleanName.png';
  }

  Widget _buildFallbackIcon(double size) =>
      Icon(Icons.audiotrack, size: size * 0.7, color: Colors.white70);

  Future<void> _playAllSounds() async {
    for (int i = 0; i < _selectedSounds.length; i++) {
      await _audioPlayers[i].setReleaseMode(ReleaseMode.loop);
      await _audioPlayers[i].play(UrlSource(_selectedSounds[i].musicURL));
      await _audioPlayers[i].setVolume(_selectedSounds[i].volume);
    }
  }

  Future<void> _pauseAllSounds() async {
    for (var player in _audioPlayers) {
      await player.pause();
    }
  }

  // Future<void> _stopAllSounds() async {
  //   for (var player in _audioPlayers) {
  //     await player.stop();
  //   }
  // }
}

// class SoundData {
//   final String id;
//   final String title;
//   final String icon;
//   final String musicURL;
//   final String filepath;
//   final bool isFav;
//   final bool isLocked;
//   final bool isSelected;
//   final bool isNew;
//   double volume;

//   SoundData({
//     required this.id,
//     required this.title,
//     required this.musicURL,
//     required this.filepath,
//     required this.icon,
//     this.isFav = false,
//     this.isLocked = false,
//     this.isSelected = false,
//     this.isNew = false,
//     this.volume = 0.5, // Default to 0.5 for safer initial volume
//   });

//   factory SoundData.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return SoundData(
//       id: doc.id,
//       title: data['title'] ?? '',
//       musicURL: data['musicURL'] ?? '',
//       filepath: data['filepath'] ?? '',
//       isFav: data['isFav'] ?? false,
//       isLocked: data['isLocked'] ?? false,
//       isSelected: data['isSelected'] ?? false,
//       isNew: data['isNew'] ?? false,
//       volume: (data['volume'] ?? 0.5).toDouble(),
//       icon: data['icon'] ?? '',
//     );
//   }
// }
