import 'dart:async';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopwise/src/pages/productDetail.dart';
import 'package:shopwise/src/widgets/extentions.dart';

import '../model/productModel.dart';
import '../services/apiServices.dart';
import '../themes/light_color.dart';
import '../themes/theme.dart';
import 'mainPage.dart';

class SearchPage extends StatefulWidget {
  final List<Product> initedProducts;
  final String searchTag;
  SearchPage({required this.initedProducts, required this.searchTag});
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final StreamController<List<Product>> searchStreamController =
      StreamController<List<Product>>();
  final StreamController<List<String>> suggestionsStreamController =
      StreamController<List<String>>();

  @override
  void initState() {
    super.initState();
    if (widget.initedProducts.isNotEmpty) {
      searchStreamController.add(widget.initedProducts);
    }
  }

  @override
  void dispose() {
    searchStreamController.close();
    suggestionsStreamController.close();
    super.dispose();
  }

  void searchProduct(String query) async {
    searchStreamController
        .add([]); // Set initial state as an empty list (loading state)

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final hasUnlimitedTokens = prefs.getBool("hasUnlimitedtokens");
    if (hasUnlimitedTokens == false) {
      int? tokenCount = prefs.getInt("tokenCount");
      if (tokenCount != 0) {
        await prefs.setInt("tokenCount", tokenCount! - 1);
      }
    }

    try {
      final List<Product> products = await ApiServices.itemSearch(query);
      // products.sort((a, b) {
      //   int aprice = int.parse(a.price.replaceAll(",", ""));
      //   int bprice = int.parse(b.price.replaceAll(",", ""));
      //   return aprice.compareTo(bprice);
      // });
      searchStreamController.add(products); // Add the value to the stream
    } catch (error) {
      searchStreamController
          .addError(error); // Add error to the stream if an error occurs
    }
  }

  void getSuggestions(String query) async {
    try {
      final List<String> suggestions = await ApiServices.getSuggestions(query);
      setState(() {
        suggestionsStreamController.add(suggestions);
      });
    } catch (error) {
      suggestionsStreamController.addError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 37, 40, 47),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 37, 40, 47),
          ),
          child: Column(
            children: [
              Container(
                margin: AppTheme.padding,
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 40,
                            iconSize: 15,
                            padding: 1,
                            isOutLine: false,
                            context: context,
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => MainPage(
                                    title: '',
                                  ),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Container(
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 197, 198, 199)
                              .withOpacity(0.6),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: TextField(
                          autofocus: true,
                          controller: _searchController,
                          onChanged: (query) {
                            if (query.isNotEmpty) {
                              getSuggestions(query);
                            } else {
                              suggestionsStreamController.add([]);
                            }
                          },
                          onSubmitted: (query) async {
                            final queryText = _searchController.text.trim();
                            if (queryText.isNotEmpty) {
                              searchProduct(queryText);
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              List<String>? searchHistory =
                                  prefs.getStringList("searchHistory");
                              searchHistory!.add(queryText);
                              prefs.setStringList(
                                  "searchHistory", searchHistory);
                            }
                          },
                          style: TextStyle(
                            color: Color.fromARGB(255, 210, 207, 207),
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Try searching with the exact name...",
                            hintStyle: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 210, 207, 207),
                            ),
                            contentPadding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color.fromARGB(255, 210, 207, 207),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, top: 10, right: 15, bottom: 15),
                  child: StreamBuilder<List<Product>>(
                    stream: searchStreamController.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData && _searchController.text.isEmpty) {
                        return _displaySearchHistory();
                      }
                      if (!snapshot.hasData) {
                        return StreamBuilder<List<String>>(
                          stream: suggestionsStreamController.stream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container(); // Return an empty container while waiting for data
                            }

                            final suggestionList = snapshot.data!;

                            return ListView.separated(
                              shrinkWrap: true,
                              itemBuilder: (ctx, i) {
                                return ListTile(
                                  onTap: () {
                                    setState(() {
                                      _searchController.text =
                                          suggestionList[i];
                                    });
                                    searchProduct(suggestionList[i]);
                                  },
                                  title: Text(
                                    suggestionList[i],
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Color.fromARGB(255, 210, 207, 207),
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.trending_up_rounded,
                                    color: Color.fromARGB(255, 210, 207, 207),
                                  ),
                                );
                              },
                              separatorBuilder: (ctx, i) => SizedBox(height: 0),
                              itemCount: suggestionList.length > 5
                                  ? 5
                                  : suggestionList.length,
                            );
                          },
                        );
                      }

                      if (snapshot.hasData) {
                        final products = snapshot.data!;
                        return AnimationLimiter(
                          child: ListView.separated(
                            separatorBuilder: (ctx, i) {
                              return SizedBox(
                                height: 20,
                              );
                            },
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: products.length,
                            itemBuilder: (BuildContext c, int i) {
                              return AnimationConfiguration.staggeredList(
                                position: i,
                                delay: Duration(milliseconds: 100),
                                child: SlideAnimation(
                                  duration: Duration(milliseconds: 2500),
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  horizontalOffset: 30,
                                  verticalOffset: 300.0,
                                  child: FlipAnimation(
                                    duration: Duration(milliseconds: 3000),
                                    curve: Curves.fastLinearToSlowEaseIn,
                                    flipAxis: FlipAxis.y,
                                    child: _resultProductCard(
                                        context, i, products[i]),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return _fadeShimmerSearchListView();
                      } else {
                        return _fadeShimmerSearchListView();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> fetchSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? searchHistory = prefs.getStringList("searchHistory");

    return searchHistory ?? [];
  }

  Widget _icon(
    IconData icon, {
    Color color = LightColor.iconColor,
    double size = 20,
    double iconSize = 15,
    double padding = 10,
    bool isOutLine = false,
    Function? onPressed,
    BuildContext? context,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        border: Border.all(
          color: LightColor.iconColor,
          style: isOutLine ? BorderStyle.solid : BorderStyle.none,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color:
            isOutLine ? Colors.transparent : Theme.of(context!).backgroundColor,
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
      ),
    ).ripple(
      () {
        if (onPressed != null) {
          onPressed();
        }
      },
      borderRadius: const BorderRadius.all(Radius.circular(13)),
    );
  }

  Widget _displaySearchHistory() {
    return FutureBuilder<List<String>>(
      future: fetchSearchHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(); // Return an empty container while waiting for data
        }

        final searchHistory = snapshot.data!;
        final reversedHistory =
            searchHistory.reversed.toList(); // Reverse the search history list

        return ListView.separated(
          shrinkWrap: true,
          itemBuilder: (ctx, i) {
            final index = reversedHistory.length -
                i -
                1; // Calculate the index based on reversed list
            return ListTile(
              onTap: () {
                setState(() {
                  _searchController.text = reversedHistory[i];
                });
                searchProduct(reversedHistory[i]);
              },
              title: Text(
                reversedHistory[i],
                style: TextStyle(
                  fontSize: 17,
                  color: Color.fromARGB(255, 210, 207, 207),
                ),
              ),
              trailing: Icon(
                Icons.history,
                color: Color.fromARGB(255, 210, 207, 207),
              ),
            );
          },
          separatorBuilder: (ctx, i) => SizedBox(height: 0),
          itemCount: reversedHistory.length > 5 ? 5 : reversedHistory.length,
        );
      },
    );
  }

  Widget _resultProductCard(BuildContext ctx, int i, Product model) {
    return Container(
      decoration: i == 0
          ? BoxDecoration(
              color: LightColor.titleTextColor.withOpacity(1),
              borderRadius: BorderRadius.circular(20),
            )
          : BoxDecoration(),
      padding: i == 0
          ? EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10)
          : EdgeInsets.all(0),
      child: Column(
        children: [
          i == 0
              ? Padding(
                  padding: EdgeInsets.only(left: 10, top: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text("Best Buy",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                )
              : Container(),
          i == 0 ? SizedBox(height: 10) : Container(),
          Container(
            width: double.infinity,
            height: 100,
            padding: EdgeInsets.only(left: 15, right: 15, top: 0),
            decoration: BoxDecoration(
              color: LightColor.background,
              border: Border.all(
                color: LightColor.titleTextColor.withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: LightColor.orange.withAlpha(40),
                      ),
                      Hero(
                        tag: "dw",
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(model.img),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: MediaQuery.of(ctx).size.width - 230,
                          child: Text(
                            model.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 210, 207, 207),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            model.offer == "% off"
                                ? Container()
                                : Text(
                                    model.offer == "₹ " ? "" : model.offer,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: LightColor.titleTextColor,
                                    ),
                                  ),
                            SizedBox(height: 3),
                            Text(
                              "₹${model.price}" ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 210, 207, 207),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(5),
                      child: Image.network(model.websiteLogo),
                    ),
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
          ).ripple(
            () {
              Navigator.of(ctx).push(
                MaterialPageRoute(
                    builder: (c) => ProductDetailPage(product: model)),
              );
            },
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ],
      ),
    );
  }

  Widget _fadeShimmerSearchListView() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 37, 40, 47),
      ),
      child: ListView.separated(
        separatorBuilder: (ctx, i) => SizedBox(height: 10),
        itemCount: 5,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Card(
              color: LightColor.background,
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      left: 10.0,
                      top: 20.0,
                      right: 10.0,
                      bottom: 10.0,
                    ),
                    child: FadeShimmer(
                      width: MediaQuery.of(context).size.width,
                      height: kToolbarHeight - 26.0,
                      radius: 4.0,
                      baseColor: Color.fromARGB(255, 37, 40, 47),
                      highlightColor: Colors.grey,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                      bottom: 10.0,
                    ),
                    child: FadeShimmer(
                      width: MediaQuery.of(context).size.width / 2.4,
                      height: kToolbarHeight - 36.0,
                      radius: 4.0,
                      baseColor: Colors.transparent,
                      highlightColor: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
