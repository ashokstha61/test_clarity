import 'package:clarity/model/sound_model.dart';

abstract class SoundState {}

class SoundInitial extends SoundState {}

class SoundLoading extends SoundState {}

class SoundLoaded extends SoundState {
  final List<SoundData> sounds;

  SoundLoaded({required this.sounds});
}

// class SoundLoaded extends SoundState {
//   final List<SoundData> sounds;

//   SoundLoaded({required this.sounds});

//   SoundLoaded copyWith({List<SoundData>? sounds}) {
//     return SoundLoaded(
//       sounds: sounds ?? this.sounds,
//     );
//   }
// }

class SoundError extends SoundState {
  final String message;

  SoundError({required this.message});
}

