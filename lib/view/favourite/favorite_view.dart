import 'package:clarity/view/favourite/favorite_tile.dart';
import 'package:clarity/view/favourite/favouratepage.dart';
import 'package:flutter/material.dart';

class FavoriteView extends StatelessWidget {
  final List<String> favorites;
  final String? currentTitle;
  final bool isPlaying;
  final VoidCallback onTogglePlayback;
  final Function(String) onItemTap;

  const FavoriteView({
    super.key,
    required this.favorites,
    required this.currentTitle,
    required this.isPlaying,
    required this.onTogglePlayback,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12162A), // adaptiveBackground
      body: Column(
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.only(top: 20, left: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Favorites",
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // List or Empty State
          Expanded(
            child: favorites.isEmpty
                ? const Center(
                    child: Text(
                      "No favorites yet",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      return FavoriteTile(
                        title: favorites[index],
                        onTap: () => onItemTap(favorites[index]),
                      );
                    },
                  ),
          ),

          // Player View (Bottom Bar)
          if (currentTitle != null)
            Container(
              height: 60,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1E1E2C),
                    Color(0xFF2E2E48),
                  ], // moonlightGradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentTitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: onTogglePlayback,
                    icon: Image.asset(
                      isPlaying
                          ? "assets/images/pause_icon.png"
                          : "assets/images/play_icon.png",
                      width: 28,
                      height: 28,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
