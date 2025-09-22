import 'package:clarity/theme.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String? initialValue;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.hintText = '',
    this.initialValue,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: initialValue,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ThemeHelper.formTitle(context),
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
