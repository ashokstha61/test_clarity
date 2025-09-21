import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class CustomImageThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final ui.Image? thumbImage; // preloaded image

  const CustomImageThumbShape({this.thumbRadius = 15, this.thumbImage});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final canvas = context.canvas;
    final paint = Paint();

    if (thumbImage != null) {
      // draw preloaded image
      final dst = Rect.fromCircle(center: center, radius: thumbRadius);
      paintImage(canvas: canvas, rect: dst, image: thumbImage!, fit: BoxFit.cover);
    } else {
      // fallback: draw a simple circle if image not loaded yet
      canvas.drawCircle(center, thumbRadius, paint..color = Colors.blue);
    }
  }

  /// Utility to preload image from assets
  static Future<ui.Image> loadImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

