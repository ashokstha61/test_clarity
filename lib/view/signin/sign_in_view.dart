import 'package:clarity/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignInView extends StatefulWidget {
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
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: isDarkMode ? Colors.white : Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: ThemeHelper.backgroundColor(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Login",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: ThemeHelper.loginAndRegisterTitleColor(context),
              ),
            ),
            const SizedBox(height: 30),

            // Email
            _buildTextField(
              widget.emailController,
              "Email",
              isDarkMode,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Password
            _buildTextField(
              widget.passwordController,
              "Password",
              isDarkMode,
              obscureText: !widget.isPasswordVisible,
              isPasswordField: true,
              isPasswordVisible: widget.isPasswordVisible,
              onTogglePassword: widget.onTogglePassword,
            ),
            const SizedBox(height: 20),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: widget.onLogin,
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Register link
            Center(
              child: TextButton(
                onPressed: widget.onRegister,
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

Widget _buildTextField(
  TextEditingController controller,
  String label,
  bool isDarkMode, {
  bool obscureText = false,
  bool isPasswordField = false,
  VoidCallback? onTogglePassword,
  bool isPasswordVisible = false,
  TextInputType? keyboardType,
  Color? borderColor,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
    decoration: InputDecoration(
      filled: true,
      fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
      labelText: label,
      labelStyle: TextStyle(
        color: isDarkMode ? Colors.white70 : Colors.black54,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: borderColor ?? (isDarkMode ? Colors.white54 : Colors.black26),
        ),
      ),
      suffixIcon: isPasswordField
          ? IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: onTogglePassword,
            )
          : null,
    ),
  );
}
