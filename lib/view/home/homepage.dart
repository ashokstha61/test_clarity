import 'package:clarity/model/model.dart';
import 'package:clarity/new_firebase_service.dart';

import 'package:flutter/material.dart';
import 'package:clarity/view/favourite/favouratepage.dart';
import 'package:clarity/view/profile/profile_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Sound page/test2.dart';
// import '../Sound page/testsound.dart';

// import '../Sound page/Sound.dart';
// import '../Sound page/multisound.dart';

// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   int _currentIndex = 0;

//   final List<Widget> _screens = [SoundPage(), Favouratepage(), ProfilePage()];

//   final List<String> _titles = ['Sounds', 'Favourites', 'Settings'];

//   List<SoundData> soundData = [];
//   final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     print("Database reference path: ${_dbRef.child('SoundData').path}");
//     getSoundData();
//   }

//   Future<void> getSoundData() async {
//     print('fetching....');
//     try {
//       final sounds = await DatabaseService().fetchSoundData();

//       for (var sound in sounds) {
//         print('Sound: ${sound.toString()}');
//         // If sound is an object with properties, you might want to print specific fields:
//         // print('Sound Name: ${sound.name}, URL: ${sound.url}');
//       }

//       // Optionally update state if you're using these sounds in your UI
//       setState(() {
//         // soundData = sounds; // Uncomment if you have a state variable
//       });
//     } catch (e) {
//       print('Error fetching sounds: $e');
//       // Optionally show error to user
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load sounds: ${e.toString()}')),
//       );
//     }
//   }

//   void _onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           _titles[_currentIndex],
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'Recoleta',
//           ),
//         ),
//       ),
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: const Color.fromARGB(255, 37, 37, 80),
//         currentIndex: _currentIndex,
//         onTap: _onTabTapped,
//         selectedItemColor: Colors.grey,
//         unselectedItemColor: const Color.fromARGB(255, 175, 165, 165),
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.audiotrack_outlined),
//             label: 'Sound',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.favorite),
//             label: 'Favorite',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;
  List<NewSoundModel> soundData = [];
  bool _isLoading = true;
  String? _errorMessage;

  late List<Widget> _screens; // Made late to initialize after fetching sounds

  final List<String> _titles = const ['Sounds', 'Favorites', 'Settings'];

  @override
  void initState() {
    super.initState();
    _screens = [
      const SoundPage(), // Placeholder, updated after fetch
      const Favouratepage(),
      const ProfilePage(),
    ];
    _fetchSoundData();
  }

  Future<void> _fetchSoundData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sounds = await DatabaseService().fetchSoundData();
      if (mounted) {
        setState(() {
          soundData = sounds;
          _screens[0] = SoundPage(); // Update SoundPage with fetched sounds
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load sounds: $e';
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load sounds: $e')));
      }
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Recoleta',
            color: isDarkMode
                ? Colors.white
                : Color.fromRGBO(41, 41, 102, 1.000),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchSoundData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 37, 37, 80),
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        unselectedItemColor: Color.fromRGBO(92, 92, 153, 1.000),
        selectedItemColor: Color.fromRGBO(190, 190, 245, 1.000),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
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
