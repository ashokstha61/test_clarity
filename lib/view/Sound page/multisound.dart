import 'package:bloc/bloc.dart';
import 'package:clarity/model/sound_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import 'remix.dart';

// --- Events ---
abstract class SoundEvent extends Equatable {
  const SoundEvent();
  @override
  List<Object?> get props => [];
}

class LoadSounds extends SoundEvent {}

class RefreshSounds extends SoundEvent {}

class ToggleSoundSelection extends SoundEvent {
  final String soundId;
  final String soundUrl;
  final bool isSelected;

  const ToggleSoundSelection({
    required this.soundId,
    required this.soundUrl,
    required this.isSelected,
  });

  @override
  List<Object?> get props => [soundId, soundUrl, isSelected];
}

class PlaySelectedSounds extends SoundEvent {}

class PauseAllSounds extends SoundEvent {}

// --- States ---
abstract class SoundState extends Equatable {
  const SoundState();
  @override
  List<Object?> get props => [];
}

class SoundLoading extends SoundState {}

class SoundLoaded extends SoundState {
  final List<SoundData> sounds;
  final bool isPlaying;

  const SoundLoaded({required this.sounds, required this.isPlaying});

  @override
  List<Object?> get props => [sounds, isPlaying];
}

class SoundError extends SoundState {
  final String message;
  const SoundError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class SoundBloc extends Bloc<SoundEvent, SoundState> {
  final FirebaseFirestore firestore;
  final Map<String, AudioPlayer> activePlayers = {};

  SoundBloc({required this.firestore}) : super(SoundLoading()) {
    on<LoadSounds>(_onLoadSounds);
    on<RefreshSounds>(_onRefreshSounds);
    on<ToggleSoundSelection>(_onToggleSoundSelection);
    on<PlaySelectedSounds>(_onPlaySelectedSounds);
    on<PauseAllSounds>(_onPauseAllSounds);
  }

  Future<void> _onLoadSounds(LoadSounds event, Emitter<SoundState> emit) async {
    try {
      final snapshot = await firestore.collection('SoundData').get();
      final sounds = snapshot.docs.map((doc) {
        final data = doc.data();
        return SoundData(
          id: doc.id,
          title: data['title'].toString(),
          musicURL: data['url'].toString(),
          icon: data['icon'].toString(),
          hasAsset: true,
          filepath: (data['filepath'] ?? '').toString(),
        );
      }).toList();
      emit(SoundLoaded(sounds: sounds, isPlaying: false));
    } catch (e) {
      emit(SoundError("Failed to load sounds: $e"));
    }
  }

  Future<void> _onRefreshSounds(
    RefreshSounds event,
    Emitter<SoundState> emit,
  ) async {
    add(LoadSounds());
  }

  Future<void> _onToggleSoundSelection(
    ToggleSoundSelection event,
    Emitter<SoundState> emit,
  ) async {
    if (state is! SoundLoaded) return;
    final current = state as SoundLoaded;
    final updated = List<SoundData>.from(current.sounds);

    final soundIndex = updated.indexWhere((sound) => sound.id == event.soundId);
    if (soundIndex == -1) return;
    final sound = updated[soundIndex];

    if (!sound.isSelected) {
      // Select → play immediately
      final player = AudioPlayer();
      updated[soundIndex] = sound.copyWith(isSelected: true);
      activePlayers[sound.id] = player;
      emit(SoundLoaded(sounds: updated, isPlaying: true));

      // Play asynchronously with error handling
      if (sound.musicURL.isNotEmpty) {
        try {
          await player.setUrl(sound.musicURL);
          player.play();
        } catch (e) {
          print('Failed to play sound ${sound.title}: $e');
        }
      } else {
        print('Sound URL is empty for ${sound.title}');
      }
    } else {
      // Deselect → stop only this sound
      if (activePlayers.containsKey(sound.id)) {
        await activePlayers[sound.id]?.stop();
        await activePlayers[sound.id]?.dispose();
        activePlayers.remove(sound.id);
      }
      updated[soundIndex] = sound.copyWith(isSelected: false);
      emit(SoundLoaded(sounds: updated, isPlaying: activePlayers.isNotEmpty));
    }
  }

  Future<void> _onPlaySelectedSounds(
    PlaySelectedSounds event,
    Emitter<SoundState> emit,
  ) async {
    for (var player in activePlayers.values) {
      player.play();
    }
    if (state is SoundLoaded) {
      emit(SoundLoaded(sounds: (state as SoundLoaded).sounds, isPlaying: true));
    }
  }

  Future<void> _onPauseAllSounds(
    PauseAllSounds event,
    Emitter<SoundState> emit,
  ) async {
    for (var player in activePlayers.values) {
      await player.pause();
    }
    if (state is SoundLoaded) {
      emit(
        SoundLoaded(sounds: (state as SoundLoaded).sounds, isPlaying: false),
      );
    }
  }

  @override
  Future<void> close() {
    for (var player in activePlayers.values) {
      player.dispose();
    }
    activePlayers.clear();
    return super.close();
  }
}

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
          if (state is SoundLoading) {
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
                                      ToggleSoundSelection(
                                        soundId: sounds[index].id,
                                        soundUrl: sounds[index].musicURL,
                                        isSelected: !sounds[index].isSelected,
                                      ),
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
