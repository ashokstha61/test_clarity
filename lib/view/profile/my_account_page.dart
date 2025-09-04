import 'package:clarity/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clarity/custom/custom_setting.dart';
import 'package:clarity/custom/custom_text_field.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  bool _isDarkMode = false;
  String fullName = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    final appState = MyApp.of(context);
    if (appState != null) _isDarkMode = appState.isDarkMode;
  }

  Future<void> loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    email = user.email ?? 'No Email';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        fullName = data?['fullName'] ?? user.displayName ?? 'No Name';
      } else {
        fullName = user.displayName ?? 'No Name';
      }
    } catch (e) {
      fullName = user.displayName ?? 'No Name';
      print("Error fetching user details: $e");
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'My Account',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors
                      .white // white in dark mode
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              labelText: 'Full Name',
              hintText: '',
              initialValue: fullName,
              readOnly: true,
            ),
            SizedBox(height: 16.0),
            CustomTextField(
              labelText: 'Email',
              hintText: 'Email',
              initialValue: email,
              readOnly: true,
            ),
            SizedBox(height: 10.0),
            // CustomSetting(
            //   title: 'App Settings',
            //   switchLabel: 'Dark Mode',
            //   switchValue: _isDarkMode,
            //   onChanged: (bool value) {
            //     setState(() {
            //       _isDarkMode = value; // Update the theme state
            //     });
            //   },
            // ),
            Divider(),
            CustomSetting(
              title: 'App Settings',
              switchLabel: 'Dark Mode',
              switchValue: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
                final appState = MyApp.of(context);
                appState?.toggleTheme(value); // Update global theme
              },
            ),
          ],
        ),
      ),
    );
  }
}
