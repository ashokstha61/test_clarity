import 'package:clarity/model/model.dart';
import 'package:clarity/theme.dart';
// import 'package:clarity/model/sound_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SoundTile extends StatelessWidget {
  // final SoundData sound;
  final NewSoundModel sound;
  final VoidCallback onTap;

  const SoundTile({super.key, required this.sound, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: SizedBox(
          width: 53.w,
          height: 53.h, // same height and width
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: const Color.fromRGBO(50, 67, 118, 1.000),
              ),
              color: sound.isSelected
                  ? const Color.fromRGBO(176, 176, 224, 1)
                  : null,
            ),
            child: Center(
              child: sound.icon.isNotEmpty
                  ? Image.asset(
                      'assets/images/${sound.icon.endsWith('.png') ? sound.icon : '${sound.icon}.png'}',
                      height: 23.sp,
                      width: 23.sp,
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
        ),
        title: Text(
          sound.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
            color: ThemeHelper.soundTitle(context),
          ),
        ),
        trailing: sound.isSelected
            ? const Icon(Icons.check, color: Colors.blue, size: 24)
            : null,
      ),
    );
  }
}
