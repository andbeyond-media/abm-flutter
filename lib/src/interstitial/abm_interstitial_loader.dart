import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../common/ad_request.dart';
import '../common/constants.dart';
import 'interstitial_ad_manager.dart';

class ABMInterstitialLoader {
  final String adUnit;
  final AdLoadRequest request;
  final Function(ABMInterstitialLoader) adLoadListener;
  final Function(LoadAdError?) adFailedListener;
  AdManagerInterstitialAd? _ad;
  late InterstitialAdManager _interstitialAdManager;

  ABMInterstitialLoader(
      this.adUnit, this.request, this.adLoadListener, this.adFailedListener) {
    _init();
  }

  void _init() {
    _interstitialAdManager = InterstitialAdManager(
        (AdStatus event, AdManagerInterstitialAd? ad, LoadAdError? err) {
      switch (event) {
        case AdStatus.loaded:
          {
            _ad = ad;
            adLoadListener(this);
          }
          break;
        case AdStatus.failed:
          {
            adFailedListener(err);
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
    _interstitialAdManager.setDetails(adUnit, request);
  }

  void load() {
    _interstitialAdManager.startLoadingAd();
  }

  void show() {
    _ad?.show();
  }

  void addFullScreenContentCallback(
      FullScreenContentCallback<AdManagerInterstitialAd>?
          fullScreenContentCallback) {
    _ad?.fullScreenContentCallback = fullScreenContentCallback;
  }
}
