import 'dart:async';
import 'dart:math';

import 'package:andbeyondmedia/andbeyondmedia.dart';
import 'package:andbeyondmedia/src/sdk/logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:collection/collection.dart';
import '../sdk/config_provider.dart';
import '../sdk/sdk_config.dart';
import 'interstitial_config.dart';

typedef EventCallBack = void Function(
    AdStatus status, AdManagerInterstitialAd? ad, LoadAdError? error);

class InterstitialAdManager {
  late String pubAdUnit;
  late AdLoadRequest pubAdRequest;

  final EventCallBack _eventCallBack;
  late StreamSubscription<int> _countryInfoSubscription;
  late StreamSubscription<int> _subscription;

  SdkConfig? _sdkConfig;
  var _shouldBeActive = false;
  CountryModel? _countryInfo;
  final _interstitialConfig = InterstitialConfig();

  InterstitialAdManager(this._eventCallBack) {
    init();
  }

  init() {
    _sdkConfig = ConfigProvider.instance.getConfig();
    _shouldBeActive = _sdkConfig != null && _sdkConfig?.global == 1;
    _getCountryInfo();
  }

  _getCountryInfo() {
    if (AndBeyondMedia.instance.lastCountryInfoStatus == 2) {
      _countryInfo = ConfigProvider.instance.getCountryInfo();
    } else {
      _countryInfoSubscription =
          AndBeyondMedia.instance.countryInfoController.stream.listen((data) {
        if (data == 2) {
          _countryInfoSubscription.cancel();
          _countryInfo = ConfigProvider.instance.getCountryInfo();
        }
      });
    }
  }

  void setDetails(
    String pubAdUnit,
    AdLoadRequest pubAdRequest,
  ) {
    this.pubAdUnit = pubAdUnit;
    this.pubAdRequest = pubAdRequest;
  }

  shouldBeActive() => _shouldBeActive;

  String getTag() => "Inter~$pubAdUnit";

  void startLoadingAd() {
    _shouldSetConfig();
  }

  void _loadVanilla() {
    _loadAd(pubAdUnit, pubAdRequest, null);
  }

  void _shouldSetConfig() {
    if (AndBeyondMedia.instance.lastConfigStatus == 2) {
      _sdkConfig = ConfigProvider.instance.getConfig();
      _shouldBeActive = _sdkConfig != null && _sdkConfig?.global == 1;
      _setConfig();
    } else {
      _subscription = AndBeyondMedia.instance.controller.stream.listen((data) {
        if (data == 2) {
          _subscription.cancel();
          _sdkConfig = ConfigProvider.instance.getConfig();
          _shouldBeActive = _sdkConfig != null && _sdkConfig?.global == 1;
          _setConfig();
        }
      });
    }
  }

  void _setConfig() {
    getTag().log(() =>
        "setConfig:entry- Version:${AndBeyondMedia.instance.getLibVersion()}");

    if (!shouldBeActive()) {
      _loadVanilla();
      return;
    }

    if (_sdkConfig?.getBlockList().any(
            (item) => pubAdUnit.toLowerCase().contains(item.toLowerCase())) ==
        true) {
      _shouldBeActive = false;
      getTag().log(() => "Complete shutdown due to block");
      _loadVanilla();
      return;
    }
    RefreshConfig? validConfig = _sdkConfig?.refreshConfig?.firstWhereOrNull(
        (config) =>
            (config.specific?.toLowerCase() == pubAdUnit.toLowerCase()) ||
            (config.type == AdTypes.INTERSTITIAL) ||
            (config.type?.toLowerCase() == 'all'));

    if (validConfig == null) {
      _shouldBeActive = false;
      getTag().log(() => "There is no valid config");
      _loadVanilla();
      return;
    }

    _interstitialConfig
      ..customUnitName =
          "/${getNetworkName()}/${_sdkConfig?.affiliatedId.toString()}-"
              "${validConfig.nameType ?? ""}"
      ..isNewUnit = pubAdUnit
          .toLowerCase()
          .contains(_sdkConfig?.networkId?.toLowerCase() ?? "")
      ..position = validConfig.position ?? 0
      ..retryConfig = getRetryConfig()
      ..newUnit = _sdkConfig?.hijackConfig?.newUnit
      ..hijack =
          _sdkConfig?.hijackConfig?.inter ?? _sdkConfig?.hijackConfig?.other
      ..unFilled =
          _sdkConfig?.unfilledConfig?.inter ?? _sdkConfig?.unfilledConfig?.other
      ..placement = validConfig.placement
      ..format = validConfig.format;
    getTag().log(() => "setConfig :${_interstitialConfig.toJson()}");
    _checkOverride();
  }

  void _checkOverride() {
    if (_interstitialConfig.isNewUnitApplied()) {
      getTag().log(() => "checkOverride on $pubAdUnit, status : new unit");
      _loadAd(_getAdUnitName(false, false, true),
          _createAdRequest(newUnit: true), null);
    } else if (_checkHijack(_interstitialConfig.hijack)) {
      getTag().log(() => "checkOverride on $pubAdUnit, status : hijack");
      _loadAd(_getAdUnitName(false, false, true),
          _createAdRequest(hijacked: true), null);
    } else {
      _loadVanilla();
    }
  }

  void _loadAd(String adUnit, AdLoadRequest adRequest,
      LoadAdError? previousError) async {
    getTag().log(() =>
        "Requesting ad with unit :$adUnit & with key values : ${adRequest.getAdRequest().customTargeting}");
    AdManagerInterstitialAd.load(
        adUnitId: adUnit,
        request: adRequest.getAdRequest(),
        adLoadCallback: AdManagerInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            getTag().log(() => "Ad loaded with unit : ${ad.adUnitId}");
            _eventCallBack(AdStatus.loaded, ad, null);
          },
          onAdFailedToLoad: (LoadAdError error) {
            getTag().log(() => "Adunit $adUnit Failed with error : $error");
            _adFailedToLoad(
                error,
                adUnit != pubAdUnit || _interstitialConfig.isNewUnitApplied(),
                previousError ?? error);
          },
        ));
  }

  void _adFailedToLoad(
      LoadAdError error, bool abmLoad, LoadAdError previousError) {
    getTag().log(() =>
        "Failed with Unfilled Config: ${_interstitialConfig.unFilled?.toJson()} && Retry config :${_interstitialConfig.retryConfig?.toJson()} & isAbm load : $abmLoad");
    if (shouldBeActive()) {
      if (abmLoad) {
        var retryUnit = _interstitialConfig.retryConfig?.adUnits?.firstOrNull;
        if ((_interstitialConfig.retryConfig?.retries ?? 0) > 0 &&
            retryUnit != null) {
          var delaySeconds =
              (_interstitialConfig.retryConfig?.retryInterval ?? 0).toInt();
          _interstitialConfig.retryConfig?.retries =
              (_interstitialConfig.retryConfig?.retries ?? 0) - 1;
          _interstitialConfig.retryConfig?.adUnits?.removeAt(0);
          _loadAdWithDelay(delaySeconds, retryUnit, error);
        } else {
          _eventCallBack(AdStatus.failed, null, error);
        }
      } else {
        if (_interstitialConfig.unFilled?.status == 1) {
          _loadAd(_getAdUnitName(true, false, false),
              _createAdRequest(unfilled: true), previousError);
        } else {
          _eventCallBack(AdStatus.failed, null, error);
        }
      }
    } else {
      _eventCallBack(AdStatus.failed, null, error);
    }
  }

  void _loadAdWithDelay(
      int delaySeconds, String retryUnit, LoadAdError previousError) {
    Timer(Duration(seconds: delaySeconds), () {
      _loadAd(retryUnit, _createAdRequest(unfilled: true), previousError);
    });
  }
}

extension InterstitialUtils on InterstitialAdManager {
  String? getNetworkName() {
    if (_sdkConfig?.networkCode?.isEmpty ?? true) {
      return _sdkConfig?.networkId;
    } else {
      return '${_sdkConfig?.networkId},${_sdkConfig?.networkCode}';
    }
  }

  String _getAdUnitName(bool unfilled, bool hijacked, bool newUnit) {
    num? position = 1;
    if (unfilled) {
      position = _interstitialConfig.unFilled?.number;
    } else if (newUnit) {
      position = _interstitialConfig.newUnit?.number;
    } else if (hijacked) {
      position = _interstitialConfig.hijack?.number;
    } else {
      position = _interstitialConfig.position;
    }
    position = position ?? 1;
    return "${_interstitialConfig.customUnitName}-$position";
  }

  RetryConfig getRetryConfig() {
    var retryConfig = RetryConfig();
    retryConfig
      ..retries = _sdkConfig?.retryConfig?.retries
      ..retryInterval = _sdkConfig?.retryConfig?.retryInterval
      ..adUnits = <String>[...(_sdkConfig?.retryConfig?.adUnits ?? [])];
    return retryConfig;
  }

  AdLoadRequest _createAdRequest(
      {bool unfilled = false, bool hijacked = false, bool newUnit = false}) {
    var keyValues = {
      "adunit": pubAdUnit,
      "hb_format": _sdkConfig?.hbFormat ?? "amp",
      "sdk_version": AndBeyondMedia.instance.getLibVersion()
    };
    if (unfilled) {
      keyValues["retry"] = "1";
    }
    if (hijacked) {
      keyValues["hijack"] = "1";
    }
    if (newUnit) {
      keyValues["new_unit"] = "1";
    }
    return AdLoadRequest().build(customTargeting: keyValues);
  }

  bool _checkHijack(LoadConfig? hijackConfig) {
    if (hijackConfig?.regionWise == 1) {
      if (_countryInfo == null) {
        return false;
      } else {
        if (hijackConfig?.status == 1) {
          final number = Random().nextInt(100) + 1;
          return number >= 1 && number <= getRegionalHijackPercentage();
        } else {
          return false;
        }
      }
    } else {
      if (hijackConfig?.status == 1) {
        final number = Random().nextInt(100) + 1;
        return number >= 1 && number <= (hijackConfig?.per ?? 0);
      } else {
        return false;
      }
    }
  }

  int getRegionalHijackPercentage() {
    var percentage = 0;
    if (_sdkConfig?.countryStatus?.active == 1 && _countryInfo != null) {
      final region = _interstitialConfig.hijack?.regionalPercentage
          ?.firstWhereOrNull((region) =>
              (region.getCities().any((it) =>
                      it.toLowerCase() == _countryInfo?.city?.toLowerCase()) ==
                  true) ||
              (region.getStates().any((it) =>
                      it.toLowerCase() == _countryInfo?.state?.toLowerCase()) ==
                  true) ||
              (region.getCountries().any((it) =>
                      it.toLowerCase() ==
                      _countryInfo?.countryCode?.toLowerCase()) ==
                  true) ||
              (region
                      .getCountries()
                      .any((it) => it.toLowerCase() == 'default') ==
                  true));

      if (region != null) {
        percentage = region.percentage ?? 0;
      }
    }
    return percentage;
  }
}
