import 'package:flutter/material.dart';

import '../../resources/app_colors.dart';

class MemeTextOnCanvas extends StatelessWidget {
  const MemeTextOnCanvas({
    Key? key,
    required this.padding,
    required this.parentConstraints,
    required this.text,
    required this.selected,
    required this.fontSize,
    required this.color,
    required this.fontWeight,
  }) : super(key: key);

  final String text;
  final bool selected;
  final double padding;
  final BoxConstraints parentConstraints;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: parentConstraints.maxWidth,
        maxHeight: parentConstraints.maxHeight,
      ),
      decoration: BoxDecoration(
          color: selected ? AppColors.darkGrey16 : Colors.transparent,
          border: selected ? Border.all(color: AppColors.fuchsia) : null),
      padding: EdgeInsets.all(padding),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
