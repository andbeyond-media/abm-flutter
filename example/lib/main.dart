import 'package:flutter/material.dart';
import 'package:andbeyondmedia/andbeyondmedia.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AndBeyondMedia.instance.initialize("com.rtb.andbeyondtest", true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Andbeyondmedia SDK Example',
        theme: ThemeData.dark(),
        initialRoute: '/',
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAdView? _bannerAd;
  ABMInterstitialLoader? interstitialLoader;
  final adUnitId = '/6499/example/banner';
  final interstitialAdUnit = '/21775744923/example/interstitial';

  @override
  void initState() {
    super.initState();
    loadAd();
    loadInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
                child: const Text("Show interstitial"),
                onPressed: () {
                  interstitialLoader?.show();
                }),
            const SizedBox(height: 200),
            Container(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 50,
                  width: 320,
                  child: getChild(),
                ),
              ),
            ),
          ],
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

  void loadInterstitialAd() async {
    ABMInterstitialLoader(interstitialAdUnit, AdLoadRequest().build(),
        (ABMInterstitialLoader ad) {
      debugPrint("pub: interstitial ad loaded");
      interstitialLoader = ad;
    }, (err) {
      debugPrint("pub: interstitial ad failed : $err");
    }).load();
  }
}
