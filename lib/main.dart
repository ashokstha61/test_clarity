import 'package:clarity/view/homepage.dart';
import 'package:flutter/material.dart';
// import 'package:clarity/view/homepage.dart';
import 'package:clarity/view/sound_selection_page.dart';
import 'package:clarity/view/splash_screen.dart';
// import 'package:clarity/view/timer_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clarity', // Updated title to match app name
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Optional: Use Material 3 for modern design
      ),
      home: SoundSelectionPage(), // Start with SoundSelectionPage
    );
  }
}
