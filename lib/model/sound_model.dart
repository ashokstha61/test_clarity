// class SoundItem {
//   final String category;
//   final String filepath;
//   final String icon;
//   final bool isFav;
//   final bool isLocked;
//   final bool isNew;
//   final bool isSelected;
//   final String musicURL;
//   final String title;
//   final double volume;

//   SoundItem({
//     required this.category,
//     required this.filepath,
//     required this.icon,
//     required this.isFav,
//     required this.isLocked,
//     required this.isNew,
//     required this.isSelected,
//     required this.musicURL,
//     required this.title,
//     required this.volume,
//   });

//   factory SoundItem.fromMap(Map<String, dynamic> map) {
//     return SoundItem(
//       category: map['category'] ?? '',
//       filepath: map['filepath'] ?? '',
//       icon: map['icon'] ?? '',
//       isFav: map['isFav'] ?? false,
//       isLocked: map['isLocked'] ?? false,
//       isNew: map['isNew'] ?? false,
//       isSelected: map['isSelected'] ?? false,
//       musicURL: map['musicURL'] ?? '',
//       title: map['title'] ?? '',
//       volume: (map['volume'] ?? 1.0).toDouble(),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'category': category,
//       'filepath': filepath,
//       'icon': icon,
//       'isFav': isFav,
//       'isLocked': isLocked,
//       'isNew': isNew,
//       'isSelected': isSelected,
//       'musicURL': musicURL,
//       'title': title,
//       'volume': volume,
//     };
//   }
// }

// class SoundItem {
//   final String title;
//   final String icon;
//   bool hasAsset = false; // Tracks if asset exists
//   final String category;
//   final String filepath;
//   final bool isFav;
//   final bool isLocked;
//   final bool isNew;
//   bool isSelected = false;
//   final String musicURL;
//   final double volume;

//   SoundItem({
//     required this.title,
//     required this.icon,
//     required this.category,
//     required this.filepath,
//     required this.isFav,
//     required this.isLocked,
//     required this.isNew,
//     required this.isSelected,
//     required this.musicURL,
//     required this.volume,
//   });

//   factory SoundItem.fromMap(Map<String, dynamic> map) {
//     // Safely extract icon field
//     String icon = 'default_icon.png'; // Default fallback
//     if (map['icon'] is String) {
//       icon = map['icon'];
//     } else if (map['icon'] is List<dynamic> && map['icon'].isNotEmpty) {
//       // If icon is a list, take the first valid string
//       icon = map['icon'].firstWhere(
//         (item) => item is String,
//         orElse: () => 'default_icon.png',
//       );
//     }

//     return SoundItem(
//       title: map['title'] is String ? map['title'] : 'Untitled',
//       icon: icon,
//       category: map['category'] is String ? map['category'] : '',
//       filepath: map['filepath'] is String ? map['filepath'] : '',
//       isFav: map['isFav'] is bool ? map['isFav'] : false,
//       isLocked: map['isLocked'] is bool ? map['isLocked'] : false,
//       isNew: map['isNew'] is bool ? map['isNew'] : false,
//       isSelected: map['isSelected'] is bool ? map['isSelected'] : false,
//       musicURL: map['musicURL'] is String ? map['musicURL'] : '',
//       volume: (map['volume'] is num ? map['volume'].toDouble() : 1.0),
//     );
//   }
// }

class SoundItem {
  final String title;
  final String icon;
  bool hasAsset = false;
  final String category;
  final String filepath;
  final bool isFav;
  final bool isLocked;
  final bool isNew;
  bool isSelected; // Mutable to allow toggling
  final String musicURL;
  final double volume;

  SoundItem({
    required this.title,
    required this.icon,
    required this.category,
    required this.filepath,
    required this.isFav,
    required this.isLocked,
    required this.isNew,
    this.isSelected = false, // Default to false
    required this.musicURL,
    required this.volume,
  });

  factory SoundItem.fromMap(Map<String, dynamic> map) {
    String icon = 'default_icon.png';
    if (map['icon'] is String) {
      icon = map['icon'];
    } else if (map['icon'] is List<dynamic> && map['icon'].isNotEmpty) {
      icon = map['icon'].firstWhere(
        (item) => item is String,
        orElse: () => 'default_icon.png',
      );
    }

    return SoundItem(
      title: map['title'] is String ? map['title'] : 'Untitled',
      icon: icon,
      category: map['category'] is String ? map['category'] : '',
      filepath: map['filepath'] is String ? map['filepath'] : '',
      isFav: map['isFav'] is bool ? map['isFav'] : false,
      isLocked: map['isLocked'] is bool ? map['isLocked'] : false,
      isNew: map['isNew'] is bool ? map['isNew'] : false,
      isSelected: false, // Always initialize to false
      musicURL: map['musicURL'] is String ? map['musicURL'] : '',
      volume: (map['volume'] is num ? map['volume'].toDouble() : 1.0),
    );
  }
}
