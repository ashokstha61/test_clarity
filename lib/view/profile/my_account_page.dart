import 'package:flutter/material.dart';
import 'package:clarity/custom/custom_setting.dart';
import 'package:clarity/custom/custom_text_field.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(labelText: 'Full Name', hintText: 'Name'),
              SizedBox(height: 16.0),
              CustomTextField(labelText: 'Email', hintText: 'Email'),
              SizedBox(height: 16.0),
              CustomSetting(
                title: 'App Settings',
                switchLabel: 'Dark Mode',
                switchValue: _isDarkMode,
                onChanged: (bool value) {
                  setState(() {
                    _isDarkMode = value; // Update the theme state
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
