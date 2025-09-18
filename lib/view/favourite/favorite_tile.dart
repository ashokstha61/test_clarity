import 'package:flutter/material.dart';

class FavoriteTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const FavoriteTile({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade200, width: 1), // c200 equivalent
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Icon(Icons.music_note, color: Colors.white),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: "Montserrat",
          color: Colors.white, // adaptiveTextColor
        ),
      ),
      onTap: onTap,
    );
  }
}
