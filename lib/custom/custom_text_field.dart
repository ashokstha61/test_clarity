import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String? initialValue;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: initialValue);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            fillColor: Color.fromRGBO(244, 244, 244, 0.5),
            border: OutlineInputBorder(),
            hintText: hintText,
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}
