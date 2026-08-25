import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DottedDivider extends StatelessWidget {
  final Color color;

  const DottedDivider({this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return Container(width: dashWidth, height: 1, color: color);
          }),
        );
      },
    );
  }
}
