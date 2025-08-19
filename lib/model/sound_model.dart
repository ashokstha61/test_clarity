// // class SoundItem {
// //   final String category;
// //   final String filepath;
// //   final String icon;
// //   final bool isFav;
// //   final bool isLocked;
// //   final bool isNew;
// //   final bool isSelected;
// //   final String musicURL;
// //   final String title;
// //   final double volume;

// //   SoundItem({
// //     required this.category,
// //     required this.filepath,
// //     required this.icon,
// //     required this.isFav,
// //     required this.isLocked,
// //     required this.isNew,
// //     required this.isSelected,
// //     required this.musicURL,
// //     required this.title,
// //     required this.volume,
// //   });

// //   factory SoundItem.fromMap(Map<String, dynamic> map) {
// //     return SoundItem(
// //       category: map['category'] ?? '',
// //       filepath: map['filepath'] ?? '',
// //       icon: map['icon'] ?? '',
// //       isFav: map['isFav'] ?? false,
// //       isLocked: map['isLocked'] ?? false,
// //       isNew: map['isNew'] ?? false,
// //       isSelected: map['isSelected'] ?? false,
// //       musicURL: map['musicURL'] ?? '',
// //       title: map['title'] ?? '',
// //       volume: (map['volume'] ?? 1.0).toDouble(),
// //     );
// //   }

// //   Map<String, dynamic> toMap() {
// //     return {
// //       'category': category,
// //       'filepath': filepath,
// //       'icon': icon,
// //       'isFav': isFav,
// //       'isLocked': isLocked,
// //       'isNew': isNew,
// //       'isSelected': isSelected,
// //       'musicURL': musicURL,
// //       'title': title,
// //       'volume': volume,
// //     };
// //   }
// // }

// // class SoundItem {
// //   final String title;
// //   final String icon;
// //   bool hasAsset = false; // Tracks if asset exists
// //   final String category;
// //   final String filepath;
// //   final bool isFav;
// //   final bool isLocked;
// //   final bool isNew;
// //   bool isSelected = false;
// //   final String musicURL;
// //   final double volume;

// //   SoundItem({
// //     required this.title,
// //     required this.icon,
// //     required this.category,
// //     required this.filepath,
// //     required this.isFav,
// //     required this.isLocked,
// //     required this.isNew,
// //     required this.isSelected,
// //     required this.musicURL,
// //     required this.volume,
// //   });

// //   factory SoundItem.fromMap(Map<String, dynamic> map) {
// //     // Safely extract icon field
// //     String icon = 'default_icon.png'; // Default fallback
// //     if (map['icon'] is String) {
// //       icon = map['icon'];
// //     } else if (map['icon'] is List<dynamic> && map['icon'].isNotEmpty) {
// //       // If icon is a list, take the first valid string
// //       icon = map['icon'].firstWhere(
// //         (item) => item is String,
// //         orElse: () => 'default_icon.png',
// //       );
// //     }

// //     return SoundItem(
// //       title: map['title'] is String ? map['title'] : 'Untitled',
// //       icon: icon,
// //       category: map['category'] is String ? map['category'] : '',
// //       filepath: map['filepath'] is String ? map['filepath'] : '',
// //       isFav: map['isFav'] is bool ? map['isFav'] : false,
// //       isLocked: map['isLocked'] is bool ? map['isLocked'] : false,
// //       isNew: map['isNew'] is bool ? map['isNew'] : false,
// //       isSelected: map['isSelected'] is bool ? map['isSelected'] : false,
// //       musicURL: map['musicURL'] is String ? map['musicURL'] : '',
// //       volume: (map['volume'] is num ? map['volume'].toDouble() : 1.0),
// //     );
// //   }
// // }

// class SoundItem {
//   final String title;
//   final String icon;
//   bool hasAsset = false;
//   final String category;
//   final String filepath;
//   final bool isFav;
//   final bool isLocked;
//   final bool isNew;
//   bool isSelected; // Mutable to allow toggling
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
//     this.isSelected = false, // Default to false
//     required this.musicURL,
//     required this.volume,
//   });

//   factory SoundItem.fromMap(Map<String, dynamic> map) {
//     String icon = 'default_icon.png';
//     if (map['icon'] is String) {
//       icon = map['icon'];
//     } else if (map['icon'] is List<dynamic> && map['icon'].isNotEmpty) {
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
//       isSelected: false, // Always initialize to false
//       musicURL: map['musicURL'] is String ? map['musicURL'] : '',
//       volume: (map['volume'] is num ? map['volume'].toDouble() : 1.0),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';

// class SoundData {
//   final String id;
//   final String title;
//   final String icon;
//   final String musicURL;
//   final String filepath;
//   final String category;
//   final bool isFav;
//   final bool isLocked;
//   bool isSelected ;
//   final bool isNew;
//   double volume;
//   bool hasAsset;

//   SoundData({
//     required this.id,
//     required this.title,
//     required this.icon,
//     required this.musicURL,
//     required this.filepath,
//     this.category = '',
//     this.isFav = false,
//     this.isLocked = false,
//     this.isSelected = false,
//     this.isNew = false,
//     this.volume = 0.5,
//     this.hasAsset = false,
//   });

//   // Factory constructor from Firestore DocumentSnapshot
//   factory SoundData.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;

//     return SoundData(
//       id: doc.id,
//       title: data['title'] ?? '',
//       musicURL: data['musicURL'] ?? '',
//       filepath: data['filepath'] ?? '',
//       icon: data['icon'] ?? 'default_icon.png',
//       category: data['category'] ?? '',
//       isFav: data['isFav'] ?? false,
//       isLocked: data['isLocked'] ?? false,
//       // isSelected: data['isSelected'] ?? false,
//       isSelected: false,
//       isNew: data['isNew'] ?? false,
//       volume: (data['volume'] ?? 0.5).toDouble(),
//     );
//   }

//   // Factory constructor from Map
//   factory SoundData.fromMap(Map<String, dynamic> map) {
//     String icon = 'default_icon.png';
//     if (map['icon'] is String) {
//       icon = map['icon'];
//     } else if (map['icon'] is List<dynamic> && map['icon'].isNotEmpty) {
//       icon = map['icon'].firstWhere(
//         (item) => item is String,
//         orElse: () => 'default_icon.png',
//       );
//     }

//     return SoundData(
//       id: map['id'] ?? '', // Added ID field which might come from map
//       title: map['title'] is String ? map['title'] : 'Untitled',
//       icon: icon,
//       category: map['category'] is String ? map['category'] : '',
//       filepath: map['filepath'] is String ? map['filepath'] : '',
//       isFav: map['isFav'] is bool ? map['isFav'] : false,
//       isLocked: map['isLocked'] is bool ? map['isLocked'] : false,
//       isNew: map['isNew'] is bool ? map['isNew'] : false,
//       // isSelected: map['isSelected'] is bool ? map['isSelected'] : false,
//       isSelected: false,
//       musicURL: map['musicURL'] is String ? map['musicURL'] : '',
//       volume: (map['volume'] is num ? map['volume'].toDouble() : 0.5),
//       hasAsset: map['hasAsset'] is bool ? map['hasAsset'] : false,
//     );
//   }

//   // Convert to Map for serialization
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'icon': icon,
//       'musicURL': musicURL,
//       'filepath': filepath,
//       'category': category,
//       'isFav': isFav,
//       'isLocked': isLocked,
//       'isSelected': isSelected,
//       'isNew': isNew,
//       'volume': volume,
//       'hasAsset': hasAsset,
//     };
//   }

//   // Helper method to toggle selection
//   SoundData toggleSelection() {
//     return SoundData(
//       id: id,
//       title: title,
//       icon: icon,
//       musicURL: musicURL,
//       filepath: filepath,
//       category: category,
//       isFav: isFav,
//       isLocked: isLocked,
//       isSelected: !isSelected,
//       isNew: isNew,
//       volume: volume,
//       hasAsset: hasAsset,
//     );
//   }

//   // Helper method to toggle favorite status
//   SoundData toggleFavorite() {
//     return SoundData(
//       id: id,
//       title: title,
//       icon: icon,
//       musicURL: musicURL,
//       filepath: filepath,
//       category: category,
//       isFav: !isFav,
//       isLocked: isLocked,
//       isSelected: isSelected,
//       isNew: isNew,
//       volume: volume,
//       hasAsset: hasAsset,
//     );
//   }

// }

import 'package:cloud_firestore/cloud_firestore.dart';

class SoundData {
  final String id;
  final String title;
  final String icon;
  final String musicURL;
  final String filepath;
  final String category;
  final bool isFav;
  final bool isLocked;
  bool isSelected;
  final bool isNew;
  double volume;
  bool hasAsset;

  SoundData({
    required this.id,
    required this.title,
    required this.icon,
    required this.musicURL,
    required this.filepath,
    this.category = '',
    this.isFav = false,
    this.isLocked = false,
    this.isSelected = false,
    this.isNew = false,
    this.volume = 0.5,
    this.hasAsset = false,
  });

  // Factory constructor from Firestore DocumentSnapshot
  factory SoundData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return SoundData(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      musicURL: data['musicURL']?.toString() ?? '',
      filepath: data['filepath']?.toString() ?? '',
      icon: data['icon']?.toString() ?? 'default_icon.png',
      category: data['category']?.toString() ?? '',
      isFav: data['isFav'] == true,
      isLocked: data['isLocked'] == true,
      isNew: data['isNew'] == true,
      volume: (data['volume'] as num?)?.toDouble() ?? 0.5,
    );
  }

  // Factory constructor from Map
  factory SoundData.fromMap(Map<String, dynamic> map) {
    return SoundData(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Untitled',
      icon: _parseIcon(map['icon']),
      category: map['category']?.toString() ?? '',
      filepath: map['filepath']?.toString() ?? '',
      isFav: map['isFav'] == true,
      isLocked: map['isLocked'] == true,
      isNew: map['isNew'] == true,
      musicURL: map['musicURL']?.toString() ?? '',
      volume: (map['volume'] as num?)?.toDouble() ?? 0.5,
      hasAsset: map['hasAsset'] == true,
    );
  }

  static String _parseIcon(dynamic iconData) {
    if (iconData is String) return iconData;
    if (iconData is List) {
      return iconData.firstWhere(
            (item) => item is String,
            orElse: () => 'default_icon.png',
          )
          as String;
    }
    return 'default_icon.png';
  }

  List<Object?> get props => [
    id,
    title,
    musicURL,
    icon,
    hasAsset,
    filepath,
    isSelected,
  ];

  // Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'musicURL': musicURL,
      'filepath': filepath,
      'category': category,
      'isFav': isFav,
      'isLocked': isLocked,
      'isSelected': isSelected,
      'isNew': isNew,
      'volume': volume,
      'hasAsset': hasAsset,
    };
  }

  // Creates a copy of the sound with updated values
  SoundData copyWith({
    String? id,
    String? title,
    String? icon,
    String? musicURL,
    String? filepath,
    String? category,
    bool? isFav,
    bool? isLocked,
    bool? isSelected,
    bool? isNew,
    double? volume,
    bool? hasAsset,
  }) {
    return SoundData(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      musicURL: musicURL ?? this.musicURL,
      filepath: filepath ?? this.filepath,
      category: category ?? this.category,
      isFav: isFav ?? this.isFav,
      isLocked: isLocked ?? this.isLocked,
      isSelected: isSelected ?? this.isSelected,
      isNew: isNew ?? this.isNew,
      volume: volume ?? this.volume,
      hasAsset: hasAsset ?? this.hasAsset,
    );
  }

  // Helper method to toggle selection
  SoundData toggleSelection() {
    return copyWith(isSelected: !isSelected);
  }

  // Helper method to toggle favorite status
  SoundData toggleFavorite() {
    return copyWith(isFav: !isFav);
  }

  // Helper method to update volume
  SoundData withVolume(double newVolume) {
    return copyWith(volume: newVolume.clamp(0.0, 1.0));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          musicURL == other.musicURL;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ musicURL.hashCode;

  @override
  String toString() {
    return 'SoundData{id: $id, title: $title, isSelected: $isSelected, volume: $volume}';
  }
}
