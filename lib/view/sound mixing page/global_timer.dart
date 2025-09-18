import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class GlobalTimerState {
  int? duration; // total seconds
  DateTime? startTime;
  Duration pausedDuration = Duration.zero;
  bool isRunning = false;
  bool isPaused = false;

  CountDownController controller = CountDownController();

  int get remaining {
    if (startTime == null || duration == null) return duration ?? 0;
    final elapsed = DateTime.now().difference(startTime!) - pausedDuration;
    final remainingTime = duration! - elapsed.inSeconds;
    return remainingTime > 0 ? remainingTime : 0;
  }
}

// Singleton
GlobalTimerState globalTimer = GlobalTimerState();
