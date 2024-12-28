<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->


`andbeyondmedia` is a powerful Flutter package built on Google Ad Manager, providing enhanced ad
functionalities for your applications. This package simplifies ad integration and offers additional
features such as automatic ad refresh and efficient management of unfilled ad spaces.

## Features

- **Built on Google Ad Manager**: Seamlessly integrate ads into your app using Google Ad Manager's
  robust platform.
- **Ad Refresh**: Automatically refresh ads at specified intervals to keep content fresh and
  engaging.
- **Unfilled Ad Management**: Efficiently handle unfilled ad spaces to ensure a smooth

## Getting started

Add `andbeyondmedia` to your `pubspec.yaml` file:

```yaml 
dependencies:
    andbeyondmedia: ^1.0.0
  ```

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart

void loadAd() async {
  BannerAdLoader(adUnit: adUnitId,
      request: AdLoadRequest().build(),
      sizes: [const AdSize(width: 320, height: 50)],
      adListener: AdListener(onAdLoaded: (ad) {
        debugPrint("pub: banner ad loaded");
        setState(() {
          _bannerAd = ad;
        });
      }, onAdFailedToLoad: (ad, err) {
        debugPrint("pub: banner ad failed : $err");
      }),
      section: "ad_details").loadAd();
}
```

## Full Example

```dart
import 'package:flutter/material.dart';
import 'package:andbeyondmedia/andbeyondmedia.dart';

class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAdView? _bannerAd;
  bool _isLoaded = false;
  final adUnitId = '/6499/example/banner';

  @override
  void initState() {
    super.initState();
    loadAd();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 50,
              width: 320,
              child: getChild(),
            ),
          ),
        ),
      ),
    );
  }

  Widget getChild() {
    if (_bannerAd == null) {
      return Container();
    } else {
      return SizedBox(width: 320, height: 50, child: _bannerAd);
    }
  }

  void loadAd() async {
    BannerAdLoader(
            adUnit: adUnitId,
            request: AdLoadRequest().build(),
            sizes: [const AdSize(width: 320, height: 50)],
            adListener: AdListener(onAdLoaded: (ad) {
              debugPrint("pub: banner ad loaded");
              setState(() {
                _bannerAd = ad;
              });
            }, onAdFailedToLoad: (ad, err) {
              debugPrint("pub: banner ad failed : $err");
            }),
            section: "ad_details")
        .loadAd();
  }
}

```

