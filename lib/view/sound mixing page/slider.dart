// import 'package:flutter/material.dart';

// class ImageSliderThumb extends SliderComponentShape {
//   final String imagePath;
//   final double size;

//   const ImageSliderThumb({required this.imagePath, this.size = 20});

//   @override
//   Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(size, size);

//   @override
//   void paint(
//     PaintingContext context,
//     Offset center, {
//     required Animation<double> activationAnimation,
//     required Animation<double> enableAnimation,
//     required bool isDiscrete,
//     required TextPainter labelPainter,
//     required RenderBox parentBox,
//     required SliderThemeData sliderTheme,
//     required TextDirection textDirection,
//     required double value,
//     required double textScaleFactor,
//     required Size sizeWithOverflow,
//   }) {
//     final canvas = context.canvas;
//     final image = AssetImage(imagePath);
//     final paintBounds = Rect.fromCenter(center: center, width: size, height: size);

//     // Load the image
//     image.resolve(const ImageConfiguration()).addListener(
//       ImageStreamListener((info, _) {
//         final imagePaint = Paint();
//         canvas.drawImageRect(
//           info.image,
//           Rect.fromLTWH(0, 0, info.image.width.toDouble(), info.image.height.toDouble()),
//           paintBounds,
//           imagePaint,
//         );
//       }),
//     );
//   }
// }
import 'package:flutter/material.dart';

class CustomImageThumbShape extends SliderComponentShape {
  final String imagePath;
  final double thumbRadius;

  const CustomImageThumbShape({
    required this.imagePath,
    this.thumbRadius = 15,
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
    final canvas = context.canvas;
    final image = AssetImage(imagePath);

    // Synchronously resolve and draw
    final ImageStream stream = image.resolve(const ImageConfiguration());
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      final img = info.image;
      final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
      final dst = Rect.fromCircle(center: center, radius: thumbRadius);
      paintImage(canvas: canvas, rect: dst, image: img, fit: BoxFit.cover);
    });

    stream.addListener(listener);
    stream.removeListener(listener); // prevent memory leaks
  }
}

