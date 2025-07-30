import 'package:clarity/custom/sound_card.dart';
import 'package:flutter/material.dart';

class SelectedMusic extends StatefulWidget {
  const SelectedMusic({
    super.key,
    required this.imagePath,
    required this.label,
  });
  final String imagePath;
  final String label;

  @override
  State<SelectedMusic> createState() => _SelectedMusicState();
}

class _SelectedMusicState extends State<SelectedMusic> {
  double _slider = 50;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      child: Row(
        children: [
          Stack(
            children: [
              SoundCard(
                imagePath: 'assets/images/himage/fire.png',
                label: 'Fire',
                onPressed: () {},
              ),
              Positioned(
                bottom: 40,
                left: 52,

                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    minimumSize: Size(24, 24),
                    padding: EdgeInsets.all(0),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 15,
                  ), // Optional: icon for a compact button
                ),
              ),
            ],
          ),
          SizedBox(
            width: 300,
            child: Slider(
              value: _slider,
              min: 0,
              max: 300,

              label: widget.label,
              onChanged: (value) {
                setState(() {
                  _slider = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
