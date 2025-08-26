import 'package:clarity/model/sound_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  

  // Enhanced error handling for fetching sounds
  Future<List<SoundData>> getSounds() async {
    try {
      debugPrint("Attempting to fetch sounds from Firebase RTDB...");

      final DatabaseEvent event = await _dbRef.child('SoundData').once();
      final DataSnapshot snapshot = event.snapshot;

      if (!snapshot.exists) {
        debugPrint("No data exists at 'SoundData' path");
        return [];
      }

      final dynamic data = snapshot.value;

      // Handle different null/empty cases
      if (data == null) {
        debugPrint("SoundData exists but is null");
        return [];
      }

      if (data is! Map) {
        debugPrint("SoundData is not in expected Map format");
        return [];
      }

      final Map<dynamic, dynamic> values = data;
      final List<SoundData> sounds = [];

      values.forEach((key, value) {
        try {
          if (value is Map) {
            sounds.add(
              SoundData.fromMap({
                'id': key.toString(),
                ...value.cast<String, dynamic>(),
              }),
            );
          } else {
            debugPrint("Skipping entry $key - not a valid sound entry");
          }
        } catch (e) {
          debugPrint("Error parsing sound $key: ${e.toString()}");
        }
      });

      debugPrint("Successfully fetched ${sounds.length} sounds");
      return sounds;
    } on FirebaseException catch (e) {
      debugPrint("Firebase error: ${e.message}");
      // You might want to rethrow or handle specific error codes
      return [];
    } catch (e) {
      debugPrint("Unexpected error: ${e.toString()}");
      return [];
    }
  }

  // Enhanced real-time updates listener with error handling
  Stream<List<SoundData>> get soundsStream {
    return _dbRef
        .child('SoundData')
        .onValue
        .handleError((error) {
          debugPrint("Stream error: ${error.toString()}");
          return Stream.value([]); // Return empty list on error
        })
        .map((DatabaseEvent event) {
          try {
            if (!event.snapshot.exists) return [];

            final dynamic data = event.snapshot.value;
            if (data == null || data is! Map) return [];

            final Map<dynamic, dynamic> values = data;
            return values.entries
                .map((entry) {
                  try {
                    return SoundData.fromMap({
                      'id': entry.key.toString(),
                      ...entry.value.cast<String, dynamic>(),
                    });
                  } catch (e) {
                    debugPrint(
                      "Error parsing sound ${entry.key}: ${e.toString()}",
                    );
                    return null;
                  }
                })
                .where((sound) => sound != null)
                .cast<SoundData>()
                .toList();
          } catch (e) {
            debugPrint("Mapping error: ${e.toString()}");
            return [];
          }
        });
  }
}
