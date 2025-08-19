import 'package:clarity/model/sound_model.dart';
import 'package:flutter/material.dart';

class SoundTile extends StatelessWidget {
  final SoundData sound;
  final VoidCallback onTap;

  const SoundTile({super.key, required this.sound, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: Container(
          height: 70,
          width: 77,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.blueGrey),
            color: sound.isSelected ? const Color.fromRGBO(176, 176, 224, 1) : null,
          ),
          child: Center(
            child: sound.hasAsset
                ? Image.asset(
                    'assets/images/${sound.icon.endsWith('.png') ? sound.icon : '${sound.icon}.png'}',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint(
                        'Failed to load asset for ${sound.title}: ${sound.icon}',
                      );
                      return const Icon(Icons.music_note);
                    },
                  )
                : const Icon(Icons.music_note),
          ),
        ),
        title: Text(
          sound.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
        trailing: sound.isSelected
            ? const Icon(Icons.check, color: Colors.blue, size: 24)
            : null,
      ),
    );
  }
}

