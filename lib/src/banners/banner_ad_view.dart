import 'dart:async';

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
  final Function(BannerAdView) adLoadListener;
  final Function(BannerAdView, LoadAdError?) adFailedListener;
  late BannerAdView bannerAdView;
  late BannerAdManager _bannerAdManager;

  BannerAdLoader(this.adUnit, this.request, this.sizes, this.adLoadListener,
      this.adFailedListener) {
    _init();
  }

  void _init() {
    _bannerAdManager = BannerAdManager((AdStatus event, LoadAdError? err) {
      switch (event) {
        case AdStatus.loaded:
          {
            adLoadListener(bannerAdView);
          }
          break;
        case AdStatus.failed:
          {
            adFailedListener(bannerAdView, err);
          }
          break;
        case AdStatus.impressed:
          break;
        case AdStatus.clicked:
          break;
        case AdStatus.opened:
          break;
        case AdStatus.closed:
          break;
        case AdStatus.dismiss:
          break;
      }
    });
    _bannerAdManager.setDetails(adUnit, request, sizes);
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
