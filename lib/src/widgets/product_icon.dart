import 'package:flutter/material.dart';
import 'package:shopwise/src/model/category.dart';
import 'package:shopwise/src/widgets/extentions.dart';
import 'package:shopwise/src/widgets/title_text.dart';

import '../themes/light_color.dart';
import '../themes/theme.dart';

class ProductIcon extends StatelessWidget {
  // final String imagePath;
  // final String text;
  final ValueChanged<Category> onSelected;
  final Category model;
  const ProductIcon({required this.model, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return model == null
        ? Container(width: 5)
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Container(
              padding: AppTheme.hPadding,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: model.isSelected
                    ? LightColor.background.withOpacity(0.7)
                    : LightColor.background.withOpacity(0.7),
                border: Border.all(
                  color: model.isSelected
                      ? LightColor.orange
                      : LightColor.background.withOpacity(0.7),
                  width: model.isSelected ? 2 : 0,
                ),
                boxShadow: <BoxShadow>[
                  // BoxShadow(
                  //   color: model.isSelected
                  //       ? const Color.fromARGB(255, 223, 223, 223)
                  //       : const Color.fromARGB(255, 223, 223, 223),
                  //   blurRadius: 10,
                  //   spreadRadius: 5,
                  //   offset: const Offset(5, 5),
                  // ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  model.image != null
                      ? SizedBox(
                          width: 30,
                          height: 30,
                          //color: Colors.pink,
                          child: Image.asset(model.image))
                      : const SizedBox(),
                  const SizedBox(width: 5),
                  model.name == null
                      ? Container()
                      : TitleText(
                          text: model.name,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        )
                ],
              ),
            ).ripple(
              () {
                onSelected(model);
              },
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          );
  }
}
