import 'package:clarity/theme.dart';
import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// class CircularTimerScreen extends StatefulWidget {
//   const CircularTimerScreen({super.key});

//   @override
//   State<CircularTimerScreen> createState() => _CircularTimerScreenState();
// }

// class _CircularTimerScreenState extends State<CircularTimerScreen> {
//   final CountDownController _controller = CountDownController();
//   final int _duration = 10; // 5 minutes (in seconds)

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(backgroundColor: Colors.black),
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Timer',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 40),
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 CircularCountDownTimer(
//                   duration: _duration,
//                   initialDuration: 0,
//                   controller: _controller,
//                   width: 200,
//                   height: 200,
//                   ringColor: Colors.grey[800]!,
//                   fillColor: Colors.blueAccent,
//                   backgroundColor: Colors.transparent,
//                   strokeWidth: 12,
//                   strokeCap: StrokeCap.round,
//                   textStyle: const TextStyle(
//                     fontSize: 48,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textFormat: CountdownTextFormat.HH_MM_SS,
//                   isReverse: true,
//                   onComplete: () {
//                     print('Timer completed!');
//                   },
//                 ),
//                 Positioned(
//                   top: 40, // Adjust position as needed
//                   child: Image.asset(
//                     "assets/images/moon.png",
//                     width: 60,
//                     height: 60,
//                     color: Colors.purple,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 40),
//             Spacer(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => _controller.pause(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey[800],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 30,
//                       vertical: 15,
//                     ),
//                   ),
//                   child: const Text(
//                     'Pause',
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: () => _controller.resume(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey[800],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 30,
//                       vertical: 15,
//                     ),
//                   ),
//                   child: const Text(
//                     'Resume',
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _controller.restart(duration: _duration),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 30,
//                   vertical: 15,
//                 ),
//               ),
//               child: const Text(
//                 'Restart',
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
  final CountDownController _controller = CountDownController();
  bool _isPaused = false;
  void _togglePauseResume() {
    setState(() {
      if (_isPaused) {
        _controller.resume(); // Resume timer
      } else {
        _controller.pause(); // Pause timer
      }
      _isPaused = !_isPaused; // flip state
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  // decoration: BoxDecoration(
                  //   color: Colors.red,
                  //   shape: BoxShape.circle,
                  // ),
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
                  duration: widget.duration, // 👈 use passed duration
                  initialDuration: 0,
                  controller: _controller,
                  width: 200.w,
                  height: 200.h,
                  ringColor: Colors.grey[800]!,
                  fillColor: Color(0xFFE5E5E5),
                  backgroundColor: Colors.transparent,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  textStyle: TextStyle(
                    fontSize: 20.sp,
                    color: ThemeHelper.iconAndTextColorRemix(context),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                  textFormat: CountdownTextFormat.HH_MM_SS,
                  isReverse: true,
                  onComplete: () {
                    print('Timer completed!');
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
              offset: Offset(0, 20),
              child: SizedBox(
                height: 180.h,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      bottom: -50,
                      child: Padding(
                        padding: EdgeInsets.only(top: 25.sp),
                        child: Image.asset(
                          "assets/images/ellipse_mix_page.png",
                          fit: BoxFit
                              .cover, // adjust as needed (cover/contain/fill)
                        ),
                      ),
                    ),
                    Positioned(
                      top: -5, // adjust for spacing from status bar
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _togglePauseResume,

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
                                  _isPaused ? 'Resume' : 'Pause',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20.w),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
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
                            ), // Go back to previous screen
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
