import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundMixingPage extends StatefulWidget {
  const SoundMixingPage({super.key});

  @override
  State<SoundMixingPage> createState() => _SoundMixingPageState();
}

class _SoundMixingPageState extends State<SoundMixingPage> {
  final List<AudioPlayer> _audioPlayers = [];
  final List<SoundModel> _selectedSounds = [];
  bool _isPlaying = false;
  List<SoundModel> _allSounds = [];
  List<SoundModel> _recommendedSounds = [];

  @override
  void initState() {
    super.initState();
    _loadSounds();
  }

  Future<void> _loadSounds() async {
    // Load sounds from your data source
    // _allSounds = await SoundRepository.getSounds();
    _updateRecommendedSounds();
  }

  void _updateRecommendedSounds() {
    setState(() {
      _recommendedSounds = _allSounds.where((sound) => !sound.isSelected).toList();
    });
  }

  @override
  void dispose() {
    for (var player in _audioPlayers) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_downward),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Your Relaxation Mix'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommended Sounds',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommendedSounds.length,
                      itemBuilder: (context, index) {
                        final sound = _recommendedSounds[index];
                        return _buildRecommendedSoundButton(sound);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Selected Sounds',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _selectedSounds.isEmpty
                        ? const Center(child: Text('No sounds selected'))
                        : ListView.builder(
                            itemCount: _selectedSounds.length,
                            itemBuilder: (context, index) {
                              final sound = _selectedSounds[index];
                              return _buildSelectedSoundItem(sound, index);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 50),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.timer,
                  label: 'Timer',
                  onPressed: _handleTimer,
                ),
                _buildPlayButton(),
                _buildControlButton(
                  icon: Icons.favorite_border,
                  label: 'Save Mix',
                  onPressed: _handleSaveMix,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSoundButton(SoundModel sound) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _toggleSoundSelection(sound),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/${sound.icon}.png',
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.music_note),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sound.title,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSoundItem(SoundModel sound, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/${sound.icon}.png',
                  width: 30,
                  height: 30,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.music_note),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sound.title,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Slider(
                    value: sound.volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      setState(() => sound.volume = value);
                      _adjustVolume(sound.filepath, value);
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _removeSound(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 36),
          onPressed: onPressed,
        ),
        Text(label),
      ],
    );
  }

  Widget _buildPlayButton() {
    return IconButton(
      icon: Icon(
        _isPlaying ? Icons.pause : Icons.play_arrow,
        size: 36,
      ),
      onPressed: _togglePlayback,
    );
  }

  void _toggleSoundSelection(SoundModel sound) {
    setState(() {
      final index = _allSounds.indexWhere((s) => s.filepath == sound.filepath);
      if (index != -1) {
        _allSounds[index].isSelected = !_allSounds[index].isSelected;
        
        if (_allSounds[index].isSelected) {
          _selectedSounds.add(_allSounds[index]);
          final player = AudioPlayer();
          _audioPlayers.add(player);
        } else {
          _selectedSounds.removeWhere((s) => s.filepath == sound.filepath);
          final playerIndex = _audioPlayers.indexWhere((p) => p.playerId == sound.filepath);
          if (playerIndex != -1) {
            _audioPlayers[playerIndex].dispose();
            _audioPlayers.removeAt(playerIndex);
          }
        }
      }
      _updateRecommendedSounds();
    });
  }

  void _removeSound(int index) {
    setState(() {
      final filepath = _selectedSounds[index].filepath;
      _selectedSounds.removeAt(index);
      
      final soundIndex = _allSounds.indexWhere((s) => s.filepath == filepath);
      if (soundIndex != -1) {
        _allSounds[soundIndex].isSelected = false;
      }
      
      final playerIndex = _audioPlayers.indexWhere((p) => p.playerId == filepath);
      if (playerIndex != -1) {
        _audioPlayers[playerIndex].dispose();
        _audioPlayers.removeAt(playerIndex);
      }
      
      _updateRecommendedSounds();
    });
  }

  void _togglePlayback() async {
    if (_isPlaying) {
      for (var player in _audioPlayers) {
        await player.pause();
      }
    } else {
      for (int i = 0; i < _selectedSounds.length; i++) {
        await _audioPlayers[i].play(UrlSource(_selectedSounds[i].filepath));
        await _audioPlayers[i].setVolume(_selectedSounds[i].volume);
      }
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _adjustVolume(String filepath, double volume) async {
    final playerIndex = _audioPlayers.indexWhere((p) => p.playerId == filepath);
    if (playerIndex != -1) {
      await _audioPlayers[playerIndex].setVolume(volume);
    }
  }

  void _handleTimer() {
    // Implement timer functionality
  }

  void _handleSaveMix() {
    // Implement save mix functionality
  }
}

class SoundModel {
  final String title;
  final String icon;
  final String filepath;
  bool isSelected;
  double volume;

  SoundModel({
    required this.title,
    required this.icon,
    required this.filepath,
    this.isSelected = false,
    this.volume = 1.0,
  });
}