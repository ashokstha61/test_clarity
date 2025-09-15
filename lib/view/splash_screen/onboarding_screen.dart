import 'package:clarity/view/signin/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:clarity/view/login/login_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<Map<String, dynamic>> _onboardingData = [
    {
      'image': 'assets/images/image1.png',
      'title': 'STRESS LESS',
      'description': 'Make mindfulness a daily habit and be kind to your mind.',
    },
    {
      'image': 'assets/images/image2.png',
      'title': 'RELAX MORE',
      'description': 'Unwind and find serenity in a guided meditation sessions.',
    },
    {
      'image': 'assets/images/image3.png',
      'title': 'SLEEP LONGER',
      'description': 'Calm racing mind and prepare your body for deep sleep.',
    },
    {
      'image': 'assets/images/image4.png',
      'title': 'LIVE BETTER',
      'description': 'Invest in personal sense of inner peace and balance.',
    },
  ];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white
        : const Color.fromRGBO(37, 45, 65, 1);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      SizedBox(height: 30.h),
                      Image.asset(
                        _onboardingData[index]['image'],
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        _onboardingData[index]['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.h),
                        child: Text(
                          _onboardingData[index]['description'],
                          style: TextStyle(fontSize: 14.sp, color: textColor),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SmoothPageIndicator(
              controller: _pageController,
              count: _onboardingData.length,
              effect: ExpandingDotsEffect(
                dotHeight: 10.r,
                dotWidth: 10.r,
                radius: 20.r,
                expansionFactor: 2.5,
                activeDotColor: Color.fromRGBO(29, 172, 146, 1),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(29, 172, 146, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  if (_currentPage < _onboardingData.length - 1) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                child: Text(
                  _currentPage == _onboardingData.length - 1
                      ? 'Let\'s Begin'
                      : 'Next',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Color.fromRGBO(255, 255, 255, 1),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: textColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}


