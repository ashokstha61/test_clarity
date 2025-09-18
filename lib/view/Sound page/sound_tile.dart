import 'package:clarity/model/model.dart';
import 'package:clarity/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SoundTile extends StatelessWidget {
  final NewSoundModel sound;
  final VoidCallback onTap;
  final bool isTrail; // 👈 new parameter

  const SoundTile({
    super.key,
    required this.sound,
    required this.onTap,
    this.isTrail = true, // default false
  });

  @override
  Widget build(BuildContext context) {
    final bool locked = !isTrail && sound.isLocked; // check isLocked only if isTrail false

    return Opacity(
      opacity: locked ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: locked ? null : onTap, // disable tap if locked
          leading: SizedBox(
            width: 53.w,
            height: 53.h,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  width: 2,
                  color: const Color.fromRGBO(176, 176, 224, 1),
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
          trailing: locked
              ? const Icon(Icons.lock, color: Colors.white, size: 24)
              : sound.isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 24)
              : null,
        ),
      ),
    );
  }
}
