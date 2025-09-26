import 'dart:convert';
import 'package:clarity/model/favSoundModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clarity/model/model.dart';

import '../../new_firebase_service.dart';
import 'favouratepage.dart'; // <- Your NewSoundModel

class FavoriteManager {
  FavoriteManager._privateConstructor();
  static final FavoriteManager instance = FavoriteManager._privateConstructor();
  final service = DatabaseService();

  List<NewSoundModel> favoriteSounds = [];

  String _mixesKey(String userId) => "SavedFavorites_$userId";

  Future<void> saveSoundMixes(Map<String, List<String>> soundMixes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert map to JSON
      final data = jsonEncode(soundMixes);

      // Save with a user-specific key
      await prefs.setString(_mixesKey(user.uid), data);

      print("✅ Sound mixes saved");
    } catch (e) {
      print("❌ Failed to save sound mixes: $e");
    }
  }

  /// Load favorites for the current user
  Future<Map<String, List<String>>> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_mixesKey(user.uid));
      if (data == null) return {};

      final decoded = jsonDecode(data) as Map<String, dynamic>;
      // Convert dynamic → List<String>
      return decoded.map((key, value) =>
          MapEntry(key, List<String>.from(value as List<dynamic>)));
    } catch (e) {
      print("❌ Failed to load sound mixes: $e");
      return {};
    }
  }

  /// Clear favorites for current user
  Future<void> clearFavorites() async {
    favoriteSounds = [];
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_mixesKey(user.uid));
    }
  }

  /// Refresh favorites (login/logout)
  Future<void> refreshFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await loadFavorites();
    } else {
      await clearFavorites();
    }
  }

  /// Add a sound to favorites
  Future<void> addFavorite(String mixName, List<String> soundTitles) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final mix = FavSoundModel(
      soundTitles: soundTitles,
      favSoundTitle: mixName,
      userId: userId.toString(),
    );

    await service.addOrUpdateMix(mix);
  }

  /// Remove a sound from favorites
  Future<void> removeFavorite(NewSoundModel sound) async {
    favoriteSounds.removeWhere((s) => s.title == sound.title);
  }

  /// Check if a sound is favorite
  bool isFavorite(NewSoundModel sound) {
    return favoriteSounds.any((s) => s.title == sound.title);
  }
}
