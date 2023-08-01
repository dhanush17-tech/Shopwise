import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
 import 'dart:math';

import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class Header extends StatelessWidget {
  final VoidCallback onSkip;

  const Header({
    required this.onSkip,
  }) : assert(onSkip != null);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 0),
          child: Container(
            padding: EdgeInsets.all(8),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: kLightBlue.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              "assets/soar.png",
              height: 48.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: GestureDetector(
              onTap: onSkip,
              child: Container(
                alignment: Alignment.center,
                width: 80,

                height: 35,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue),
                child: Text(
                  
                  'Skip',
                  style: GoogleFonts.poppins(color: kWhite, fontSize: 20,fontWeight: FontWeight.w500),
                ),
              )),
        ),
      ],
    );
  }
}
