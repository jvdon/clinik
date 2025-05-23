import 'package:flutter/material.dart';

class TextIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final double width;
  TextIcon({super.key, required this.icon, required this.text, this.width = 150});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.width,
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}
