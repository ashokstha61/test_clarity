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

  NewSoundModel? _currentSound;

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

  void _onTap(NewSoundModel sound) async {
    setState(() {
      _currentSound = sound;
    });

    await AudioManager().toggleSoundSelection(favoriteSounds, sound, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF12162A),
      body: SafeArea(
        child: Column(
          children: [
            // Title
            SizedBox(height: 5.h),

            // Show EmptyFile if no favorites, else show FavoriteView
            Expanded(
              child: favoriteSounds.isEmpty
                  ? EmptyFile()
                  : ListView.builder(
                      itemCount: favoriteSounds.length,
                      itemBuilder: (context, index) {
                        final sound = favoriteSounds[index];
                        return FavoriteTile(
                          title: sound.title,
                          onTap: () => _onTap(sound),
                        );
                      },
                    ),
            ),

            // Divider(color: Colors.grey.shade700, height: 1.h),

            // Bottom Player Bar
            if (widget.currentTitle != null)
              Container(
                height: 60.h,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E1E2C), Color(0xFF2E2E48)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 25.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.currentTitle!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.textColor(context),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onTogglePlayback,
                      icon: Image.asset(
                        widget.isPlaying
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
