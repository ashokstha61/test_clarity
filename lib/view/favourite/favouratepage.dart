import 'package:clarity/model/model.dart';
import 'package:clarity/theme.dart';
import 'package:clarity/view/favourite/empty_file.dart';
import 'package:clarity/view/favourite/favorite_tile.dart';
import 'package:clarity/view/favourite/favouratemanager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../new_firebase_service.dart';
import '../Sound page/AudioManager.dart';

Map<String, List<String>> soundMixes = {
  // "Morning Mix": ["Birds", "Piano", "Rain"],
  // "Focus Mix": ["White Noise", "Typing", "Soft Wind"],
  // "Sleep Mix": ["Ocean", "Rain", "Thunder"],
};

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

class _FavoritesPageState extends State<FavoritesPage> {
  List<NewSoundModel> favoriteSounds = [];
  List<NewSoundModel> Sounds = [];
  final DatabaseService _firebaseService = DatabaseService();
  final AudioManager _audioManager = AudioManager();
  String? currentMix;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadSounds();
  }

  void _loadFavorites() async {
    final fav = await FavoriteManager.instance.loadFavorites();
    setState(() {
      favoriteSounds = FavoriteManager.instance.favoriteSounds;
      soundMixes = fav;
    });
  }

  Future<void> _loadSounds() async {
    setState(() {
      // _isLoading = true;
      // _errorMessage = null;
    });

    try {
      final sounds = await _firebaseService.fetchSoundData();
      for (var sound in sounds) {
        sound.isSelected = _audioManager.selectedSoundTitles.contains(
          sound.title,
        );
      }
      // _cachedSounds = sounds;

      setState(() {
        Sounds = sounds;
        // _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // _errorMessage = 'Failed to load sounds: $e';
        // _isLoading = false;
      });
    }
  }

  void _onFavoriteTap(String mixName, List<String> soundTitles) async {
  setState(() {
  currentMix = mixName; // mark current
  isPlaying = true;
  });

  final selectedSounds = Sounds
      .where((s) => soundTitles.contains(s.title))
      .toList();

  if (selectedSounds.isEmpty) {
  debugPrint("⚠️ No matching sounds found for $mixName");
  return;
  }

  // Ensure AudioPlayers exist
  await AudioManager().ensurePlayers(selectedSounds);

  // Sync players (volumes, etc.)
  await AudioManager().syncPlayers(selectedSounds);

  // Play all sounds in this mix
  await AudioManager().playAll();
  }

  void _togglePlayback() async {
    if (currentMix != null) {

      if (isPlaying) {
        setState(() {
          isPlaying = false;
        });
        await AudioManager().pauseAll();
      } else {
        setState(() {
          isPlaying = true;
        });
        await AudioManager().playAll();
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 5.h),
            Expanded(
              child: soundMixes.isEmpty
                  ? EmptyFile()
                  : ListView.builder(
                      itemCount: soundMixes.length,
                      itemBuilder: (context, index) {
                        final mixName = soundMixes.keys.elementAt(index);
                        final soundTitles = soundMixes[mixName]!;
                        return FavoriteTile(
                          title: mixName,
                          onTap: ()=>_onFavoriteTap(mixName,soundTitles),




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
