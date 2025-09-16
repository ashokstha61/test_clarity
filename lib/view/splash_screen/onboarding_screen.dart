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
      'title': 'RELAX MORE.',
      'description': 'Unwind and find serenity in a guided meditation sessions',
    },
    {
      'image': 'assets/images/image3.png',
      'title': 'SLEEP LONGER.',
      'description': 'Calm racing mind and prepare your body for deep sleep.',
    },
    {
      'image': 'assets/images/image4.png',
      'title': 'LIVE BETTER.',
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
        padding: EdgeInsetsGeometry.all(10.sp),
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
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(height: 40.h),
                        Image.asset(
                          _onboardingData[index]['image'],
                          width: 334.w,
                          height: 458.h,
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
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _onboardingData[index]['description'],
                            style: TextStyle(fontSize: 14.sp, color: textColor),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20.h),

            SmoothPageIndicator(
              controller: _pageController,
              count: _onboardingData.length,

              effect: ExpandingDotsEffect(
                radius: 5.sp,
                activeDotColor: Color.fromRGBO(29, 172, 146, 1),
              ),
            ),

            SizedBox(height: 20.h),
            SizedBox(
              width: 334.w,
              height: 60.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(29, 172, 146, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                  fontSize: 16.sp,
                  color: textColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget circularIndicator(bool isActive) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 5),
    width: isActive ? 12 : 10,
    height: isActive ? 12 : 10,
    decoration: BoxDecoration(
      color: isActive
          ? Color.fromRGBO(29, 172, 146, 1)
          : Color.fromRGBO(210, 238, 233, 1),
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
