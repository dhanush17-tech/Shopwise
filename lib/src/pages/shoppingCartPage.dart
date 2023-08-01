import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopwise/src/pages/productDetail.dart';
import 'package:shopwise/src/widgets/extentions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/productModel.dart';
import '../services/apiServices.dart';
import '../themes/light_color.dart';
import '../themes/theme.dart';
import '../widgets/title_text.dart';

class ShoppingCartPage extends StatefulWidget {
  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  Widget _item(Product model) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 80,
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: LightColor.orange.withAlpha(40),
                  ),
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: NetworkImage(
                        model.img,
                      ),
                    )),
                  ),
                ],
              ),
            ),
            Expanded(
                child: ListTile(
              title: TitleText(
                text: model.title,
                fontSize: 15,
                color: Color.fromARGB(255, 197, 198, 199),
                textAlign: TextAlign.start,
                fontWeight: FontWeight.w700,
              ),
              subtitle: Row(
                children: <Widget>[
                  TitleText(
                    text: '₹ ',
                    color: LightColor.titleTextColor,
                    fontSize: 12,
                  ),
                  Text(
                    model.price.toString(),
                    style: TextStyle(color: LightColor.titleTextColor),
                  ),
                ],
              ),
            ).ripple(() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => ProductDetailPage(
                            product: model,
                          )));
            })),
            IconButton(
              icon: Icon(Icons.delete_outline_outlined),
              onPressed: () async {},
              color: Color.fromARGB(255, 233, 98, 75),
            ).ripple(() async {
              for (var element in likedList) {
                if (element.buyLink == model.buyLink) {
                  likedList.remove(element);
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setStringList("liked",
                      List.from(likedList.map((e) => jsonEncode(e.toJson()))));
                  bool didUnsubscribe = await ApiServices.unsubscribeFromTopic(
                      prefs.getString("fcmtoken"), element.title);
                  if (didUnsubscribe) {
                    print("deleted Successfully");
                  } else {
                    print("deleted  fail");
                  }
                  break;
                }
              }
              getList();
            })
          ],
        ),
      ),
    );
  }

  // Widget _price() {
  //   for (var element in likedList){
  //     price+=element.
  //   }
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: <Widget>[
  //       TitleText(
  //         text: '5 Items',
  //         color: LightColor.grey,
  //         fontSize: 14,
  //         fontWeight: FontWeight.w500,
  //       ),
  //       TitleText(
  //         text: '12 USD',
  //         fontSize: 18,
  //       ),
  //     ],
  //   );
  // }

  Widget _submitButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        ApiServices.addCart(
            List.from(likedList.map((e) => jsonEncode(e.toJson()))),
            prefs.getString("fcmtoken"),
            (de) {});
      },
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          LightColor.titleTextColor,
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 4),
        width: double.infinity,
        child: const TitleText(
          text: 'Set Price Alert',
          color: Color.fromARGB(255, 236, 236, 236),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  getList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List list = prefs.get("liked") as List;
    print("Thsi is product");
    print(list);
    setState(() {
      likedList = list.map((e) => Product.fromJson(jsonDecode(e))).toList();
    });
  }

  List<Product> likedList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.padding,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (ctx, i) {
                  return _item(likedList[i]);
                },
                separatorBuilder: (ctx, i) => SizedBox(
                      height: 10,
                    ),
                itemCount: likedList.length),
            likedList.isNotEmpty
                ? Divider(
                    thickness: 3,
                    height: 70,
                  )
                : SizedBox(height: 20),
            // _price(),
            likedList.isNotEmpty
                ? _submitButton(context)
                : Column(
                    children: [
                      Image.asset("assets/empty_cart.png", scale: 2),
                      SizedBox(
                        height: 10,
                      ),
                      TitleText(
                        text: "No Price Alerts Set",
                        fontSize: 25,
                      )
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
