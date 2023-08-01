import 'package:flutter/material.dart';
import 'package:shopwise/src/pages/homePage.dart';
import 'package:shopwise/src/pages/mainPage.dart';
import 'package:shopwise/src/pages/onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding/widgets/ripple.dart';

class SplashScreen extends StatefulWidget {
  
  final double screenHeight;
  SplashScreen({required this.screenHeight});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleAnimationController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    _rippleAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: widget.screenHeight,
    ).animate(CurvedAnimation(
      parent: _rippleAnimationController,
      curve: Curves.ease,
    ));
    navigateToNextScreen();
  }

  navigateToNextScreen() async {
    final bool isFirstTimeUser = await checkFirstTimeUser();

    Future.delayed(Duration(seconds: 2), () async {
      if (isFirstTimeUser) {
        await _rippleAnimationController.forward();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (x) => const Onboarding(screenHeight: 900)),
        );
      } else {
        await _rippleAnimationController.forward();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (x) => MainPage(title: '')),
            (route) => false);
      }
    });
  }

  Future<bool> checkFirstTimeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var isFirstTime = prefs.getBool("isFirstTime");
    if (isFirstTime == true || isFirstTime == null) {
      await prefs.setBool("isFirstTime", false);
      await prefs.setBool("hasUnlimitedtokens", false);
      await prefs.setStringList("liked", []);
      await prefs.setInt("tokenCount", 10);
      await prefs.setStringList("searchHistory", []);
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _rippleAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 37, 40, 47),
      body: Stack(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/S.png",
                scale: 3,
              ),
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
