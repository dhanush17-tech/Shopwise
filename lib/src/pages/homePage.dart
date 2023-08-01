import 'dart:async';

import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopwise/src/model/data.dart';
import 'package:shopwise/src/pages/productDetail.dart';
import 'package:shopwise/src/pages/searchPage.dart';
import 'package:shopwise/src/widgets/extentions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/productModel.dart';
import '../services/apiServices.dart';
import '../themes/light_color.dart';
import '../themes/theme.dart';
import '../widgets/product_card.dart';
import '../widgets/product_icon.dart';
import '../widgets/title_text.dart';
import 'coupon_page.dart';

class MyHomePage extends StatefulWidget {
  String title = "";
  MyHomePage({required this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _categoryWidget() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: AppTheme.fullWidth(context),
        height: 80,
        alignment: Alignment.center,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: AppData.categoryList
              .map(
                (category) => ProductIcon(
                  model: category,
                  onSelected: (model) {
                    _streamController.sink.add(null);

                    setState(() {
                      AppData.categoryList.forEach((item) {
                        item.isSelected = false;
                      });
                      model.isSelected = true;
                    });
                    _fetchLatestDeals(
                      model.dealType,
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  double progress = 0.0;
  int productsLength = 0;
  int _index = 0;
  bool isNotFound = false;
  Widget _productWidget() {
    return Container(
        height: AppTheme.fullWidth(context) * .9,
        child: StreamBuilder(
            stream: myStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Check if the snapshot has data
                List<Product>? products = snapshot.data as List<Product>?;
                if (products != null) {
                  // Check if the products list is not null
                  return PageView.builder(
                    itemCount: (snapshot.data as List<Product>).length,
                    controller: PageController(viewportFraction: 0.7),
                    onPageChanged: (int index) {
                      setState(() => _index = index);
                      _currentPageIndex = index;
                    },
                    itemBuilder: (_, i) {
                      return TweenAnimationBuilder(
                          duration: Duration(milliseconds: 300),
                          tween: Tween(begin: 0.8, end: _index == i ? 1 : 0.8),
                          builder: (ctx, tween, d) {
                            return Container(
                              height: AppTheme.fullWidth(context) * .6,
                              child: Transform.scale(
                                  scale: double.parse(tween.toString()),
                                  child: ProductCard(
                                    product:
                                        (snapshot.data as List<Product>?)![i],
                                    onSelected: (model) async {
                                      print("ferfrerf");
                                      final SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      if (prefs.getBool("hasUnlimitedtokens") ==
                                          false) {
                                        final SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        int? tokenCount = await prefs.getInt(
                                          "tokenCount",
                                        );
                                        await prefs.setInt(
                                            "tokenCount", tokenCount! - 1);
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (c) =>
                                                    ProductDetailPage(
                                                        product: model)));
                                      }
                                    },
                                  )),
                            );
                          });
                    },
                  );
                } else {
                  // Render a loading indicator when the products list is null
                  return fadeShimmerDocView(progressValue);
                }
              } else if (snapshot.hasError) {
                // Handle error state
                return Text('Error: ${snapshot.error}');
              } else {
                // Render a loading indicator while waiting for data
                return fadeShimmerDocView(progressValue);
              }
            }));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _streamController.sink.add(null);
    addWithoutChecking();
    fetchBannersandSaleItems();
    fetchStores();
  }

  List<Banners> banners = [];
  List<SalesItem> salesItems = [];
  List<Coupon> coupons = [];
  fetchStores() {
    ApiServices.fetchLatestUsedCoupon().then((value) {
      setState(() {
        coupons = value;
      });
    });
  }

  fetchBannersandSaleItems() {
    ApiServices.fetchBannersandSaleItems().then((value) {
      setState(() {
        banners = value['banners'];
        salesItems = value["salesItems"];
      });
    });
  }

  addWithoutChecking() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    ApiServices.getLatestDeals("mobiles", updateProgress).then((value) {
      value.sort((a, b) {
        String priceA = a.price.replaceAll(",", "");
        String priceB = b.price.replaceAll(",", "");
        return int.parse(priceB).compareTo(int.parse(priceA));
      });
      setState(() {
        productsLength = value.length;
      });
      // Cache the fetched data
      prefs.setString("mobiles", Product.stringifyList(value));

      // Update the stream with the fetched data
      _streamController.sink.add(value);
      prefs.remove('laptops');
      prefs.remove("tv");
    });
  }

  Future<void> _fetchLatestDeals(String dealType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the data is already cached
    final String? cachedData = prefs.getString(dealType);

    if (cachedData != null) {
      // Data exists in cache, parse and use it
      final List<Product> cachedProducts = Product.parseList(cachedData);
      _streamController.sink.add(cachedProducts);
    } else {
      // Data does not exist in cache, fetch from API
      ApiServices.getLatestDeals(dealType, updateProgress).then((value) {
        value.sort((a, b) {
          String priceA = a.price.replaceAll(",", "");
          String priceB = b.price.replaceAll(",", "");
          return int.parse(priceB).compareTo(int.parse(priceA));
        });

        // Cache the fetched data
        prefs.setString(dealType, Product.stringifyList(value));
        setState(() {
          productsLength = value.length;
        });
        // Update the stream with the fetched data
        _streamController.sink.add(value);
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _streamController.close();
  }

  double progressValue = 0.0;

  void updateProgress(double progress) {
    setState(() {
      progressValue = progress;
    });
  }

  StreamController _streamController = StreamController();

  Stream get myStream => _streamController.stream;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 180,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        dragStartBehavior: DragStartBehavior.down,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: AppTheme.padding,
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (c) => SearchPage(
                                initedProducts: [],
                                searchTag: "",
                              )));
                    },
                    child: Container(
                        height: 60,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 197, 198, 199)
                                .withOpacity(0.6),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: AppTheme.padding,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 1.0),
                                child: Text(
                                  "Search for products...",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                              )
                            ],
                          ),
                        )),
                  )),
                  SizedBox(width: 20),
                  _barcodeIcon(context)
                ],
              ),
            ),
            _categoryWidget(),
            _productWidget(),
            SizedBox(height: 30),
            // Padding(
            //   padding: const EdgeInsets.only(left: 20.0),
            //   child: TitleText(text: "Exclusive Deals"),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Container(
            //     height: 150, // Set the desired height of the carousel
            //     child: PageView.builder(
            //       scrollDirection: Axis.horizontal,
            //       itemCount: banners.length,
            //       onPageChanged: (index) {
            //         setState(() {
            //           _currentPageIndex = index;
            //         });
            //       },
            //       itemBuilder: (context, index) {
            //         final banner = banners[index];
            //         return Container(
            //           margin: EdgeInsets.all(10),
            //           width: 300, // Set the desired width of each banner
            //           height: 150,
            //           decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(10),
            //             image: DecorationImage(
            //               image: NetworkImage(banner.img_url),
            //               fit: BoxFit.cover,
            //             ),
            //           ),
            //           child: GestureDetector(
            //             onTap: () {
            //               // Handle banner tap event
            //               // e.g., open a URL in a webview
            //               launchUrl(Uri.parse(banner.url));
            //             },
            //           ),
            //         );
            //       },
            //     ),
            //   ),
            // ),
            Align(
              alignment: Alignment.center,
              child: DotsIndicator(
                dotsCount: productsLength != 0 ? productsLength : 1,
                position: _currentPageIndex != 0 ? _currentPageIndex : 0,
                decorator: DotsDecorator(
                  size: const Size.square(5.0),
                  activeSize: const Size(18.0, 5.0),
                  color: Colors.grey[400]!,
                  activeColor: Colors.white,
                  spacing: const EdgeInsets.symmetric(horizontal: 2.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: TitleText(
                  text: "Explore Coupons",
                  color: Colors.grey[400]!,
                )),
            SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  separatorBuilder: (ctx, i) {
                    return SizedBox(height: 20);
                  },
                  itemCount: coupons.length,
                  shrinkWrap: true,
                  itemBuilder: (ctx, i) {
                    Coupon coupon = coupons[i];
                    return Padding(
                      padding: const EdgeInsets.only(left: 18, right: 1.0),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: LightColor.background,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                    constraints: BoxConstraints(
                                        minWidth: 100,
                                        maxWidth: 100,
                                        maxHeight: 50),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromARGB(255, 37, 40, 47),
                                    ),
                                    child: Center(
                                        child: coupon.imgUrl!.contains(".svg")
                                            ? SvgPicture.network(coupon.imgUrl!,
                                                color:
                                                    LightColor.titleTextColor)
                                            : Image.network(coupon.imgUrl!))),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 215,
                                  child: Text(coupon.couponTitle!,
                                      style: GoogleFonts.fredoka(
                                          color: Colors.white)),
                                )
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.copy_rounded,
                                  color: LightColor.titleTextColor
                                      .withOpacity(0.8)),
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: coupon.couponCode!));
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: salesItems.length,
              itemBuilder: (context, index) {
                final salesItem = salesItems[index];
                return GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse(salesItem.url));
                  },
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(salesItem.img_url),
                          fit: BoxFit.cover,
                        )),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

int _currentPageIndex = 0;
_barcodeIcon(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      final barcodeResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Color for the toolbar background
        'Cancel', // Text for the toolbar cancel button
        true, // Show flash icon
        ScanMode.BARCODE, // Scan mode
      );

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (cx) {
            return AlertDialog(
                title: Text('Barcode Search'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(child: CircularProgressIndicator()),
                    SizedBox(height: 16),
                    Text('Searching barcode...'),
                  ],
                ));
          });
      if (barcodeResult == "-1") {
        Navigator.of(context).pop();
        return;
      }
      List<Product> value = await ApiServices.barcodeSearch(barcodeResult,
          (double progressValue) {
        // setState(() {
        //   progress = progressValue;
        // });
      });

      // Close the dialog when the search is completed
      if (value.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        int? tokenCount = await prefs.getInt(
          "tokenCount",
        );
        await prefs.setInt("tokenCount", tokenCount! - 1);
        Navigator.of(context).pop();

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => SearchPage(
                    searchTag: value[0].title, initedProducts: value)));
      } else {
        Navigator.of(context).pop();

        showDialog(
            context: context,
            builder: (cx) {
              return AlertDialog(
                  content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/not_found.png"),
                            fit: BoxFit.cover)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("We couldn't find a match\nTry searching by name")
                ],
              ));
            });
      }

      // Close the dialog when the search is completed
      //_qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
      //  context: context,
      //onCode: (code) {
      // setState(() {
      //   isLoading = true;
      // });
      //if (isLoading) {
      //     showDialog(
      //         context: context,
      //         builder: (c) {
      //           return AlertDialog(
      //             title: Text('Barcode Search'),
      //             content: Column(
      //               mainAxisSize: MainAxisSize.min,
      //               children: [
      //                 LinearProgressIndicator(
      //                     value: progress),
      //                 SizedBox(height: 16),
      //                 Text('Searching barcode...'),
      //               ],
      //             ),
      //           );
      //         });
      //   }
      //   ApiServices.barcodeSearch(code).then((value) {
      //     setState(() {
      //       isLoading = false;
      //     });
      //     Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (c) => SearchPage(
      //                 searchTag: value[0].title,
      //                 initedProducts: value)));
      //   });
      // });
    },
    child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(13)),
          color: Theme.of(context).backgroundColor,
          // boxShadow: [
          //   BoxShadow(
          //       color: Color.fromARGB(255, 230, 230, 230),
          //       blurRadius: 10,
          //       spreadRadius: 15),
          // ]
        ),
        child: Icon(
          Icons.qr_code_rounded,
          color: Color.fromARGB(255, 210, 207, 207),
          size: 26,
        )),
  );
}

fadeShimmerDocView(progressValue) {
  return ListView.builder(
      itemCount: 2,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Container(
          width: MediaQuery.of(context).size.width / 1.2,
          margin: const EdgeInsets.only(left: 10.0, bottom: 10.0),
          child: Card(
            color: Color.fromARGB(255, 37, 40, 47),
            elevation: 2.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(
                    left: 10.0, top: 20.0, right: 10.0, bottom: 10.0),
                child: FadeShimmer(
                    width: MediaQuery.of(context).size.width,
                    height: kToolbarHeight - 26.0,
                    radius: 4.0,
                    baseColor: Colors.transparent,
                    highlightColor: Colors.grey),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 10.0, right: 10.0, bottom: 10.0),
                child: FadeShimmer(
                    width: MediaQuery.of(context).size.width / 2.4,
                    height: kToolbarHeight - 36.0,
                    radius: 4.0,
                    baseColor: Colors.transparent,
                    highlightColor: Colors.grey),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 10.0, right: 10.0, bottom: 10.0),
                child: FadeShimmer(
                    width: MediaQuery.of(context).size.width,
                    height: kToolbarHeight + 144.0,
                    radius: 4.0,
                    baseColor: Colors.transparent,
                    highlightColor: Colors.grey),
              ),
              LinearProgressIndicator(
                value: progressValue,
              ),
            ]),
          ),
        );
      });
}

Widget icon(IconData icon, BuildContext context,
    {Color color = LightColor.iconColor}) {
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(13)),
      color: Theme.of(context).backgroundColor,
      //    boxShadow: AppTheme.shadow
    ),
    child: Icon(
      icon,
      color: color,
    ),
  ).ripple(() {}, borderRadius: BorderRadius.all(Radius.circular(13)));
}
