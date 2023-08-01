import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopwise/src/pages/mainPage.dart';
import 'package:shopwise/src/pages/onboarding/onboarding.dart';
import 'package:shopwise/src/pages/splashscreen.dart';
import 'package:shopwise/src/themes/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
  checkFirstTimeUser();
}

Future<bool> checkFirstTimeUser() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var isFirstTime = prefs.getBool("isFirstTime");
  if (isFirstTime == true || isFirstTime == null) {
    prefs.setBool("isFirstTime", false);
    prefs.setBool("hasUnlimitedtokens", false);
    prefs.setStringList("liked", []);
    prefs.setInt("tokenCount", 10);
    prefs.setStringList("searchHistory", []);
    return true;
  } else {
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: AppTheme.lightTheme.copyWith(
          textTheme: GoogleFonts.mulishTextTheme(Theme.of(context).textTheme),
        ),
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
          screenHeight: MediaQuery.of(context).size.height,
        ));
  }
}
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: checkFirstTimeUser(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           final bool isFirstTimeUser = snapshot.data!;
//           if (isFirstTimeUser) {
//             return MaterialApp(
//               title: 'E-Commerce ',
//               theme: AppTheme.lightTheme.copyWith(
//                 textTheme:
//                     GoogleFonts.mulishTextTheme(Theme.of(context).textTheme),
//               ),
//               home: const Onboarding(screenHeight: 900),
//             );
//           } else {
//             return MaterialApp(
//                 title: 'E-Commerce ',
//                 theme: AppTheme.lightTheme.copyWith(
//                   textTheme: GoogleFonts.mulishTextTheme(
//                     Theme.of(context).textTheme,
//                   ),
//                 ),
//                 debugShowCheckedModeBanner: false,
//                 home: MainPage(title: ""));
//           }
//         } else if (snapshot.hasError) {
//           // Handle error case
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             home: const Scaffold(
//               backgroundColor: Color.fromARGB(255, 37, 40, 47),
//             ),
//           );
//         } else {
//           // Show a loading spinner while checking for first-time user
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             home: Scaffold(
//               backgroundColor: Color.fromARGB(255, 37, 40, 47),
//             ),
//           );
//         }
//       },
//     );
//   }
// }
  
    
            // routes: Routes.getRoute(),
            // onGenerateRoute: (RouteSettings settings) {
            //   if (settings.name.contains('detail')) {
            //     return CustomRoute<bool>(
            //         builder: (BuildContext context) => ProductDetailPage());
            //   } else if (settings.name.contains('search')) {
            //     return CustomRoute<bool>(
            //         builder: (BuildContext context) => SearchPage());
            //   } else {
            //     return CustomRoute<bool>(
            //         builder: (BuildContext context) => MyHomePage());
            //   }
            // },
            // initialRoute: "MainPage",
            
 