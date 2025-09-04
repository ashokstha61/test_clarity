import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String? initialValue;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.initialValue,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: initialValue,
    );
    final textColor = readOnly
        ? Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF3B3B7A)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly
                ? Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF3B3B7A)
                      : const Color(0xFF3B3B7A)
                : const Color(0xFF3B3B7A),
            border: OutlineInputBorder(),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}
