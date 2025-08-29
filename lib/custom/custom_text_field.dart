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
              : Colors.black
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
                      ? Colors.grey.shade800
                      : Colors.grey.shade300
                : Color.fromRGBO(244, 244, 244, 0.5),
            border: OutlineInputBorder(),
            hintText: hintText,
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}
