import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/light_color.dart';

class TitleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  const TitleText(
      {required this.text,
      this.fontSize = 18,
      this.textAlign = TextAlign.center,
      this.color = LightColor.titleTextColor,
      this.fontWeight = FontWeight.w800});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        maxLines: 2,
        textAlign: textAlign,
        style: GoogleFonts.mulish(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ));
  }
}
