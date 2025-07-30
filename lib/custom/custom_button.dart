import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final String image;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.image,
    required this.label,
    required this.onPressed,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _ispressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _ispressed = !_ispressed;
        });
        widget.onPressed();
      },
      child: Container(
        padding: const EdgeInsets.all(5),

        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          leading: Container(
            height: 70,
            width: 77,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.blueGrey),
              color: _ispressed ? const Color.fromRGBO(176, 176, 224, 1) : null,
            ),
            child: Center(
              child: Image.asset(widget.image, height: 24, width: 24),
            ),
          ),
          title: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          trailing: _ispressed
              ? const Icon(Icons.check, size: 24, color: Colors.black)
              : null,
        ),
      ),
    );
  }
}
