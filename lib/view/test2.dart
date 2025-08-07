import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RelaxationMixPage extends StatefulWidget {
  const RelaxationMixPage({super.key});

  @override
  State<RelaxationMixPage> createState() => _RelaxationMixPageState();
}

class _RelaxationMixPageState extends State<RelaxationMixPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> recommendedSounds = [];
  List<Map<String, dynamic>> selectedSounds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSounds();
  }

  Future<void> _fetchSounds() async {
    try {
      final snapshot = await _firestore.collection('SoundData').get();

      setState(() {
        recommendedSounds = snapshot.docs
            .map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'title': data['title'] ?? '',
                'category': data['category'] ?? '',
                'icon': _getIconData(data['icon'] ?? ''),
                'isRecommended': data['isRecommended'] ?? false,
                'musicURL': data['musicURL'] ?? '',
              };
            })
            .where((sound) => sound['isRecommended'])
            .toList();
            

        isLoading = false;
      });
    } catch (e) {
      print('Error fetching sounds: $e');
      setState(() => isLoading = false);
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'thunder_icon':
        return Icons.flash_on;
      case 'leaves_icon':
        return Icons.nature;
      case 'snow_icon':
        return Icons.ac_unit;
      case 'love_icon':
        return Icons.favorite;
      case 'lullaby_icon':
        return Icons.night_shelter;
      default:
        return Icons.music_note;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      // ... (keep existing app bar code)
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recommended Sounds Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Recommended Sounds',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: recommendedSounds.length,
              itemBuilder: (context, index) {
                final sound = recommendedSounds[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SoundCard(
                    label: sound['title'],
                    icon: sound['icon'],
                    onPressed: () => _toggleSound(sound),
                  ),
                );
              },
            ),
          ),

          // Selected Sounds Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Selected Sounds',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (selectedSounds.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('No sounds selected'),
            )
          else
            Column(
              children: selectedSounds.map((sound) {
                return SoundControlCard(
                  label: sound['title'],
                  icon: sound['icon'],
                  onRemove: () => _removeSound(sound),
                  audioPlayer: audioPlayer,
                );
              }).toList(),
            ),

          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'play_button',
                  onPressed: _playAllSounds,
                  child: const Icon(Icons.play_arrow),
                  mini: true,
                ),
                FloatingActionButton(
                  heroTag: 'stop_button',
                  onPressed: _stopAllSounds,
                  child: const Icon(Icons.stop),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSound(Map<String, dynamic> sound) {
    setState(() {
      if (selectedSounds.any((s) => s['id'] == sound['id'])) {
        selectedSounds.removeWhere((s) => s['id'] == sound['id']);
      } else {
        selectedSounds.add(sound);
      }
    });
  }

  void _removeSound(Map<String, dynamic> sound) {
    setState(() {
      selectedSounds.removeWhere((s) => s['id'] == sound['id']);
    });
    audioPlayer.stop();
  }

  void _playAllSounds() async {
    if (selectedSounds.isNotEmpty) {
      // Play the first selected sound (expand this for multiple sounds)
      await audioPlayer.play(UrlSource(selectedSounds.first['musicURL']));
    }
  }

  void _stopAllSounds() {
    audioPlayer.stop();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}

class SoundCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const SoundCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 36, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class SoundControlCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onRemove;
  final AudioPlayer audioPlayer;

  const SoundControlCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onRemove,
    required this.audioPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: onRemove),
          ],
        ),
      ),
    );
  }
}
