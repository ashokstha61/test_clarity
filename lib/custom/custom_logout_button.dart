import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomLogoutButton extends StatelessWidget {
  final String title;
  final Color textColor;
  final double fontSize;
  final VoidCallback? onPressed;

  const CustomLogoutButton({
    super.key,
    required this.title,
    this.textColor = const Color.fromRGBO(51, 51, 109, 1),
    this.fontSize = 18,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(alignment: Alignment.centerLeft),

      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          decoration: TextDecoration.underline,
          decorationColor: textColor,
          fontSize: fontSize.sp,
          fontWeight: FontWeight.w800,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}
