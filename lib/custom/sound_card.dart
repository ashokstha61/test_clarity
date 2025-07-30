import 'package:flutter/material.dart';

class SoundCard extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback onPressed;

  SoundCard({required this.label, required this.imagePath, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
      child: ListTile(
        leading: Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        onTap: onPressed,
      ),
    );
  }
}