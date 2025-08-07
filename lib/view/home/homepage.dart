import 'package:clarity/firebase_service.dart';
import 'package:clarity/model/sound_model.dart';
import 'package:flutter/material.dart';
import 'package:clarity/view/favourite/favouratepage.dart';
import 'package:clarity/view/profile/profile_page.dart';
import 'package:clarity/view/Sound%20page/soundpage.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [SoundPage(), Favouratepage(), ProfilePage()];

  final List<String> _titles = ['Sounds', 'Favourites', 'Settings'];

  List<SoundItem> soundData = [];
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Database reference path: ${_dbRef.child('SoundData').path}");
    getSoundData();
  }

  Future<void> getSoundData() async {
    print('fetching....');
    try {
      final sounds = await DatabaseService().getSounds();

      for (var sound in sounds) {
        print('Sound: ${sound.toString()}');
        // If sound is an object with properties, you might want to print specific fields:
        // print('Sound Name: ${sound.name}, URL: ${sound.url}');
      }

      // Optionally update state if you're using these sounds in your UI
      setState(() {
        // soundData = sounds; // Uncomment if you have a state variable
      });
    } catch (e) {
      print('Error fetching sounds: $e');
      // Optionally show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load sounds: ${e.toString()}')),
      );
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            fontFamily: 'Recoleta',
          ),
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 37, 37, 80),
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.grey,
        unselectedItemColor: const Color.fromARGB(255, 175, 165, 165),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.audiotrack_outlined),
            label: 'Sound',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
