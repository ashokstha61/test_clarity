import 'package:clarity/model/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'SoundData';

  Future<List<NewSoundModel>> fetchSoundData() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs.map((doc) {
        return NewSoundModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error fetching sound data: $e');
      return [];
    }
  }

  Future<NewSoundModel?> fetchSoundById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return NewSoundModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching sound by ID: $e');
      return null;
    }
  }

  Future<void> addSoundData(NewSoundModel sound) async {
    try {
      await _firestore.collection(_collectionName).add({
        'filepath': sound.filepath,
        'icon': sound.icon,
        'isFav': sound.isFav,
        'isLocked': sound.isLocked,
        'isNew': sound.isNew,
        'isSelected': sound.isSelected,
        'musicURL': sound.musicUrl,
        'title': sound.title,
        'volume': sound.volume,
      });
    } catch (e) {
      print('Error adding sound data: $e');
    }
  }

  Future<void> updateSoundData(String id, NewSoundModel sound) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'filepath': sound.filepath,
        'icon': sound.icon,
        'isFav': sound.isFav,
        'isLocked': sound.isLocked,
        'isNew': sound.isNew,
        'isSelected': sound.isSelected,
        'musicURL': sound.musicUrl,
        'title': sound.title,
        'volume': sound.volume,
      });
    } catch (e) {
      print('Error updating sound data: $e');
    }
  }

  Future<void> deleteSoundData(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      print('Error deleting sound data: $e');
    }
  }
}