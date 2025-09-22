import 'package:clarity/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavoriteTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const FavoriteTile({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade200, width: 1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Icon(Icons.music_note, color: ThemeHelper.iconColor(context)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            fontFamily: "Montserrat",
            color: ThemeHelper.iconAndTextColorRemix(context),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
