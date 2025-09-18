import 'package:clarity/model/model.dart';

class FavoriteManager {
  FavoriteManager._privateConstructor();
  static final FavoriteManager instance = FavoriteManager._privateConstructor();

  List<NewSoundModel> favoriteSounds = [];

  void addFavorite(NewSoundModel sound) {
    favoriteSounds.add(sound);
    // optionally save to local storage or Firestore
  }

  List<NewSoundModel> getFavorites() {
    return favoriteSounds;
  }
}
