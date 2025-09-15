import 'package:clarity/theme.dart';
import 'package:flutter/material.dart';

import 'timer_test.dart';

class TimerScreen extends StatelessWidget {
  // final Function(int) onTimerSelected;
  final int soundCount;

  const TimerScreen({
    super.key,
    // required this.onTimerSelected,
    required this.soundCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.music_note,
              size: 28,
              color: ThemeHelper.textColorTimer(context),
            ),
            Positioned(
              right: 0, // adjust position
              top: 0,
              child: Container(
                padding: EdgeInsets.all(4),

                child: Text(
                  "$soundCount", // count of selected sounds
                  style: TextStyle(
                    color: ThemeHelper.textColorTimer(context),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          'Timer',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: ThemeHelper.textColorTimer(context),
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close, size: 28),
            onPressed: () {
              Navigator.pop(context); // Close the modal
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Choose your timer duration',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'montserrat',
                    color: ThemeHelper.textColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              ...[5, 10, 15, 30, 60, 120, 240, 480].map((minutes) {
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 0),
                      title: Text(
                        (minutes ~/ 60 > 0)
                            ? '${minutes ~/ 60} Hour${minutes ~/ 60 > 1 ? 's' : ''}'
                            : '$minutes Minutes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ThemeHelper.textColorTimer(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        // onTimerSelected(
                        //   minutes * 60,
                        // ); // Convert minutes to seconds
                        minutes * 60;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CircularTimerScreen(duration: minutes * 60, soundCount: soundCount),
                          ),
                        ); // Close the modal after selection
                      },
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.grey[300],
                    ), // Add styled divider between ListTiles
                  ],
                );
              }).toList(),
              // Remove the last Divider
              if ([5, 10, 15, 30, 60, 120, 240, 480].isNotEmpty)
                SizedBox(height: 16), // Increased padding at the end
            ],
          ),
        ),
      ),
    );
  }
}
