// // import 'dart:async';
// // import 'package:bloc/bloc.dart';
// // import 'package:audioplayers/audioplayers.dart';
// // import 'package:clarity/model/sound_model.dart';

// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // import 'soundevent.dart';
// // import 'soundstate.dart';

// // class SoundBloc extends Bloc<SoundEvent, SoundState> {
// //   final FirebaseFirestore firestore;
// //   final Map<String, bool> _assetExistsCache = {};
// //   final Map<String, AudioPlayer> _activePlayers = {};
// //   Set<String> _selectedIds = {};
// //   bool _isPlayingAll = false;

// //   SoundBloc({required this.firestore}) : super(SoundInitial()) {
// //     on<LoadSounds>(_onLoadSounds);
// //     on<ToggleSoundSelection>(_onToggleSoundSelection);
// //     on<RefreshSounds>(_onRefreshSounds);
// //   }

// //   bool isAnySoundPlaying() => _isPlayingAll;

// //   Future<void> _onLoadSounds(LoadSounds event, Emitter<SoundState> emit) async {
// //     emit(SoundLoading());
// //     try {
// //       await _loadSelectedFromPrefs();
// //       final sounds = await _fetchSounds();
// //       emit(SoundLoaded(sounds: sounds));
// //     } catch (e) {
// //       emit(SoundError(message: 'Failed to load sounds: $e'));
// //     }
// //   }

// //   Future<void> _onRefreshSounds(
// //     RefreshSounds event,
// //     Emitter<SoundState> emit,
// //   ) async {
// //     _assetExistsCache.clear();
// //     add(LoadSounds());
// //   }

// //   Future<void> _onToggleSoundSelection(
// //     ToggleSoundSelection event,
// //     Emitter<SoundState> emit,
// //   ) async {
// //     if (state is SoundLoaded) {
// //       final currentState = state as SoundLoaded;
// //       final updatedSounds = List<SoundData>.from(currentState.sounds);

// //       final sound = updatedSounds[event.index];
// //       final newSound = sound.toggleSelection();
// //       updatedSounds[event.index] = newSound;

// //       if (newSound.isSelected) {
// //         _selectedIds.add(newSound.id);
// //         await _playSound(newSound.id, newSound.musicURL);
// //       } else {
// //         _selectedIds.remove(newSound.id);
// //         await _stopSound(newSound.id);
// //       }

// //       await _saveSelectedToPrefs();
// //       emit(SoundLoaded(sounds: updatedSounds));
// //     }
// //   }

// //   Future<void> playAllSelected() async {
// //     if (state is SoundLoaded) {
// //       final currentState = state as SoundLoaded;
// //       for (final sound in currentState.sounds) {
// //         if (sound.isSelected && !_activePlayers.containsKey(sound.id)) {
// //           await _playSound(sound.id, sound.musicURL);
// //         }
// //       }
// //       _isPlayingAll = true;
// //     }
// //   }

// //   Future<void> pauseAllSelected() async {
// //     for (final player in _activePlayers.values) {
// //       await player.pause();
// //     }
// //     _isPlayingAll = false;
// //   }

// //   Future<List<SoundData>> _fetchSounds() async {
// //     final snapshot = await firestore.collection('SoundData').get();
// //     if (snapshot.docs.isEmpty) return [];

// //     final sounds = snapshot.docs.map((doc) {
// //       final data = doc.data();
// //       final sound = SoundData.fromMap(data);
// //       sound.isSelected = _selectedIds.contains(sound.id);
// //       return sound;
// //     }).toList();

// //     for (final sound in sounds) {
// //       final iconName = sound.icon.endsWith('.png')
// //           ? sound.icon
// //           : '${sound.icon}.png';
// //       sound.hasAsset = await _checkAssetExists('assets/images/$iconName');
// //     }

// //     return sounds;
// //   }

// //   Future<bool> _checkAssetExists(String path) async {
// //     if (_assetExistsCache.containsKey(path)) return _assetExistsCache[path]!;
// //     try {
// //       await rootBundle.load(path);
// //       _assetExistsCache[path] = true;
// //       return true;
// //     } catch (_) {
// //       _assetExistsCache[path] = false;
// //       return false;
// //     }
// //   }

// //   Future<void> _saveSelectedToPrefs() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.setStringList('selectedSounds', _selectedIds.toList());
// //   }

// //   Future<void> _loadSelectedFromPrefs() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     _selectedIds = (prefs.getStringList('selectedSounds') ?? []).toSet();
// //   }

// //   Future<void> _playSound(String id, String url) async {
// //     try {
// //       if (_activePlayers.containsKey(id)) return;

// //       final player = AudioPlayer();
// //       _activePlayers[id] = player;

// //       await player.setReleaseMode(ReleaseMode.loop);
// //       await player.play(UrlSource(url));
// //     } catch (e) {
// //       debugPrint("Error playing audio: $e");
// //     }
// //   }

// //   Future<void> _stopSound(String id) async {
// //     if (_activePlayers.containsKey(id)) {
// //       await _activePlayers[id]!.stop();
// //       await _activePlayers[id]!.dispose();
// //       _activePlayers.remove(id);
// //     }
// //   }

// //   Future<void> clearSelectedSounds() async {
// //     for (final id in _selectedIds.toList()) {
// //       await _stopSound(id);
// //     }
// //     _selectedIds.clear();
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.remove('selectedSounds');
// //   }

// //   @override
// //   Future<void> close() {
// //     for (final player in _activePlayers.values) {
// //       player.dispose();
// //     }
// //     _activePlayers.clear();
// //     return super.close();
// //   }
// // }

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:clarity/model/sound_model.dart';
import 'package:clarity/view/Sound page/bloc/sound_event.dart';
import 'package:clarity/view/Sound page/bloc/sound_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundBloc extends Bloc<SoundEvent, SoundState> {
  // final FirebaseFirestore firestore;
  // final Map<String, bool> _assetExistsCache = {};
  // final Map<String, AudioPlayer> _activePlayers = {};
  // Set<String> _selectedIds = {};
  // bool _isPlayingAll = false;

  // SoundBloc({required this.firestore}) : super(SoundInitial()) {
  //   on<LoadSounds>(_onLoadSounds);
  //   on<ToggleSoundSelection>(_onToggleSoundSelection);
  //   on<RefreshSounds>(_onRefreshSounds);
  // }

  // bool isAnySoundPlaying() => _isPlayingAll;

  // Future<void> _onLoadSounds(LoadSounds event, Emitter<SoundState> emit) async {
  //   emit(SoundLoading());
  //   try {
  //     await _loadSelectedFromPrefs();
  //     final sounds = await _fetchSounds();
  //     emit(SoundLoaded(sounds: sounds));
  //   } catch (e) {
  //     emit(SoundError(message: 'Failed to load sounds: $e'));
  //   }
  // }

  // Future<void> _onRefreshSounds(
  //   RefreshSounds event,
  //   Emitter<SoundState> emit,
  // ) async {
  //   _assetExistsCache.clear();
  //   add(LoadSounds());
  // }

  // Future<void> _onToggleSoundSelection(
  //   ToggleSoundSelection event,
  //   Emitter<SoundState> emit,
  // ) async {
  //   if (state is SoundLoaded) {
  //     final currentState = state as SoundLoaded;
  //     final updatedSounds = List<SoundData>.from(currentState.sounds);

  //     final sound = updatedSounds[event.index];
  //     final newSound = sound.toggleSelection();
  //     updatedSounds[event.index] = newSound;

  //     if (newSound.isSelected) {
  //       _selectedIds.add(newSound.id);
  //       await _playSound(newSound.id, newSound.musicURL);
  //     } else {
  //       _selectedIds.remove(newSound.id);
  //       await _stopSound(newSound.id);
  //     }

  //     await _saveSelectedToPrefs();
  //     emit(SoundLoaded(sounds: updatedSounds));
  //   }
  // }

  // Future<void> playAllSelected() async {
  //   if (state is SoundLoaded) {
  //     final currentState = state as SoundLoaded;
  //     final selectedSounds = currentState.sounds.where((s) => s.isSelected);

  //     // Play all selected sounds that aren't already playing
  //     for (final sound in selectedSounds) {
  //       if (!_activePlayers.containsKey(sound.id)) {
  //         await _playSound(sound.id, sound.musicURL);
  //       } else {
  //         // If already playing but paused, resume playback
  //         await _activePlayers[sound.id]?.resume();
  //       }
  //     }
  //     _isPlayingAll = true;
  //   }
  // }

  // Future<void> pauseAllSelected() async {
  //   for (final player in _activePlayers.values) {
  //     await player.pause();
  //   }
  //   _isPlayingAll = false;
  // }

  // Future<void> _playSound(String id, String url) async {
  //   try {
  //     // If already playing, don't start again
  //     if (_activePlayers.containsKey(id) && _isPlayingAll) return;

  //     final player = AudioPlayer();
  //     _activePlayers[id] = player;

  //     // Set volume lower when playing multiple sounds
  //     final volume = _activePlayers.length > 1 ? 0.7 : 1.0;
  //     await player.setVolume(volume);
  //     await player.setReleaseMode(ReleaseMode.loop);
  //     await player.play(UrlSource(url));
  //   } catch (e) {
  //     debugPrint("Error playing audio: $e");
  //   }
  // }

  // Future<void> _stopSound(String id) async {
  //   if (_activePlayers.containsKey(id)) {
  //     await _activePlayers[id]!.stop();
  //     await _activePlayers[id]!.dispose();
  //     _activePlayers.remove(id);
  //   }
  // }

  // final FirebaseFirestore firestore;
  // final Map<String, bool> _assetExistsCache = {};
  // final Map<String, AudioPlayer> _activePlayers = {};
  // Set<String> _selectedIds = {};

  // SoundBloc({required this.firestore}) : super(SoundInitial()) {
  //   on<LoadSounds>(_onLoadSounds);
  //   on<ToggleSoundSelection>(_onToggleSoundSelection);
  //   on<RefreshSounds>(_onRefreshSounds);
  // }

  // bool isAnySoundPlaying() => _activePlayers.values.any(
  //   (player) => player.state == PlayerState.playing,
  // );

  // Future<void> _onLoadSounds(LoadSounds event, Emitter<SoundState> emit) async {
  //   emit(SoundLoading());
  //   try {
  //     await _loadSelectedFromPrefs();
  //     final sounds = await _fetchSounds();
  //     emit(SoundLoaded(sounds: sounds));
  //   } catch (e) {
  //     emit(SoundError(message: 'Failed to load sounds: $e'));
  //   }
  // }

  // Future<void> _onRefreshSounds(
  //   RefreshSounds event,
  //   Emitter<SoundState> emit,
  // ) async {
  //   _assetExistsCache.clear();
  //   add(LoadSounds());
  // }

  // Future<void> _onToggleSoundSelection(
  //   ToggleSoundSelection event,
  //   Emitter<SoundState> emit,
  // ) async {
  //   if (state is SoundLoaded) {
  //     final currentState = state as SoundLoaded;

  //     // Immediately update UI
  //     final updatedSounds = List<SoundData>.from(currentState.sounds);
  //     final sound = updatedSounds[event.index];
  //     updatedSounds[event.index] = sound.toggleSelection();
  //     emit(SoundLoaded(sounds: updatedSounds));

  //     // Then handle audio in background
  //     if (updatedSounds[event.index].isSelected) {
  //       _selectedIds.add(sound.id);
  //       unawaited(_playSound(sound.id, sound.musicURL));
  //     } else {
  //       _selectedIds.remove(sound.id);
  //       unawaited(_stopSound(sound.id));
  //     }

  //     unawaited(_saveSelectedToPrefs());
  //   }
  // }

  // Future<void> playAllSelected() async {
  //   if (state is SoundLoaded) {
  //     final currentState = state as SoundLoaded;
  //     for (final sound in currentState.sounds.where((s) => s.isSelected)) {
  //       unawaited(_playSound(sound.id, sound.musicURL));
  //     }
  //   }
  // }

  // Future<void> pauseAllSelected() async {
  //   for (final player in _activePlayers.values) {
  //     unawaited(player.pause());
  //   }
  // }

  // Future<void> _playSound(String id, String url) async {
  //   try {
  //     if (_activePlayers.containsKey(id) &&
  //         _activePlayers[id]!.state == PlayerState.playing) {
  //       return;
  //     }

  //     final player = _activePlayers[id] ?? AudioPlayer();
  //     _activePlayers[id] = player;

  //     await player.setReleaseMode(ReleaseMode.loop);
  //     await player.play(UrlSource(url));
  //   } catch (e) {
  //     debugPrint("Error playing audio: $e");
  //   }
  // }

  // Future<void> _stopSound(String id) async {
  //   if (_activePlayers.containsKey(id)) {
  //     await _activePlayers[id]!.stop();
  //     await _activePlayers[id]!.dispose();
  //     _activePlayers.remove(id);
  //   }
  // }

  final FirebaseFirestore firestore;
  final Map<String, bool> _assetExistsCache = {};
  final Map<String, AudioPlayer> _activePlayers = {};
  Set<String> _selectedIds = {};

  SoundBloc({required this.firestore}) : super(SoundInitial()) {
    on<LoadSounds>(_onLoadSounds);
    on<ToggleSoundSelection>(_onToggleSoundSelection);
    on<RefreshSounds>(_onRefreshSounds);
  }

  bool isAnySoundPlaying() => _activePlayers.values
      .any((player) => player.state == PlayerState.playing);

  Future<void> _onLoadSounds(LoadSounds event, Emitter<SoundState> emit) async {
    emit(SoundLoading());
    try {
      await _loadSelectedFromPrefs();
      final sounds = await _fetchSounds();
      emit(SoundLoaded(sounds: sounds));
    } catch (e) {
      emit(SoundError(message: 'Failed to load sounds: $e'));
    }
  }

  Future<void> _onRefreshSounds(RefreshSounds event, Emitter<SoundState> emit) async {
    _assetExistsCache.clear();
    add(LoadSounds());
  }

  Future<void> _onToggleSoundSelection(
    ToggleSoundSelection event,
    Emitter<SoundState> emit,
  ) async {
    if (state is SoundLoaded) {
      final currentState = state as SoundLoaded;
      final updatedSounds = List<SoundData>.from(currentState.sounds);
      final sound = updatedSounds[event.index];
      
      // Toggle selection
      updatedSounds[event.index] = sound.toggleSelection();
      
      // Immediate UI update
      emit(SoundLoaded(sounds: updatedSounds));

      // Handle audio
      if (updatedSounds[event.index].isSelected) {
        _selectedIds.add(sound.id);
        _playSound(sound.id, sound.musicURL); // Don't await here
      } else {
        _selectedIds.remove(sound.id);
        _stopSound(sound.id); // Don't await here
      }

      await _saveSelectedToPrefs();
    }
  }

  Future<void> playAllSelected() async {
    if (state is SoundLoaded) {
      final currentState = state as SoundLoaded;
      await Future.wait(
        currentState.sounds
          .where((s) => s.isSelected)
          .map((sound) => _playSound(sound.id, sound.musicURL))
      );
    }
  }

  Future<void> pauseAllSelected() async {
    await Future.wait(
      _activePlayers.values.map((player) => player.pause())
    );
  }

  Future<void> _playSound(String id, String url) async {
    try {
      // Don't restart if already playing
      if (_activePlayers.containsKey(id) && 
          _activePlayers[id]!.state == PlayerState.playing) {
        return;
      }

      final player = AudioPlayer();
      _activePlayers[id] = player;
      
      // Configure player
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(1.0); // Full volume for each sound
      
      // Start playback
      await player.play(UrlSource(url));
    } catch (e) {
      debugPrint("Error playing audio ($id): $e");
    }
  }

  Future<void> _stopSound(String id) async {
    if (_activePlayers.containsKey(id)) {
      final player = _activePlayers[id]!;
      await player.stop();
      await player.dispose();
      _activePlayers.remove(id);
    }
  }
  // Adjust volumes when number of playing sounds changes
  Future<void> _adjustVolumes() async {
    final count = _activePlayers.length;
    if (count <= 1) return;

    final volume = 1.0 / count;
    for (final player in _activePlayers.values) {
      await player.setVolume(volume);
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

    for (final sound in sounds) {
      final iconName = sound.icon.endsWith('.png')
          ? sound.icon
          : '${sound.icon}.png';
      sound.hasAsset = await _checkAssetExists('assets/images/$iconName');
    }

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedSounds', _selectedIds.toList());
  }

  Future<void> _loadSelectedFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedIds = (prefs.getStringList('selectedSounds') ?? []).toSet();
  }

  Future<void> clearSelectedSounds() async {
    for (final id in _selectedIds.toList()) {
      await _stopSound(id);
    }
    _selectedIds.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedSounds');
  }

  @override
  Future<void> close() {
    for (final player in _activePlayers.values) {
      player.dispose();
    }
    _activePlayers.clear();
    return super.close();
  }
}

// import 'dart:async';
// import 'package:bloc/bloc.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:clarity/model/sound_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'soundevent.dart';
// import 'soundstate.dart';

// class SoundBloc extends Bloc<SoundEvent, SoundState> {
//   final FirebaseFirestore firestore;
//   final Map<String, bool> _assetExistsCache = {};
//   final Map<String, AudioPlayer> _activePlayers = {};
//   Set<String> _selectedIds = {};
//   bool _isPlayingAll = false;

//   SoundBloc({required this.firestore}) : super(SoundInitial()) {
//     on<LoadSounds>(_onLoadSounds);
//     on<ToggleSoundSelection>(_onToggleSoundSelection);
//     on<RefreshSounds>(_onRefreshSounds);
//   }

//   bool isAnySoundPlaying() => _isPlayingAll;

//   Future<void> _onLoadSounds(LoadSounds event, Emitter<SoundState> emit) async {
//     emit(SoundLoading());
//     try {
//       await _loadSelectedFromPrefs();
//       final sounds = await _fetchSounds();
//       emit(SoundLoaded(sounds: sounds));
//     } catch (e) {
//       emit(SoundError(message: 'Failed to load sounds: $e'));
//     }
//   }

//   Future<void> _onRefreshSounds(RefreshSounds event, Emitter<SoundState> emit) async {
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
//       final newSound = sound.toggleSelection();
//       updatedSounds[event.index] = newSound;

//       if (newSound.isSelected) {
//         _selectedIds.add(newSound.id);
//         await _playSound(newSound.id, newSound.musicURL);
//       } else {
//         _selectedIds.remove(newSound.id);
//         await _stopSound(newSound.id);
//       }

//       await _saveSelectedToPrefs();
//       emit(SoundLoaded(sounds: updatedSounds));
//     }
//   }

//   Future<void> playAllSelected() async {
//     if (state is SoundLoaded) {
//       final currentState = state as SoundLoaded;
//       for (final sound in currentState.sounds.where((s) => s.isSelected)) {
//         await _playSound(sound.id, sound.musicURL);
//       }
//       _isPlayingAll = true;
//     }
//   }

//   Future<void> pauseAllSelected() async {
//     for (final player in _activePlayers.values) {
//       await player.pause();
//     }
//     _isPlayingAll = false;
//   }

//   Future<void> _playSound(String id, String url) async {
//     try {
//       final player = AudioPlayer();
//       _activePlayers[id] = player;
//       await player.setReleaseMode(ReleaseMode.loop);
//       await player.play(UrlSource(url));
//     } catch (e) {
//       debugPrint("Error playing audio: $e");
//     }
//   }

//   Future<void> _stopSound(String id) async {
//     if (_activePlayers.containsKey(id)) {
//       await _activePlayers[id]!.stop();
//       await _activePlayers[id]!.dispose();
//       _activePlayers.remove(id);
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

//     for (final sound in sounds) {
//       final iconName = sound.icon.endsWith('.png') 
//           ? sound.icon 
//           : '${sound.icon}.png';
//       sound.hasAsset = await _checkAssetExists('assets/images/$iconName');
//     }

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
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('selectedSounds', _selectedIds.toList());
//   }

//   Future<void> _loadSelectedFromPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     _selectedIds = (prefs.getStringList('selectedSounds') ?? []).toSet();
//   }

//   @override
//   Future<void> close() {
//     for (final player in _activePlayers.values) {
//       player.dispose();
//     }
//     _activePlayers.clear();
//     return super.close();
//   }
// }