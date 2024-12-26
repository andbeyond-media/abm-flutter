import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../banners/banner_ad_view.dart';

class AdListener {
  final Function(BannerAdView)? onAdLoaded;
  final Function(BannerAdView)? onAdOpened;
  final Function(BannerAdView)? onAdWillDismissScreen;
  final Function(BannerAdView)? onAdClosed;
  final Function(BannerAdView)? onAdImpression;
  final Function(BannerAdView)? onAdClicked;
  final Function(BannerAdView, LoadAdError?)? onAdFailedToLoad;

  AdListener(
      {this.onAdLoaded,
      this.onAdOpened,
      this.onAdWillDismissScreen,
      this.onAdClosed,
      this.onAdImpression,
      this.onAdClicked,
      this.onAdFailedToLoad});
}
