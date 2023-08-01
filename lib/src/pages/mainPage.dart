import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shopwise/src/pages/productDetail.dart';
import 'package:shopwise/src/pages/shoppingCartPage.dart';
import 'package:shopwise/src/services/apiServices.dart';
import 'package:shopwise/src/widgets/extentions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/productModel.dart';
import '../themes/light_color.dart';
import '../themes/theme.dart';
import '../widgets/title_text.dart';
import 'homePage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  String title = "";

  MainPage({
    required this.title,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isHomePageSelected = true;
  int tokenCount = 0;

  Widget _appBar() {
    return Container(
      padding: AppTheme.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RotatedBox(
            quarterTurns: 4,
            child: _icon(
              isHomePageSelected
                  ? Icons.bookmark_rounded
                  : Icons.local_fire_department_rounded,
              () {
                setState(() {
                  isHomePageSelected = !isHomePageSelected;
                });
              },
              color: Color.fromARGB(255, 210, 207, 207),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(13)),
              color: Theme.of(context).backgroundColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.bolt_rounded,
                  color: Color.fromARGB(255, 210, 207, 207),
                ),
                Text(
                  hasUnlimitedtokens == false
                      ? "${tokenCount} More Tokens "
                      : "Unlimited Tokens",
                  style: TextStyle(color: Color.fromARGB(255, 197, 198, 199)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _icon(IconData icon, Function onPressed,
      {Color color = LightColor.iconColor}) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(13)),
        color: Theme.of(context).backgroundColor,
      ),
      child: Icon(
        icon,
        color: color,
      ),
    ).ripple(onPressed, borderRadius: BorderRadius.all(Radius.circular(13)));
  }

  Widget _title() {
    return Container(
        margin: AppTheme.padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TitleText(
                  text: isHomePageSelected ? 'Our' : 'Shopping',
                  fontSize: 27,
                  fontWeight: FontWeight.w400,
                ),
                TitleText(
                  text: isHomePageSelected ? 'Products' : 'Cart',
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ],
        ));
  }

  void onBottomIconPressed(int index) {
    if (index == 0 || index == 1) {
      setState(() {
        isHomePageSelected = true;
      });
    } else {
      setState(() {
        isHomePageSelected = false;
      });
    }
  }

  Future<void> main() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await messaging.getToken();
    print('Token: $token');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("fcmtoken", token!);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (d) =>
                  ProductDetailPage(product: Product.fromJson(message.data))));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Received background message: ${message.notification?.title}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (d) =>
                  ProductDetailPage(product: Product.fromJson(message.data))));
    });
  }

  bool _isBannerAdReady = false;

  void checkTokenReset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int lastResetTimestamp = prefs.getInt('lastResetTimestamp') ?? 0;

    DateTime currentDate = DateTime.now();

    DateTime resetDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 0, 0, 0)
            .add(Duration(days: 1));

    if (currentDate.isAfter(resetDate)) {
      prefs.setInt('tokenCount', 10);

      prefs.setInt('lastResetTimestamp', currentDate.millisecondsSinceEpoch);
    }
  }

  @override
  void initState() {
    super.initState();
    main();
    Stripe.publishableKey =
        "pk_live_51NKDQqSAhYdYCbX9gyJaWlmqGo4ULU8lzEX0s9MAnABfeN53za3a7yQC9H4Zaum6w2o2WbbwERj31RYrhOQhydjD005NbOmmxV";
    getToken();
    checkTokenReset();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? tokenCountPrefs = prefs.getInt("tokenCount");
    setState(() {
      tokenCount = tokenCountPrefs ?? 0;
    });

    if (tokenCount <= 0) {
      if (prefs.getBool("hasUnlimitedtokens") == false) {
        iap();
      }
      if (prefs.getBool("hasUnlimitedtokens") == true) {
        setState(() {
          hasUnlimitedtokens = true;
        });
      }
    }
  }

  void decrementTokenCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt('tokenCount') ?? 0;
    if (currentCount != 0) {
      prefs.setInt('tokenCount', currentCount - 1);
      setState(() {
        tokenCount = currentCount - 1;
      });
    }
  }

  bool hasUnlimitedtokens = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 37, 40, 47),
      body: SafeArea(
        child: Stack(
          fit: StackFit.loose,
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(height: 10),
            SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 37, 40, 47),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _appBar(),
                    _title(),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInToLinear,
                      switchOutCurve: Curves.easeOutBack,
                      child: isHomePageSelected
                          ? MyHomePage(
                              title: '',
                            )
                          : Align(
                              alignment: Alignment.topCenter,
                              child: ShoppingCartPage(),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  iap() {
    showModalBottomSheet(
      enableDrag: false,
      context: context,
      isDismissible: false,
      backgroundColor: Color.fromARGB(255, 37, 40, 47),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // Return false to prevent the bottom sheet from being dismissed
            return false;
          },
          child: StatefulBuilder(builder: (context, setState) {
            return Container(
              height: 320,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: LightColor.background,
                              ),
                              width: 30,
                              height: 30,
                              child: Icon(
                                Icons.bolt_rounded,
                                color: Color.fromARGB(255, 210, 207, 207),
                              ),
                            ),
                            SizedBox(width: 15),
                            Text(
                              "Unlimited Tokens",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: LightColor.titleTextColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "120 INR",
                          style: TextStyle(
                            fontSize: 15,
                            color: LightColor.lightGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 2,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 25,
                              child: Icon(
                                Icons.credit_card_rounded,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Checkout instantly with your card",
                            style: TextStyle(
                              fontSize: 15,
                              color: LightColor.lightGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Text(
                      "After this purchase, you will have unlimited tokens. You won't be limited to 10 tokens a day.",
                      style: TextStyle(
                        fontSize: 15,
                        color: LightColor.lightGrey,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        LightColor.titleTextColor,
                      ),
                    ),
                    onPressed: () async {
                      makePayment(setState, context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: TitleText(
                        text: status,
                        color: Color.fromARGB(255, 236, 236, 236),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
        );
      },
    );
  }

  String status = "Buy Now";
  Future<void> makePayment(setState, context) async {
    try {
      paymentIntent = await createPaymentIntent('120', 'INR');
      //Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92',),
                  // googlePay: const PaymentSheetGooglePay(testEnv: true, currencyCode: "US", merchantCountryCode: "+92"),
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Adnan'))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet(setState, context);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  Map<String, dynamic>? paymentIntent;

  displayPaymentSheet(setState, context) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setBool("hasUnlimitedtokens", true);
        getToken();
        setState(() {
          status = "Payment Successful";
        });

        // showDialog(
        //     context: context,
        //     builder: (_) => AlertDialog(
        //           content: Column(
        //             mainAxisSize: MainAxisSize.min,
        //             children: [
        //               Row(
        //                 children: const [
        //                   Icon(
        //                     Icons.check_circle,
        //                     color: Colors.green,
        //                   ),
        //                   Text("Payment Successfull"),
        //                 ],
        //               ),
        //             ],
        //           ),
        //         ));
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));
        Navigator.pop(context);

        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } catch (e) {
      print('Error is:---> $e');
      setState(() {
        status = "Payment Failed";
      });
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled"),
              ));
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer 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',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // ignore: avoid_print
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }
}
