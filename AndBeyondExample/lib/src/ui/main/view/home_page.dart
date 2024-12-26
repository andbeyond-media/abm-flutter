import 'package:andbeyondexample/src/ui/base/view/base_page.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:andbeyondmedia/src/banners/banner_ad_view.dart';
import 'package:andbeyondmedia/src/common/ad_request.dart';
import 'package:andbeyondmedia/src/common/ad_listeners.dart';

class HomePage extends BasePageScreen {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends BasePageScreenState<HomePage> with BaseScreen {
  BannerAdView? _bannerAd;
  bool _isLoaded = false;

  final adUnitId = '/6499/example/banner';

  @override
  void initState() {
    super.initState();
    loadAd();
  }

  @override
  Widget body() {
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
