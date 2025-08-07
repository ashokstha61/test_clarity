import 'package:cloud_firestore/cloud_firestore.dart';

class SoundModel {
  final String id;
  final String title;
  final String icon;
  final String musicURL;
  final bool isFav;
  final bool isLocked;
  final bool isSelected;
  final double volume;

  SoundModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.musicURL,
    this.isFav = false,
    this.isLocked = false,
    this.isSelected = false,
    this.volume = 1.0,
  });

  factory SoundModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SoundModel(
      id: doc.id,
      title: data['title']?.toString() ?? 'Untitled',
      icon: data['icon']?.toString() ?? 'default_icon.png',
      musicURL: data['musicURL']?.toString() ?? '',
      isFav: data['isFav'] as bool? ?? false,
      isLocked: data['isLocked'] as bool? ?? false,
      isSelected: data['isSelected'] as bool? ?? false,
      volume: (data['volume'] as num?)?.toDouble() ?? 1.0,
    );
  }

  SoundModel copyWith({
    bool? isSelected,
    bool? isFav,
  }) {
    return SoundModel(
      id: id,
      title: title,
      icon: icon,
      musicURL: musicURL,
      isFav: isFav ?? this.isFav,
      isLocked: isLocked,
      isSelected: isSelected ?? this.isSelected,
      volume: volume,
    );
  }
}