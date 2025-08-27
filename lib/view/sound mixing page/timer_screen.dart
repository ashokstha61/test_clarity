import 'package:flutter/material.dart';

import 'timer_test.dart';

class TimerScreen extends StatelessWidget {
  final Function(int) onTimerSelected;

  const TimerScreen({super.key, required this.onTimerSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.music_note, size: 28),
        title: Text(
          'Timer',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 24,
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
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        onTimerSelected(
                          minutes * 60,
                        ); // Convert minutes to seconds
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CircularTimerScreen(duration: minutes * 60),
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
