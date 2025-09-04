// import 'dart:async';

// import 'package:clarity/view/home/homepage.dart';
// import 'package:clarity/view/login/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:clarity/view/splash_screen/onboarding_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   // final prefs = await SharedPreferences.getInstance();
//   //   final bool? onboardingSeen = prefs.getBool('onboardingSeen');
//   //    bool isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
//   @override
//   void initState() {
//     super.initState();
//     // Navigate to OnboardingScreen after 3 seconds
//     // Timer(const Duration(seconds: 3), () {
//     //   Navigator.pushReplacement(
//     //     context,
//     //     MaterialPageRoute(builder: (context) => const OnboardingScreen()),
//     //   );
//     // });
//     _navigateNext();
//   }

//   Future<void> _navigateNext() async {
//     final prefs = await SharedPreferences.getInstance();
//     final bool? onboardingSeen = prefs.getBool('onboardingSeen');
//     final bool isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;

//     // Wait for 3 seconds to show splash
//     await Future.delayed(const Duration(seconds: 3));

//     if (!mounted) return;

//     // print(isUserLoggedIn);
//     if (isUserLoggedIn) {
//       // ✅ User already logged in → Go to Homepage
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const Homepage()),
//       );
//     } else if (onboardingSeen == null || onboardingSeen == false) {
//       // ✅ First time user → Show onboarding
//       await prefs.setBool('onboardingSeen', true);
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const OnboardingScreen()),
//         );
//       }
//     } else {
//       // ✅ Onboarding seen but not logged in → Go to Login
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final textColor = theme.brightness == Brightness.dark
//         ? Colors.white
//         : const Color.fromRGBO(37, 45, 65, 1);
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset('assets/images/Image.png', height: 160, width: 160),
//             const SizedBox(height: 20),
//             Text(
//               'Clarity'.toUpperCase(),
//               style: TextStyle(
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//                 color: textColor,
//                 fontFamily: 'montserrat',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clarity/view/home/homepage.dart';
import 'package:clarity/view/login/login_screen.dart';
import 'package:clarity/view/splash_screen/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final int splashDuration = 3; // seconds

  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? onboardingSeen = prefs.getBool('onboardingSeen');
    final bool isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;

    // Show splash for defined duration
    await Future.delayed(Duration(seconds: splashDuration));

    if (!mounted) return;

    if (isUserLoggedIn) {
      // ✅ User already logged in → Go to Homepage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Homepage()),
      );
    } else if (onboardingSeen == null || onboardingSeen == false) {
      // ✅ First time user → Show Onboarding
      await prefs.setBool('onboardingSeen', true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } else {
      // ✅ Onboarding seen but not logged in → Go to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white
        : const Color.fromRGBO(37, 45, 65, 1);

    return Scaffold(
      backgroundColor: Colors.white, // Splash background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            Lottie.asset(
              'assets/lottie/sleep.json',
              height: 200,
              width: 200,
              fit: BoxFit.contain,
              repeat: false,
            ),

            const SizedBox(height: 20),

            // App logo
            // Image.asset('assets/images/Image.png', height: 120, width: 120),
            // const SizedBox(height: 20),

            // App title
            // Text(
            //   'Clarity'.toUpperCase(),
            //   style: TextStyle(
            //     fontSize: 30,
            //     fontWeight: FontWeight.bold,
            //     color: textColor,
            //     fontFamily: 'montserrat',
            //   ),
            // ),
            Text(
              'S L E E P H O R I A',
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
