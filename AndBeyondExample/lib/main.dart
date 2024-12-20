import 'dart:io';

import 'package:andbeyondexample/src/appvalues/app_routes.dart';
import 'package:andbeyondexample/src/appvalues/app_theme.dart';
import 'package:andbeyondexample/src/ui/main/view/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:andbeyondmedia/andbeyondmedia.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Platform.isAndroid
      ? SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent, // navigation bar color
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark))
      : SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent, // navigation bar color
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light));
  MobileAds.instance.initialize();
  AndBeyondMedia.instance.initialize(true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      theme: MyThemes.lightTheme,
      routes: AppRoutes.routes,
      initialRoute: "/",
      home: const SplashPage(),
    );
  }
}
