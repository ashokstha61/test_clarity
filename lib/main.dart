// import 'package:clarity/view/test_page.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// // Global variable to track initialization
// bool _isFirebaseInitialized = false;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase only once
//   if (!_isFirebaseInitialized) {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     _isFirebaseInitialized = true;
//     print('Firebase initialized successfully');
//   }

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Clarity',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: TestPage(),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:firebase_database/firebase_database.dart';

// // Global variable to track initialization
// bool _isFirebaseInitialized = false;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   if (!_isFirebaseInitialized) {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     _isFirebaseInitialized = true;
//     print('Firebase initialized successfully');
//   }

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Clarity',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const TestPage(),
//     );
//   }
// }

// class TestPage extends StatefulWidget {
//   const TestPage({super.key});

//   @override
//   TestPageState createState() => TestPageState();
// }

// class TestPageState extends State<TestPage> {
//   late FirebaseDatabase _database;
//   late DatabaseReference _dbRef;
//   String _status = 'Press the button to test connection.';

//   @override
//   void initState() {
//     super.initState();

//     // Use explicit database URL
//     _database = FirebaseDatabase.instanceFor(
//       app: Firebase.app(),
//       databaseURL: 'https://aura-5fcbb-default-rtdb.firebaseio.com', // replace if needed
//     );

//     _dbRef = _database.ref();
//     _testDatabaseConnection();
//   }

//   Future<void> _testDatabaseConnection() async {
//     try {
//       print("\n=== DATABASE CONNECTION TEST ===");
//       print("Using database: ${_database.databaseURL}");

//       final rootSnapshot = await _dbRef.get();
//       final exists = rootSnapshot.exists;
//       final rootData = rootSnapshot.value;

//       final soundSnapshot = await _dbRef.child('SoundData').get();
//       final soundExists = soundSnapshot.exists;
//       final soundData = soundSnapshot.value;

//       print("Root exists: $exists");
//       print("Root data: $rootData");
//       print("SoundData exists: $soundExists");
//       if (soundExists) {
//         print("SoundData content: $soundData");
//       }

//       setState(() {
//         _status = '''
// ✅ Connected to Firebase!
// Root exists: $exists
// SoundData exists: $soundExists
// ''';
//       });
//     } catch (e) {
//       print("FATAL ERROR: $e");
//       setState(() {
//         _status = '❌ Error: ${e.toString()}';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Firebase Test")),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: _testDatabaseConnection,
//                 child: const Text("Test Again"),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 _status,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// bool _isFirebaseInitialized = false;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   if (!_isFirebaseInitialized) {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     _isFirebaseInitialized = true;
//     print('Firebase initialized successfully');
//   }
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Clarity',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const TestPage(),
//     );
//   }
// }

// class TestPage extends StatefulWidget {
//   const TestPage({super.key});
//   @override
//   TestPageState createState() => TestPageState();
// }

// class TestPageState extends State<TestPage> {
//   String _status = 'Press the button to test Firestore connection.';

//   @override
//   void initState() {
//     super.initState();
//     _initializeFirestoreServices();
//   }

//   Future<void> _initializeFirestoreServices() async {
//     await fetchAndPrintAllSounds();
//     // await _testFirestoreConnection();
//     // await addSoundToFirestore(
//     //   id: 'sound_15',
//     //   title: 'Thunder',
//     //   musicURL:
//     //   'https://cdn.pixabay.com/download/audio/2024/02/19/audio_sample.mp3',
//     //   filepath: 'thunder',
//     //   icon: 'thunder_icon',
//     //   category: ['Thunder'],
//     //   volume: 1.0,
//     //   isNew: true,
//     // );
//   }

//   Future<void> _testFirestoreConnection() async {
//     try {
//       print("\n=== FIRESTORE CONNECTION TEST ===");
//       final snapshot =
//       await FirebaseFirestore.instance.collection('SoundData').limit(1).get();

//       final exists = snapshot.docs.isNotEmpty;
//       print("SoundData collection has data: $exists");

//       setState(() {
//         _status = exists
//             ? '✅ Connected to Firestore! SoundData collection contains documents.'
//             : '⚠️ Connected to Firestore but SoundData collection is empty.';
//       });
//     } catch (e) {
//       print("FATAL ERROR: $e");
//       setState(() {
//         _status = '❌ Error: ${e.toString()}';
//       });
//     }
//   }

//   Future<void> fetchAndPrintAllSounds() async {
//     try {
//       final querySnapshot =
//       await FirebaseFirestore.instance.collection('SoundData').get();

//       if (querySnapshot.docs.isEmpty) {
//         print('No sounds found in Firestore.');
//       } else {
//         print('Fetched sounds from Firestore:');
//         for (var doc in querySnapshot.docs) {
//           print('Document ID: ${doc.id}');
//           print('Data: ${doc.data()}');
//         }
//       }
//       setState(() {
//         _status = '✅ Fetched ${querySnapshot.docs.length} sounds from Firestore. See console for details.';
//       });
//     } catch (e) {
//       print('Error fetching sounds: $e');
//       setState(() {
//         _status = '❌ Error fetching sounds: $e';
//       });
//     }
//   }

//   Future<void> addSoundToFirestore({
//     required String id,
//     required String title,
//     required String musicURL,
//     required String filepath,
//     required String icon,
//     required List<String> category,
//     required double volume,
//     bool isFav = false,
//     bool isLocked = false,
//     bool isNew = false,
//     bool isSelected = false,
//   }) async {
//     try {
//       await FirebaseFirestore.instance.collection('SoundData').doc(id).set({
//         'title': title,
//         'musicURL': musicURL,
//         'filepath': filepath,
//         'icon': icon,
//         'category': category,
//         'volume': volume,
//         'isFav': isFav,
//         'isLocked': isLocked,
//         'isNew': isNew,
//         'isSelected': isSelected,
//       });

//       print('✅ Sound $id added successfully');
//     } catch (e) {
//       print('❌ Failed to add sound: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Firestore Test")),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: _testFirestoreConnection,
//                 child: const Text("Test Firestore Connection"),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 _status,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:audioplayers/audioplayers.dart';
import 'package:clarity/view/home/homepage.dart';
import 'package:clarity/view/sound%20mixing%20page/relaxationmix.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Homepage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// class RelaxationMixScreen extends StatefulWidget {
//   const RelaxationMixScreen({super.key});

//   @override
//   _RelaxationMixScreenState createState() => _RelaxationMixScreenState();
// }

// class _RelaxationMixScreenState extends State<RelaxationMixScreen> {
//   double _volume = 1.0;
//   String? _selectedSound;
//   List<Map<String, String>> sounds = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchSounds();
//   }

//   Future<void> _fetchSounds() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('soundData')
//           .get();

//       setState(() {
//         sounds = snapshot.docs.map((doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           return {
//             'title': data['title']?.toString() ?? '',
//             'image': data['image']?.toString() ?? '',
//           };
//         }).toList();
//       });
//     } catch (e) {
//       // Fallback to local sounds if Firebase fails
//       setState(() {
//         sounds = [
//           {'title': 'Bird', 'image': 'bird.png'},
//           {'title': 'Breeze', 'image': 'breeze.png'},
//           {'title': 'Fireplace', 'image': 'fireplace.png'},
//           {'title': 'Forest', 'image': 'forest.png'},
//           {'title': 'Guitar', 'image': 'guitar.png'},
//           {'title': 'Hearts', 'image': 'hearts.png'},
//           {'title': 'Keyboard', 'image': 'keyboard.png'},
//           {'title': 'Leaves', 'image': 'leaves.png'},
//           {'title': 'Lullaby', 'image': 'lullaby.png'},
//           {'title': 'Meditation', 'image': 'meditation.png'},
//           {'title': 'Mountains', 'image': 'mountains.png'},
//           {'title': 'Ocean', 'image': 'ocean.png'},
//           {'title': 'Piano', 'image': 'piano.png'},
//           {'title': 'Rain', 'image': 'rain.png'},
//           {'title': 'Sensory', 'image': 'sensory.png'},
//           {'title': 'Snow', 'image': 'snow.png'},
//           {'title': 'Streams', 'image': 'streams.png'},
//           {'title': 'Sunrise', 'image': 'sunrise.png'},
//           {'title': 'Sunset', 'image': 'sunset.png'},
//           {'title': 'Thunder', 'image': 'thunder.png'},
//           {'title': 'Wave', 'image': 'wave.png'},
//         ];
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromRGBO(17, 23, 42, 1),
//       appBar: AppBar(
//         backgroundColor: Color.fromRGBO(17, 23, 42, 1),
//         title: const Text(
//           'Your Relaxation Mix',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Text(
//               'Recommended Sounds',
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//           ),
//           SizedBox(
//             height: 100,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
//               child: Row(
//                 children: [
//                   const SizedBox(width: 8),
//                   ...sounds.map(
//                     (sound) => Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: SoundButton(
//                         title: sound['title']!,
//                         imagePath: sound['image']!,
//                         onPressed: () =>
//                             setState(() => _selectedSound = sound['title']),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsetsGeometry.all(16),
//             child: Text(
//               'Selected Sounds',
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//           ),

//           if (_selectedSound != null)
//             ListTile(
//               leading: const Icon(Icons.cloud, color: Colors.purple),
//               title: Text(
//                 _selectedSound!,
//                 style: const TextStyle(color: Colors.white),
//               ),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.purple),
//                     onPressed: () => setState(() => _selectedSound = null),
//                   ),
//                   SizedBox(
//                     width: 150,
//                     child: Slider(
//                       value: _volume,
//                       min: 0.0,
//                       max: 1.0,
//                       activeColor: Colors.purple,
//                       inactiveColor: Colors.grey,
//                       onChanged: (value) => setState(() => _volume = value),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           const Spacer(),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         height: 160,
//         decoration: BoxDecoration(
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(16),
//             topRight: Radius.circular(16),
//           ),
//           color: Color.fromRGBO(181, 184, 227, 1),
//         ),
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildBottomButton(Icons.timer, 'Timer'),
//             _buildBottomButton(Icons.play_arrow, 'Play'),
//             _buildBottomButton(Icons.favorite_border, 'Save Mix'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomButton(IconData icon, String label) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         CircleAvatar(
//           radius: 20,
//           backgroundColor: Colors.grey[700],
//           child: Icon(icon, color: Colors.white),
//         ),
//         const SizedBox(height: 4),
//         Text(label, style: const TextStyle(color: Colors.white)),
//       ],
//     );
//   }
// }

// class SoundButton extends StatelessWidget {
//   final String title;
//   final String imagePath;
//   final VoidCallback onPressed;

//   const SoundButton({
//     super.key,
//     required this.title,
//     required this.imagePath,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.grey[800],
//         side: const BorderSide(color: Colors.purple),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Image.asset(
//             'assets/images/himage/$imagePath',
//             width: 40,
//             height: 40,
//             errorBuilder: (context, error, stackTrace) =>
//                 const Icon(Icons.music_note, color: Colors.white, size: 40),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: const TextStyle(color: Colors.white, fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }
// }
