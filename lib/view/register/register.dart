// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;

//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _registerUser() async {
//     final name = _nameController.text.trim();
//     final phone = _phoneController.text.trim();
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//     final confirmPassword = _confirmPasswordController.text.trim();

//     // Validation
//     if (name.isEmpty) {
//       _showAlert("Invalid Input", "Please enter your full name.");
//       return;
//     }
//     if (email.isEmpty) {
//       _showAlert("Invalid Input", "Email is required.");
//       return;
//     }
//     if (password.isEmpty) {
//       _showAlert("Invalid Input", "Password is required.");
//       return;
//     }
//     if (password != confirmPassword) {
//       _showAlert("Error", "Passwords do not match.");
//       return;
//     }
//     if (!_isValidEmail(email)) {
//       _showAlert("Error", "Please enter a valid email address.");
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // Create Firebase user
//       UserCredential result = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       String uid = result.user!.uid;

//       // Save additional user info in Firestore
//       await _firestore.collection("users").doc(uid).set({
//         "fullName": name,
//         "phone": phone,
//         "email": email,
//         "uid": uid,
//         "createdAt": FieldValue.serverTimestamp(),
//       });

//       _showAlert("Success", "Registered successfully.", () {
//         Navigator.pop(context); // Go back to login
//       });
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'email-already-in-use') {
//         _showAlert(
//           "Error",
//           "This email is already registered. Please use another email or login.",
//         );
//       } else {
//         _showAlert("Error", e.message ?? "Registration failed.");
//       }
//     } catch (e) {
//       _showAlert("Error", e.toString());
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   bool _isValidEmail(String email) {
//     final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//     return regex.hasMatch(email);
//   }

//   void _showAlert(String title, String message, [VoidCallback? onOk]) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               if (onOk != null) onOk();
//             },
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode =
//         MediaQuery.of(context).platformBrightness == Brightness.dark;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Register"),
//         automaticallyImplyLeading: false,
//       ),
//       body: Stack(
//         children: [
//           // Registration Form
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(
//                       labelText: "Full Name",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TextField(
//                     controller: _phoneController,
//                     keyboardType: TextInputType.phone,
//                     decoration: const InputDecoration(
//                       labelText: "Phone Number",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TextField(
//                     controller: _emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: const InputDecoration(
//                       labelText: "Email",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TextField(
//                     controller: _passwordController,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       labelText: "Password",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TextField(
//                     controller: _confirmPasswordController,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       labelText: "Confirm Password",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: _registerUser,
//                       child: const Text(
//                         "Register",
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text("Already have an account? Login"),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Loading indicator
//           if (_isLoading)
//             Container(
//               color: Colors.black54,
//               child: const Center(child: CircularProgressIndicator()),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:clarity/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPhoneValid = true;

  @override
  void initState() {
    super.initState();

    _phoneController.addListener(() {
      if (_phoneController.text.length > 10) {
        setState(() => _isPhoneValid = false);
      } else {
        setState(() => _isPhoneValid = true);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (name.isEmpty) {
      _showAlert("Invalid Input", "Please enter your full name.");
      return;
    }
    // if (phone.isEmpty) {
    //   _showAlert("Invalid Input", "Phone number is required.");
    //   return;
    // }
    if (phone.isNotEmpty && phone.length != 10) {
      _showAlert("Invalid Input", "Phone number must be exactly 10 digits.");
      return;
    }
    // else if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
    //   _showAlert("Invalid Input", "Phone number must be exactly 10 digits.");
    //   return;
    // }

    if (email.isEmpty) {
      _showAlert("Invalid Input", "Email is required.");
      return;
    } else if (!_isValidEmail(email)) {
      _showAlert("Error", "Please enter a valid email address.");
      return;
    }

    if (password.isEmpty) {
      _showAlert("Invalid Input", "Password is required.");
      return;
    } else if (password.length < 6) {
      _showAlert("Error", "Password must be at least 6 characters long.");
      return;
    } else if (password.contains(' ')) {
      _showAlert("Error", "Password should not contain spaces.");
      return;
    } else if (!_isValidEmail(email)) {
      _showAlert("Error", "Please enter a valid email address.");
      return;
    }

    if (confirmPassword.isEmpty) {
      _showAlert("Invalid Input", "Please confirm your password.");
      return;
    } else if (password != confirmPassword) {
      _showAlert("Error", "Passwords do not match.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create Firebase user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = result.user!.uid;

      // Save additional user info in Firestore
      await _firestore.collection("users").doc(uid).set({
        "fullName": name,
        "phone": phone,
        "email": email,
        "uid": uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      _showAlert("Success", "Registered successfully.", () {
        Navigator.pop(context); // Go back to login
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showAlert(
          "Error",
          "This email is already registered. Please use another email or login.",
        );
      } else {
        _showAlert("Error", e.message ?? "Registration failed.");
      }
    } catch (e) {
      _showAlert("Error", e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  void _showAlert(String title, String message, [VoidCallback? onOk]) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) onOk();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ThemeHelper.registerColor(context),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: ThemeHelper.registerTextColor(context),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(_nameController, "Full Name", isDarkMode),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _phoneController,
                    "Phone Number",
                    isDarkMode,
                    keyboardType: TextInputType.phone,
                    borderColor: _isPhoneValid ? null : Colors.red,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // only digits
                      LengthLimitingTextInputFormatter(10), // max 10 digits
                    ],
                  ),

                  const SizedBox(height: 12),
                  _buildTextField(
                    _emailController,
                    "Email",
                    isDarkMode,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _passwordController,
                    "Password",
                    isDarkMode,
                    obscureText: !_isPasswordVisible,
                    isPasswordField: true,
                    isPasswordVisible: _isPasswordVisible,
                    onTogglePassword: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _confirmPasswordController,
                    "Confirm Password",
                    isDarkMode,
                    obscureText: !_isConfirmPasswordVisible,
                    isPasswordField: true,
                    isPasswordVisible: _isConfirmPasswordVisible,
                    onTogglePassword: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _registerUser,
                      child: const Text(
                        "Register",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text.rich(
                        TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.white70),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
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
          ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
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
  List<TextInputFormatter>? inputFormatters, // new parameter
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
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
