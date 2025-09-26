import 'dart:convert';

class FavSoundModel {
  final List<String> soundTitles;
  final String favSoundTitle;
  final String userId;

  FavSoundModel({
    required this.soundTitles,
    required this.favSoundTitle,
    required this.userId,
  });

  // Convert JSON to FavSoundModel object
  factory FavSoundModel.fromJson(Map<String, dynamic> json) {
    return FavSoundModel(
      soundTitles: List<String>.from(json['soundTitles'] ?? []),
      favSoundTitle: json['favSoundTitle'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  // Convert FavSoundModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'soundTitles': soundTitles,
      'favSoundTitle': favSoundTitle,
      'userId': userId,
    };
  }

  // Optional: Convert list of FavSoundModel objects to JSON string
  static String encode(List<FavSoundModel> mixes) => jsonEncode(
    mixes.map<Map<String, dynamic>>((mix) => mix.toJson()).toList(),
  );

  // Optional: Decode JSON string to list of FavSoundModel objects
  static List<FavSoundModel> decode(String mixes) =>
      (jsonDecode(mixes) as List<dynamic>)
          .map<FavSoundModel>((item) => FavSoundModel.fromJson(item))
          .toList();
}
