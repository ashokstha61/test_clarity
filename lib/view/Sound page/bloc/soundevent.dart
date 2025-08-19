// abstract class SoundEvent {}

// class LoadSounds extends SoundEvent {}

// class RefreshSounds extends SoundEvent {}

// class ToggleSoundSelection extends SoundEvent {
//   final int index;

//   ToggleSoundSelection(this.index);
// }



abstract class SoundEvent {}

class LoadSounds extends SoundEvent {}

class RefreshSounds extends SoundEvent {}

class ToggleSoundSelection extends SoundEvent {
  final int index;

  ToggleSoundSelection(this.index);
}

class PlaySelectedSounds extends SoundEvent {}

class PauseAllSounds extends SoundEvent {}

