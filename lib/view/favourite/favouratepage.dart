import 'package:clarity/model/model.dart';
import 'package:clarity/theme.dart';
import 'package:clarity/view/favourite/empty_file.dart';
import 'package:clarity/view/favourite/favorite_tile.dart';
import 'package:clarity/view/favourite/favouratemanager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

class _FavoritesPageState extends State<FavoritesPage> {
  List<NewSoundModel> favoriteSounds = [];
  NewSoundModel? currentMix;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    await FavoriteManager.instance.loadFavorites();
    setState(() {
      favoriteSounds = FavoriteManager.instance.favoriteSounds;
    });
  }

  void _onFavoriteTap(NewSoundModel sound) async {
    final filepaths = sound.mixFilePaths ?? [];

    if (filepaths.isEmpty) return; // prevent crash if no files

    if (currentMix == null || sound.filepath != currentMix!.filepath) {
      // If new mix → stop old one and play this
      if (currentMix?.mixFilePaths != null) {
        await AudioManager().pauseSounds(
          currentMix!.mixFilePaths,
          context: "mix_",
        );
      }
      currentMix = sound;
      await AudioManager().playMix(filepaths, context: "mix_");
      isPlaying = true; // ✅ mark as playing
    } else {
      // If same mix tapped → toggle play/pause
      final playingNow = AudioManager().isAnyPlayingInContext(
        filepaths,
        context: "mix_",
      );
      if (playingNow) {
        await AudioManager().pauseSounds(filepaths, context: "mix_");
        isPlaying = false; // ✅ mark as paused
      } else {
        await AudioManager().playMix(filepaths, context: "mix_");
        isPlaying = true; // ✅ mark as playing
      }
    }

    setState(() {}); // refresh UI
  }

  void _togglePlayback() async {
    if (currentMix != null) {
      if (isPlaying) {
        await AudioManager().pauseSound(currentMix!.filepath);
      } else {
        await AudioManager().playSound(currentMix!.filepath);
      }
      setState(() {
        isPlaying = !isPlaying;
      });
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
              child: favoriteSounds.isEmpty
                  ? EmptyFile()
                  : ListView.builder(
                      itemCount: favoriteSounds.length,
                      itemBuilder: (context, index) {
                        final sound = favoriteSounds[index];
                        return FavoriteTile(
                          title: sound.title,
                          onTap: () => _onFavoriteTap(sound),
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
                      currentMix!.title,
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
