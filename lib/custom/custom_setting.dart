import 'package:flutter/material.dart';

class CustomSetting extends StatefulWidget {
  final String title;
  final String switchLabel;
  final bool switchValue;
  final Function(bool) onChanged;

  const CustomSetting({
    super.key,
    required this.title,
    required this.switchLabel,
    required this.switchValue,
    required this.onChanged,
  });

  @override
  CustomSettingState createState() => CustomSettingState();
}

class CustomSettingState extends State<CustomSetting> {
  late bool _switchValue;

  @override
  void initState() {
    super.initState();
    _switchValue = widget.switchValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SwitchListTile(
          title: Text(widget.switchLabel),
          value: _switchValue,
          onChanged: (bool value) {
            setState(() {
              _switchValue = value;
            });
            widget.onChanged(value);
          },
        ),
      ],
    );
  }
}
