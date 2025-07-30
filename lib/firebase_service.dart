import 'package:clarity/model/sound_model.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Fetch all sounds
  Future<List<Map<String, dynamic>>> getSounds() async {
    try {
      // Replace 'sounds' with your actual database path
      final snapshot = await _dbRef.child('sounds').get();
      
      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        return values.entries.map((entry) {
          return {
            'id': entry.key,
            ...entry.value as Map<String, dynamic>
          };
        }).toList();
      } else {
        print("No sounds available");
        return [];
      }
    } catch (e) {
      print("Error fetching sounds: $e");
      rethrow; // Or return empty list: return [];
    }
  }

  // Real-time updates listener
  Stream<List<SoundItem>> get soundsStream {
    return _dbRef.child('oundData').onValue.map((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> values =
            event.snapshot.value as Map<dynamic, dynamic>;
        return values.values
            .map((value) => SoundItem.fromMap(Map<String, dynamic>.from(value)))
            .toList();
      }
      return [];
    });
  }
}
