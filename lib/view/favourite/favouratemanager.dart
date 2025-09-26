// import 'package:clarity/model/model.dart';

// class FavoriteManager {
//   FavoriteManager._privateConstructor();
//   static final FavoriteManager instance = FavoriteManager._privateConstructor();

//   List<NewSoundModel> favoriteSounds = [];

//   void addFavorite(NewSoundModel sound) {
//      if (!favoriteSounds.any((s) => s.title == sound.title)) {
//       favoriteSounds.add(sound);
//     }
//   }

//   List<NewSoundModel> getFavorites() {
//     return favoriteSounds;
//   }
// }
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clarity/model/model.dart';

import 'favouratepage.dart'; // <- Your NewSoundModel

class FavoriteManager {
  FavoriteManager._privateConstructor();
  static final FavoriteManager instance = FavoriteManager._privateConstructor();

  List<NewSoundModel> favoriteSounds = [];

  String _mixesKey(String userId) => "SavedFavorites_$userId";

  /// Save favorites for the current user
  Future<void> saveFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(favoriteSounds.map((e) => e.toJson()).toList());
      await prefs.setString(_mixesKey(user.uid), data);
    } catch (e) {
      print("❌ Failed to save favorites: $e");
    }
  }

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
    soundMixes.addAll({
      mixName: soundTitles,
    });

    soundMixes.forEach((mix, titles) {
      print("🎶 $mix:");
      for (final title in titles) {
        print("   • $title");
      }
    });
    // if (!favoriteSounds.any((s) => s.title == sound.title)) {
    //   favoriteSounds.add(sound.copyWith(isFav: true));
    //   await saveFavorites();
    // }

    await saveSoundMixes(soundMixes);
  }

  /// Remove a sound from favorites
  Future<void> removeFavorite(NewSoundModel sound) async {
    favoriteSounds.removeWhere((s) => s.title == sound.title);
    await saveFavorites();
  }

  /// Check if a sound is favorite
  bool isFavorite(NewSoundModel sound) {
    return favoriteSounds.any((s) => s.title == sound.title);
  }


}
