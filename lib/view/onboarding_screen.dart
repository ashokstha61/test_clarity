import 'package:flutter/material.dart';
import 'package:clarity/view/login_screen.dart';
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
    return Scaffold(
      body: SafeArea(
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
                        SizedBox(height: 40),
                        Image.asset(
                          _onboardingData[index]['image'],
                          width: 334,
                          height: 458,
                        ),
                        SizedBox(height: 20),
                        Text(
                          _onboardingData[index]['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color.fromRGBO(37, 45, 65, 1),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _onboardingData[index]['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(37, 45, 65, 1),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            SmoothPageIndicator(
              controller: _pageController,
              count: _onboardingData.length,
              effect: ExpandingDotsEffect(
                activeDotColor: Color.fromRGBO(29, 172, 146, 1),
              ),
            ),

            SizedBox(height: 20),
            SizedBox(
              width: 334,
              height: 91,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }
                },
                child: Text(
                  _currentPage == _onboardingData.length - 1
                      ? 'Let\'s Begin'
                      : 'Next',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(255, 255, 255, 1),
                  ),
                ),
              ),
            ),

            TextButton(
              onPressed: () {},
              child: Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 37, 45, 65),
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
