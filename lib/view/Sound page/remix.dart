import 'package:clarity/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RelaxationMixBar extends StatelessWidget {
  final VoidCallback onArrowTap;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final String imagePath;
  final int soundCount;
  final bool isPlaying;

  const RelaxationMixBar({
    super.key,
    required this.onArrowTap,
    required this.onPlay,
    required this.onPause,
    required this.imagePath,
    required this.soundCount,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 193, 193, 242),
            Color.fromARGB(255, 41, 41, 102),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onArrowTap,
            child: Container(
              width: 260.w,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white,
                    size: 30,
                  ),
                  Image.asset(
                    imagePath,
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.contain,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Relaxation Mix",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "$soundCount sound selected",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 5.h,)
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Image.asset(
              isPlaying ? 'assets/images/pause.png' : 'assets/images/play.png',
              width: 24,
              height: 24,
            ),
            onPressed: isPlaying ? onPause : onPlay,
          ),
        ],
      ),
    );
  }
}
