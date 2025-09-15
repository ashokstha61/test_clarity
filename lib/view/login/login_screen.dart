import 'package:clarity/view/signin/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clarity/view/login/auth.dart';
import '../../custom/custom_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 60),
          Image.asset('assets/images/LoginPageImage.png'),
          SizedBox(height: 50),
          Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 15),
                //   child: CustomLoginButton(
                //     label: 'Continue with Apple',
                //     imagePath: 'assets/images/apple.png',
                //     onPressed: () {},
                //   ),
                // ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomLoginButton(
                    label: 'Connect with Google',
                    imagePath: 'assets/images/google.png',
                    onPressed: () async {
                      User? user = await _authService.signInWithGoogle();
                      if (user != null) {
                        // Navigate to home or show success
                      } else {
                        // Show error message
                      }
                    },
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomLoginButton(
                    label: 'Connect with Email',
                    imagePath: 'assets/images/email.png',
                    onPressed: () async {
                      // String email = await _showEmailDialog();
                      // String password = await _showPasswordDialog();
                      // if (email.isNotEmpty && password.isNotEmpty) {
                      //   User? user = await _authService.signInWithEmailAndPassword(email: email, password: password);
                      //   if (user != null) {
                      //     // Navigate to home or show success
                      //   } else {
                      //     // Show error message
                      //   }
                      // }
                      // Navigator.pushReplacementNamed(
                      //   // context,
                      //   // MaterialPageRoute(builder: (_) => SignInScreen()),
                      // );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                        // remove all previous
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
