import 'package:flutter/material.dart';

class SoundCard extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback onPressed;

  const SoundCard({
    super.key,
    required this.label,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
      elevation: 1,
      child: Container(
        height: 60, // Reduced from 80 to 60
        width: 70, // Slightly narrower to match new height
        padding: EdgeInsets.all(4.0), // Reduced padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 30, // Reduced from 40
              height: 30,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 4), // Reduced spacing
            Text(
              label,
              style: TextStyle(
                fontSize: 10, // Slightly smaller font
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
