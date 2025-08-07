class SoundItem {
  final String label;
  final String icon;

  SoundItem({required this.label, required this.icon});

  factory SoundItem.fromMap(Map<String, dynamic> map) {
    return SoundItem(
      label: map['label'] ?? 'Unknown',
      icon: map['icon'] ?? 'default_icon.png',
    );
  }
}