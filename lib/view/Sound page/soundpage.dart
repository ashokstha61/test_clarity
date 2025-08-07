import 'package:flutter/material.dart';
import 'package:clarity/custom/custom_button.dart';

class Soundpage extends StatelessWidget {
  const Soundpage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 5),
      scrollDirection: Axis.vertical,

      children: [
        Divider(),
        CustomButton(
          label: 'Thunderstorm',
          image: 'assets/images/thunder_icon.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Rain',
          image: 'assets/images/rain_icon.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Snow',
          image: 'assets/images/snow_icon.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Love',
          image: 'assets/images/hearts_icon.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'forest',
          image: 'assets/images/forest_icon.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Sensory',
          image: 'assets/images/sensory_icon.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Lullaby',
          image: 'assets/images/baby_lullaby_icon.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Piano',
          image: 'assets/images/piano_icon.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Keyboard',
          image: 'assets/images/keyboard_icon.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Guitar',
          image: 'assets/images/guitar_icon.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Spa',
          image: 'assets/images/spa_icon.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Fireplace',
          image: 'assets/images/fireplace_icon.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Ocean',
          image: 'assets/images/waves_icon.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Breeze',
          image: 'assets/images/breeze_icon.png',
          onPressed: () {},
        ),
        Divider(),
      ],
    );
  }
}
