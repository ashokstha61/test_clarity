import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class CustomImageThumbShape extends SliderComponentShape {
  final String imagePath;
  final double thumbRadius;
  ui.Image? _cachedImage;

  CustomImageThumbShape({required this.imagePath, this.thumbRadius = 10.0}) {
    _loadImage();
  }

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
    final Canvas canvas = context.canvas;

    // IMPORTANT: Ignore all animations to maintain consistent size
    // Don't use activationAnimation or enableAnimation for scaling

    // Draw a background circle with consistent size
    final Paint backgroundPaint = Paint()
      ..color = const Color(0xFF6D5B7D)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, backgroundPaint);

    // Draw the image if loaded with consistent size
    _drawImage(canvas, center);
  }

  void _loadImage() async {
    try {
      final ByteData data = await rootBundle.load(imagePath);
      final Uint8List bytes = data.buffer.asUint8List();
      _cachedImage = await decodeImageFromList(bytes);
    } catch (e) {
      debugPrint('Failed to load image: $imagePath - $e');
    }
  }

  void _drawImage(Canvas canvas, Offset center) {
    if (_cachedImage != null) {
      final Paint paint = Paint()..filterQuality = FilterQuality.high;

      // Use FIXED size regardless of animations
      final double imageSize = thumbRadius * 2; // Always use the same size
      final Rect imageRect = Rect.fromCenter(
        center: center,
        width: imageSize,
        height: imageSize,
      );

      // Clip to circle to keep image within thumb bounds
      canvas.save();

      // Draw the image covering the entire thumb area
      canvas.drawImageRect(
        _cachedImage!,
        Rect.fromLTWH(
          0,
          0,
          _cachedImage!.width.toDouble(),
          _cachedImage!.height.toDouble(),
        ),
        imageRect,
        paint,
      );

      canvas.restore();
    } else {
      // Fallback placeholder while image loads
      final Paint paint = Paint();
      final Rect imageRect = Rect.fromCenter(
        center: center,
        width: thumbRadius * 1.2,
        height: thumbRadius * 1.2,
      );

      // Draw placeholder rectangle
      paint.color = const Color.fromRGBO(128, 128, 178, 0.8);
      canvas.drawRect(imageRect, paint);

      // Add vertical lines as placeholder
      paint.color = Colors.white;
      paint.strokeWidth = 1.0;
      for (int i = 0; i < 3; i++) {
        double x = imageRect.left + (i + 1) * imageRect.width / 4;
        canvas.drawLine(
          Offset(x, imageRect.top + 2),
          Offset(x, imageRect.bottom - 2),
          paint,
        );
      }
    }
  }
}
