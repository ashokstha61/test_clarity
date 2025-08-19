// import 'dart:async';
// // import 'package:bloc/bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';
// import 'package:clarity/model/sound_model.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'remix.dart';

// class SoundBloc extends Bloc<SoundEvent, SoundState> {
//   final FirebaseFirestore firestore;
//   final Map<String, bool> _assetExistsCache = {};
//   final Map<String, AudioPlayer> _audioPlayers = {};
//   final Set<String> _selectedIds = {};
//   bool _isPlaying = false;

//   SoundBloc({required this.firestore}) : super(SoundInitial()) {
//     on<LoadSounds>(_onLoadSounds);
//     on<ToggleSoundSelection>(_onToggleSoundSelection);
//     on<RefreshSounds>(_onRefreshSounds);
//     on<PlaySelectedSounds>(_onPlaySelectedSounds);
//     on<PauseAllSounds>(_onPauseAllSounds);

//     _initAudioSession();
//   }

//   Future<void> _initAudioSession() async {
//     try {
//       final session = await AudioSession.instance;
//       await session.configure(
//         const AudioSessionConfiguration(
//           avAudioSessionCategory: AVAudioSessionCategory.playback,
//           avAudioSessionCategoryOptions:
//               AVAudioSessionCategoryOptions.mixWithOthers,
//           androidAudioAttributes: AndroidAudioAttributes(
//             contentType: AndroidAudioContentType.music,
//             usage: AndroidAudioUsage.media,
//           ),
//           androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
//           androidWillPauseWhenDucked: false,
//         ),
//       );
//     } catch (e) {
//       debugPrint('Error configuring audio session: $e');
//     }
//   }

//   bool isAnySoundPlaying() => _isPlaying;

//   Future<void> _onLoadSounds(LoadSounds event, Emitter<SoundState> emit) async {
//     emit(SoundLoading());
//     try {
//       await _loadSelectedFromPrefs();
//       final sounds = await _fetchSounds();
//       emit(SoundLoaded(sounds: sounds, isPlaying: _isPlaying));
//     } catch (e) {
//       emit(SoundError(message: 'Failed to load sounds: $e'));
//     }
//   }

//   Future<void> _onRefreshSounds(
//     RefreshSounds event,
//     Emitter<SoundState> emit,
//   ) async {
//     _assetExistsCache.clear();
//     add(LoadSounds());
//   }

//   Future<void> _onToggleSoundSelection(
//     ToggleSoundSelection event,
//     Emitter<SoundState> emit,
//   ) async {
//     if (state is SoundLoaded) {
//       final currentState = state as SoundLoaded;
//       final updatedSounds = List<SoundData>.from(currentState.sounds);
//       final sound = updatedSounds[event.index];

//       // Toggle selection
//       updatedSounds[event.index] = sound.toggleSelection();

//       // Immediately emit state update to show UI changes (including RelaxationMixBar)
//       if (updatedSounds[event.index].isSelected) {
//         _selectedIds.add(sound.id);
//         _isPlaying = true;

//         // Update UI immediately before audio setup
//         emit(SoundLoaded(sounds: updatedSounds, isPlaying: true));

//         // Then handle audio setup and playback
//         await _setupPlayer(sound.id, sound.musicURL, sound.volume);
//         await _audioPlayers[sound.id]?.play();

//         // Make sure all other selected sounds are playing too
//         for (final id in _selectedIds) {
//           if (id != sound.id && _audioPlayers.containsKey(id)) {
//             _audioPlayers[id]?.play();
//           }
//         }
//       } else {
//         _selectedIds.remove(sound.id);
//         // Update UI immediately
//         if (_selectedIds.isEmpty) {
//           _isPlaying = false;
//           emit(SoundLoaded(sounds: updatedSounds, isPlaying: false));
//         } else {
//           emit(SoundLoaded(sounds: updatedSounds, isPlaying: _isPlaying));
//         }

//         // Then handle audio cleanup
//         await _removePlayer(sound.id);
//       }

//       await _saveSelectedToPrefs();
//       await _adjustVolumes();
//     }
//   }

//   Future<void> _onPlaySelectedSounds(
//     PlaySelectedSounds event,
//     Emitter<SoundState> emit,
//   ) async {
//     if (state is SoundLoaded) {
//       final currentState = state as SoundLoaded;
//       _isPlaying = true;
//       emit(currentState.copyWith(isPlaying: true));

//       // Play all selected sounds simultaneously
//       await Future.wait(_audioPlayers.values.map((player) => player.play()));

//       await _adjustVolumes();
//     }
//   }

//   Future<void> _onPauseAllSounds(
//     PauseAllSounds event,
//     Emitter<SoundState> emit,
//   ) async {
//     if (state is SoundLoaded) {
//       final currentState = state as SoundLoaded;
//       _isPlaying = false;
//       emit(currentState.copyWith(isPlaying: false));

//       await Future.wait(_audioPlayers.values.map((player) => player.pause()));
//     }
//   }

//   Future<void> _setupPlayer(String id, String url, double volume) async {
//     try {
//       if (_audioPlayers.containsKey(id)) return;

//       final player = AudioPlayer();
//       _audioPlayers[id] = player;

//       // Configure player
//       await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
//       await player.setLoopMode(LoopMode.all);
//       await player.setVolume(volume);

//       // Set up error handling
//       player.playerStateStream.listen(
//         (state) {
//           if (state.processingState == ProcessingState.idle &&
//               state.playing == false &&
//               _isPlaying) {
//             debugPrint("Player for $id stopped unexpectedly");
//           }
//         },
//         onError: (error) {
//           debugPrint("Player error for $id: $error");
//         },
//       );
//     } catch (e) {
//       debugPrint("Error setting up player for $id: $e");
//     }
//   }

//   Future<void> _removePlayer(String id) async {
//     if (_audioPlayers.containsKey(id)) {
//       try {
//         await _audioPlayers[id]?.dispose();
//       } catch (e) {
//         debugPrint("Error disposing player $id: $e");
//       } finally {
//         _audioPlayers.remove(id);
//       }
//     }
//   }

//   Future<void> _adjustVolumes() async {
//     final playerCount = _audioPlayers.length;
//     if (playerCount == 0) return;

//     // Calculate base volume adjustment to prevent clipping
//     final baseAdjustment = playerCount > 1 ? 0.8 / playerCount : 1.0;

//     for (final entry in _audioPlayers.entries) {
//       try {
//         await entry.value.setVolume(baseAdjustment);
//       } catch (e) {
//         debugPrint("Error adjusting volume for ${entry.key}: $e");
//       }
//     }
//   }

//   Future<List<SoundData>> _fetchSounds() async {
//     final snapshot = await firestore.collection('SoundData').get();
//     if (snapshot.docs.isEmpty) return [];

//     final sounds = snapshot.docs.map((doc) {
//       final data = doc.data();
//       final sound = SoundData.fromMap(data);
//       sound.isSelected = _selectedIds.contains(sound.id);
//       return sound;
//     }).toList();

//     // Check asset existence concurrently
//     await Future.wait(
//       sounds.map((sound) async {
//         final iconName = sound.icon.endsWith('.png')
//             ? sound.icon
//             : '${sound.icon}.png';
//         sound.hasAsset = await _checkAssetExists('assets/images/$iconName');
//       }),
//     );

//     return sounds;
//   }

//   Future<bool> _checkAssetExists(String path) async {
//     if (_assetExistsCache.containsKey(path)) return _assetExistsCache[path]!;
//     try {
//       await rootBundle.load(path);
//       _assetExistsCache[path] = true;
//       return true;
//     } catch (_) {
//       _assetExistsCache[path] = false;
//       return false;
//     }
//   }

//   Future<void> _saveSelectedToPrefs() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setStringList('selectedSounds', _selectedIds.toList());
//     } catch (e) {
//       debugPrint("Error saving to preferences: $e");
//     }
//   }

//   Future<void> _loadSelectedFromPrefs() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _selectedIds.clear();
//       _selectedIds.addAll(
//         (prefs.getStringList('selectedSounds') ?? []).toSet(),
//       );
//     } catch (e) {
//       debugPrint("Error loading from preferences: $e");
//     }
//   }

//   @override
//   Future<void> close() async {
//     await Future.wait(_audioPlayers.values.map((player) => player.dispose()));
//     _audioPlayers.clear();
//     return super.close();
//   }
// }

// // state
// abstract class SoundState {}

// class SoundInitial extends SoundState {}

// class SoundLoading extends SoundState {}

// class SoundLoaded extends SoundState {
//   final List<SoundData> sounds;
//   final bool isPlaying;

//   SoundLoaded({required this.sounds, this.isPlaying = false});

//   SoundLoaded copyWith({List<SoundData>? sounds, bool? isPlaying}) {
//     return SoundLoaded(
//       sounds: sounds ?? this.sounds,
//       isPlaying: isPlaying ?? this.isPlaying,
//     );
//   }
// }

// class SoundError extends SoundState {
//   final String message;

//   SoundError({required this.message});
// }

// //event

// abstract class SoundEvent {}

// class LoadSounds extends SoundEvent {}

// class RefreshSounds extends SoundEvent {}

// class ToggleSoundSelection extends SoundEvent {
//   final int index;

//   ToggleSoundSelection(this.index);
// }

// class PlaySelectedSounds extends SoundEvent {}

// class PauseAllSounds extends SoundEvent {}

// //sound page

// class SoundPage extends StatelessWidget {
//   const SoundPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           SoundBloc(firestore: FirebaseFirestore.instance)..add(LoadSounds()),
//       child: const _SoundView(),
//     );
//   }
// }

// class _SoundView extends StatelessWidget {
//   const _SoundView();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<SoundBloc, SoundState>(
//         builder: (context, state) {
//           if (state is SoundInitial || state is SoundLoading) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Loading sounds...'),
//                 ],
//               ),
//             );
//           }

//           if (state is SoundError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, size: 64, color: Colors.red),
//                   const SizedBox(height: 16),
//                   Text(
//                     state.message,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: () =>
//                         context.read<SoundBloc>().add(LoadSounds()),
//                     icon: const Icon(Icons.refresh),
//                     label: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (state is SoundLoaded) {
//             final sounds = state.sounds;
//             final selectedSounds = sounds.where((s) => s.isSelected).toList();
//             final isPlaying = state.isPlaying;

//             return Column(
//               children: [
//                 Expanded(
//                   child: RefreshIndicator(
//                     onRefresh: () async {
//                       context.read<SoundBloc>().add(RefreshSounds());
//                     },
//                     child: sounds.isEmpty
//                         ? const Center(child: Text('No sounds available'))
//                         : ListView.builder(
//                             physics: const AlwaysScrollableScrollPhysics(),
//                             itemCount: sounds.length,
//                             itemBuilder: (context, index) {
//                               return Column(
//                                 children: [
//                                   const Divider(),
//                                   SoundTile(
//                                     sound: sounds[index],
//                                     onTap: () => context.read<SoundBloc>().add(
//                                       ToggleSoundSelection(index),
//                                     ),
//                                   ),
//                                   if (index == sounds.length - 1)
//                                     const Divider(),
//                                 ],
//                               );
//                             },
//                           ),
//                   ),
//                 ),

//                 if (selectedSounds.isNotEmpty)
//                   RelaxationMixBar(
//                     onArrowTap: () {},
//                     onPlay: () =>
//                         context.read<SoundBloc>().add(PlaySelectedSounds()),
//                     onPause: () =>
//                         context.read<SoundBloc>().add(PauseAllSounds()),
//                     imagePath: 'assets/images/remix_image.png',
//                     soundCount: selectedSounds.length,
//                     isPlaying: isPlaying,
//                   ),
//               ],
//             );
//           }

//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }

// //sound tile

// class SoundTile extends StatelessWidget {
//   final SoundData sound;
//   final VoidCallback onTap;

//   const SoundTile({super.key, required this.sound, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(5),
//       child: ListTile(
//         contentPadding: EdgeInsets.zero,
//         onTap: onTap,
//         leading: Container(
//           height: 70,
//           width: 77,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//             border: Border.all(color: Colors.blueGrey),
//             color: sound.isSelected
//                 ? const Color.fromRGBO(176, 176, 224, 1)
//                 : null,
//           ),
//           child: Center(
//             child: sound.hasAsset
//                 ? Image.asset(
//                     'assets/images/${sound.icon.endsWith('.png') ? sound.icon : '${sound.icon}.png'}',
//                     height: 24,
//                     width: 24,
//                     errorBuilder: (context, error, stackTrace) {
//                       debugPrint(
//                         'Failed to load asset for ${sound.title}: ${sound.icon}',
//                       );
//                       return const Icon(Icons.music_note);
//                     },
//                   )
//                 : const Icon(Icons.music_note),
//           ),
//         ),
//         title: Text(
//           sound.title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'Montserrat',
//           ),
//         ),
//         trailing: sound.isSelected
//             ? const Icon(Icons.check, color: Colors.blue, size: 24)
//             : null,
//       ),
//     );
//   }
// }

import 'dart:async';
// import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:clarity/model/sound_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remix.dart';

// class SoundBloc extends Bloc<SoundEvent, SoundState> {
//   final FirebaseFirestore firestore;
//   final Map<String, bool> _assetExistsCache = {};
//   final Map<String, AudioPlayer> _audioPlayers = {};
//   final Set<String> _selectedIds = {};
//   bool _isPlaying = false;

//   SoundBloc({required this.firestore}) : super(SoundInitial()) {
//     on<LoadSounds>(_onLoadSounds);
//     on<ToggleSoundSelection>(_onToggleSoundSelection);
//     on<RefreshSounds>(_onRefreshSounds);
//     on<PlaySelectedSounds>(_onPlaySelectedSounds);
//     on<PauseAllSounds>(_onPauseAllSounds);

//     _initAudioSession();
//   }

//   Future<void> _initAudioSession() async {
//     try {
//       final session = await AudioSession.instance;
//       await session.configure(
//         const AudioSessionConfiguration(
//           avAudioSessionCategory: AVAudioSessionCategory.playback,
//           avAudioSessionCategoryOptions:
//               AVAudioSessionCategoryOptions.mixWithOthers,
//           androidAudioAttributes: AndroidAudioAttributes(
//             contentType: AndroidAudioContentType.music,
//             usage: AndroidAudioUsage.media,
//           ),
//           androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
//           androidWillPauseWhenDucked: false,
//         ),
//       );
//     } catch (e) {
//       debugPrint('Error configuring audio session: $e');
//     }
//   }

//   bool isAnySoundPlaying() => _isPlaying;

//   Future<void> _onLoadSounds(LoadSounds event, Emitter<SoundState> emit) async {
//     emit(SoundLoading());
//     try {
//       await _loadSelectedFromPrefs();
//       final sounds = await _fetchSounds();

//       // Setup players for previously selected sounds
//       if (_selectedIds.isNotEmpty) {
//         await _setupSelectedPlayers(sounds);
//       }

//       emit(SoundLoaded(sounds: sounds, isPlaying: _isPlaying));
//     } catch (e) {
//       emit(SoundError(message: 'Failed to load sounds: $e'));
//     }
//   }

//   Future<void> _setupSelectedPlayers(List<SoundData> sounds) async {
//     for (final soundId in _selectedIds) {
//       final sound = sounds.firstWhere(
//         (s) => s.id == soundId,
//         orElse: () => SoundData(
//           id: '',
//           title: '',
//           icon: '',
//           musicURL: '',
//           filepath: '',
//           volume: 0.5,
//         ),
//       );
//       if (sound.id.isNotEmpty) {
//         await _setupPlayer(sound.id, sound.musicURL, sound.volume);
//       }
//     }
//   }

//   Future<void> _onRefreshSounds(
//     RefreshSounds event,
//     Emitter<SoundState> emit,
//   ) async {
//     _assetExistsCache.clear();
//     add(LoadSounds());
//   }

//   Future<void> _onToggleSoundSelection(
//     ToggleSoundSelection event,
//     Emitter<SoundState> emit,
//   ) async {
//     if (state is SoundLoaded) {
//       final currentState = state as SoundLoaded;
//       final updatedSounds = List<SoundData>.from(currentState.sounds);
//       final sound = updatedSounds[event.index];

//       // Toggle selection
//       updatedSounds[event.index] = sound.toggleSelection();
//       final isNowSelected = updatedSounds[event.index].isSelected;

//       if (isNowSelected) {
//         // Add to selected sounds
//         _selectedIds.add(sound.id);
//         debugPrint(
//           "Added sound ${sound.id} to selection. Total: ${_selectedIds.length}",
//         );

//         // Setup the new player first
//         await _setupPlayer(sound.id, sound.musicURL, sound.volume);
//         debugPrint("Player setup complete for ${sound.id}");

//         // Update playing state and emit immediately
//         _isPlaying = true;
//         emit(SoundLoaded(sounds: updatedSounds, isPlaying: true));

//         // Adjust volumes for all players (including the new one)
//         await _adjustVolumes();

//         // Start playing all selected sounds
//         await _playAllSelectedSounds();
//         debugPrint("All sounds should be playing now");
//       } else {
//         // Remove from selected sounds
//         _selectedIds.remove(sound.id);
//         debugPrint(
//           "Removed sound ${sound.id} from selection. Remaining: ${_selectedIds.length}",
//         );

//         // Remove the player
//         await _removePlayer(sound.id);

//         // Update playing state
//         _isPlaying = _selectedIds.isNotEmpty;

//         // Emit state update
//         emit(SoundLoaded(sounds: updatedSounds, isPlaying: _isPlaying));

//         // Adjust volumes for remaining players
//         if (_selectedIds.isNotEmpty) {
//           await _adjustVolumes();
//         }
//       }

//       // Save preferences
//       await _saveSelectedToPrefs();
//     }
//   }

//   Future<void> _playAllSelectedSounds() async {
//     debugPrint("Attempting to play ${_selectedIds.length} selected sounds");

//     if (_selectedIds.isEmpty) {
//       debugPrint("No sounds selected to play");
//       return;
//     }

//     final playFutures = <Future>[];

//     for (final playerId in _selectedIds) {
//       if (_audioPlayers.containsKey(playerId)) {
//         final player = _audioPlayers[playerId]!;
//         debugPrint("Adding sound $playerId to play queue");

//         playFutures.add(
//           player
//               .play()
//               .then((_) {
//                 debugPrint("Successfully started playing $playerId");
//               })
//               .catchError((e) {
//                 debugPrint("Error playing sound $playerId: $e");
//                 return null;
//               }),
//         );
//       } else {
//         debugPrint("WARNING: Player not found for selected sound: $playerId");
//       }
//     }

//     if (playFutures.isNotEmpty) {
//       debugPrint("Starting ${playFutures.length} sounds simultaneously...");
//       try {
//         await Future.wait(playFutures);
//         debugPrint("All sounds started successfully");
//       } catch (e) {
//         debugPrint("Error in Future.wait for playing sounds: $e");
//       }
//     } else {
//       debugPrint("No valid players found to start");
//     }
//   }

//   Future<void> _onPlaySelectedSounds(
//     PlaySelectedSounds event,
//     Emitter<SoundState> emit,
//   ) async {
//     if (state is SoundLoaded) {
//       final currentState = state as SoundLoaded;
//       _isPlaying = true;
//       emit(currentState.copyWith(isPlaying: true));

//       // Play all selected sounds simultaneously
//       await _playAllSelectedSounds();
//       await _adjustVolumes();
//     }
//   }

//   Future<void> _onPauseAllSounds(
//     PauseAllSounds event,
//     Emitter<SoundState> emit,
//   ) async {
//     if (state is SoundLoaded) {
//       final currentState = state as SoundLoaded;
//       _isPlaying = false;
//       emit(currentState.copyWith(isPlaying: false));

//       // Pause all players
//       final futures = _audioPlayers.values.map((player) => player.pause());
//       try {
//         await Future.wait(futures);
//       } catch (e) {
//         debugPrint("Error pausing sounds: $e");
//       }
//     }
//   }

//   Future<void> _setupPlayer(
//     String id,
//     String url,
//     double originalVolume,
//   ) async {
//     try {
//       // Don't create duplicate players
//       if (_audioPlayers.containsKey(id)) {
//         return;
//       }

//       final player = AudioPlayer();
//       _audioPlayers[id] = player;

//       // Configure player with error handling
//       try {
//         await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
//         await player.setLoopMode(LoopMode.all);
//         // Set the original volume first, will be adjusted later in _adjustVolumes
//         await player.setVolume(originalVolume);
//       } catch (e) {
//         debugPrint("Error configuring player for $id: $e");
//         // Remove the player if configuration failed
//         _audioPlayers.remove(id);
//         await player.dispose();
//         return;
//       }

//       // Set up state monitoring
//       player.playerStateStream.listen(
//         (playerState) {
//           if (playerState.processingState == ProcessingState.idle &&
//               !playerState.playing &&
//               _isPlaying &&
//               _selectedIds.contains(id)) {
//             debugPrint(
//               "Player for $id stopped unexpectedly, attempting restart",
//             );
//             // Try to restart the player
//             player.play().catchError((e) {
//               debugPrint("Failed to restart player $id: $e");
//             });
//           }
//         },
//         onError: (error) {
//           debugPrint("Player state error for $id: $error");
//         },
//       );
//     } catch (e) {
//       debugPrint("Error setting up player for $id: $e");
//       // Clean up on error
//       if (_audioPlayers.containsKey(id)) {
//         _audioPlayers[id]?.dispose();
//         _audioPlayers.remove(id);
//       }
//     }
//   }

//   Future<void> _removePlayer(String id) async {
//     if (_audioPlayers.containsKey(id)) {
//       try {
//         final player = _audioPlayers[id]!;
//         await player.stop();
//         await player.dispose();
//       } catch (e) {
//         debugPrint("Error disposing player $id: $e");
//       } finally {
//         _audioPlayers.remove(id);
//       }
//     }
//   }

//   Future<void> _adjustVolumes() async {
//     final playerCount = _audioPlayers.length;
//     if (playerCount == 0) return;

//     // Get current state to access sound data with individual volumes
//     if (state is! SoundLoaded) return;
//     final currentSounds = (state as SoundLoaded).sounds;

//     // Calculate base volume adjustment to prevent clipping
//     final baseAdjustment = playerCount > 1 ? 0.8 / playerCount : 1.0;

//     final futures = <Future>[];
//     for (final entry in _audioPlayers.entries) {
//       // Find the original volume for this sound
//       final soundData = currentSounds.firstWhere(
//         (sound) => sound.id == entry.key,
//         orElse: () => SoundData(
//           id: entry.key,
//           title: '',
//           icon: '',
//           musicURL: '',
//           filepath: '',
//           volume: 0.5,
//         ),
//       );

//       // Apply both the original volume and the adjustment for multiple sounds
//       final adjustedVolume = soundData.volume * baseAdjustment;

//       futures.add(
//         entry.value.setVolume(adjustedVolume.clamp(0.0, 1.0)).catchError((e) {
//           debugPrint("Error adjusting volume for ${entry.key}: $e");
//         }),
//       );
//     }

//     if (futures.isNotEmpty) {
//       await Future.wait(futures);
//     }
//   }

//   Future<List<SoundData>> _fetchSounds() async {
//     final snapshot = await firestore.collection('SoundData').get();
//     if (snapshot.docs.isEmpty) return [];

//     final sounds = snapshot.docs.map((doc) {
//       final data = doc.data();
//       final sound = SoundData.fromMap(data);
//       sound.isSelected = _selectedIds.contains(sound.id);
//       return sound;
//     }).toList();

//     // Check asset existence concurrently
//     await Future.wait(
//       sounds.map((sound) async {
//         final iconName = sound.icon.endsWith('.png')
//             ? sound.icon
//             : '${sound.icon}.png';
//         sound.hasAsset = await _checkAssetExists('assets/images/$iconName');
//       }),
//     );

//     return sounds;
//   }

//   Future<bool> _checkAssetExists(String path) async {
//     if (_assetExistsCache.containsKey(path)) return _assetExistsCache[path]!;
//     try {
//       await rootBundle.load(path);
//       _assetExistsCache[path] = true;
//       return true;
//     } catch (_) {
//       _assetExistsCache[path] = false;
//       return false;
//     }
//   }

//   Future<void> _saveSelectedToPrefs() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setStringList('selectedSounds', _selectedIds.toList());
//     } catch (e) {
//       debugPrint("Error saving to preferences: $e");
//     }
//   }

//   Future<void> _loadSelectedFromPrefs() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _selectedIds.clear();
//       _selectedIds.addAll(
//         (prefs.getStringList('selectedSounds') ?? []).toSet(),
//       );
//     } catch (e) {
//       debugPrint("Error loading from preferences: $e");
//     }
//   }

//   @override
//   Future<void> close() async {
//     // Stop and dispose all players
//     final futures = <Future>[];
//     for (final player in _audioPlayers.values) {
//       futures.add(
//         player.stop().then((_) => player.dispose()).catchError((e) {
//           debugPrint("Error disposing player: $e");
//         }),
//       );
//     }

//     if (futures.isNotEmpty) {
//       await Future.wait(futures);
//     }

//     _audioPlayers.clear();
//     return super.close();
//   }
// }

// import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';
// import 'package:clarity/model/sound_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// State classes at top level
// abstract class SoundState {}

// class SoundInitial extends SoundState {}

// class SoundLoading extends SoundState {}

// class SoundLoaded extends SoundState {
//   final List<SoundData> sounds;
//   final bool isPlaying;

//   SoundLoaded({required this.sounds, this.isPlaying = false});

//   SoundLoaded copyWith({List<SoundData>? sounds, bool? isPlaying}) {
//     return SoundLoaded(
//       sounds: sounds ?? this.sounds,
//       isPlaying: isPlaying ?? this.isPlaying,
//     );
//   }
// }

// class SoundError extends SoundState {
//   final String message;

//   SoundError({required this.message});
// }

// abstract class SoundEvent {}

// class LoadSounds extends SoundEvent {}

// class RefreshSounds extends SoundEvent {}

// class ToggleSoundSelection extends SoundEvent {
//   final int index;

//   ToggleSoundSelection(this.index);
// }

// class PlaySelectedSounds extends SoundEvent {}

// class PauseAllSounds extends SoundEvent {}

// class SoundBloc extends Bloc<SoundEvent, SoundState> {
//   final FirebaseFirestore firestore;
//   final Map<String, bool> _assetExistsCache = {};
//   final Map<String, AudioPlayer> _audioPlayers = {};
//   final Set<String> _selectedIds = {};
//   bool _isPlaying = false;
//   final Map<String, AudioSession> _audioSessions = {};

//   SoundBloc({required this.firestore}) : super(SoundInitial()) {
//     on<LoadSounds>(_onLoadSounds);
//     on<ToggleSoundSelection>(_onToggleSoundSelection);
//     on<RefreshSounds>(_onRefreshSounds);
//     on<PlaySelectedSounds>(_onPlaySelectedSounds);
//     on<PauseAllSounds>(_onPauseAllSounds);
//   }
//   Future<void> _initAudioSessionForPlayer(String id) async {
//     try {
//       final session = await AudioSession.instance;
//       await session.configure(
//         AudioSessionConfiguration(
//           avAudioSessionCategory: AVAudioSessionCategory.playback,
//           avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
//           androidAudioAttributes: AndroidAudioAttributes(
//             contentType: AndroidAudioContentType.music,
//             usage: AndroidAudioUsage.media,
//           ),
//           androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
//           androidWillPauseWhenDucked: false,
//         ),
//       );
//       _audioSessions[id] = session;
//     } catch (e) {
//       debugPrint('Error configuring audio session for $id: $e');
//     }
//   }

//   bool isAnySoundPlaying() => _isPlaying;

//   Future<void> _onLoadSounds(LoadSounds event, Emitter<SoundState> emit) async {
//     emit(SoundLoading());
//     try {
//       await _loadSelectedFromPrefs();
//       final sounds = await _fetchSounds();

//       // Initialize players for already selected sounds
//       for (final sound in sounds.where((s) => s.isSelected)) {
//         await _setupPlayer(sound.id, sound.musicURL, sound.volume);
//       }

//       emit(SoundLoaded(sounds: sounds, isPlaying: _isPlaying));
//     } catch (e) {
//       emit(SoundError(message: 'Failed to load sounds: $e'));
//     }
//   }

//   Future<void> _onRefreshSounds(
//     RefreshSounds event,
//     Emitter<SoundState> emit,
//   ) async {
//     _assetExistsCache.clear();
//     add(LoadSounds());
//   }

//   // Future<void> _onToggleSoundSelection(
//   //   ToggleSoundSelection event,
//   //   Emitter<SoundState> emit,
//   // ) async {
//   //   if (state is SoundLoaded) {
//   //     final currentState = state as SoundLoaded;
//   //     final updatedSounds = List<SoundData>.from(currentState.sounds);
//   //     final sound = updatedSounds[event.index];

//   //     // Toggle selection
//   //     updatedSounds[event.index] = sound.toggleSelection();
//   //     final isNowSelected = updatedSounds[event.index].isSelected;

//   //     if (isNowSelected) {
//   //       _selectedIds.add(sound.id);
//   //       await _setupPlayer(sound.id, sound.musicURL, sound.volume);

//   //       // Automatically play when selecting if not the first sound
//   //       if (_selectedIds.length > 1) {
//   //         _isPlaying = true;
//   //         await _playAllSelected();
//   //       }
//   //     } else {
//   //       _selectedIds.remove(sound.id);
//   //       await _removePlayer(sound.id);

//   //       // Update playing state if no sounds left
//   //       if (_selectedIds.isEmpty) {
//   //         _isPlaying = false;
//   //       }
//   //     }

//   //     await _saveSelectedToPrefs();
//   //     await _adjustVolumes();

//   //     emit(SoundLoaded(sounds: updatedSounds, isPlaying: _isPlaying));
//   //   }
//   // }

//   // Future<void> _playAllSelected() async {
//   //   try {
//   //     await Future.wait(_audioPlayers.values.map((player) => player.play()));
//   //   } catch (e) {
//   //     debugPrint("Error playing all sounds: $e");
//   //   }
//   // }
//    Future<void> _onToggleSoundSelection(
//     ToggleSoundSelection event,
//     Emitter<SoundState> emit,
//   ) async {
//     if (state is SoundLoaded) {
//       final currentState = state as SoundLoaded;
//       final updatedSounds = List<SoundData>.from(currentState.sounds);
//       final sound = updatedSounds[event.index];

//       updatedSounds[event.index] = sound.toggleSelection();
//       final isNowSelected = updatedSounds[event.index].isSelected;

//       if (isNowSelected) {
//         _selectedIds.add(sound.id);
//         await _initAudioSessionForPlayer(sound.id);
//         await _setupPlayer(sound.id, sound.musicURL, sound.volume);

//         // Show RelaxationMixBar immediately
//         emit(currentState.copyWith(
//           sounds: updatedSounds,
//           isPlaying: _isPlaying,
//         ));

//         // Auto-play when selected
//         _isPlaying = true;
//         await _playAllSelected();
//         emit(currentState.copyWith(
//           sounds: updatedSounds,
//           isPlaying: true,
//         ));
//       } else {
//         _selectedIds.remove(sound.id);
//         await _removePlayer(sound.id);
//         _audioSessions.remove(sound.id);

//         _isPlaying = _selectedIds.isNotEmpty;
//         emit(currentState.copyWith(
//           sounds: updatedSounds,
//           isPlaying: _isPlaying,
//         ));
//       }

//       await _saveSelectedToPrefs();
//       await _adjustVolumes();
//     }
//   }

//   Future<void> _playAllSelected() async {
//     try {
//       // Initialize all players first
//       await Future.wait(_audioPlayers.values.map((player) async {
//         if (player.processingState != ProcessingState.ready) {
//           await player.setAudioSource(player.audioSource!);
//         }
//       }));

//       // Play all simultaneously with independent sessions
//       await Future.wait(_audioPlayers.values.map((player) => player.play()));
//     } catch (e) {
//       debugPrint("Error playing sounds: $e");
//       _isPlaying = false;
//       if (state is SoundLoaded) {
//         emit((state as SoundLoaded).copyWith(isPlaying: false));
//       }
//     }
//   }

//   Future<void> _onPlaySelectedSounds(
//     PlaySelectedSounds event,
//     Emitter<SoundState> emit,
//   ) async {
//     if (state is SoundLoaded) {
//       final currentState = state as SoundLoaded;
//       _isPlaying = true;
//       emit(currentState.copyWith(isPlaying: true));

//       await _playAllSelected();
//       await _adjustVolumes();
//     }
//   }

//   Future<void> _onPauseAllSounds(
//     PauseAllSounds event,
//     Emitter<SoundState> emit,
//   ) async {
//     if (state is SoundLoaded) {
//       final currentState = state as SoundLoaded;
//       _isPlaying = false;
//       emit(currentState.copyWith(isPlaying: false));

//       await Future.wait(_audioPlayers.values.map((player) => player.pause()));
//     }
//   }

//  Future<void> _setupPlayer(String id, String url, double volume) async {
//     try {
//       if (_audioPlayers.containsKey(id)) return;

//       final player = AudioPlayer();
//       _audioPlayers[id] = player;

//       await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
//       await player.setLoopMode(LoopMode.all);
//       await player.setVolume(volume);

//       player.playerStateStream.listen((state) {
//         if (state.processingState == ProcessingState.idle &&
//             !state.playing &&
//             _isPlaying) {
//           debugPrint("Player $id stopped - attempting restart");
//           player.play().catchError((e) => debugPrint("Restart failed: $e"));
//         }
//       }, onError: (e) {
//         debugPrint("Player error for $id: $e");
//         _removePlayer(id).catchError((e) => debugPrint("Error removing player: $e"));
//       });
//     } catch (e) {
//       debugPrint("Error setting up player for $id: $e");
//       await _removePlayer(id);
//     }
//   }

//   Future<void> _removePlayer(String id) async {
//     try {
//       await _audioPlayers[id]?.dispose();
//     } catch (e) {
//       debugPrint("Error disposing player $id: $e");
//     } finally {
//       _audioPlayers.remove(id);
//       _audioSessions.remove(id);
//     }
//   }

//   Future<void> _adjustVolumes() async {
//     final playerCount = _audioPlayers.length;
//     if (playerCount == 0) return;

//     // Calculate base volume adjustment to prevent clipping
//     final baseAdjustment = playerCount > 1 ? 0.8 / playerCount : 1.0;

//     for (final entry in _audioPlayers.entries) {
//       try {
//         // Get the sound's individual volume setting
//         final sound = (state as SoundLoaded).sounds.firstWhere(
//           (s) => s.id == entry.key,
//           orElse: () => SoundData(
//             id: entry.key,
//             title: '',
//             icon: '',
//             musicURL: '',
//             filepath: '',
//             volume: 0.5,
//           ),
//         );

//         // Apply both the individual volume and the group adjustment
//         await entry.value.setVolume(sound.volume * baseAdjustment);
//       } catch (e) {
//         debugPrint("Error adjusting volume for ${entry.key}: $e");
//       }
//     }
//   }

//   Future<List<SoundData>> _fetchSounds() async {
//     final snapshot = await firestore.collection('SoundData').get();
//     if (snapshot.docs.isEmpty) return [];

//     final sounds = snapshot.docs.map((doc) {
//       final data = doc.data();
//       final sound = SoundData.fromMap(data);
//       sound.isSelected = _selectedIds.contains(sound.id);
//       return sound;
//     }).toList();

//     // Check asset existence concurrently
//     await Future.wait(
//       sounds.map((sound) async {
//         final iconName = sound.icon.endsWith('.png')
//             ? sound.icon
//             : '${sound.icon}.png';
//         sound.hasAsset = await _checkAssetExists('assets/images/$iconName');
//       }),
//     );

//     return sounds;
//   }

//   Future<bool> _checkAssetExists(String path) async {
//     if (_assetExistsCache.containsKey(path)) return _assetExistsCache[path]!;
//     try {
//       await rootBundle.load(path);
//       _assetExistsCache[path] = true;
//       return true;
//     } catch (_) {
//       _assetExistsCache[path] = false;
//       return false;
//     }
//   }

//   Future<void> _saveSelectedToPrefs() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setStringList('selectedSounds', _selectedIds.toList());
//     } catch (e) {
//       debugPrint("Error saving to preferences: $e");
//     }
//   }

//   Future<void> _loadSelectedFromPrefs() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _selectedIds.clear();
//       _selectedIds.addAll(
//         (prefs.getStringList('selectedSounds') ?? []).toSet(),
//       );
//     } catch (e) {
//       debugPrint("Error loading from preferences: $e");
//     }
//   }
// }
// // Move state classes to top level
// class SoundPage extends StatelessWidget {
//   const SoundPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           SoundBloc(firestore: FirebaseFirestore.instance)..add(LoadSounds()),
//       child: const _SoundView(),
//     );
//   }
// }

// // Move _SoundView to top level

// class _SoundView extends StatelessWidget {
//   const _SoundView();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<SoundBloc, SoundState>(
//         builder: (context, state) {
//           if (state is SoundInitial || state is SoundLoading) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Loading sounds...'),
//                 ],
//               ),
//             );
//           }

//           if (state is SoundError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, size: 64, color: Colors.red),
//                   const SizedBox(height: 16),
//                   Text(
//                     state.message,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: () =>
//                         context.read<SoundBloc>().add(LoadSounds()),
//                     icon: const Icon(Icons.refresh),
//                     label: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (state is SoundLoaded) {
//             final sounds = state.sounds;
//             final selectedSounds = sounds.where((s) => s.isSelected).toList();
//             final isPlaying = state.isPlaying;

//             return Column(
//               children: [
//                 Expanded(
//                   child: RefreshIndicator(
//                     onRefresh: () async {
//                       context.read<SoundBloc>().add(RefreshSounds());
//                     },
//                     child: sounds.isEmpty
//                         ? const Center(child: Text('No sounds available'))
//                         : ListView.builder(
//                             physics: const AlwaysScrollableScrollPhysics(),
//                             itemCount: sounds.length,
//                             itemBuilder: (context, index) {
//                               return Column(
//                                 children: [
//                                   const Divider(),
//                                   SoundTile(
//                                     sound: sounds[index],
//                                     onTap: () => context.read<SoundBloc>().add(
//                                       ToggleSoundSelection(index),
//                                     ),
//                                   ),
//                                   if (index == sounds.length - 1)
//                                     const Divider(),
//                                 ],
//                               );
//                             },
//                           ),
//                   ),
//                 ),

//                 if (selectedSounds.isNotEmpty)
//                   RelaxationMixBar(
//                     onArrowTap: () {},
//                     onPlay: () =>
//                         context.read<SoundBloc>().add(PlaySelectedSounds()),
//                     onPause: () =>
//                         context.read<SoundBloc>().add(PauseAllSounds()),
//                     imagePath: 'assets/images/remix_image.png',
//                     soundCount: selectedSounds.length,
//                     isPlaying: isPlaying,
//                   ),
//               ],
//             );
//           }

//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }

// class SoundTile extends StatelessWidget {
//   final SoundData sound;
//   final VoidCallback onTap;

//   const SoundTile({super.key, required this.sound, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(5),
//       child: ListTile(
//         contentPadding: EdgeInsets.zero,
//         onTap: onTap,
//         leading: Container(
//           height: 70,
//           width: 77,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//             border: Border.all(color: Colors.blueGrey),
//             color: sound.isSelected
//                 ? const Color.fromRGBO(176, 176, 224, 1)
//                 : null,
//           ),
//           child: Center(
//             child: sound.hasAsset
//                 ? Image.asset(
//                     'assets/images/${sound.icon.endsWith('.png') ? sound.icon : '${sound.icon}.png'}',
//                     height: 24,
//                     width: 24,
//                     errorBuilder: (context, error, stackTrace) {
//                       debugPrint(
//                         'Failed to load asset for ${sound.title}: ${sound.icon}',
//                       );
//                       return const Icon(Icons.music_note);
//                     },
//                   )
//                 : const Icon(Icons.music_note),
//           ),
//         ),
//         title: Text(
//           sound.title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'Montserrat',
//           ),
//         ),
//         trailing: sound.isSelected
//             ? const Icon(Icons.check, color: Colors.blue, size: 24)
//             : null,
//       ),
//     );
//   }
// }

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==================== STATE CLASSES ====================
abstract class SoundState {}

class SoundInitial extends SoundState {}

class SoundLoading extends SoundState {}

class SoundLoaded extends SoundState {
  final List<SoundData> sounds;
  final bool isPlaying;

  SoundLoaded({required this.sounds, this.isPlaying = false});

  SoundLoaded copyWith({List<SoundData>? sounds, bool? isPlaying}) {
    return SoundLoaded(
      sounds: sounds ?? this.sounds,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class SoundError extends SoundState {
  final String message;
  SoundError({required this.message});
}

// ==================== EVENT CLASSES ====================
abstract class SoundEvent {}

class LoadSounds extends SoundEvent {}

class RefreshSounds extends SoundEvent {}

class ToggleSoundSelection extends SoundEvent {
  final int index;
  ToggleSoundSelection(this.index);
}

class PlaySelectedSounds extends SoundEvent {}

class PauseAllSounds extends SoundEvent {}

// ==================== BLOC ====================
class SoundBloc extends Bloc<SoundEvent, SoundState> {
  final FirebaseFirestore firestore;
  final Map<String, AudioPlayer> _audioPlayers = {};
  final Set<String> _selectedIds = {};
  bool _isPlaying = false;
  final Map<String, bool> _assetExistsCache = {};

  SoundBloc({required this.firestore}) : super(SoundInitial()) {
    on<LoadSounds>(_onLoadSounds);
    on<ToggleSoundSelection>(_onToggleSoundSelection);
    on<RefreshSounds>(_onRefreshSounds);
    on<PlaySelectedSounds>(_onPlaySelectedSounds);
    on<PauseAllSounds>(_onPauseAllSounds);

    _initGlobalAudioSession(); // ✅ only once
  }

  Future<void> _initGlobalAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      debugPrint("Error initializing audio session: $e");
    }
  }

  bool isAnySoundPlaying() => _isPlaying;

  Future<void> _onLoadSounds(LoadSounds event, Emitter<SoundState> emit) async {
    emit(SoundLoading());
    try {
      await _loadSelectedFromPrefs();
      final sounds = await _fetchSounds();

      for (final sound in sounds.where((s) => s.isSelected)) {
        await _setupPlayer(sound.id, sound.musicURL, sound.volume);
      }

      emit(SoundLoaded(sounds: sounds, isPlaying: _isPlaying));
    } catch (e) {
      emit(SoundError(message: 'Failed to load sounds: $e'));
    }
  }

  Future<void> _onRefreshSounds(
    RefreshSounds event,
    Emitter<SoundState> emit,
  ) async {
    _assetExistsCache.clear();
    add(LoadSounds());
  }

  // Future<void> _onToggleSoundSelection(
  //   ToggleSoundSelection event,
  //   Emitter<SoundState> emit,
  // ) async {
  //   if (state is SoundLoaded) {
  //     final currentState = state as SoundLoaded;
  //     final updatedSounds = List<SoundData>.from(currentState.sounds);
  //     final sound = updatedSounds[event.index];

  //     updatedSounds[event.index] = sound.toggleSelection();
  //     final isNowSelected = updatedSounds[event.index].isSelected;

  //     if (isNowSelected) {
  //       _selectedIds.add(sound.id);
  //       await _setupPlayer(sound.id, sound.musicURL, sound.volume);

  //       // ✅ show remix bar immediately
  //       emit(currentState.copyWith(
  //         sounds: updatedSounds,
  //         isPlaying: true,
  //       ));

  //       // ✅ start playback
  //       _isPlaying = true;
  //       await _playAllSelected();
  //     } else {
  //       _selectedIds.remove(sound.id);
  //       await _removePlayer(sound.id);

  //       _isPlaying = _selectedIds.isNotEmpty;
  //       emit(currentState.copyWith(
  //         sounds: updatedSounds,
  //         isPlaying: _isPlaying,
  //       ));
  //     }

  //     await _saveSelectedToPrefs();
  //     await _adjustVolumes();
  //   }
  // }

  Future<void> _onToggleSoundSelection(
    ToggleSoundSelection event,
    Emitter<SoundState> emit,
  ) async {
    if (state is! SoundLoaded) return;
    final currentState = state as SoundLoaded;
    final updatedSounds = List<SoundData>.from(currentState.sounds);
    final sound = updatedSounds[event.index];

    updatedSounds[event.index] = sound.toggleSelection();
    final isNowSelected = updatedSounds[event.index].isSelected;

    if (isNowSelected) {
      // SELECT → setup player and play immediately
      _selectedIds.add(sound.id);
      await _setupPlayer(sound.id, sound.musicURL, sound.volume);
      _audioPlayers[sound.id]?.play(); // play only this new sound
    } else {
      // DESELECT → stop only this sound
      _selectedIds.remove(sound.id);
      await _audioPlayers[sound.id]?.stop();
      await _removePlayer(sound.id);
    }

    // Update state: isPlaying = any selected still playing
    final anyPlaying = _selectedIds.isNotEmpty;
    emit(currentState.copyWith(sounds: updatedSounds, isPlaying: anyPlaying));

    await _adjustVolumes(); // adjust volumes for remaining sounds
    await _saveSelectedToPrefs();
  }

  // Future<void> _playAllSelected() async {
  // try {
  //   await Future.wait(_audioPlayers.values.map((player) async {
  //     if (!player.playing) {
  //       await player.play();
  //     }
  //   }));
  // } catch (e) {
  //   debugPrint("Error playing all sounds: $e");
  //   _isPlaying = false;
  //   if (state is SoundLoaded) {
  //     emit((state as SoundLoaded).copyWith(isPlaying: false));
  //   }
  // }

  Future<void> _playAllSelected() async {
    await Future.wait(
      _audioPlayers.values.map((player) async {
        if (!player.playing) await player.play();
      }),
    );
  }

  Future<void> _onPlaySelectedSounds(
    PlaySelectedSounds event,
    Emitter<SoundState> emit,
  ) async {
    if (state is SoundLoaded) {
      final currentState = state as SoundLoaded;
      _isPlaying = true;
      emit(currentState.copyWith(isPlaying: true));
      await _playAllSelected();
      await _adjustVolumes();
    }
  }

  Future<void> _onPauseAllSounds(
    PauseAllSounds event,
    Emitter<SoundState> emit,
  ) async {
    if (state is SoundLoaded) {
      final currentState = state as SoundLoaded;
      _isPlaying = false;
      emit(currentState.copyWith(isPlaying: false));
      await Future.wait(_audioPlayers.values.map((p) => p.pause()));
    }
  }

  Future<void> _setupPlayer(String id, String url, double volume) async {
    try {
      if (_audioPlayers.containsKey(id)) return;

      final player = AudioPlayer();
      _audioPlayers[id] = player;

      await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await player.setLoopMode(LoopMode.all);
      await player.setVolume(volume);

      player.playerStateStream.listen(
        (state) {
          if (state.processingState == ProcessingState.idle &&
              !state.playing &&
              _isPlaying) {
            player.play().catchError((e) => debugPrint("Restart failed: $e"));
          }
        },
        onError: (e) {
          debugPrint("Player error for $id: $e");
          _removePlayer(id);
        },
      );
    } catch (e) {
      debugPrint("Error setting up player for $id: $e");
      await _removePlayer(id);
    }
  }

  Future<void> _removePlayer(String id) async {
    try {
      await _audioPlayers[id]?.dispose();
    } catch (_) {}
    _audioPlayers.remove(id);
  }

  Future<void> _adjustVolumes() async {
    final playerCount = _audioPlayers.length;
    if (playerCount == 0) return;
    final baseAdjustment = playerCount > 1 ? 0.8 / playerCount : 1.0;

    for (final entry in _audioPlayers.entries) {
      try {
        final sound = (state as SoundLoaded).sounds.firstWhere(
          (s) => s.id == entry.key,
          orElse: () => SoundData(
            id: entry.key,
            title: '',
            icon: '',
            musicURL: '',
            filepath: '',
            volume: 0.5,
          ),
        );
        await entry.value.setVolume(sound.volume * baseAdjustment);
      } catch (e) {
        debugPrint("Error adjusting volume for ${entry.key}: $e");
      }
    }
  }

  Future<List<SoundData>> _fetchSounds() async {
    final snapshot = await firestore.collection('SoundData').get();
    if (snapshot.docs.isEmpty) return [];
    final sounds = snapshot.docs.map((doc) {
      final data = doc.data();
      final sound = SoundData.fromMap(data);
      sound.isSelected = _selectedIds.contains(sound.id);
      return sound;
    }).toList();

    await Future.wait(
      sounds.map((sound) async {
        final iconName = sound.icon.endsWith('.png')
            ? sound.icon
            : '${sound.icon}.png';
        sound.hasAsset = await _checkAssetExists('assets/images/$iconName');
      }),
    );
    return sounds;
  }

  Future<bool> _checkAssetExists(String path) async {
    if (_assetExistsCache.containsKey(path)) return _assetExistsCache[path]!;
    try {
      await rootBundle.load(path);
      _assetExistsCache[path] = true;
      return true;
    } catch (_) {
      _assetExistsCache[path] = false;
      return false;
    }
  }

  Future<void> _saveSelectedToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('selectedSounds', _selectedIds.toList());
    } catch (e) {
      debugPrint("Error saving prefs: $e");
    }
  }

  Future<void> _loadSelectedFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedIds.clear();
      _selectedIds.addAll(
        (prefs.getStringList('selectedSounds') ?? []).toSet(),
      );
    } catch (e) {
      debugPrint("Error loading prefs: $e");
    }
  }
}

// ==================== UI (unchanged) ====================
class SoundPage extends StatelessWidget {
  const SoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SoundBloc(firestore: FirebaseFirestore.instance)..add(LoadSounds()),
      child: const _SoundView(),
    );
  }
}

class _SoundView extends StatelessWidget {
  const _SoundView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SoundBloc, SoundState>(
        builder: (context, state) {
          if (state is SoundInitial || state is SoundLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading sounds...'),
                ],
              ),
            );
          }

          if (state is SoundError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<SoundBloc>().add(LoadSounds()),
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SoundLoaded) {
            final sounds = state.sounds;
            final selectedSounds = sounds.where((s) => s.isSelected).toList();
            final isPlaying = state.isPlaying;

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<SoundBloc>().add(RefreshSounds());
                    },
                    child: sounds.isEmpty
                        ? const Center(child: Text('No sounds available'))
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: sounds.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Divider(),
                                  SoundTile(
                                    sound: sounds[index],
                                    onTap: () => context.read<SoundBloc>().add(
                                      ToggleSoundSelection(index),
                                    ),
                                  ),
                                  if (index == sounds.length - 1) Divider(),
                                ],
                              );
                            },
                          ),
                  ),
                ),
                if (selectedSounds.isNotEmpty)
                  RelaxationMixBar(
                    onArrowTap: () {},
                    onPlay: () =>
                        context.read<SoundBloc>().add(PlaySelectedSounds()),
                    onPause: () =>
                        context.read<SoundBloc>().add(PauseAllSounds()),
                    imagePath: 'assets/images/remix_image.png',
                    soundCount: selectedSounds.length,
                    isPlaying: isPlaying,
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class SoundTile extends StatelessWidget {
  final SoundData sound;
  final VoidCallback onTap;

  const SoundTile({super.key, required this.sound, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: Container(
          height: 70,
          width: 77,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.blueGrey),
            color: sound.isSelected
                ? const Color.fromRGBO(176, 176, 224, 1)
                : null,
          ),
          child: Center(
            child: sound.hasAsset
                ? Image.asset(
                    'assets/images/${sound.icon.endsWith('.png') ? sound.icon : '${sound.icon}.png'}',
                    height: 24,
                    width: 24,
                    errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
                  )
                : const Icon(Icons.music_note),
          ),
        ),
        title: Text(
          sound.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
        trailing: sound.isSelected
            ? const Icon(Icons.check, color: Colors.blue, size: 24)
            : null,
      ),
    );
  }
}
