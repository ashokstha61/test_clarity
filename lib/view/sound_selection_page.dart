import 'dart:async';
import 'package:clarity/custom/sound_control_widget.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:clarity/custom/sound_card.dart';
import 'sound mixing page/timer_screen.dart';

class SoundSelectionPage extends StatefulWidget {
  const SoundSelectionPage({super.key});

  @override
  SoundSelectionPageState createState() => SoundSelectionPageState();
}

class SoundSelectionPageState extends State<SoundSelectionPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;
  final List<Map<String, dynamic>> _activeSounds = [];

  final List<Map<String, dynamic>> sounds = [
    {
      'label': 'Thunderstorm',
      'image': 'assets/images/thunder_icon.png',
      'audio': 'assets/audio/thunderstorm.mp3',
    },
    {
      'label': 'Rain',
      'image': 'assets/images/rain_icon.png',
      'audio': 'assets/audio/rain.mp3',
    },
    {
      'label': 'Snow',
      'image': 'assets/images/snow_icon.png',
      'audio': 'assets/audio/snow.mp3',
    },
    {
      'label': 'Love',
      'image': 'assets/images/hearts_icon.png',
      'audio': 'assets/audio/love.mp3',
    },
    {
      'label': 'Forest',
      'image': 'assets/images/forest_icon.png',
      'audio': 'assets/audio/forest.mp3',
    },
    {
      'label': 'Sensory',
      'image': 'assets/images/sensory_icon.png',
      'audio': 'assets/audio/sensory.mp3',
    },
    {
      'label': 'Lullaby',
      'image': 'assets/images/baby_lullaby_icon.png',
      'audio': 'assets/audio/lullaby.mp3',
    },
    {
      'label': 'Piano',
      'image': 'assets/images/piano_icon.png',
      'audio': 'assets/audio/piano.mp3',
    },
    {
      'label': 'Keyboard',
      'image': 'assets/images/keyboard_icon.png',
      'audio': 'assets/audio/keyboard.mp3',
    },
    {
      'label': 'Guitar',
      'image': 'assets/images/guitar_icon.png',
      'audio': 'assets/audio/guitar.mp3',
    },
    {
      'label': 'Spa',
      'image': 'assets/images/spa_icon.png',
      'audio': 'assets/audio/spa.mp3',
    },
    {
      'label': 'Fireplace',
      'image': 'assets/images/fireplace_icon.png',
      'audio': 'assets/audio/fireplace.mp3',
    },
    {
      'label': 'Ocean',
      'image': 'assets/images/waves_icon.png',
      'audio': 'assets/audio/ocean.mp3',
    },
    {
      'label': 'Breeze',
      'image': 'assets/images/breeze_icon.png',
      'audio': 'assets/audio/breeze.mp3',
    },
  ];

  void _playSound(String soundName) async {
    final sound = sounds.firstWhere(
      (s) => s['label'] == soundName,
      orElse: () => {'audio': ''},
    );

    if (sound['audio'] != null && sound['audio'].isNotEmpty) {
      if (!_activeSounds.any((s) => s['label'] == soundName)) {
        setState(() {
          _activeSounds.add({
            'label': soundName,
            'icon': _getIconForSound(soundName),
            'audio': sound['audio'],
          });
        });
      }
      await audioPlayer.play(AssetSource(sound['audio']));
    }
  }

  IconData _getIconForSound(String soundName) {
    switch (soundName) {
      case 'Thunder':
        return Icons.flash_on;
      case 'Rain':
        return Icons.cloud;
      case 'Snow':
        return Icons.ac_unit;
      case 'Forest':
        return Icons.nature;
      case 'Ocean':
        return Icons.waves;
      case 'Fireplace':
        return Icons.fireplace;
      case 'Lullaby':
        return Icons.night_shelter;
      case 'Piano':
        return Icons.piano;
      case 'Guitar':
        return Icons.music_note;
      default:
        return Icons.music_note;
    }
  }

  void _showTimerScreen() {
    showModalBottomSheet(
      context: context,
      builder: (context) => TimerScreen(
        onTimerSelected: (duration) {
          setState(() {
            _remainingSeconds = duration;
            _isTimerRunning = true;
          });
          Navigator.pop(context);
          _startTimer();
        },
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isTimerRunning = false;
          audioPlayer.stop();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.keyboard_arrow_down),
        title: Text('Your Relaxation Mix'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Flexible(
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: sounds.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    width: 80,
                    child: SoundCard(
                      label: sounds[index]['label'],
                      imagePath: sounds[index]['image'],
                      onPressed: () => _playSound(sounds[index]['label']),
                    ),
                  ),
                );
              },
            ),
          ),
          // ),
          SizedBox(
            height: 40,
            child: Text(
              'Selected Sound',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.start,
            ),
          ),
          SoundControlWidget(
            label: 'thunder',
            icon: Icons.thunderstorm_outlined,
            onRemove: () {},
            audioPlayer: audioPlayer,
            // audioPlayer: audioPlayer,
          ),
          // Column(
          //   children: _activeSounds.map((sound) {
          //     return SoundControlWidget(
          //       key: ValueKey(sound['label']),
          //       label: sound['label'],
          //       icon: sound['icon'],
          //       audioPlayer: audioPlayer,
          //       audioPath: sound['audio'],
          //       onRemove: () {
          //         setState(() {
          //           _activeSounds.removeWhere(
          //             (s) => s['label'] == sound['label'],
          //           );
          //         });
          //       },
          //     );
          //   }).toList(),
          // ),
          Spacer(),
          // if (_isTimerRunning)
          //   Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Text(
          //       'Remaining: ${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
          //       style: TextStyle(fontSize: 16),
          //     ),
          //   ),
          // SizedBox(height: 600),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 24.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.8),
                  Theme.of(context).primaryColorDark.withOpacity(0.9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12.0,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Set Timer Button
                FloatingActionButton(
                  heroTag: 'timer_button',
                  onPressed: _showTimerScreen,
                  child: Icon(Icons.timer),
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                ),

                // Play All Button
                FloatingActionButton(
                  heroTag: 'play_button',
                  onPressed: () {
                    if (_activeSounds.isNotEmpty) {
                      audioPlayer.resume();
                    }
                  },
                  child: Icon(Icons.play_arrow),
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                ),

                // Stop All Button
                FloatingActionButton(
                  heroTag: 'stop_button',
                  onPressed: () {
                    audioPlayer.stop();
                  },
                  child: Icon(Icons.stop),
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
