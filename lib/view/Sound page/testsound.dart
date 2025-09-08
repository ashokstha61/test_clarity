// //this file works perfectly fine for sound page with multiple sound selection and playback

// import 'package:clarity/model/model.dart';
// import 'package:clarity/new_firebase_service.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';

// import '../sound mixing page/fixedrelaxationmix.dart';
// import '../sound mixing page/relaxationmix test.dart';
// // import '../sound mixing page/fixedrelaxationmix.dart';
// import 'remix.dart';
// import 'sound_tile.dart';



// class AudioManager {
//   static final AudioManager _instance = AudioManager._internal();
//   factory AudioManager() => _instance;
//   AudioManager._internal();

//   bool isPlaying = false;
//   final Map<String, AudioPlayer> _players = {};

//   // ✅ Notifier to update UI when playing/paused
//   final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);

//   Future<void> removeSound(String title) async {
//     final player = _players[title];
//     if (player != null) {
//       await player.pause();
//       await player.dispose();
//       _players.remove(title);
//     }

//     // FIX: Update notifier immediately after removing sound
//     _updatePlayingState();
//   }

//   Future<void> syncPlayers(List<NewSoundModel> selectedSounds) async {
//     // Remove players that are no longer selected
//     final keysToRemove = _players.keys
//         .where((key) => !selectedSounds.any((s) => s.title == key))
//         .toList();

//     for (final key in keysToRemove) {
//       final player = _players[key];
//       if (player != null) {
//         await player.pause();
//         await player.dispose();
//         _players.remove(key);
//       }
//     }

//     // Add new players for newly selected sounds
//     for (final sound in selectedSounds) {
//       final key = sound.title;
//       if (!_players.containsKey(key)) {
//         try {
//           final player = AudioPlayer();
//           await player.setAudioSource(
//             AudioSource.uri(Uri.parse(sound.musicUrl)),
//           );
//           await player.setLoopMode(LoopMode.one);
//           _players[key] = player;
//           await player.play(); // auto-play
//         } catch (e) {
//           print("❌ Failed to initialize ${sound.title}: $e");
//         }
//       }
//     }

//     await adjustVolumes(selectedSounds);

//     // FIX: Update playing state based on current players
//     _updatePlayingState();
//   }

//   // Future<void> syncPlayers(List<NewSoundModel> selectedSounds) async {
//   //   // Store the current playing state before making changes
//   //   final wasPlayingBefore = hasPlayingSounds;

//   //   // Remove players that are no longer selected
//   //   final keysToRemove = _players.keys
//   //       .where((key) => !selectedSounds.any((s) => s.title == key))
//   //       .toList();

//   //   for (final key in keysToRemove) {
//   //     final player = _players[key];
//   //     if (player != null) {
//   //       await player.pause();
//   //       await player.dispose();
//   //       _players.remove(key);
//   //     }
//   //   }

//   //   // Add new players for newly selected sounds
//   //   for (final sound in selectedSounds) {
//   //     final key = sound.title;
//   //     if (!_players.containsKey(key)) {
//   //       try {
//   //         final player = AudioPlayer();
//   //         await player.setAudioSource(
//   //           AudioSource.uri(Uri.parse(sound.musicUrl)),
//   //         );
//   //         await player.setLoopMode(LoopMode.one);
//   //         _players[key] = player;

//   //         // Only auto-play new sounds if other sounds were already playing
//   //         if (wasPlayingBefore) {
//   //           await player.play();
//   //         }
//   //       } catch (e) {
//   //         print("❌ Failed to initialize ${sound.title}: $e");
//   //       }
//   //     }
//   //   }

//   //   await adjustVolumes(selectedSounds);

//   //   // Update playing state based on current players
//   //   _updatePlayingState();
//   // }

//   Future<void> adjustVolumes(List<NewSoundModel> sounds) async {
//     for (var sound in sounds) {
//       final player = _players[sound.title];
//       if (player != null) {
//         await player.setVolume(sound.volume.toDouble());
//       }
//     }
//   }

//   Future<void> stopSound(String title) async {
//     final player = _players[title];
//     if (player != null) {
//       await player.pause();
//       await player.dispose();
//       _players.remove(title);
//     }
//     _updatePlayingState();
//   }

//   Future<void> playAll() async {
//     for (var player in _players.values) {
//       if (!player.playing) {
//         await player.play();
//       }
//     }
//     // FIX: Update state after playing
//     _updatePlayingState();
//   }

//   Future<void> pauseAll() async {
//     for (var player in _players.values) {
//       if (player.playing) {
//         await player.pause();
//       }
//     }
//     // FIX: Update state after pausing
//     _updatePlayingState();
//   }

//   // FIX: Helper method to properly update playing state
//   void _updatePlayingState() {
//     final hasPlayingSound = _players.values.any((player) => player.playing);
//     isPlaying = hasPlayingSound;
//     isPlayingNotifier.value = hasPlayingSound;
//   }

//   // FIX: Add method to get current playing state
//   bool get hasPlayingSounds => _players.values.any((player) => player.playing);

//   // FIX: Add method to get active players count
//   int get activePlayersCount => _players.length;
// }

// class SoundPage extends StatefulWidget {
//   const SoundPage({super.key});

//   @override
//   State<SoundPage> createState() => _SoundPageState();
// }

// class _SoundPageState extends State<SoundPage> {
//   final DatabaseService _firebaseService = DatabaseService();
//   List<NewSoundModel> _sounds = [];
//   bool _isLoading = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadSounds();
//   }

//   Future<void> _loadSounds() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final sounds = await _firebaseService.fetchSoundData();
//       setState(() {
//         _sounds = sounds;
//         print(_sounds);
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load sounds: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   void _toggleSoundSelection(int index) {
//     final sound = _sounds[index];
//     if (sound.isSelected) {
//       // Deselect
//       setState(() {
//         _sounds[index] = _sounds[index].copyWith(isSelected: false);
//       });
//     } else {
//       // Select and ensure no duplicates
//       if (!_sounds.any((s) => s.title == sound.title && s.isSelected)) {
//         setState(() {
//           _sounds[index] = _sounds[index].copyWith(isSelected: true);
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('${sound.title} is already selected')),
//         );
//         return;
//       }
//     }

//     final selected = _sounds.where((s) => s.isSelected).toList();
//     AudioManager().syncPlayers(selected);
//   }

//   Future<void> _playAllSelected() async {
//     await AudioManager().playAll();
//     setState(() {});
//   }

//   Future<void> _pauseAllSelected() async {
//     await AudioManager().pauseAll();
//     setState(() {});
//   }

//   // bool _isAnySoundPlaying() {

//   //   final selectedSounds = _sounds.where((s) => s.isSelected).toList();
//   //   if (selectedSounds.isEmpty) return false;
//   //   return selectedSounds.any((s) {
//   //     final player = AudioManager()._players[s.title];
//   //     return player != null && player.playing;
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     if (_errorMessage != null) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 _errorMessage!,
//                 style: const TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _loadSounds,
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     final selectedSounds = _sounds.where((s) => s.isSelected).toList();

//     return Scaffold(
//       body: Column(
//         children: [
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: _loadSounds,
//               child: _sounds.isEmpty
//                   ? SingleChildScrollView(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       child: SizedBox(
//                         height:
//                             MediaQuery.sizeOf(context).height - kToolbarHeight,
//                         child: const Center(
//                           child: Text(
//                             'No sounds available',
//                             style: TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ),
//                     )
//                   : ListView.builder(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       itemCount: _sounds.length,
//                       itemBuilder: (context, index) {
//                         return Column(
//                           children: [
//                             const Divider(height: 1),
//                             SoundTile(
//                               sound: _sounds[index],
//                               onTap: () => _toggleSoundSelection(index),
//                             ),
//                             if (index == _sounds.length - 1)
//                               const Divider(height: 1),
//                           ],
//                         );
//                       },
//                     ),
//             ),
//           ),

//           if (selectedSounds.isNotEmpty)
//             ValueListenableBuilder<bool>(
//               valueListenable: AudioManager().isPlayingNotifier,
//               builder: (context, isPlaying, _) {
//                 return RelaxationMixBar(
//                   onArrowTap: () async {
//                     final result = await showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       backgroundColor: Colors.transparent,
//                       builder: (context) {
//                         return Container(
//                           height: MediaQuery.of(context).size.height,
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.vertical(
//                               top: Radius.circular(16),
//                             ),
//                           ),
//                           child: RelaxationMixPage(
//                             sounds: _sounds,
//                             onSoundsChanged: (updatedSounds) {
//                               setState(() {
//                                 _sounds = updatedSounds;
//                               });
//                             },
//                           ),
//                         );
//                       },
//                     );

//                     if (result != null) {
//                       setState(() => _sounds = result);
//                       final selected = _sounds
//                           .where((s) => s.isSelected)
//                           .toList();
//                       await AudioManager().syncPlayers(selected);
//                     }
//                   },
//                   onPlay: _playAllSelected,
//                   onPause: _pauseAllSelected,
//                   imagePath: 'assets/images/remix_image.png',
//                   soundCount: selectedSounds.length,
//                   isPlaying: isPlaying, // ✅ use notifier value
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }
