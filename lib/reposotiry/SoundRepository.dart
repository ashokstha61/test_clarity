import 'package:clarity/model/sound_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SoundRepository {
  final FirebaseFirestore firestore;

  SoundRepository(this.firestore);

  Future<List<SoundData>> fetchSounds() async {
    final snapshot = await firestore.collection('sounds').get();
    return snapshot.docs.map((doc) => SoundData.fromFirestore(doc)).toList();
  }
}
