
import 'package:andbeyondexample/src/ui/main/view/home_page.dart';
import 'package:flutter/cupertino.dart';

import '../ui/main/view/splash_page.dart';

class AppRoutes {
  static const String splash = "/splash";
  static const String home = "/home";


  static Map<String, Widget Function(BuildContext)> routes = {
    splash: (context) => const SplashPage(),
    home: (context) => const HomePage()
  };
}
