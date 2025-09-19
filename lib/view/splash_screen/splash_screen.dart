

import 'dart:async';
import 'package:clarity/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(
        context,
      ), // Splash background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            Lottie.asset(
              "assets/lottie/sleep.json",
              height: 200.h,
              width: 200.h,
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
                color: ThemeHelper.textColor(context),
                fontSize: 24.sp,
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
