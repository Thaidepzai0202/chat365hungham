import 'package:flutter/material.dart';

class PopupMenuItemText extends StatelessWidget {
  PopupMenuItemText({super.key, required this.callback, required this.text});

  String text;
  VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return PopupMenuItem<String>(
      height: 30,
      value: text,
      onTap: callback,
      child: Text(
        text,
        style: const TextStyle(fontSize: 12), // Điều chỉnh font size ở đây
      ),
    );
  }
}
