// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';

// class SoundControlWidget extends StatefulWidget {
//   final String label;
//   final IconData icon;
//   final AudioPlayer audioPlayer;
//   final VoidCallback onRemove;
//   final String? audioPath;

//   const SoundControlWidget({
//     super.key,
//     required this.label,
//     required this.icon,
//     required this.audioPlayer,
//     required this.onRemove,
//     this.audioPath,
//   });

//   @override
//   SoundControlWidgetState createState() => SoundControlWidgetState();
// }

// class SoundControlWidgetState extends State<SoundControlWidget> {
//   final double _volume = 0.7;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.audioPath != null) {
//       widget.audioPlayer.setVolume(_volume);
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Row(
//         children: [
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               Icon(widget.icon, size: 48),
//               Positioned(
//                 top: 0,
//                 right: 0,
//                 child: ElevatedButton(
//                   onPressed: widget.onRemove,
                  
//                   style: ElevatedButton.styleFrom(
//                     shape: const CircleBorder(),
//                     padding: const EdgeInsets.all(4),
//                     minimumSize: const Size(24, 24),
//                   ),
//                   child: Icon(Icons.close, size: 16),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.label, style: const TextStyle(fontSize: 16)),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//                       // onPressed: _togglePlayback,
//                       onPressed: () {},
//                     ),
//                     Expanded(
//                       child: Slider(
//                         value: _volume,
//                         // onChanged: _handleVolumeChange,
//                         onChanged: (value) {},
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _togglePlayback() async {
//     if (_isPlaying) {
//       await widget.audioPlayer.pause();
//     } else if (widget.audioPath != null) {
//       await widget.audioPlayer.play(AssetSource(widget.audioPath!));
//     }

//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

 

//   @override
//   void dispose() {
//     widget.audioPlayer.stop();
//     super.dispose();
//   }
// }
