import 'package:clarity/model/soundmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SoundController {
  final FirebaseFirestore _firestore;

  SoundController(this._firestore);

  Future<List<SoundModel>> getSounds() async {
    try {
      final snapshot = await _firestore.collection('SoundData').get();
      return snapshot.docs.map(SoundModel.fromFirestore).toList();
    } catch (e) {
      debugPrint('Error fetching sounds: $e');
      return [];
    }
  }

  Future<void> toggleSelection(String id, bool isSelected) async {
    try {
      await _firestore.collection('SoundData').doc(id).update({
        'isSelected': isSelected,
      });
    } catch (e) {
      debugPrint('Error updating selection: $e');
      rethrow;
    }
  }
}