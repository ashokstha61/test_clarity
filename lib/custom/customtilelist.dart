import 'package:clarity/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final IconData trailingIcon;
  final Color iconColor;
  final VoidCallback? onTap;

  const CustomListTile({
    super.key,
    required this.title,
    this.trailingIcon = Icons.chevron_right,
    this.iconColor = const Color(0xFF6B7280),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,

          fontFamily: 'Montserrat',
          color: ThemeHelper.customListTileColor(context),
        ),
      ),
      trailing: Icon(trailingIcon, color: iconColor),
      onTap: onTap,
    );
  }
}
