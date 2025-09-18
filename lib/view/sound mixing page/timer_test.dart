import 'package:clarity/theme.dart';
import 'package:clarity/view/Sound%20page/sound.dart';
import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'fixedrelaxationmix.dart';
import 'global_timer.dart';

class CircularTimerScreen extends StatefulWidget {
  final int duration;
  final int soundCount; // in seconds

  const CircularTimerScreen({
    super.key,
    required this.duration,
    required this.soundCount,
  });

  @override
  State<CircularTimerScreen> createState() => _CircularTimerScreenState();
}

class _CircularTimerScreenState extends State<CircularTimerScreen> {
  // final CountDownController _controller = CountDownController();
  bool _isPaused = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (!globalTimer.isRunning) {
      globalTimer.duration = widget.duration;
      globalTimer.startTime = DateTime.now();
      globalTimer.isRunning = true;
      globalTimer.isPaused = false;
      globalTimer.pausedDuration = Duration.zero;
    }

    _isPaused = globalTimer.isPaused;
  }

  void _togglePauseResume() {
    // setState(() {
    //   if (_isPaused) {
    //     _controller.resume(); // Resume timer
    //   } else {
    //     _controller.pause(); // Pause timer
    //   }
    //   _isPaused = !_isPaused; // flip state
    // });
    setState(() {
      if (_isPaused) {
        // Resume
        globalTimer.controller.resume();
      } else {
        // Pause
        globalTimer.controller.pause();
      }
      _isPaused = !_isPaused;
      globalTimer.isPaused = _isPaused;
    });
  }

  void _quitTimer() {
    globalTimer.controller.reset();
    globalTimer.isRunning = false;
    globalTimer.isPaused = false;
    globalTimer.pausedDuration = Duration.zero;
    globalTimer.startTime = null;
  }

  @override
  Widget build(BuildContext context) {
    final remainingTime = globalTimer.remaining;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeHelper.timerBackgroundColor(context),
        leading: Padding(
          padding: EdgeInsets.all(8.sp),
          child: Stack(
            children: [
              Icon(
                Icons.music_note,
                color: ThemeHelper.iconAndTextColorRemix(context),
              ),
              Positioned(
                right: 0, // adjust position
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(4),

                  child: Text(
                    "${widget.soundCount}", // count of selected sounds
                    style: TextStyle(
                      color: ThemeHelper.iconAndTextColorRemix(context),
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              size: 28,
              color: ThemeHelper.iconAndTextColorRemix(context),
            ),
            onPressed: () {
              Navigator.pop(context); // Close the modal
            },
          ),
        ],
      ),
      backgroundColor: ThemeHelper.timerBackgroundColor(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Timer',
              style: TextStyle(
                color: ThemeHelper.iconAndTextColorRemix(context),
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            SizedBox(height: 40.h),
            Stack(
              alignment: Alignment.center,
              children: [
                CircularCountDownTimer(
                  duration:
                      globalTimer.duration ??
                      widget.duration, // 👈 use passed duration
                  // initialDuration: 0,
                  initialDuration:
                      (globalTimer.duration ?? widget.duration) - remainingTime,
                  // controller: _controller,
                  controller: globalTimer.controller,
                  width: 200.w,
                  height: 200.h,
                  ringColor: Colors.grey[800]!,
                  fillColor: Color(0xFFE5E5E5),
                  backgroundColor: Colors.transparent,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.square,
                  textStyle: TextStyle(
                    fontSize: 20.sp,
                    color: ThemeHelper.iconAndTextColorRemix(context),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                  textFormat: CountdownTextFormat.HH_MM_SS,
                  isReverse: true,
                  // isReverseAnimation: true,
                  onChange: (time) {
                    // Update remaining time dynamically
                  },
                  onComplete: () async {
                    await AudioManager().pauseAll();
                    // setState(() {
                    //   _isPaused = true;
                    //   _isCompleted = true;
                    // });
                    globalTimer.isRunning = false;
                    globalTimer.isPaused = true;
                    setState(() {
                      _isCompleted = true;
                    });
                  },
                ),
                Positioned(
                  top: 35,
                  child: Image.asset(
                    "assets/images/moon.png",
                    width: 35.w,
                    height: 35.h,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.h),
            Spacer(),

            Transform.translate(
              offset: Offset(0, 20.h),
              child: SizedBox(
                height: 200.h,
                // width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      bottom: -70.sp,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.sp),
                        child: Image.asset(
                          "assets/images/ellipse_mix_page.png",
                          fit: BoxFit
                              .contain, // adjust as needed (cover/contain/fill)
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50, // adjust for spacing from status bar
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: _isCompleted ? 0.5 : 1.0,
                            child: IconButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onPressed: _isCompleted
                                  ? null
                                  : _togglePauseResume,

                              icon: Column(
                                children: [
                                  Image.asset(
                                    _isPaused
                                        ? "assets/images/playImage.png"
                                        : "assets/images/pauseImage.png",
                                    width: 50.w,
                                    height: 50.h,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    _isPaused ? 'Play' : 'Pause',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20.w),
                          IconButton(
                            // onPressed: () => _controller.reset(),
                            onPressed: _quitTimer,
                            splashColor: Colors.transparent,
                            icon: Column(
                              children: [
                                Image.asset(
                                  "assets/images/quit.png",
                                  width: 50.w,
                                  height: 50.h,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Quit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
