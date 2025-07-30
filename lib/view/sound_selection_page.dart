import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:clarity/custom/sound_card.dart';
import 'timer_screen.dart';

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
  String? _selectedSound;

  final List<Map<String, dynamic>> sounds = [
    {
      'label': 'Thunderstorm',
      'image': 'assets/images/himage/thunder.png',
      // 'audio': 'assets/audio/thunderstorm.mp3',
    },
    {
      'label': 'Rain',
      'image': 'assets/images/himage/rain.png',
      // 'audio': 'assets/audio/rain.mp3',
    },
    {
      'label': 'Snow',
      'image': 'assets/images/himage/snow.png',
      // 'audio': 'assets/audio/snow.mp3',
    },
    {
      'label': 'Love',
      'image': 'assets/images/himage/love.png',
      // 'audio': 'assets/audio/love.mp3',
    },
    {
      'label': 'Forest',
      'image': 'assets/images/himage/forest.png',
      // 'audio': 'assets/audio/forest.mp3',
    },
    {
      'label': 'Sensory',
      'image': 'assets/images/himage/sensory.png',
      // 'audio': 'assets/audio/sensory.mp3',
    },
    {
      'label': 'Lullaby',
      'image': 'assets/images/himage/lullaby.png',
      // 'audio': 'assets/audio/lullaby.mp3',
    },
    {
      'label': 'Piano',
      'image': 'assets/images/himage/piano.png',
      // 'audio': 'assets/audio/piano.mp3',
    },
    {
      'label': 'Keyboard',
      'image': 'assets/images/himage/keyboard.png',
      // 'audio': 'assets/audio/keyboard.mp3',
    },
    {
      'label': 'Guitar',
      'image': 'assets/images/himage/guitar.png',
      // 'audio': 'assets/audio/guitar.mp3',
    },
    {
      'label': 'Spa',
      'image': 'assets/images/himage/meditation.png',
      // 'audio': 'assets/audio/spa.mp3',
    },
    {
      'label': 'Fireplace',
      'image': 'assets/images/himage/fire.png',
      // 'audio': 'assets/audio/fireplace.mp3',
    },
    {
      'label': 'Ocean',
      'image': 'assets/images/himage/wave.png',
      // 'audio': 'assets/audio/ocean.mp3',
    },
    {
      'label': 'Breeze',
      'image': 'assets/images/himage/wind.png',
      // 'audio': 'assets/audio/breeze.mp3',
    },
  ];

  void _playSound(String soundName) async {
    final sound = sounds.firstWhere(
      (s) => s['label'] == soundName,
      orElse: () => {'audio': ''},
    );

    if (sound['audio'] != null && sound['audio'].isNotEmpty) {
      await audioPlayer.play(AssetSource(sound['audio']));
      setState(() {
        _selectedSound = soundName;
      });
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
          Flexible(
            child: SizedBox(
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
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Spacer(),

          if (_isTimerRunning)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Remaining: ${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _showTimerScreen,
                  child: Text('Set Timer'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedSound != null) _playSound(_selectedSound!);
                  },
                  child: Text('Play'),
                ),
                ElevatedButton(
                  onPressed: () {
                    audioPlayer.stop();
                    setState(() {
                      _selectedSound = null;
                    });
                  },
                  child: Text('Stop'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
