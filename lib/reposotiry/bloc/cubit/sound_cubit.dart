import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'sound_state.dart';

class SoundCubit extends Cubit<SoundState> {
  SoundCubit() : super(SoundInitial());
}
