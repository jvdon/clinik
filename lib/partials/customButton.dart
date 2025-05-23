import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function() onTap;
  final Widget child;
  final double width;
  final double height;
  const CustomButton({super.key, required this.child, required this.onTap, this.width = 250, this.height = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15))),
      child: TextButton(
        child: child,
        onPressed: onTap,
      ),
    );
  }
}
