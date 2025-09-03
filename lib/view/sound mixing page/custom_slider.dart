import 'package:flutter/material.dart';

class CustomImageThumbShape extends SliderComponentShape {
  final String imagePath;
  final double thumbRadius;

  const CustomImageThumbShape({
    required this.imagePath,
    this.thumbRadius = 10.0,
  });

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

    // Draw a background circle (optional)
    final Paint backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, thumbRadius, backgroundPaint);

    // Load and draw the image
    _drawImage(canvas, center);
  }

  void _drawImage(Canvas canvas, Offset center) async {
    // For a synchronous approach, you might want to preload the image
    // This is a simplified version - in production, consider using
    // image caching and proper async loading
    
    final Paint paint = Paint();
    
    // You'll need to load your image asset here
    // This is a placeholder for the actual image loading logic
    final Rect imageRect = Rect.fromCenter(
      center: center,
      width: thumbRadius * 1.5,
      height: thumbRadius * 1.5,
    );
    
    // Draw placeholder rectangle for now
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