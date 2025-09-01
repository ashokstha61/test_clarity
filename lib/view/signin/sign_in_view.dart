import 'package:flutter/material.dart';

class SignInView extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final bool isPasswordVisible;
  final VoidCallback onTogglePassword;

  const SignInView({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.onRegister,
    required this.isPasswordVisible,
    required this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Login",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 30),

            // Email
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDarkMode ? Colors.black : Colors.white,
                labelText: "Email",
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Password with eye toggle
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDarkMode ? Colors.black : Colors.white,
                labelText: "Password",
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: onTogglePassword,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(195, 254, 170, 1.000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                // radius: BorderRadius.circular(8),
                onPressed: onLogin,
                child: const Text("Login"),
              ),
            ),
            const SizedBox(height: 12),

            // Register link
            Center(
              child: TextButton(
                onPressed: onRegister,
                child: const Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: "Register",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
