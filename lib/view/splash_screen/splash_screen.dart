import 'dart:async';

import 'package:clarity/view/globals/globals.dart' as globals;
import 'package:clarity/view/home/homepage.dart';
import 'package:clarity/view/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:clarity/view/splash_screen/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to OnboardingScreen after 3 seconds
    // Timer(const Duration(seconds: 3), () {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    //   );
    // });
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? onboardingSeen = prefs.getBool('onboardingSeen');

    // Wait for 3 seconds to show splash
    await Future.delayed(const Duration(seconds: 3));

    if (globals.isUserLoggedIn) {
      // Skip onboarding & login → go straight to homepage
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Homepage()),
        );
      }
    } else {
      // Show onboarding first
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }

    if (onboardingSeen == null || onboardingSeen == false) {
      // Mark onboarding as seen
      await prefs.setBool('onboardingSeen', true);

      // Navigate to OnboardingScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } else {
      // Navigate directly to LoginScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white
        : const Color.fromRGBO(37, 45, 65, 1);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/Image.png', height: 160, width: 160),
            const SizedBox(height: 20),
            Text(
              'Clarity'.toUpperCase(),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: 'montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
