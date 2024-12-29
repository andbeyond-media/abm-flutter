
import 'package:flutter/material.dart';
import 'package:andbeyondmedia/andbeyondmedia.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  AndBeyondMedia.instance.initialize("com.rtb.andbeyondtest", true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fancy Dialog Example',
        theme: ThemeData.dark(),
        initialRoute: '/',
        home: HomePage());
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
