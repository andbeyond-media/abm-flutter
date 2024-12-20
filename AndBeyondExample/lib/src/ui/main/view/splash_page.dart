import 'dart:async';

import 'package:andbeyondexample/src/ui/base/view/base_page.dart';
import 'package:flutter/material.dart';

import '../../../appvalues/app_routes.dart';
import '../../../appvalues/app_theme.dart';

class SplashPage extends BasePageScreen {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends BasePageScreenState<SplashPage> with BaseScreen {

  late Timer timer;

  @override
  void initState() {
    startTimer();
  }

  @override
  Widget body() {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: AppTheme.appThemeColor,
        child: const Center(child: Text("ABM SDK Example", style: TextStyle(color: Colors.white))),
      ),
    );
  }

  startTimer() async {
    var timerSeconds = 2;
    timer = Timer(Duration(seconds: timerSeconds), navigate);
  }

  void navigate() async {
    timer.cancel();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
  }
}
