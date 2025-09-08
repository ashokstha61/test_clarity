// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'bloc/soundbloc.dart' as testbloc;
// // import 'package:clarity/view/Sound page/bloc/soundevent.dart';
// // import 'package:clarity/view/Sound page/bloc/soundstate.dart';
// // import 'remix.dart';
// // import 'sound_tile.dart';

// // class SoundPage extends StatelessWidget {
// //   const SoundPage({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return BlocProvider(
// //       create: (context) =>
// //           testbloc.SoundBloc(firestore: FirebaseFirestore.instance)
// //             ..add(LoadSounds()),
// //       child: const _SoundView(),
// //     );
// //   }
// // }

// // class _SoundView extends StatelessWidget {
// //   const _SoundView();

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: BlocBuilder<testbloc.SoundBloc, SoundState>(
// //         builder: (context, state) {
// //           if (state is SoundInitial || state is SoundLoading) {
// //             return const Center(child: CircularProgressIndicator());
// //           }

// //           if (state is SoundError) {
// //             return Center(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Text(state.message),
// //                   const SizedBox(height: 16),
// //                   ElevatedButton(
// //                     onPressed: () =>
// //                         context.read<testbloc.SoundBloc>().add(LoadSounds()),
// //                     child: const Text('Retry'),
// //                   ),
// //                 ],
// //               ),
// //             );
// //           }

// //           if (state is SoundLoaded) {
// //             final sounds = state.sounds;
// //             final selectedSounds = sounds.where((s) => s.isSelected).toList();
// //             final isPlaying = context
// //                 .read<testbloc.SoundBloc>()
// //                 .isAnySoundPlaying();

// //             return Column(
// //               children: [
// //                 Expanded(
// //                   child: RefreshIndicator(
// //                     onRefresh: () async {
// //                       context.read<testbloc.SoundBloc>().add(RefreshSounds());
// //                     },
// //                     child: sounds.isEmpty
// //                         ? SingleChildScrollView(
// //                             physics: const AlwaysScrollableScrollPhysics(),
// //                             child: SizedBox(
// //                               height: MediaQuery.of(context).size.height,
// //                               child: const Center(
// //                                 child: Text('No sounds available'),
// //                               ),
// //                             ),
// //                           )
// //                         : ListView.builder(
// //                             physics: const AlwaysScrollableScrollPhysics(),
// //                             itemCount: sounds.length,
// //                             itemBuilder: (context, index) {
// //                               return Column(
// //                                 children: [
// //                                   const Divider(),
// //                                   SoundTile(
// //                                     sound: sounds[index],
// //                                     onTap: () => context
// //                                         .read<testbloc.SoundBloc>()
// //                                         .add(ToggleSoundSelection(index)),
// //                                   ),
// //                                   if (index == sounds.length - 1)
// //                                     const Divider(),
// //                                 ],
// //                               );
// //                             },
// //                           ),
// //                   ),
// //                 ),
// //                 if (selectedSounds.isNotEmpty)
// //                   RelaxationMixBar(
// //                     onArrowTap: () {},
// //                     onPlay: () =>
// //                         context.read<testbloc.SoundBloc>().playAllSelected(),
// //                     onPause: () =>
// //                         context.read<testbloc.SoundBloc>().pauseAllSelected(),
// //                     imagePath: 'assets/images/remix_image.png',
// //                     soundCount: selectedSounds.length,
// //                     isPlaying: isPlaying,
// //                   ),
// //               ],
// //             );
// //           }

// //           return const SizedBox.shrink();
// //         },
// //       ),
// //     );
// //   }
// // }

// import 'package:clarity/model/model.dart';
// import 'package:clarity/new_firebase_service.dart';
// import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:just_audio/just_audio.dart';

// // import '../sound mixing page/remix_test.dart';
// import '../sound mixing page/fixedrelaxationmix.dart';
// import 'remix.dart';
// import 'sound_tile.dart';

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
//   bool _isPlaying = false;
//   final player = AudioPlayer();
//   final List<AudioPlayer> _players = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadSounds();
//     playSelectedSound();
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

//   Future<void> playSelectedSound() async {
//     // Stop any existing players before starting fresh
//     for (var p in _players) {
//       await p.dispose();
//     }
//     _players.clear();

//     final selectedSounds = _sounds.where((s) => s.isSelected).toList();

//     for (var sound in selectedSounds) {
//       try {
//         final player = AudioPlayer();

//         // Load the source
//         await player.setAudioSource(AudioSource.uri(Uri.parse(sound.musicUrl)));

//         // Loop this track forever
//         await player.setLoopMode(LoopMode.one);

//         // Play
//         player.play();

//         _players.add(player);

//         print("✅ Playing: ${sound.title}");
//       } catch (e) {
//         print("❌ Failed to play ${sound.title}: $e");
//       }
//     }
//     player.playerStateStream.listen((state) {
//       setState(() {
//         _isPlaying = _players.any((p) => p.playing);
//       });
//     });
//   }

//   void _toggleSoundSelection(int index) {
//     final sound = _sounds[index];

//     // Check if the sound is already selected and playing
//     final isPlaying = _players.any(
//       (p) => p.playing && _sounds[index].isSelected,
//     );

//     if (sound.isSelected && isPlaying) {
//       // Optionally show a message that the sound is already playing
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('${sound.title} is already playing!')),
//       );
//       return; // Do not toggle
//     }

//     setState(() {
//       _sounds[index] = _sounds[index].copyWith(isSelected: !sound.isSelected);
//     });

//     playSelectedSound();
//   }

//   void _playAllSelected() {
//     for (var player in _players) {
//       if (!player.playing) {
//         player.play();
//       }
//     }
//     // Placeholder: Implement audio playback for selected sounds
//     setState(() {
//       _isPlaying = true;
//     });
//   }

//   void _pauseAllSelected() {
//     for (var player in _players) {
//       if (player.playing) {
//         player.pause();
//       }
//     }
//     // Placeholder: Implement audio playback for selected sounds
//     setState(() {
//       _isPlaying = false;
//     });
//   }

//   bool _isAnySoundPlaying() {
//     // Placeholder: Return playback state

//     return _isPlaying;
//   }

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
//             RelaxationMixBar(
//               onArrowTap: () async {
//                 final result = await showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true, // full height
//                   backgroundColor: Colors.transparent,
//                   builder: (context) {
//                     return Container(
//                       height: MediaQuery.of(context).size.height,
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.vertical(
//                           top: Radius.circular(16),
//                         ),
//                       ),

//                       child: RelaxationMixPage(
//                         sounds: _sounds, onSoundsChanged: (onSoundsChanged ) {  }, // pass your data
//                       ),
//                     );
//                   },
//                 );
//                 if (result != null) {
//                   setState(() => _sounds = result);
//                   await playSelectedSound(); // reapply playback to the new selection
//                 }
//               },
//               onPlay: _playAllSelected,
//               onPause: _pauseAllSelected,
//               imagePath: 'assets/images/remix_image.png',
//               soundCount: selectedSounds.length,
//               isPlaying: _isAnySoundPlaying(),
//             ),
//         ],
//       ),
//     );
//   }
// }
