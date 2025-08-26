part of 'sound_cubit.dart';

sealed class SoundState extends Equatable {
  const SoundState();

  @override
  List<Object> get props => [];
}

final class SoundInitial extends SoundState {}
