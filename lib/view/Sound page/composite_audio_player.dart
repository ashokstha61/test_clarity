import 'package:just_audio/just_audio.dart';

class CompositeAudioPlayer {
  final List<AudioPlayer> _players = [];
  bool _playing = false;

  bool get playing => _playing;

  void add(AudioPlayer player) {
    _players.add(player);
    if (_playing) {
      player.play();
    }
  }

  void remove(AudioPlayer player) {
    _players.remove(player);
    player.pause();
  }

  Future<void> play() async {
    _playing = true;
    await Future.wait(_players.map((player) => player.play()));
  }

  Future<void> pause() async {
    _playing = false;
    await Future.wait(_players.map((player) => player.pause()));
  }

  Future<void> stop() async {
    _playing = false;
    await Future.wait(_players.map((player) => player.stop()));
  }

  Future<void> dispose() async {
    await Future.wait(_players.map((player) => player.dispose()));
    _players.clear();
  }
}