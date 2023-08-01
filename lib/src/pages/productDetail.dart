import 'dart:async';
import 'dart:convert';

import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopwise/src/pages/mainPage.dart';
import 'package:shopwise/src/widgets/extentions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/productModel.dart';
import '../services/apiServices.dart';
import '../themes/light_color.dart';
import '../themes/theme.dart';
import '../widgets/title_text.dart';

class ProductDetailPage extends StatefulWidget {
  Product product;
  ProductDetailPage({required this.product});
  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  @override
  void initState() {
    super.initState();
    checkIfLiked();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInToLinear));
    controller.forward();
    getProductInfo();
  }

  getProductInfo() async {
    setState(() {
      widget.product.description = "loading";
    });
    ApiServices.getProductInfo(widget.product.title, widget.product.buyLink)
        .then((value) {
      print(value);
      setState(() {
        widget.product.buyLink = value.buyLink;
        widget.product.images = value.images;
        widget.product.totalReviews = value.totalReviews;
        widget.product.ratings = value.ratings;

        _productDeatailsController.sink.add(widget.product);
        ApiServices.getProductDescription(value.amazonLink).then((value) {
          print(value);
          setState(() {
            widget.product.description = value!;
          });
        });
      });
      print(widget.product.buyLink);
      print(widget.product.images);
      print(widget.product.totalReviews);
      print(widget.product.ratings);
      print(widget.product.description);
    });
  }

  bool isLiked = false;
  checkIfLiked() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList("liked");
    print(list);

    if (list!.contains(jsonEncode(widget.product.toJson()))) {
      setState(() {
        isLiked = true;
      });
    }
    ;
  }

  StreamController<Product> _productDeatailsController = StreamController();
  Stream<Product> get _productDeatailsStream =>
      _productDeatailsController.stream;

  @override
  void dispose() {
    controller.dispose();
    _productDeatailsController.close();
    super.dispose();
  }

  Widget _appBar() {
    return Container(
      padding: AppTheme.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 15,
            padding: 12,
            isOutLine: true,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          loaded
              ? _icon(isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? LightColor.red : LightColor.lightGrey,
                  size: 15,
                  padding: 12,
                  isOutLine: false, onPressed: () async {
                  setState(() {
                    isLiked = !isLiked;
                  });

                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  List<String>? list = prefs.getStringList("liked");

                  if (list == null) {
                    list = [];
                  }

                  if (isLiked) {
                    list.add(jsonEncode(widget.product.toJson()));
                    ApiServices.addCart(
                        list, prefs.getString("fcmtoken"), (de) {});
                  } else {
                    list.remove(jsonEncode(widget.product.toJson()));
                    ApiServices.unsubscribeFromTopic(
                        prefs.getString("fcmtoken"), widget.product.title);
                  }

                  prefs.setStringList("liked", list);
                })
              : Container(),
        ],
      ),
    );
  }

  Widget _submitButton(BuildContext context, snapshot) {
    if (snapshot.hasData) {
      return TextButton(
        onPressed: () async {
          // final Uri url = Uri.parse(widget.product.buyLink);
          if (!await launch(widget.product.buyLink)) {
            throw Exception('Could not launch ${widget.product.buyLink}');
          }
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
            text: 'Buy Now',
            color: Color.fromARGB(255, 236, 236, 236),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(
            left: 10.0, top: 20.0, right: 10.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeShimmer(
                width: MediaQuery.of(context).size.width,
                height: 55,
                radius: 4.0,
                baseColor: Colors.transparent,
                highlightColor: Colors.grey),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.only(right: 10.0, bottom: 10.0),
              child: FadeShimmer(
                  width: MediaQuery.of(context).size.width / 2.4,
                  height: kToolbarHeight - 36.0,
                  radius: 4.0,
                  baseColor: Colors.transparent,
                  highlightColor: Colors.grey),
            ),
            Container(
              margin:
                  const EdgeInsets.only(top: 20.0, right: 10.0, bottom: 10.0),
              child: FadeShimmer(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  radius: 4.0,
                  baseColor: Colors.transparent,
                  highlightColor: Colors.grey),
            )
          ],
        ),
      );
    }
  }

  Widget _icon(
    IconData icon, {
    Color color = LightColor.iconColor,
    double size = 20,
    double padding = 10,
    bool isOutLine = false,
    Function? onPressed,
  }) {
    return Container(
      height: 40,
      width: 40,
      padding: EdgeInsets.all(padding),
      // margin: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        border: Border.all(
            color: LightColor.iconColor,
            style: isOutLine ? BorderStyle.solid : BorderStyle.none),
        borderRadius: const BorderRadius.all(Radius.circular(13)),
        color:
            isOutLine ? Colors.transparent : Theme.of(context).backgroundColor,
        // boxShadow: <BoxShadow>[
        //   const BoxShadow(
        //       color: Color(0xfff8f8f8),
        //       blurRadius: 5,
        //       spreadRadius: 10,
        //       offset: Offset(5, 5)),
        // ],
      ),
      child: Icon(icon, color: color, size: size),
    ).ripple(() {
      if (onPressed != null) {
        onPressed();
      }
    }, borderRadius: const BorderRadius.all(Radius.circular(13)));
  }

  Widget _productImage() {
    return AnimatedBuilder(
      builder: (context, child) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: animation.value,
          child: child,
        );
      },
      animation: animation,
      child: Container(
        height: 210,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Padding(
            //   padding: const EdgeInsets.all(15.0),
            //   child: AutoSizeText(
            //     widget.product.title,
            //     maxLines: 1,
            //     style: GoogleFonts.mulish(
            //         fontWeight: FontWeight.w800,
            //         color: LightColor.lightGrey,
            //         fontSize: 100),
            //   ),
            // ),
            Container(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Hero(
                    tag: "dw",
                    child: Image.network(
                      widget.product.img,
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget _categoryWidget(snapshot) {
    if (snapshot.hasData) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 0),
          width: AppTheme.fullWidth(context),
          height: 80,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  widget.product.images.map((x) => _thumbnail(x)).toList()),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(
            left: 10.0, top: 20.0, right: 10.0, bottom: 10.0),
        child: FadeShimmer(
            width: MediaQuery.of(context).size.width,
            height: kToolbarHeight - 26.0,
            radius: 4.0,
            baseColor: Colors.transparent,
            highlightColor: Colors.grey),
      );
    }
  }

  Widget _thumbnail(String image) {
    return AnimatedBuilder(
      animation: animation,
      //  builder: null,
      builder: (context, child) => AnimatedOpacity(
        opacity: animation.value,
        duration: const Duration(milliseconds: 300),
        child: child,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          height: 40,
          width: 50,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: LightColor.grey,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(13)),
              image: DecorationImage(
                image: NetworkImage(image),
              )
              // color: Theme.of(context).backgroundColor,
              ),
        ).ripple(() {},
            borderRadius: const BorderRadius.all(Radius.circular(13))),
      ),
    );
  }

  bool loaded = false;
  Widget _detailWidget() {
    return StreamBuilder<Object>(
        stream: _productDeatailsStream,
        builder: (context, snapshot) {
          WidgetsFlutterBinding.ensureInitialized();
          loaded = true;

          return DraggableScrollableSheet(
            maxChildSize: .63,
            initialChildSize: .63,
            minChildSize: .63,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: Color.fromARGB(255, 37, 40, 47),
                  //gradient: LinearGradient(
                  //   colors: [
                  //     Color.fromARGB(255, 247, 245, 245),
                  //     Color(0xfff7f7f7),
                  //   ],
                  //   begin: Alignment.topCenter,
                  //   end: Alignment.bottomCenter,
                  // ),
                ),
                child: Padding(
                  padding: AppTheme.padding.copyWith(bottom: 0),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        const SizedBox(height: 5),
                        Container(
                          alignment: Alignment.center,
                          child: Container(
                            width: 50,
                            height: 5,
                            decoration: const BoxDecoration(
                                color: LightColor.iconColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // _categoryWidget(snapshot),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              TitleText(
                                text: widget.product.title,
                                fontSize: 25,
                                textAlign: TextAlign.start,
                                color: const Color.fromARGB(255, 215, 217, 220),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TitleText(
                                text: "₹${widget.product.price}" ?? "",
                                fontSize: 25,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              widget.product.offer == "% off"
                                  ? Container()
                                  : TitleText(
                                      text: " ${widget.product.offer}",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: LightColor.orange,
                                    )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _submitButton(context, snapshot),
                        const SizedBox(
                          height: 20,
                        ),
                        _description(widget.product.description),
                        const SizedBox(
                          height: 20,
                        ),
                        widget.product.ratings == ""
                            ? Container()
                            : const TitleText(
                                text: "Reviews",
                                fontSize: 14,
                              ),
                        const SizedBox(height: 20),
                        widget.product.ratings == ""
                            ? Container()
                            : snapshot.hasData
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        borderRadius: BorderRadius.circular(15),
                                        //   boxShadow: [
                                        //   BoxShadow(
                                        //       color: Color.fromARGB(255, 216, 216, 216),
                                        //       blurRadius: 16,
                                        //       spreadRadius: 1),
                                        // ]
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    TitleText(
                                                        text: widget
                                                            .product.ratings,
                                                        fontSize: 25),
                                                    const Text(
                                                      " / 5",
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              156,
                                                              158,
                                                              160)),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 0,
                                                ),
                                                const Text(
                                                  "Based on Reviews",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color.fromARGB(
                                                          255, 156, 158, 160)),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                              ]),
                                          SizedBox(height: 20),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (double.tryParse(
                                                      widget.product.ratings) !=
                                                  null)
                                                if (double.parse(widget
                                                        .product.ratings) >=
                                                    4)
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text("😎",
                                                          style: TextStyle(
                                                              fontSize: 30)),
                                                      SizedBox(width: 10),
                                                      TitleText(
                                                        text:
                                                            "Highly Recommended",
                                                        fontSize: 20,
                                                      ),
                                                    ],
                                                  ),
                                              if (double.parse(widget
                                                          .product.ratings) >
                                                      3.5 &&
                                                  double.parse(widget
                                                          .product.ratings) <
                                                      4)
                                                Row(
                                                  children: [
                                                    Text("🙂",
                                                        style: TextStyle(
                                                            fontSize: 30)),
                                                    SizedBox(width: 10),
                                                    TitleText(
                                                      text: "Recommended",
                                                      fontSize: 27,
                                                    ),
                                                  ],
                                                ),
                                              if (double.parse(
                                                      widget.product.ratings) <=
                                                  3.5)
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text("😟",
                                                        style: TextStyle(
                                                            fontSize: 30)),
                                                    SizedBox(width: 10),
                                                    TitleText(
                                                      text: "Not Recommended",
                                                      fontSize: 23,
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.only(
                                        left: 10.0,
                                        top: 20.0,
                                        right: 10.0,
                                        bottom: 10.0),
                                    child: FadeShimmer(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 100,
                                        radius: 4.0,
                                        baseColor: Colors.transparent,
                                        highlightColor: Colors.grey),
                                  ),
                        const SizedBox(
                          height: 100,
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  Widget _description(description) {
    return description == "loading"
        ? FadeShimmer(
            width: MediaQuery.of(context).size.width,
            height: 55,
            radius: 4.0,
            baseColor: Colors.transparent,
            highlightColor: Colors.grey)
        : description == ""
            ? Container()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const TitleText(
                    text: "Description",
                    fontSize: 14,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.product.description,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 156, 158, 160)),
                  ),
                ],
              );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 37, 40, 47),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              //     gradient: LinearGradient(
              //   colors: [
              //     Color(0xfffbfbfb),
              //     Color(0xfff7f7f7),
              //   ],
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              // )
              color: Color.fromARGB(255, 49, 54, 62),
            ),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    _appBar(),
                    _productImage(),
                  ],
                ),
                _detailWidget()
              ],
            ),
          ),
        ));
  }
}
