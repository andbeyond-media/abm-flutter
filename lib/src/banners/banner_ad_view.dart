import 'dart:async';

import 'package:andbeyondmedia/src/common/ad_listeners.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../common/ad_request.dart';
import '../common/constants.dart';
import 'banner_ad_manager.dart';

class BannerAdLoader {
  final String adUnit;
  final AdLoadRequest request;
  final List<AdSize> sizes;
  final AdListener adListener;
  late BannerAdView bannerAdView;
  late BannerAdManager _bannerAdManager;
  String section = "";
  String adType = AdTypes.BANNER;

  BannerAdLoader(
      {required this.adUnit,
      required this.request,
      required this.sizes,
      required this.adListener,
      this.section = "",
      this.adType = AdTypes.BANNER})
      : assert(sizes.isNotEmpty) {
    _init();
  }

  void _init() {
    _bannerAdManager = BannerAdManager((AdStatus event, LoadAdError? err) {
      switch (event) {
        case AdStatus.loaded:
          {
            adListener.onAdLoaded?.call(bannerAdView);
          }
          break;
        case AdStatus.failed:
          {
            adListener.onAdFailedToLoad?.call(bannerAdView, err);
          }
          break;
        case AdStatus.impressed:
          adListener.onAdImpression?.call(bannerAdView);
          break;
        case AdStatus.clicked:
          adListener.onAdClicked?.call(bannerAdView);
          break;
        case AdStatus.opened:
          adListener.onAdOpened?.call(bannerAdView);
          break;
        case AdStatus.closed:
          adListener.onAdClosed?.call(bannerAdView);
          break;
        case AdStatus.dismiss:
          adListener.onAdWillDismissScreen?.call(bannerAdView);
          break;
      }
    });
    _bannerAdManager.setDetails(adUnit, request, sizes, section, adType);
  }

  BannerAdView loadAd() {
    bannerAdView = BannerAdView(bannerManager: _bannerAdManager);
    _bannerAdManager.startLoadingAd();
    return bannerAdView;
  }
}

class BannerAdView extends StatefulWidget {
  final BannerAdManager bannerManager;

  const BannerAdView({super.key, required this.bannerManager});

  @override
  State<BannerAdView> createState() => _BannerAdViewState();
}

class _BannerAdViewState extends State<BannerAdView>
    with WidgetsBindingObserver {
  AdManagerBannerAd? _bannerAd;
  Widget? _fallbackAd;
  late StreamSubscription<AdManagerBannerAd?> _adSubscription;
  late StreamSubscription<Widget?> _fallbackAdSubscription;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _startObservingAds();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.bannerManager.adDestroyed();
    _bannerAd?.dispose();
    _adSubscription.cancel();
    _fallbackAdSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: const Key('my-widget-key'),
        onVisibilityChanged: (visibilityInfo) {
          var visiblePercentage = visibilityInfo.visibleFraction * 100;
          widget.bannerManager.setVisibility(visiblePercentage);
        },
        child: getAdWidget());
  }

  Widget getAdWidget() {
    if (_bannerAd != null) {
      return AdWidget(key: ValueKey(_bannerAd), ad: _bannerAd!);
    } else if (_fallbackAd != null) {
      return _fallbackAd!;
    } else {
      return Container();
    }
  }

  void _startObservingAds() {
    _adSubscription = widget.bannerManager.adController.stream.listen((ad) {
      setState(() {
        _fallbackAd = null;
        _bannerAd = ad;
      });
    });
    _fallbackAdSubscription =
        widget.bannerManager.fallbackAdController.stream.listen((ad) {
      setState(() {
        _fallbackAd = ad;
        _bannerAd = null;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.bannerManager.adResumed();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      widget.bannerManager.adPaused();
    }
  }
}
