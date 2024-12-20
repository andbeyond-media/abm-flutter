import 'dart:async';
import 'dart:math';

import 'package:andbeyondmedia/src/common/extensions.dart';
import 'package:andbeyondmedia/src/sdk/Logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../andbeyondmedia.dart';
import '../common/ad_request.dart';
import '../common/constants.dart';
import '../sdk/ConfigProvider.dart';
import '../sdk/SDKConfig.dart';
import '../widgets/countdown_timer.dart';
import 'banner_config.dart';

typedef EventCallBack = void Function(AdStatus status, LoadAdError? error);

class BannerAdManager {
  late String pubAdUnit;
  late AdLoadRequest pubAdRequest;
  late List<AdSize> pubAdSizes;
  String section = "";

  final EventCallBack _eventCallBack;
  AdManagerBannerAd? _bannerAdHolder;
  AdManagerBannerAd? _oldBannerAdHolder;
  late StreamSubscription<int> _subscription;
  late StreamSubscription<int> _countryInfoSubscription;
  final StreamController<AdManagerBannerAd?> adController =
      StreamController<AdManagerBannerAd?>();
  final StreamController<Widget?> fallbackAdController =
      StreamController<Widget?>();

  var _isForegroundRefresh = 1;
  CountdownTimer? _activeTimeCounter;
  CountdownTimer? _passiveTimeCounter;
  CountdownTimer? _unfilledRefreshCounter;
  SdkConfig? _sdkConfig;
  var _shouldBeActive = false;
  final _bannerConfig = BannerConfig();
  bool _pendingImpression = false;
  bool _refreshBlocked = false;
  bool _wasFirstLook = true;
  CountryModel? _countryInfo;

  BannerAdManager(this._eventCallBack) {
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
      String pubAdUnit, AdLoadRequest pubAdRequest, List<AdSize> pubAdSizes) {
    this.pubAdUnit = pubAdUnit;
    this.pubAdRequest = pubAdRequest;
    this.pubAdSizes = pubAdSizes;
  }

  shouldBeActive() => _shouldBeActive;

  void startLoadingAd() {
    _shouldSetConfig();
  }

  void _loadVanilla() {
    _loadAd(pubAdUnit, pubAdRequest, pubAdSizes, true);
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
    pubAdUnit.log(
        () => "setConfig:entry- Version:${AndBeyondMedia.instance.getLibVersion()}");
    if (!shouldBeActive()) {
      _loadVanilla();
      return;
    }

    if (_sdkConfig?.getBlockList().any(
            (item) => pubAdUnit.toLowerCase().contains(item.toLowerCase())) ==
        true) {
      _shouldBeActive = false;
      pubAdUnit.log(() => "Complete shutdown due to block");
      _loadVanilla();
      return;
    }

    RefreshConfig? validConfig = _sdkConfig?.refreshConfig?.firstWhereOrNull(
        (config) =>
            (config.specific?.toLowerCase() == pubAdUnit.toLowerCase()) ||
            (config.type == AdTypes.BANNER) ||
            (config.type?.toLowerCase() == 'all'));

    if (validConfig == null) {
      _shouldBeActive = false;
      pubAdUnit.log(() => "There is no valid config");
      _loadVanilla();
      return;
    }

    _bannerConfig
      ..instantRefresh = _sdkConfig?.instantRefresh
      ..customUnitName =
          "/${getNetworkName()}/${_sdkConfig?.affiliatedId.toString()}-"
              "${getUnitNameType(validConfig.nameType ?? "", _sdkConfig?.supportedSizes, pubAdSizes)}"
      ..isNewUnit = pubAdUnit
          .toLowerCase()
          .contains(_sdkConfig?.networkId?.toLowerCase() ?? "")
      ..publisherAdUnit = pubAdUnit
      ..position = validConfig.position ?? 0
      ..placement = validConfig.placement
      ..newUnit = _sdkConfig?.hijackConfig?.newUnit
      ..retryConfig = getRetryConfig()
      ..hijack = getValidLoadConfig(AdTypes.BANNER, true,
          _sdkConfig?.hijackConfig, _sdkConfig?.unfilledConfig)
      ..unFilled = getValidLoadConfig(AdTypes.BANNER, false,
          _sdkConfig?.hijackConfig, _sdkConfig?.unfilledConfig)
      ..difference = _sdkConfig?.difference ?? 0
      ..activeRefreshInterval = _sdkConfig?.activeRefreshInterval ?? 0
      ..passiveRefreshInterval = _sdkConfig?.passiveRefreshInterval ?? 0
      ..factor = _sdkConfig?.factor ?? 1
      ..visibleFactor = _sdkConfig?.visibleFactor ?? 1
      ..minView = _sdkConfig?.minView ?? 0
      ..minViewRtb = _sdkConfig?.minViewRtb ?? 0
      ..format = validConfig.format
      ..fallback = _sdkConfig?.fallback
      ..geoEdge = _sdkConfig?.geoEdge
      ..nativeFallback = _sdkConfig?.nativeFallback;
    if (validConfig.follow == 1 &&
        validConfig.sizes != null &&
        validConfig.sizes?.isNotEmpty == true) {
      _bannerConfig.adSizes = getCustomSizes(pubAdSizes, validConfig.sizes);
    } else {
      _bannerConfig.adSizes = pubAdSizes;
    }
    pubAdUnit.log(() => "setConfig :${_bannerConfig.toJson()}");
    _checkOverride();
  }

  void _checkOverride() {
    if (_bannerConfig.isNewUnitApplied()) {
      pubAdUnit.log(() =>
          "checkOverride on ${_bannerConfig.publisherAdUnit}, status : new unit");
      if (_ifNativePossible() &&
          !_bannerConfig.adSizes.contains(AdSize.fluid)) {
        _bannerConfig.adSizes.add(AdSize.fluid);
      }
      _loadAd(_getAdUnitName(false, false, true),
          _createAdRequest(1, newUnit: true), _bannerConfig.adSizes, true);
    } else if (_checkHijack(_bannerConfig.hijack)) {
      pubAdUnit.log(() =>
          "checkOverride on ${_bannerConfig.publisherAdUnit}, status : hijack");
      if (_ifNativePossible() &&
          !_bannerConfig.adSizes.contains(AdSize.fluid)) {
        _bannerConfig.adSizes.add(AdSize.fluid);
      }
      _loadAd(_getAdUnitName(false, false, true),
          _createAdRequest(1, hijacked: true), _bannerConfig.adSizes, true);
    } else {
      _loadVanilla();
    }
  }

  void _loadAd(String adUnit, AdLoadRequest adRequest, List<AdSize> adSizes,
      bool firstLook) async {
    pubAdUnit.log(() =>
        "Requesting ad with unit :$adUnit & with key values : ${adRequest.getAdRequest().customTargeting}");

    _bannerAdHolder = AdManagerBannerAd(
      adUnitId: adUnit,
      request: adRequest.getAdRequest(),
      sizes: adSizes,
      listener: AdManagerBannerAdListener(onAdLoaded: (ad) {
        pubAdUnit.log(() => "Ad loaded with unit : ${ad.adUnitId}");
        _oldBannerAdHolder?.dispose();
        adController.add(_bannerAdHolder);
        _oldBannerAdHolder = _bannerAdHolder;
        _pendingImpression = true;
        _saveRefreshTime();
        _sendEventToPub(ad, AdStatus.loaded, firstLook);
        _adLoaded(
            firstLook, ad.adUnitId, ad.responseInfo?.loadedAdapterResponseInfo);
      }, onAdImpression: (ad) {
        _pendingImpression = false;
        _saveRefreshTime();
        _sendEventToPub(ad, AdStatus.impressed, firstLook);
      }, onAdFailedToLoad: (ad, err) {
        pubAdUnit.log(() => "Adunit $adUnit Failed with error : $err");
        _adFailedToLoad(adUnit, firstLook,
            adUnit != pubAdUnit || _bannerConfig.isNewUnitApplied());
      }, onAdClicked: (ad) {
        _sendEventToPub(ad, AdStatus.clicked, firstLook);
      }, onAdClosed: (ad) {
        _sendEventToPub(ad, AdStatus.closed, firstLook);
      }, onAdOpened: (ad) {
        _sendEventToPub(ad, AdStatus.opened, firstLook);
      }, onAdWillDismissScreen: (ad) {
        _sendEventToPub(ad, AdStatus.dismiss, firstLook);
      }),
    )..load();
  }

  void _saveRefreshTime() {
    final currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
    _bannerConfig.lastRefreshAt = currentTimeStamp;
  }

  void _adLoaded(
      bool firstLook, String loadedAdUnit, AdapterResponseInfo? loadedAdapter) {
    if (!shouldBeActive() || _refreshBlocked) {
      pubAdUnit.log(() =>
          'Not eligible for refresh bcz should active :${shouldBeActive()} && refresh blocked : $_refreshBlocked');
      return;
    }
    _bannerConfig.retryConfig = getRetryConfig();
    _unfilledRefreshCounter?.cancel();
    final blockedTerms =
        (_sdkConfig?.networkBlock?.replaceAll(' ', '').split(',') ?? []);
    var isNetworkBlocked = false;
    for (final term in blockedTerms) {
      if (term.isNotEmpty &&
          loadedAdapter?.adapterClassName
                  .toLowerCase()
                  .contains(term.toLowerCase()) ==
              true) {
        isNetworkBlocked = true;
        break;
      }
    }

    if (!isNetworkBlocked &&
        !isRegionBlocked() &&
        !(loadedAdapter?.adSourceId != null &&
            loadedAdapter?.adSourceId.isNotEmpty == true &&
            blockedTerms.contains(loadedAdapter?.adSourceId)) &&
        !(loadedAdapter?.adSourceName != null &&
            loadedAdapter?.adSourceName.isNotEmpty == true &&
            blockedTerms.contains(loadedAdapter?.adSourceName)) &&
        !(loadedAdapter?.adSourceInstanceId != null &&
            loadedAdapter?.adSourceInstanceId.isNotEmpty == true &&
            blockedTerms.contains(loadedAdapter?.adSourceInstanceId)) &&
        !(loadedAdapter?.adSourceInstanceName != null &&
            loadedAdapter?.adSourceInstanceName.isNotEmpty == true &&
            blockedTerms.contains(loadedAdapter?.adSourceInstanceName)) &&
        !ifUnitOnHold(loadedAdUnit) &&
        !ifUnitOnRegionalHold(loadedAdUnit) &&
        !ifSectionOnRegionalHold(section)) {
      _startRefreshing(resetVisibleTime: true, isPublisherLoad: firstLook);
    } else {
      _refreshBlocked = true;
      pubAdUnit.log(() => 'Refresh blocked');
      _passiveTimeCounter?.cancel();
      _activeTimeCounter?.cancel();
    }
  }

  void _startRefreshing(
      {bool resetVisibleTime = false,
      bool isPublisherLoad = false,
      int? timers}) {
    pubAdUnit.log(() =>
        'startRefreshing: resetVisibleTime: $resetVisibleTime isPublisherLoad: $isPublisherLoad timers: $timers passive : ${_bannerConfig.passiveRefreshInterval} active: ${_bannerConfig.activeRefreshInterval}');

    if (resetVisibleTime) {
      _bannerConfig.isVisibleFor = 0;
    }
    _wasFirstLook = isPublisherLoad;

    if (timers != null) {
      switch (timers) {
        case 0:
          _startPassiveCounter(_bannerConfig.passiveRefreshInterval.toInt());
          break;
        case 1:
          _startActiveCounter(_bannerConfig.activeRefreshInterval.toInt());
          break;
        case 2:
          _startUnfilledRefreshCounter();
          break;
      }
    } else {
      _startPassiveCounter(_bannerConfig.passiveRefreshInterval.toInt());
      _startActiveCounter(_bannerConfig.activeRefreshInterval.toInt());
    }
  }

  void _startActiveCounter(int seconds) {
    if (seconds <= 0) return;
    _activeTimeCounter?.cancel();
    _activeTimeCounter = CountdownTimer(
      duration: Duration(seconds: seconds),
      onRemainingTimeChanged: (remainingTime) {
        if (_bannerConfig.isVisible == true) {
          _bannerConfig.isVisibleFor++;
        }
        _bannerConfig.activeRefreshInterval--;
      },
      onTimerFinished: () {
        _bannerConfig.activeRefreshInterval =
            _sdkConfig?.activeRefreshInterval ?? 0;
        _refresh(active: 1, firstLook: false);
      },
    );
  }

  void _startPassiveCounter(int seconds) {
    if (seconds <= 0) return;
    _passiveTimeCounter?.cancel();
    _passiveTimeCounter = CountdownTimer(
      duration: Duration(seconds: seconds),
      onRemainingTimeChanged: (remainingTime) {
        _bannerConfig.passiveRefreshInterval--;
      },
      onTimerFinished: () {
        _bannerConfig.passiveRefreshInterval =
            _sdkConfig?.passiveRefreshInterval ?? 0;
        _refresh(active: 0, firstLook: false);
      },
    );
  }

  void _startUnfilledRefreshCounter() {
    _activeTimeCounter?.cancel();
    _passiveTimeCounter?.cancel();

    final time = _sdkConfig?.unfilledTimerConfig?.time?.toInt() ?? 0;
    if (time <= 0) return;

    pubAdUnit.log(() => 'Unfilled timer started with time :$time');

    _unfilledRefreshCounter?.cancel();
    _unfilledRefreshCounter = CountdownTimer(
      duration: Duration(seconds: time),
      onRemainingTimeChanged: (remainingTime) {},
      onTimerFinished: () {
        _refresh(
            active: 0,
            unfilled: true,
            fixedUnit: _sdkConfig?.unfilledTimerConfig?.unit,
            firstLook: false);
      },
    );
  }

  _refresh(
      {int active = 1,
      bool unfilled = false,
      bool instantRefresh = false,
      String? fixedUnit,
      bool firstLook = false}) {
    if (!shouldBeActive() || _refreshBlocked || _bannerConfig.adSizes.isEmpty) {
      return;
    }
    pubAdUnit.log(() =>
        "Trying opportunity: active = $active, retrying = $unfilled, instant = $instantRefresh");
    final currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
    final differenceOfLastRefresh =
        ((currentTimeStamp - _bannerConfig.lastRefreshAt!) / 1000.0)
            .ceil()
            .toInt();
    var timers = (active == 0 && unfilled) ? 2 : active;
    if (instantRefresh) {
      timers = 3;
    }

    var takeOpportunity = false;

    if (active == 1) {
      var pickOpportunity = false;
      if (_bannerConfig.isVisible == true) {
        pickOpportunity = true;
      } else {
        if (_bannerConfig.visibleFactor < 0) {
          pickOpportunity = false;
        } else {
          if (((currentTimeStamp - _bannerConfig.lastActiveOpportunity!) /
                      1000.0)
                  .ceil()
                  .toInt() >=
              _bannerConfig.visibleFactor *
                  _bannerConfig.activeRefreshInterval) {
            pickOpportunity = true;
          }
        }
      }

      if (pickOpportunity) {
        _bannerConfig.lastActiveOpportunity = currentTimeStamp;
        if (differenceOfLastRefresh >= _bannerConfig.difference &&
            (_bannerConfig.isVisibleFor >=
                (!_wasFirstLook || _bannerConfig.isNewUnitApplied()
                    ? _bannerConfig.minViewRtb
                    : _bannerConfig.minView))) {
          takeOpportunity = true;
        }
      }
    } else if (active == 0) {
      var pickOpportunity = false;
      if (_isForegroundRefresh == 1) {
        if (_bannerConfig.isVisible == true) {
          pickOpportunity = true;
        } else {
          if (_bannerConfig.factor < 0) {
            pickOpportunity = false;
          } else {
            if (((currentTimeStamp - _bannerConfig.lastPassiveOpportunity!) /
                        1000.0)
                    .ceil()
                    .toInt() >=
                _bannerConfig.factor * _bannerConfig.passiveRefreshInterval) {
              pickOpportunity = true;
            }
          }
        }
      } else {
        if (_bannerConfig.factor < 0) {
          pickOpportunity = false;
        } else {
          if (((currentTimeStamp - _bannerConfig.lastPassiveOpportunity!) /
                      1000.0)
                  .ceil()
                  .toInt() >=
              _bannerConfig.factor * _bannerConfig.passiveRefreshInterval) {
            pickOpportunity = true;
          }
        }
      }

      if (pickOpportunity) {
        _bannerConfig.lastPassiveOpportunity = currentTimeStamp;
        if (differenceOfLastRefresh >= _bannerConfig.difference &&
            (_bannerConfig.isVisibleFor >=
                (!_wasFirstLook || _bannerConfig.isNewUnitApplied()
                    ? _bannerConfig.minViewRtb
                    : _bannerConfig.minView))) {
          takeOpportunity = true;
        }
      }
    }
    if (AndBeyondMedia.instance.connectionAvailable() == true &&
        _isForegroundRefresh == 1 &&
        (unfilled || takeOpportunity) &&
        _canRefresh()) {
      _bannerConfig.lastRefreshAt = currentTimeStamp;
      pubAdUnit.log(() =>
          "Opportunity Taken: active = $active, retrying = $unfilled, instant = $instantRefresh");

      if (_ifNativePossible() &&
          !_bannerConfig.adSizes.contains(AdSize.fluid)) {
        _bannerConfig.adSizes.add(AdSize.fluid);
      }

      if (_bannerConfig.refreshCount < 10) {
        _bannerConfig.refreshCount++;
      } else {
        _bannerConfig.refreshCount = 10;
      }

      _loadAd(
          fixedUnit ?? _getAdUnitName(unfilled, false, false),
          _createAdRequest(active, unfilled: unfilled, instant: instantRefresh),
          _bannerConfig.adSizes,
          firstLook);
    } else {
      _startRefreshing(timers: timers);
    }
  }

  void _adFailedToLoad(String triedUnit, bool firstLook, bool abmLoad) {
    pubAdUnit.log(() =>
        "Failed with Unfilled Config: ${_bannerConfig.unFilled?.toJson()} && Retry config :${_bannerConfig.retryConfig?.toJson()} & is Abm load : $abmLoad & isFirstLook : $firstLook");
    if (shouldBeActive()) {
      if (abmLoad) {
        var retryUnit = _bannerConfig.retryConfig?.adUnits?.firstOrNull;
        if ((_bannerConfig.retryConfig?.retries ?? 0) > 0 &&
            retryUnit != null) {
          var delaySeconds =
              (_bannerConfig.retryConfig?.retryInterval ?? 0).toInt();
          _bannerConfig.retryConfig?.retries =
              (_bannerConfig.retryConfig?.retries ?? 0) - 1;
          _bannerConfig.retryConfig?.adUnits?.removeAt(0);
          _loadAdWithDelay(delaySeconds, retryUnit, firstLook);
        } else {
          _checkForFallback(triedUnit, abmLoad, firstLook);
        }
      } else {
        if (_bannerConfig.unFilled?.status == 1) {
          if (_bannerConfig.unFilled?.regionWise == 1 &&
              (_countryInfo == null ||
                  isRegionBlocked() ||
                  ifUnitOnRegionalHold(_bannerConfig.publisherAdUnit) ||
                  ifSectionOnRegionalHold(section))) {
            _sendEventToPub(null, AdStatus.failed, firstLook);
          } else {
            _refresh(unfilled: true, firstLook: true);
          }
        } else {
          _sendEventToPub(null, AdStatus.failed, firstLook);
        }
      }
    } else {
      _sendEventToPub(null, AdStatus.failed, firstLook);
    }
  }

  void _loadAdWithDelay(int delaySeconds, String retryUnit, bool firstLook) {
    Timer(Duration(seconds: delaySeconds), () {
      _refresh(unfilled: true, fixedUnit: retryUnit, firstLook: firstLook);
    });
  }

  void _checkForFallback(String triedUnit, bool abmLoad, bool firstLook) {
    pubAdUnit.log(() =>
        "Checking fallback for first look $firstLook & abm load $abmLoad");
    if ((firstLook && _bannerConfig.fallback?.firstlook == 1) &&
        _bannerConfig.unFilled?.regionWise == 1 &&
        (_countryInfo == null ||
            isRegionBlocked() ||
            ifUnitOnRegionalHold(pubAdUnit) ||
            ifSectionOnRegionalHold(section))) {
      pubAdUnit.log(() => "Not eligible for fallback 1");
      _sendEventToPub(null, AdStatus.failed, firstLook);
      return;
    }

    if (!firstLook &&
        _sdkConfig?.seemlessRefresh == 1 &&
        _sdkConfig?.seemlessRefreshFallback != 1) {
      pubAdUnit.log(() => "Fallback redirected to success for seemless");
      _pendingImpression = false;
      _saveRefreshTime();
      _sendEventToPub(null, AdStatus.loaded, firstLook);
      _adLoaded(firstLook, triedUnit, null);
      return;
    }

    if ((firstLook && _bannerConfig.fallback?.firstlook == 1) ||
        (!firstLook && _bannerConfig.fallback?.other == 1)) {
      final matchedBanners = <FallbackBanner>[];
      for (final pubSize in pubAdSizes) {
        final matchedSize = _bannerConfig.fallback?.banners?.firstWhereOrNull(
            (it) =>
                (it.width?.toIntOrNull() ?? 0) == pubSize.width &&
                (it.height?.toIntOrNull() ?? 0) == pubSize.height);
        if (matchedSize != null) {
          matchedBanners.add(matchedSize);
        }
      }

      FallbackBanner? biggestBanner;
      var maxArea = 0;
      for (final banner in matchedBanners) {
        final area = (banner.width?.toIntOrNull() ?? 0) *
            (banner.height?.toIntOrNull() ?? 0);
        if (maxArea < area) {
          biggestBanner = banner;
          maxArea = area;
        }
      }

      if (biggestBanner == null) {
        AdSize? biggestPubSize;
        maxArea = 0;
        for (final pubSize in pubAdSizes) {
          final area = pubSize.width * pubSize.height;
          if (maxArea < area) {
            biggestPubSize = pubSize;
            maxArea = area;
          }
        }

        biggestBanner = _bannerConfig.fallback?.banners?.firstWhereOrNull(
            (it) =>
                it.height?.toLowerCase() == 'all' &&
                it.width?.toLowerCase() == 'all');
        if (biggestBanner != null) {
          biggestBanner.height = biggestPubSize?.height.toString();
          biggestBanner.width = biggestPubSize?.width.toString();
        }
      }

      if (biggestBanner != null &&
          (biggestBanner.width?.toIntOrNull() ?? 0) != 0 &&
          (biggestBanner.height?.toIntOrNull() ?? 0) != 0) {
        _attachFallback(triedUnit, biggestBanner, firstLook);
      } else {
        pubAdUnit.log(() => "Not eligible for fallback 3");
        _sendEventToPub(null, AdStatus.failed, firstLook);
      }
    } else {
      pubAdUnit.log(() => "Not eligible for fallback 4");
      _sendEventToPub(null, AdStatus.failed, firstLook);
    }
  }

  void _attachFallback(
      String triedUnit, FallbackBanner fallbackBanner, bool firstLook) {
    if (fallbackBanner.type == null ||
        fallbackBanner.type?.toLowerCase() == "image") {
      pubAdUnit.log(() => "Attach fallback image for : $triedUnit");
      var fallbackWidget = InkWell(
        key: ValueKey(Random().nextInt(999999)),
        onTap: () {
          _launchUrl(fallbackBanner.url ?? "");
        },
        child: SizedBox(
          width: fallbackBanner.width?.toIntOrNull()?.toDouble(),
          height: fallbackBanner.height?.toIntOrNull()?.toDouble(),
          child: CachedNetworkImage(
            imageUrl: fallbackBanner.image ?? "",
            placeholder: (context, url) => Container(),
            errorWidget: (context, url, error) => Container(),
          ),
        ),
      );
      fallbackAdController.add(fallbackWidget);
      _pendingImpression = false;
      _saveRefreshTime();
      _sendEventToPub(null, AdStatus.loaded, firstLook);
      _adLoaded(firstLook, triedUnit, null);
    } else {
      pubAdUnit.log(() => "Attach fallback web for : $triedUnit");
      //web fallback in progress
    }
  }
}

extension BannerLifecycle on BannerAdManager {
  void setVisibility(double visiblePercentage) {
    var visible = visiblePercentage > 30;
    if (visible == _bannerConfig.isVisible) {
      return;
    }

    var tryInstantRefresh = false;
    if (_bannerConfig.isVisible != null) {
      final savedVisibility = _bannerConfig.isVisible!;
      tryInstantRefresh = !savedVisibility && visible;
    }
    _bannerConfig.isVisible = visible;
    if (tryInstantRefresh && _bannerConfig.instantRefresh == 1) {
      _refresh(
          active: 0, unfilled: false, instantRefresh: true, firstLook: false);
    }
  }

  void adResumed() {
    _isForegroundRefresh = 1;
    if (_bannerConfig.adSizes.isNotEmpty) {
      _startActiveCounter(_bannerConfig.activeRefreshInterval.toInt());
    }
  }

  void adPaused() {
    _isForegroundRefresh = 0;
    _activeTimeCounter?.cancel();
  }

  void adDestroyed() {
    _activeTimeCounter?.cancel();
    _passiveTimeCounter?.cancel();
    _unfilledRefreshCounter?.cancel();
  }
}

extension BannerUtils on BannerAdManager {
  void _sendEventToPub(Ad? ad, AdStatus status, bool firstLook,
      {LoadAdError? err}) {
    if (firstLook || _sdkConfig?.infoConfig?.refreshCallbacks == 1) {
      _eventCallBack(status, err);
    }
  }

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
      position = _bannerConfig.unFilled?.number;
    } else if (newUnit) {
      position = _bannerConfig.newUnit?.number;
    } else if (hijacked) {
      position = _bannerConfig.hijack?.number;
    } else {
      position = _bannerConfig.position;
    }
    position = position ?? 1;
    return "${_bannerConfig.customUnitName}-$position";
  }

  AdLoadRequest _createAdRequest(int active,
      {bool unfilled = false,
      bool hijacked = false,
      bool instant = false,
      bool newUnit = false}) {
    var keyValues = {
      "adunit": pubAdUnit,
      "active": active.toString(),
      "refresh": _bannerConfig.refreshCount.toString(),
      "hb_format": _sdkConfig?.hbFormat ?? "amp",
      "visible": _isForegroundRefresh.toString(),
      "min_view":
          (_bannerConfig.isVisibleFor > 10 ? 10 : _bannerConfig.isVisibleFor)
              .toString(),
      "sdk_version": AndBeyondMedia.instance.getLibVersion()
    };
    if (unfilled) {
      keyValues["retry"] = "1";
    }
    if (hijacked) {
      keyValues["hijack"] = "1";
    }
    if (instant) {
      keyValues["instant"] = "1";
    }
    if (newUnit) {
      keyValues["new_unit"] = "1";
    }
    return AdLoadRequest().build(customTargeting: keyValues);
  }

  String getUnitNameType(
      String type, List<ABMSize>? supportedSizes, List<AdSize> pubSizes) {
    if (supportedSizes == null || supportedSizes.isEmpty) {
      return type;
    } else {
      final matchedSizes = <ABMSize>[];
      for (final pubSize in pubSizes) {
        final matchedSize = supportedSizes.firstWhereOrNull(
          (size) =>
              (size.width?.toIntOrNull() ?? 0) == pubSize.width &&
              (size.height?.toIntOrNull() ?? 0) == pubSize.height,
        );
        if (matchedSize != null) {
          matchedSizes.add(matchedSize);
        }
      }

      ABMSize? biggestSize;
      var maxArea = 0;
      for (final size in matchedSizes) {
        final area = (size.width?.toInt() ?? 0) * (size.height?.toInt() ?? 0);
        if (maxArea < area) {
          biggestSize = size;
          maxArea = area;
        }
      }

      return biggestSize != null
          ? '${biggestSize.width}-${biggestSize.height}'
          : type;
    }
  }

  RetryConfig getRetryConfig() {
    var retryConfig = RetryConfig();
    retryConfig
      ..retries = _sdkConfig?.retryConfig?.retries
      ..retryInterval = _sdkConfig?.retryConfig?.retryInterval
      ..adUnits = <String>[...(_sdkConfig?.retryConfig?.adUnits ?? [])];
    return retryConfig;
  }

  LoadConfig? getValidLoadConfig(String adType, bool forHijack,
      LoadConfigs? hijackConfig, LoadConfigs? unfilledConfig) {
    LoadConfig? validConfig;

    switch (adType.toUpperCase()) {
      case AdTypes.BANNER:
        validConfig = forHijack ? hijackConfig?.banner : unfilledConfig?.banner;
        break;
      case AdTypes.INLINE:
        validConfig = forHijack ? hijackConfig?.inline : unfilledConfig?.inline;
        break;
      case AdTypes.ADAPTIVE:
        validConfig =
            forHijack ? hijackConfig?.adaptive : unfilledConfig?.adaptive;
        break;
      case AdTypes.INREAD:
        validConfig = forHijack ? hijackConfig?.inread : unfilledConfig?.inread;
        break;
      case AdTypes.STICKY:
        validConfig = forHijack ? hijackConfig?.sticky : unfilledConfig?.sticky;
        break;
      default:
        validConfig = forHijack ? hijackConfig?.other : unfilledConfig?.other;
    }
    validConfig ??= forHijack ? hijackConfig?.other : unfilledConfig?.other;
    return validConfig;
  }

  List<AdSize> getCustomSizes(
      List<AdSize> adSizes, List<ABMSize>? sizeOptions) {
    final sizes = <AdSize>[];
    for (final adSize in adSizes) {
      final lookingWidth = adSize.width != 0 ? adSize.width.toString() : 'ALL';
      final lookingHeight =
          adSize.height != 0 ? adSize.height.toString() : 'ALL';
      final sizeOption = sizeOptions?.firstWhereOrNull(
        (size) => size.height == lookingHeight && size.width == lookingWidth,
      );

      sizeOption?.sizes?.forEach((selectedSize) {
        if (selectedSize.width == 'ALL' || selectedSize.height == 'ALL') {
          sizes.add(adSize);
        } else if (sizes.none((size) =>
            size.width == (selectedSize.width?.toInt() ?? 0) &&
            size.height == (selectedSize.height?.toInt() ?? 0))) {
          sizes.add(AdSize(
              width: (selectedSize.width?.toIntOrNull() ?? 0),
              height: (selectedSize.height?.toIntOrNull() ?? 0)));
        }
      });
    }
    return sizes;
  }

  bool _checkHijack(LoadConfig? hijackConfig) {
    if (hijackConfig?.regionWise == 1) {
      if (_countryInfo == null) {
        return false;
      } else {
        if (hijackConfig?.status == 1) {
          if (ifUnitOnRegionalHold(_bannerConfig.publisherAdUnit) ||
              isRegionBlocked() ||
              ifSectionOnRegionalHold(section)) {
            return false;
          } else {
            final number = Random().nextInt(100) + 1;
            return number >= 1 && number <= getRegionalHijackPercentage();
          }
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

  bool _ifNativePossible() {
    if (_bannerConfig.nativeFallback != 1) {
      return false;
    } else {
      var maxArea = 0;
      AdSize? biggestPubSize;
      for (final pubSize in pubAdSizes) {
        final area = pubSize.width * pubSize.height;
        if (maxArea < area) {
          biggestPubSize = pubSize;
          maxArea = area;
        }
      }
      return biggestPubSize != null &&
          biggestPubSize.height > 120 &&
          biggestPubSize.width > 120;
    }
  }

  bool ifUnitOnHold(String adUnit) {
    final hold = (_sdkConfig?.heldUnits?.any(
                (it) => adUnit.toLowerCase().contains(it.toLowerCase())) ==
            true) ||
        (_sdkConfig?.heldUnits?.any((it) => it.toLowerCase().contains('all')) ==
            true);
    if (hold) {
      pubAdUnit.log(() => 'Blocking refresh on : $adUnit');
    }
    return hold;
  }

  bool isRegionBlocked() {
    var isRegionBlocked = false;
    if (_sdkConfig?.countryStatus?.active == 1 &&
        ((_sdkConfig?.blockedRegions?.getCities().any((it) =>
                    it.toLowerCase() == _countryInfo?.city?.toLowerCase()) ==
                true) ||
            (_sdkConfig?.blockedRegions?.getStates().any((it) =>
                    it.toLowerCase() == _countryInfo?.state?.toLowerCase()) ==
                true) ||
            (_sdkConfig?.blockedRegions?.getCountries().any((it) =>
                    it.toLowerCase() ==
                    _countryInfo?.countryCode?.toLowerCase()) ==
                true))) {
      isRegionBlocked = true;
    }
    return isRegionBlocked;
  }

  bool ifUnitOnRegionalHold(String adUnit) {
    var hold = false;
    if (_sdkConfig?.countryStatus?.active == 1) {
      _sdkConfig?.regionalHalts?.forEach((region) {
        if (((region.getCities().any((it) =>
                        it.toLowerCase() ==
                        _countryInfo?.city?.toLowerCase()) ==
                    true) ||
                (region.getStates().any((it) =>
                        it.toLowerCase() ==
                        _countryInfo?.state?.toLowerCase()) ==
                    true) ||
                (region.getCountries().any((it) =>
                        it.toLowerCase() ==
                        _countryInfo?.countryCode?.toLowerCase()) ==
                    true)) &&
            (region.units?.any(
                    (it) => adUnit.toLowerCase().contains(it.toLowerCase())) ==
                true)) {
          hold = true;
        }
      });
    }
    if (hold) {
      pubAdUnit.log(() => 'Regional blocking refresh on unit : $adUnit');
    }
    return hold;
  }

  bool ifSectionOnRegionalHold(String section) {
    var hold = false;
    if (_sdkConfig?.countryStatus?.active == 1) {
      _sdkConfig?.sectionRegionalHalt?.forEach((region) {
        if (((region.getCities().any((it) =>
                        it.toLowerCase() ==
                        _countryInfo?.city?.toLowerCase()) ==
                    true) ||
                (region.getStates().any((it) =>
                        it.toLowerCase() ==
                        _countryInfo?.state?.toLowerCase()) ==
                    true) ||
                (region.getCountries().any((it) =>
                        it.toLowerCase() ==
                        _countryInfo?.countryCode?.toLowerCase()) ==
                    true)) &&
            (region.sections?.any(
                    (it) => section.toLowerCase().contains(it.toLowerCase())) ==
                true)) {
          hold = true;
        }
      });
    }
    if (hold) {
      pubAdUnit.log(() => 'Regional blocking refresh on section : $section');
    }
    return hold;
  }

  int getRegionalHijackPercentage() {
    var percentage = 0;
    if (_sdkConfig?.countryStatus?.active == 1 && _countryInfo != null) {
      final region = _bannerConfig.hijack?.regionalPercentage?.firstWhereOrNull(
          (region) =>
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

  bool _canRefresh() {
    return _sdkConfig?.forceImpression != 1 ? true : !_pendingImpression;
  }

  _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
