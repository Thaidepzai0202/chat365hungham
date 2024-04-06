import 'package:flutter/material.dart';

class WeightedIcon extends StatelessWidget {
  final IconData icon;
  final FontWeight? weight;
  final double? size;
  final Color? color;
  const WeightedIcon(this.icon, {super.key, this.size, this.weight, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      String.fromCharCode(icon.codePoint),
      style: TextStyle(
        inherit: false,
        color: color,
        fontSize: size,
        fontWeight: weight,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
      ),
    );
  }
}