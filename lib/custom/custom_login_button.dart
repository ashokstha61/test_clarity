import 'package:clarity/theme.dart';
import 'package:flutter/material.dart';

class CustomLoginButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onPressed;

  const CustomLoginButton({
    super.key,
    required this.imagePath,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
        overlayColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        padding: EdgeInsets.symmetric(vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Colors.grey),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 24.0, width: 24.0),
          SizedBox(width: 8.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
              color: ThemeHelper.textColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
