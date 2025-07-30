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
          image: 'assets/images/himage/thunder.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Rain',
          image: 'assets/images/himage/rain.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Snow',
          image: 'assets/images/himage/snow.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Love',
          image: 'assets/images/himage/love.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'forest',
          image: 'assets/images/himage/forest.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Sensory',
          image: 'assets/images/himage/sensory.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Lullaby',
          image: 'assets/images/himage/lullaby.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Piano',
          image: 'assets/images/himage/piano.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Keyboard',
          image: 'assets/images/himage/keyboard.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Guitar',
          image: 'assets/images/himage/guitar.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Spa',
          image: 'assets/images/himage/meditation.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Fireplace',
          image: 'assets/images/himage/fire.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Ocean',
          image: 'assets/images/himage/wave.png',
          onPressed: () {},
        ),
        Divider(),
        CustomButton(
          label: 'Breeze',
          image: 'assets/images/himage/wind.png',
          onPressed: () {},
        ),
        Divider(),
      ],
    );
  }
}
