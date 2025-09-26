import 'package:clarity/model/favSoundModel.dart';
import 'package:clarity/model/model.dart';
import 'package:clarity/theme.dart';
import 'package:clarity/view/favourite/empty_file.dart';
import 'package:clarity/view/favourite/favorite_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../new_firebase_service.dart';
import '../Sound page/AudioManager.dart';

class FavoritesPage extends StatefulWidget {
  final String? currentTitle;
  final bool isPlaying;
  final VoidCallback onTogglePlayback;
  final Function(NewSoundModel) onItemTap;

  const FavoritesPage({
    super.key,
    this.currentTitle,
    this.isPlaying = false,
    required this.onTogglePlayback,
    required this.onItemTap,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

// class _FavoritesPageState extends State<FavoritesPage> {
//   List<FavSoundModel> favoriteSounds = [];
//   List<NewSoundModel> Sounds = [];
//   final DatabaseService _firebaseService = DatabaseService();
//   final AudioManager _audioManager = AudioManager();
//   String? currentMix;
//   bool isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadFavorites();
//     _loadSounds();
//   }

//   void _loadFavorites() async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     final favData = await _firebaseService.loadMixes(userId.toString());
//     setState(() {
//       favoriteSounds = favData;
//     });
//   }

//   Future<void> _loadSounds() async {
//     setState(() {
//       // _isLoading = true;
//       // _errorMessage = null;
//     });

//     try {
//       final sounds = await _firebaseService.fetchSoundData();
//       for (var sound in sounds) {
//         sound.isSelected = _audioManager.selectedSoundTitles.contains(
//           sound.title,
//         );
//       }
//       // _cachedSounds = sounds;

//       setState(() {
//         Sounds = sounds;
//         // _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         // _errorMessage = 'Failed to load sounds: $e';
//         // _isLoading = false;
//       });
//     }
//   }

//   void _onFavoriteTap(String mixName, List<String> soundTitles) async {
//     setState(() {
//     currentMix = mixName;
//     isPlaying = true;
//     });

//     final selectedSounds = Sounds
//         .where((s) => soundTitles.contains(s.title))
//         .toList();

//     if (selectedSounds.isEmpty) {
//     debugPrint("⚠️ No matching sounds found for $mixName");
//     return;
//     }

//     await AudioManager().ensurePlayers(selectedSounds);
//     await AudioManager().syncPlayers(selectedSounds);
//     await AudioManager().playAll();
//   }

//   void _togglePlayback() async {
//     if (currentMix != null) {

//       if (isPlaying) {
//         setState(() {
//           isPlaying = false;
//         });
//         await AudioManager().pauseAll();
//       } else {
//         setState(() {
//           isPlaying = true;
//         });
//         await AudioManager().playAll();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             SizedBox(height: 5.h),
//             Expanded(
//               child: favoriteSounds.isEmpty
//                   ? EmptyFile()
//                   : ListView.builder(
//                       itemCount: favoriteSounds.length,
//                       itemBuilder: (context, index) {
//                         final favSound = favoriteSounds[index];
//                         final mixName = favSound.favSoundTitle;
//                         final soundTitles = favSound.soundTitles;
//                         return FavoriteTile(
//                           title: mixName,
//                           onTap: ()=>_onFavoriteTap(mixName,soundTitles),
//                         );
//                       },
//                     ),
//             ),

//             if (currentMix != null)
//               Container(
//                 height: 60.h,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color.fromARGB(255, 61, 61, 147),
//                       Color.fromARGB(255, 64, 64, 144),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 25.sp),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       currentMix!,
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontFamily: "Montserrat",
//                         fontWeight: FontWeight.w600,
//                         color: ThemeHelper.iconAndTextColorRemix(context),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: _togglePlayback,
//                       icon: Image.asset(
//                         isPlaying
//                             ? "assets/images/pause.png"
//                             : "assets/images/play.png",
//                         width: 28.w,
//                         height: 28.h,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _FavoritesPageState extends State<FavoritesPage> {
  List<FavSoundModel> favoriteSounds = [];
  List<NewSoundModel> Sounds = [];
  final DatabaseService _firebaseService = DatabaseService();
  final AudioManager _audioManager = AudioManager();
  String? currentMix;
  bool isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadFavorites();
    await _loadSounds();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final favData = await _firebaseService.loadMixes(userId.toString());
    setState(() {
      favoriteSounds = favData;
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSounds() async {
    try {
      final sounds = await _firebaseService.fetchSoundData();
      for (var sound in sounds) {
        sound.isSelected = _audioManager.selectedSoundTitles.contains(
          sound.title,
        );
      }

      setState(() {
        Sounds = sounds;
      });
    } catch (e) {
      debugPrint("Failed to load sounds: $e");
    }
  }

  void _onFavoriteTap(String mixName, List<String> soundTitles) async {
    setState(() {
      currentMix = mixName;
      isPlaying = true;
    });

    final selectedSounds = Sounds.where(
      (s) => soundTitles.contains(s.title),
    ).toList();

    if (selectedSounds.isEmpty) {
      debugPrint("⚠️ No matching sounds found for $mixName");
      return;
    }

    await AudioManager().ensurePlayers(selectedSounds);
    await AudioManager().syncPlayers(selectedSounds);
    await AudioManager().playAll();
  }

  void _togglePlayback() async {
    if (currentMix != null) {
      if (isPlaying) {
        setState(() => isPlaying = false);
        await AudioManager().pauseAll();
      } else {
        setState(() => isPlaying = true);
        await AudioManager().playAll();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 5.h),
            Expanded(
              child: favoriteSounds.isEmpty
                  ? EmptyFile()
                  : ListView.builder(
                      itemCount: favoriteSounds.length,
                      itemBuilder: (context, index) {
                        final favSound = favoriteSounds[index];
                        final mixName = favSound.favSoundTitle;
                        final soundTitles = favSound.soundTitles;
                        return FavoriteTile(
                          title: mixName,
                          onTap: () => _onFavoriteTap(mixName, soundTitles),
                        );
                      },
                    ),
            ),
            if (currentMix != null)
              Container(
                height: 60.h,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 61, 61, 147),
                      Color.fromARGB(255, 64, 64, 144),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 25.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentMix!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.iconAndTextColorRemix(context),
                      ),
                    ),
                    IconButton(
                      onPressed: _togglePlayback,
                      icon: Image.asset(
                        isPlaying
                            ? "assets/images/pause.png"
                            : "assets/images/play.png",
                        width: 28.w,
                        height: 28.h,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
