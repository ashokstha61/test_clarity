import 'package:flutter/material.dart';

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
      title: Text(title, style: const TextStyle(fontSize: 18)),
      trailing: Icon(trailingIcon, color: iconColor),
      onTap: onTap,
    );
  }
}
