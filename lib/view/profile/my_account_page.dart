import 'package:clarity/main.dart';
import 'package:clarity/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clarity/custom/custom_setting.dart';
import 'package:clarity/custom/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _loadCachedUserInfo(); // Load from cache first
    _loadUserInfoFromFirestore(); // Then check Firestore
    final appState = MyApp.of(context);
    if (appState != null) _isDarkMode = appState.isDarkMode;
  }

  /// Load cached values (instant display)
  Future<void> _loadCachedUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      fullName = prefs.getString('fullName') ?? user?.displayName ?? 'No Name';
      email = prefs.getString('email') ?? user?.email ?? 'No Email';
    });
  }

  /// Fetch from Firestore only if newer data exists
  Future<void> _loadUserInfoFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final fetchedName = data?['fullName'];

        if (fetchedName != null &&
            fetchedName.isNotEmpty &&
            fetchedName != fullName) {
          setState(() {
            fullName = fetchedName;
          });

          // ✅ Save to cache
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('fullName', fetchedName);
          await prefs.setString('email', user.email ?? 'No Email');
        }
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
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
            color: ThemeHelper.appBarTitle(context),
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
              initialValue: fullName,
              readOnly: true,
            ),
            SizedBox(height: 16.0),
            CustomTextField(
              labelText: 'Email',
              initialValue: email,
              readOnly: true,
            ),
            SizedBox(height: 10.0),
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
