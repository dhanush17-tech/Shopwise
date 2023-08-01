import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopwise/src/widgets/extentions.dart';
import 'package:shopwise/src/widgets/title_text.dart';

import '../model/productModel.dart';
import '../pages/productDetail.dart';
import '../themes/light_color.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final ValueChanged<Product> onSelected;
  ProductCard({required this.product, required this.onSelected});

//   @override
//   _ProductCardState createState() => _ProductCardState();
// }

// class _ProductCardState extends State<ProductCard> {
//   Product product;
//   @override
//   void initState() {
//     product = widget.product;
//     super.initState();
//   }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        // boxShadow: <BoxShadow>[
        //     BoxShadow(
        //         color: Color.fromARGB(255, 240, 239, 239),
        //         blurRadius: 15,
        //         spreadRadius: 2),
        //   ],
        // ),
      ),
      //  CircleAvatar(
      //               radius: 40,
      //               backgroundColor: LightColor.orange.withAlpha(40),
      //             ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 600,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Hero(
                tag: "dw",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Image border
                  child: Image.network(
                    product.img,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TitleText(
                  text: product.title
                      .split(' ')
                      .map((word) => word.isNotEmpty
                          ? '${word[0].toUpperCase()}${word.substring(1)}'
                          : word)
                      .join(' '), //Capitalize the first letter of every word,
                  fontSize: 16,
                ),
                const SizedBox(height: 5),
                TitleText(
                  text: product.offer,
                  fontSize: 12,
                  color: LightColor.orange,
                ),
                const SizedBox(height: 5),
                TitleText(
                  text: "₹${product.price}",
                  fontSize: 16,
                ),
              ],
            ),
          ),
        ],
      ).ripple(() {
        onSelected(product);
      }, borderRadius: const BorderRadius.all(Radius.circular(20))),
    );
  }
}
