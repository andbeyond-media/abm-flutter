import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../appvalues/app_theme.dart';

abstract class BasePageScreen extends StatefulWidget {
  const BasePageScreen({super.key});
}

abstract class BasePageScreenState<Page extends BasePageScreen>
    extends State<Page> {}

mixin BaseScreen<Page extends BasePageScreen> on BasePageScreenState<Page> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        body(),
        Visibility(
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible: false,
          child: Container(
            alignment: Alignment.center,
            color: Colors.white.withOpacity(0.5),
            height: double.infinity,
            width: double.infinity,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
              child: const CircularProgressIndicator(
                color: AppTheme.appThemeButtonColor,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget body();

  @override
  void dispose() {
    super.dispose();
  }
}
