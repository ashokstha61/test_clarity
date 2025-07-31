import 'package:clarity/model/sound_model.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Fetch all sounds
  Future<List<Map<String, dynamic>>> getSounds() async {
    try {
      print("Attempting to fetch sounds from Firebase...");
      final snapshot = await _dbRef.child('SoundData').get();

      if (!snapshot.exists) {
        print("No data exists at 'SoundData' path");
        return [];
      }

      final dynamic data = snapshot.value;

      if (data == null) {
        print("SoundData exists but is null");
        return [];
      }

      if (data is! Map) {
        print("SoundData is not in expected Map format");
        return [];
      }

      final Map<dynamic, dynamic> values = data;
      final List<Map<String, dynamic>> sounds = [];

      values.forEach((key, value) {
        if (value is Map) {
          sounds.add({'id': key.toString(), ...value as Map<String, dynamic>});
        } else {
          print("Skipping entry $key - not a valid sound entry");
        }
      });

      print("Successfully fetched ${sounds.length} sounds");
      return sounds;
    } catch (e) {
      print("Error fetching sounds: ${e.toString()}");
      return []; // Return empty list instead of rethrowing if you prefer
    }
  }

  // Real-time updates listener
  Stream<List<SoundItem>> get soundsStream {
    return _dbRef.child('SoundData').onValue.map((event) {
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
