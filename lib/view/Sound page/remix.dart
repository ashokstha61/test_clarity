import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RelaxationMixBar extends StatefulWidget {
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
    this.isPlaying = true,
  });

  @override
  State<RelaxationMixBar> createState() => _RelaxationMixBarState();
}

class _RelaxationMixBarState extends State<RelaxationMixBar> {
  @override
  Widget build(BuildContext context) {
    bool _isProcessing = false;

    void _handleTap() {
      if (_isProcessing) return;
      setState(() => _isProcessing = true);

      try {
        if (widget.isPlaying) {
          widget.onPause(); // call directly
        } else {
          widget.onPlay();
        }
      } finally {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) setState(() => _isProcessing = false);
          });
        }
      }
    }

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
            onTap: widget.onArrowTap,
            child: Container(
              width: 260.w,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 30),
                  Image.asset(
                    widget.imagePath,
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
                        "${widget.soundCount} sound selected",
                        style: TextStyle(color: Colors.white, fontSize: 12.sp),
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Image.asset(
              widget.isPlaying
                  ? 'assets/images/pause.png'
                  : 'assets/images/play.png',
              width: 24,
              height: 24,
            ),
            onPressed: _handleTap,
          ),
        ],
      ),
    );
  }
}
