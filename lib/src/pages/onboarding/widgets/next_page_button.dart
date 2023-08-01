import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

 
import '../constants.dart';

class NextPageButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NextPageButton({
    required this.onPressed,
  }) : assert(onPressed != null);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      padding:  const  EdgeInsets.all(kPaddingM),
      elevation: .0,
      shape:const CircleBorder(),
      fillColor: kDarkBlue,
      child:  const Icon(
        Icons.arrow_forward,
        color: kWhite,
        size: 32.0,
      ),
      onPressed: onPressed, 
    );
  }
}
