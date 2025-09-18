import 'package:clarity/view/favourite/favorite_view.dart';
import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<String> favorites = ["Mix Audio 1", "Mix Audio 2"];
  String? currentMix;
  bool isPlaying = false;

  void togglePlayback() {
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void handleItemTap(String mix) {
    setState(() {
      if (currentMix == mix) {
        // toggle play/pause
        isPlaying = !isPlaying;
      } else {
        currentMix = mix;
        isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FavoriteView(
      favorites: favorites,
      currentTitle: currentMix,
      isPlaying: isPlaying,
      onTogglePlayback: togglePlayback,
      onItemTap: handleItemTap,
    );
  }
}
