class NewSoundModel {
  final String filepath;
  final String icon;
  final bool isFav;
  bool isLocked;
  bool isNew;
  bool isSelected;
  final String musicUrl;
  final String title;
  num volume;
  List<String> mixFilePaths;

  NewSoundModel({
    required this.filepath,
    required this.icon,
    required this.isFav,
    required this.isLocked,
    required this.isNew,
    required this.isSelected,
    required this.musicUrl,
    required this.title,
    required this.volume,
    required this.mixFilePaths,
  });

  factory NewSoundModel.fromJson(Map<String, dynamic> json) {
    return NewSoundModel(
      filepath: json['filepath'] as String,
      icon: json['icon'] as String,
      isFav: json['isFav'] as bool,
      isLocked: json['isLocked'] as bool,
      isNew: json['isNew'] as bool,
      isSelected: json['isSelected'] as bool,
      musicUrl: json['musicURL'] as String,
      title: json['title'] as String,
      volume: json['volume'] as num,
      mixFilePaths: List<String>.from(json['mixFilePaths'] ?? []),
    );
  }

  NewSoundModel copyWith({
    String? filepath,
    String? icon,
    bool? isFav,
    bool? isLocked,
    bool? isNew,
    bool? isSelected,
    String? musicUrl,
    String? title,
    num? volume,
    List<String>? mixFilePaths,
  }) => NewSoundModel(
    filepath: filepath ?? this.filepath,
    icon: icon ?? this.icon,
    isFav: isFav ?? this.isFav,
    isLocked: isLocked ?? this.isLocked,
    isNew: isNew ?? this.isNew,
    isSelected: isSelected ?? this.isSelected,
    musicUrl: musicUrl ?? this.musicUrl,
    title: title ?? this.title,
    volume: volume ?? this.volume,
    mixFilePaths: mixFilePaths ?? this.mixFilePaths,
  );

  Map<String, dynamic> toJson() => {
    'filepath': filepath,
    'icon': icon,
    'isFav': isFav,
    'isLocked': isLocked,
    'isNew': isNew,
    'isSelected': isSelected,
    'musicURL': musicUrl,
    'title': title,
    'volume': volume,
    'mixFilePaths': mixFilePaths, // ✅ serialize
  };
}
