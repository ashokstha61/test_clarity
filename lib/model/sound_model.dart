class SoundItem {
  final String category;
  final String filepath;
  final String icon;
  final bool isFav;
  final bool isLocked;
  final bool isNew;
  final bool isSelected;
  final String musicURL;
  final String title;
  final double volume;

  SoundItem({
    required this.category,
    required this.filepath,
    required this.icon,
    required this.isFav,
    required this.isLocked,
    required this.isNew,
    required this.isSelected,
    required this.musicURL,
    required this.title,
    required this.volume,
  });

  factory SoundItem.fromMap(Map<String, dynamic> map) {
    return SoundItem(
      category: map['category'] ?? '',
      filepath: map['filepath'] ?? '',
      icon: map['icon'] ?? '',
      isFav: map['isFav'] ?? false,
      isLocked: map['isLocked'] ?? false,
      isNew: map['isNew'] ?? false,
      isSelected: map['isSelected'] ?? false,
      musicURL: map['musicURL'] ?? '',
      title: map['title'] ?? '',
      volume: (map['volume'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'filepath': filepath,
      'icon': icon,
      'isFav': isFav,
      'isLocked': isLocked,
      'isNew': isNew,
      'isSelected': isSelected,
      'musicURL': musicURL,
      'title': title,
      'volume': volume,
    };
  }
}