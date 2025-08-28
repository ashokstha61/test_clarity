// import 'package:clarity/view/home/homepage.dart';
import 'package:clarity/view/splash_screen/splash_screen.dart';
// import 'package:clarity/view/sound%20mixing%20page/timer_screen.dart';
// import 'package:clarity/view/testSoundpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'view/sound mixing page/remix test.dart';
// import 'package:just_audio/just_audio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashScreen(), debugShowCheckedModeBanner: false);
  }
}
