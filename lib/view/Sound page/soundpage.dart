// import 'package:flutter/material.dart';
// import 'package:clarity/custom/custom_button.dart';

// class Soundpage extends StatelessWidget {
//   const Soundpage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: EdgeInsets.symmetric(horizontal: 5),
//       scrollDirection: Axis.vertical,

//       children: [
//         Divider(),
//         CustomButton(
//           label: 'Thunderstorm',
//           image: 'assets/images/thunder_icon.png',
//           onPressed: () {},
//         ),
//         Divider(),
//         CustomButton(
//           label: 'Rain',
//           image: 'assets/images/rain_icon.png',
//           onPressed: () {},
//         ),
//         Divider(),
//         CustomButton(
//           label: 'Snow',
//           image: 'assets/images/snow_icon.png',
//           onPressed: () {},
//         ),
//         Divider(),
//         CustomButton(
//           label: 'Love',
//           image: 'assets/images/hearts_icon.png',
//           onPressed: () {},
//         ),
//         Divider(),
//         CustomButton(
//           label: 'forest',
//           image: 'assets/images/forest_icon.png',
//           onPressed: () {},
//         ),
//         Divider(),
//         CustomButton(
//           label: 'Sensory',
//           image: 'assets/images/sensory_icon.png',
//           onPressed: () {},
//         ),
//         Divider(),
//         CustomButton(
//           label: 'Lullaby',
//           image: 'assets/images/baby_lullaby_icon.png',
//           onPressed: () {},
//         ),
//         Divider(),
//         CustomButton(
//           label: 'Piano',
//           image: 'assets/images/piano_icon.png',
//           onPressed: () {},
//         ),
//         Divider(),
//         CustomButton(
//           label: 'Keyboard',
//           image: 'assets/images/keyboard_icon.png',
//           onPressed: () {},
//         ),
//         Divider(),
//         CustomButton(
//           label: 'Guitar',
//           image: 'assets/images/guitar_icon.png',
//           onPressed: () {},
//         ),
//         Divider(),
//         CustomButton(
//           label: 'Spa',
//           image: 'assets/images/spa_icon.png',
//           onPressed: () {},
//         ),
//         Divider(),
//         CustomButton(
//           label: 'Fireplace',
//           image: 'assets/images/fireplace_icon.png',
//           onPressed: () {},
//         ),
//         Divider(),
//         CustomButton(
//           label: 'Ocean',
//           image: 'assets/images/waves_icon.png',
//           onPressed: () {},
//         ),
//         Divider(),
//         CustomButton(
//           label: 'Breeze',
//           image: 'assets/images/breeze_icon.png',
//           onPressed: () {},
//         ),
//         Divider(),
//       ],
//     );
//   }
// }

import 'package:clarity/model/sound_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

// class SoundPage extends StatefulWidget {
//   const SoundPage({super.key});

//   @override
//   State<SoundPage> createState() => _SoundPageState();
// }

// class _SoundPageState extends State<SoundPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late Future<List<SoundItem>> _soundsFuture;
//   final Map<String, bool> _assetExistsCache = {};

//   @override
//   void initState() {
//     super.initState();
//     _soundsFuture = _fetchSounds();
//   }

//   Future<bool> _checkAssetExists(String path) async {
//     if (_assetExistsCache.containsKey(path)) {
//       return _assetExistsCache[path]!;
//     }
//     try {
//       await rootBundle.load(path);
//       _assetExistsCache[path] = true;
//       return true;
//     } catch (_) {
//       _assetExistsCache[path] = false;
//       return false;
//     }
//   }

//   Future<List<SoundItem>> _fetchSounds() async {
//     try {
//       final snapshot = await _firestore.collection('SoundData').get();
//       if (snapshot.docs.isEmpty) {
//         debugPrint('No documents found in SoundData collection');
//         return [];
//       }

//       final sounds = snapshot.docs.map((doc) {
//         final sound = SoundItem.fromMap(doc.data());
//         debugPrint('Fetched sound: ${sound.title}, icon: ${sound.icon}');
//         return sound;
//       }).toList();

//       // Verify assets for all sounds
//       for (var sound in sounds) {
//         final iconName = sound.icon.endsWith('.png')
//             ? sound.icon
//             : '${sound.icon}.png';
//         final assetPath = 'assets/images/$iconName';
//         sound.hasAsset = await _checkAssetExists(assetPath);
//         debugPrint('Sound ${sound.title}: $iconName exists? ${sound.hasAsset}');
//       }

//       return sounds;
//     } catch (e) {
//       debugPrint("Error fetching sounds: $e");
//       return [];
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<List<SoundItem>>(
//         future: _soundsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError ||
//               !snapshot.hasData ||
//               snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text('No sounds available or error occurred'),
//             );
//           }

//           final sounds = snapshot.data!;
//           return ListView(
//             padding: const EdgeInsets.symmetric(horizontal: 5),
//             children: [
//               for (var sound in sounds) ...[
//                 const Divider(),
//                 _SoundTile(sound: sound),
//               ],
//               const Divider(),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class _SoundTile extends StatelessWidget {
//   final SoundItem sound;

//   const _SoundTile({required this.sound});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(5),
//       child: ListTile(
//         contentPadding: EdgeInsets.zero,
//         leading: Container(
//           height: 70,
//           width: 77,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//             border: Border.all(color: Colors.blueGrey),
//           ),
//           child: Center(
//             child: sound.hasAsset
//                 ? Image.asset(
//                     'assets/images/${sound.icon.endsWith('.png') ? sound.icon : '${sound.icon}.png'}',
//                     height: 24,
//                     width: 24,
//                     errorBuilder: (context, error, stackTrace) {
//                       debugPrint(
//                         'Failed to load asset for ${sound.title}: ${sound.icon}',
//                       );
//                       return const Icon(Icons.music_note);
//                     },
//                   )
//                 : const Icon(Icons.music_note),
//           ),
//         ),
//         title: Text(
//           sound.title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'Montserrat',
//           ),
//         ),
//       ),
//     );
//   }
// }

class SoundPage extends StatefulWidget {
  const SoundPage({super.key});

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<SoundItem> _sounds = [];
  final Map<String, bool> _assetExistsCache = {};
  bool _isLoading = true; // Start with loading true

  @override
  void initState() {
    super.initState();
    _fetchSounds();
  }

  Future<bool> _checkAssetExists(String path) async {
    if (_assetExistsCache.containsKey(path)) {
      return _assetExistsCache[path]!;
    }
    try {
      await rootBundle.load(path);
      _assetExistsCache[path] = true;
      return true;
    } catch (_) {
      _assetExistsCache[path] = false;
      return false;
    }
  }

  Future<void> _fetchSounds() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final snapshot = await _firestore.collection('SoundData').get();
      if (snapshot.docs.isEmpty) {
        debugPrint('No documents found in SoundData collection');
        setState(() {
          _sounds = [];
          _isLoading = false;
        });
        return;
      }

      final sounds = snapshot.docs.map((doc) {
        final sound = SoundItem.fromMap(doc.data());
        debugPrint('Fetched sound: ${sound.title}, icon: ${sound.icon}');
        return sound;
      }).toList();

      // Verify assets for all sounds
      for (var sound in sounds) {
        final iconName = sound.icon.endsWith('.png')
            ? sound.icon
            : '${sound.icon}.png';
        final assetPath = 'assets/images/$iconName';
        sound.hasAsset = await _checkAssetExists(assetPath);
        debugPrint('Sound ${sound.title}: $iconName exists? ${sound.hasAsset}');
      }

      setState(() {
        _sounds = sounds;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching sounds: $e");
      setState(() {
        _sounds = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load sounds: $e')));
    }
  }

  void _toggleSoundSelection(int index) {
    setState(() {
      _sounds[index].isSelected = !_sounds[index].isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sounds.isEmpty
          ? const Center(child: Text('No sounds available or error occurred'))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              children: [
                for (var i = 0; i < _sounds.length; i++) ...[
                  const Divider(),
                  _SoundTile(
                    sound: _sounds[i],
                    onTap: () => _toggleSoundSelection(i),
                  ),
                ],
                const Divider(),
              ],
            ),
    );
  }
}

class _SoundTile extends StatelessWidget {
  final SoundItem sound;
  final VoidCallback onTap;

  const _SoundTile({required this.sound, required this.onTap});

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
            color: sound.isSelected ? Color.fromRGBO(176, 176, 224, 1) : null,
          ),
          child: Center(
            child: sound.hasAsset
                ? Image.asset(
                    'assets/images/${sound.icon.endsWith('.png') ? sound.icon : '${sound.icon}.png'}',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint(
                        'Failed to load asset for ${sound.title}: ${sound.icon}',
                      );
                      return const Icon(Icons.music_note);
                    },
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
