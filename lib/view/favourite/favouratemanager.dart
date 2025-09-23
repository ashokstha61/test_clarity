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
import 'package:clarity/model/model.dart'; // <- Your NewSoundModel

class FavoriteManager {
  FavoriteManager._privateConstructor();
  static final FavoriteManager instance = FavoriteManager._privateConstructor();

  List<NewSoundModel> favoriteSounds = [];

  String _favoritesKey(String userId) => "SavedFavorites_$userId";

  /// Save favorites for the current user
  Future<void> saveFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(favoriteSounds.map((e) => e.toJson()).toList());
      await prefs.setString(_favoritesKey(user.uid), data);
    } catch (e) {
      print("❌ Failed to save favorites: $e");
    }
  }

  /// Load favorites for the current user
  Future<void> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      favoriteSounds = [];
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_favoritesKey(user.uid));

      if (savedData != null) {
        final List decoded = jsonDecode(savedData);
        favoriteSounds = decoded.map((e) => NewSoundModel.fromJson(e)).toList();
      } else {
        favoriteSounds = [];
      }
    } catch (e) {
      print("❌ Failed to load favorites: $e");
      favoriteSounds = [];
    }
  }

  /// Clear favorites for current user
  Future<void> clearFavorites() async {
    favoriteSounds = [];
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey(user.uid));
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
  Future<void> addFavorite(NewSoundModel sound) async {
    if (!favoriteSounds.any((s) => s.title == sound.title)) {
      favoriteSounds.add(sound.copyWith(isFav: true));
      await saveFavorites();
    }
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

  List<NewSoundModel> getFavorites() {
    return favoriteSounds;
  }
}
