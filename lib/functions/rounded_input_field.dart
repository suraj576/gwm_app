import 'package:flutter/material.dart';
import 'package:groundwater_management/functions/text_field_container.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const RoundedInputField({
    Key? key,
    required this.hintText,
    required this.icon,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        onChanged: onChanged,
        cursorColor: Colors.green,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: Colors.green[900],
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
