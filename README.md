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

Add `andbeyondmedia` and `google_mobile_ads` to your `pubspec.yaml` file:

```yaml 
dependencies:
  andbeyondmedia: latest
  google_mobile_ads: latest
  ```

## Usage

### Main function

Initialize Andbeyondmedia SDK by providing app's package name

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AndBeyondMedia.instance.initialize("com.example.app", true);
  runApp(const MyApp());
}
```

### Banner Ad

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

### Interstitial ad

Loading an interstitial ad

```dart
 void loadInterstitialAd() async {
  ABMInterstitialLoader(interstitialAdUnit, AdLoadRequest().build(),
          (ABMInterstitialLoader ad) {
        debugPrint("pub: interstitial ad loaded");
        interstitialLoader = ad;
      }, (err) {
        debugPrint("pub: interstitial ad failed : $err");
      }).load();
}
```

Showing interstitial ad

```dart
  interstitialLoader?.show()
```