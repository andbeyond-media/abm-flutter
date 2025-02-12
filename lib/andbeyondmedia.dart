library andbeyondmedia;

import 'dart:async';
import 'dart:math';

import 'package:andbeyondmedia/src/interstitial/interstitial_config.dart';
import 'package:andbeyondmedia/src/interstitial/silent_interstitial.dart';
import 'package:andbeyondmedia/src/sdk/config_provider.dart';
import 'package:andbeyondmedia/src/sdk/logger.dart';
import 'package:andbeyondmedia/src/sdk/network_manager.dart';
import 'package:andbeyondmedia/src/sdk/sdk_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

export 'src/banners/banner_ad_view.dart';
export 'src/common/ad_listeners.dart';
export 'src/common/ad_request.dart';
export 'src/common/constants.dart';
export 'src/interstitial/abm_interstitial_loader.dart';

///Main class to start the SDK
class AndBeyondMedia {
  AndBeyondMedia._();

  static final AndBeyondMedia _instance = AndBeyondMedia._().._init();

  ///Creating static instance
  static AndBeyondMedia get instance => _instance;

  ///Managing if the logger should be enabled or not
  var logEnabled = false;

  ///Will help the package publisher
  String? specialTag = "";
  final _networkManager = NetworkManager.instance;

  ///Managing silent interstitial
  SilentInterstitial? silentInterstitial;

  ///Controller to push config fetch events
  final controller = StreamController<int>.broadcast();

  ///Controller to push geo information fetch events
  final countryInfoController = StreamController<int>.broadcast();

  ///Used to check the config fetch status
  int lastConfigStatus = 0;

  ///Used to check the geo info fetch status
  int lastCountryInfoStatus = 0;
  late StreamSubscription<int> _configSub;
  late StreamSubscription<int> _countryInfoSub;

  void _init() {
    controller.add(0);
    countryInfoController.add(0);
  }

  ///Method to initialize the SDK
  initialize(String packageName, [bool enableLog = false]) {
    log("ABM Version ${getLibVersion()} initialized.");
    _keepCheckOfConfig();
    logEnabled = enableLog;
    _networkManager.register();
    ConfigProvider.instance.savePackageName(packageName);
    ConfigProvider.instance.fetchConfig();
  }

  void _keepCheckOfConfig() {
    _configSub = controller.stream.listen((status) {
      lastConfigStatus = status;
      if (status == 2) {
        _configSub.cancel();
      }
    });
    _countryInfoSub = countryInfoController.stream.listen((status) {
      lastCountryInfoStatus = status;
      if (status == 2) {
        _countryInfoSub.cancel();
      }
    });
  }

  ///Method which will be called after config is fetched
  configFetched(SdkConfig? config) {
    specialTag = config?.infoConfig?.specialTag;
    logEnabled = (logEnabled || config?.infoConfig?.normalInfo == 1);
    MobileAds.instance.initialize().then((_) {
      controller.add(2);
    });
  }

  void geoDetected(CountryModel? countryConfig,
      SilentInterstitialConfig? silentInterstitialConfig) {
    silentInterstitial ??= SilentInterstitial();

    if (silentInterstitialConfig == null) {
      silentInterstitial?.destroy();
      return;
    }

    bool shouldStart;
    final regionConfig = silentInterstitialConfig.regions;
    if (regionConfig == null ||
        (regionConfig.getCities().isEmpty &&
            regionConfig.getStates().isEmpty &&
            regionConfig.getCountries().isEmpty)) {
      shouldStart = true;
    } else {
      if ((regionConfig.mode ?? "allow").toLowerCase().contains("allow")) {
        shouldStart = regionConfig.getCities().any((city) =>
                city.toLowerCase() ==
                (countryConfig?.city ?? "").toLowerCase()) ||
            regionConfig.getStates().any((state) =>
                state.toLowerCase() ==
                (countryConfig?.state ?? "").toLowerCase()) ||
            regionConfig.getCountries().any((country) =>
                country.toLowerCase() ==
                (countryConfig?.countryCode ?? "").toLowerCase());
      } else {
        shouldStart = !regionConfig.getCities().any((city) =>
                city.toLowerCase() ==
                (countryConfig?.city ?? "").toLowerCase()) &&
            !regionConfig.getStates().any((state) =>
                state.toLowerCase() ==
                (countryConfig?.state ?? "").toLowerCase()) &&
            !regionConfig.getCountries().any((country) =>
                country.toLowerCase() ==
                (countryConfig?.countryCode ?? "").toLowerCase());
      }
    }

    final number = Random().nextInt(100) + 1;
    if (shouldStart && number <= (silentInterstitialConfig.active ?? 0)) {
      silentInterstitial?.init();
    }
  }

  ///Method to provide the SDK version
  String getLibVersion() {
    return "0.0.6";
  }

  ///Method to check connectivity status
  bool connectionAvailable() {
    return _networkManager.isInternetAvailable();
  }
}
