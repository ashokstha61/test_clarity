import 'package:flutter/material.dart';

class RelaxationMixBar extends StatelessWidget {
  final VoidCallback onArrowTap;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final String imagePath;
  final int soundCount;
  final bool isPlaying;

  const RelaxationMixBar({
    super.key,
    required this.onArrowTap,
    required this.onPlay,
    required this.onPause,
    required this.imagePath,
    required this.soundCount,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 193, 193, 242), // top color
            Color.fromARGB(255, 41, 41, 102), // bottom color
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            onPressed: onArrowTap,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              // "assets/images/remix_image.png",
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Relaxation Mix",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "$soundCount sounds",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),

          // IconButton(
          //   icon: isPlaying
          //       ? Image.asset('assets/images/pause.png', width: 24, height: 24)
          //       : Image.asset('assets/images/play.png', width: 24, height: 24),
          //   onPressed: isPlaying ? onPause : onPlay,
          // ),
          IconButton(
            icon: Image.asset(
              isPlaying ? 'assets/images/pause.png' : 'assets/images/play.png',
              width: 24,
              height: 24,
            ),
            onPressed: isPlaying ? onPause : onPlay,
          ),
        ],
      ),
    );
  }
}
