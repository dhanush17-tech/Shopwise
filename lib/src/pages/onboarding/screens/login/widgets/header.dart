import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shopwise/src/themes/light_color.dart';
import 'dart:math';

import '../../../constants.dart';

class Header extends StatelessWidget {
  final VoidCallback onSkip;

  const Header({
    required this.onSkip,
  }) : assert(onSkip != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                "assets/logo.png",
                scale: 4.5,
              )),
          GestureDetector(
            onTap: onSkip,
            child: Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: LightColor.background,
              ),
              child: Text(
                'Skip',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    ?.copyWith(color: kWhite, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
