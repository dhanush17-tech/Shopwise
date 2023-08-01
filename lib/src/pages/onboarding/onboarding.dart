import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopwise/src/pages/homePage.dart';
import 'package:shopwise/src/pages/mainPage.dart';
import 'package:shopwise/src/pages/onboarding/screens/login/widgets/header.dart';
import 'package:shopwise/src/pages/onboarding/widgets/next_page_button.dart';
import 'package:shopwise/src/pages/onboarding/widgets/onboarding_page_indicator.dart';
import 'package:shopwise/src/pages/onboarding/widgets/ripple.dart';
import 'constants.dart';
import 'package:flutter/src/services/system_chrome.dart';

class Onboarding extends StatefulWidget {
  final double screenHeight;

  const Onboarding({
    required this.screenHeight,
  }) : assert(screenHeight != null);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> with TickerProviderStateMixin {
  late AnimationController _cardsAnimationController;
  late AnimationController _pageIndicatorAnimationController;
  late AnimationController _rippleAnimationController;

  late Animation<Offset> _slideAnimationLightCard;
  late Animation<Offset> _slideAnimationDarkCard;
  late Animation<double> _pageIndicatorAnimation;
  late Animation<double> _rippleAnimation;

  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _cardsAnimationController = AnimationController(
      vsync: this,
      duration: kCardAnimationDuration,
    );
    _pageIndicatorAnimationController = AnimationController(
      vsync: this,
      duration: kButtonAnimationDuration,
    );
    _rippleAnimationController = AnimationController(
      vsync: this,
      duration: kRippleAnimationDuration,
    );

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: widget.screenHeight,
    ).animate(CurvedAnimation(
      parent: _rippleAnimationController,
      curve: Curves.ease,
    ));

    _setPageIndicatorAnimation();
    _setCardsSlideOutAnimation();
  }

  @override
  void dispose() {
    _cardsAnimationController.dispose();
    _pageIndicatorAnimationController.dispose();
    _rippleAnimationController.dispose();
    super.dispose();
  }

  bool get isFirstPage => _currentPage == 1;

  Widget _getPage() {
    switch (_currentPage) {
      case 1:
        return SlideTransition(
          position: _slideAnimationDarkCard,
          child: Column(
            children: [
              const SizedBox(height: 0),
              Container(
                height: MediaQuery.of(context).size.height - 440,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 30,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: const Color(0xFF4985FD),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(top: 3.0, left: 3),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.asset(
                                          "assets/logo.png",
                                          scale: 7,
                                        ))),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      "iPhone 13 256GB is on sale 🎉\ngrab it quick",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width -
                                          140,
                                      height: 100,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: const DecorationImage(
                                              fit: BoxFit.cover,
                                              image: AssetImage(
                                                  "assets/onboarding_phone.png"))),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 100,
                      left: 50,
                      child: Row(
                        children: [
                          Text(
                            "Real Time Price Alerts ",
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.show_chart_rounded,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 30,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFF4985FD),
                                  ),
                                  child: const Icon(
                                    Icons.fiber_smart_record_sharp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: Container(
                                  width: 17,
                                  height: 17,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.redAccent,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "1",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 0),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Price Alerts",
                  style: GoogleFonts.poppins(
                      fontSize: 30,
                      color: kDarkBlue,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 0),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Get alerts when the price of your favorite product goes down.",
                  style: GoogleFonts.poppins(color: kWhite, fontSize: 15.5),
                ),
              ),
            ],
          ),
        );
      case 2:
        return SlideTransition(
          position: _slideAnimationDarkCard,
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height - 440,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "assets/barcode_scan.jpg",
                          scale: 4,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // Text("All you need to do is, Scan ",
                    //     style: TextStyle(
                    //         fontSize: 20,
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.bold))
                    Positioned(
                        top: 10,
                        left: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            "assets/scanresult.jpg",
                            scale: 6,
                          ),
                        ))
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Search with Barcode",
                  style: GoogleFonts.poppins(
                      fontSize: 30,
                      color: kDarkBlue,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 00),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Scan the barcode or search with the product name to get the best price",
                  style: GoogleFonts.poppins(color: kWhite, fontSize: 15.5),
                ),
              ),
            ],
          ),
        );
      case 3:
        return SlideTransition(
          position: _slideAnimationDarkCard,
          child: Column(
            children: [
              const SizedBox(height: 0),
              Container(
                height: MediaQuery.of(context).size.height - 440,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "assets/latestDeals.jpg",
                          scale: 5,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Latest Deals",
                  style: GoogleFonts.poppins(
                      height: 1,
                      fontSize: 30,
                      color: kDarkBlue,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Get the latest deals across all the websites at one place",
                  style: GoogleFonts.poppins(color: kWhite),
                ),
              ),
            ],
          ),
        );
      default:
        throw Exception("Page with number '$_currentPage' does not exist.");
    }
  }

  void _setCardsSlideInAnimation() {
    setState(() {
      _slideAnimationLightCard = Tween<Offset>(
        begin: const Offset(3.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _cardsAnimationController,
        curve: Curves.easeOut,
      ));
      _slideAnimationDarkCard = Tween<Offset>(
        begin: const Offset(1.5, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _cardsAnimationController,
        curve: Curves.easeOut,
      ));
      _cardsAnimationController.reset();
    });
  }

  void _setCardsSlideOutAnimation() {
    setState(() {
      _slideAnimationLightCard = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.0, 0.0),
      ).animate(CurvedAnimation(
        parent: _cardsAnimationController,
        curve: Curves.easeIn,
      ));
      _slideAnimationDarkCard = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-1.5, 0.0),
      ).animate(CurvedAnimation(
        parent: _cardsAnimationController,
        curve: Curves.easeIn,
      ));
      _cardsAnimationController.reset();
    });
  }

  void _setPageIndicatorAnimation({bool isClockwiseAnimation = true}) {
    var multiplicator = isClockwiseAnimation ? 2 : -2;

    setState(() {
      _pageIndicatorAnimation = Tween(
        begin: 0.0,
        end: multiplicator * pi,
      ).animate(
        CurvedAnimation(
          parent: _pageIndicatorAnimationController,
          curve: Curves.easeIn,
        ),
      );
      _pageIndicatorAnimationController.reset();
    });
  }

  void _setNextPage(int nextPageNumber) {
    setState(() {
      _currentPage = nextPageNumber;
    });
  }

  Future<void> _nextPage() async {
    switch (_currentPage) {
      case 1:
        if (_pageIndicatorAnimation.status == AnimationStatus.dismissed) {
          _pageIndicatorAnimationController.forward();
          await _cardsAnimationController.forward();
          _setNextPage(2);
          _setCardsSlideInAnimation();
          await _cardsAnimationController.forward();
          _setCardsSlideOutAnimation();
          _setPageIndicatorAnimation(isClockwiseAnimation: false);
        }
        break;
      case 2:
        if (_pageIndicatorAnimation.status == AnimationStatus.dismissed) {
          _pageIndicatorAnimationController.forward();
          await _cardsAnimationController.forward();
          _setNextPage(3);
          _setCardsSlideInAnimation();
          await _cardsAnimationController.forward();
        }
        break;
      case 3:
        if (_pageIndicatorAnimation.status == AnimationStatus.completed) {
          await _goToLogin();
        }
        break;
    }
  }

  Future<void> _goToLogin() async {
    await _rippleAnimationController.forward();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => MainPage(
                  title: "",
                )),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 37, 40, 47),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Header(
                    onSkip: () async => await _goToLogin(),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: _getPage(),
                ),
                AnimatedBuilder(
                  animation: _pageIndicatorAnimation,
                  child: NextPageButton(
                    onPressed: () async => await _nextPage(),
                  ),
                  builder: (_, Widget? child) {
                    return OnboardingPageIndicator(
                      angle: _pageIndicatorAnimation.value,
                      currentPage: _currentPage,
                      child: child!,
                    );
                  },
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (_, Widget? child) {
              return Ripple(
                radius: _rippleAnimation.value,
              );
            },
          ),
        ],
      ),
    );
  }
}
