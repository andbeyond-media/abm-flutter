library andbeyondmedia;

import 'dart:async';
import 'dart:ui';

import 'package:andbeyondmedia/src/sdk/ConfigProvider.dart';
import 'package:andbeyondmedia/src/sdk/Logger.dart';
import 'package:andbeyondmedia/src/sdk/NetworkManager.dart';
import 'package:andbeyondmedia/src/sdk/SDKConfig.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AndBeyondMedia {
  AndBeyondMedia._();

  static final AndBeyondMedia _instance = AndBeyondMedia._().._init();

  static AndBeyondMedia get instance => _instance;
  var logEnabled = false;
  String? specialTag = "";
  final _networkManager = NetworkManager.instance;

  final controller = StreamController<int>.broadcast();
  final countryInfoController = StreamController<int>.broadcast();
  int lastConfigStatus = 0;
  int lastCountryInfoStatus = 0;
  late StreamSubscription<int> _configSub;
  late StreamSubscription<int> _countryInfoSub;

  void _init() {
    controller.add(0);
    countryInfoController.add(0);
  }

  initialize([bool enableLog = false]) {
    log("ABM Version ${getLibVersion()} initialized.");
    _keepCheckOfConfig();
    logEnabled = enableLog;
    _networkManager.register();
    ConfigProvider.instance.fetchConfig(null);
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

  configFetched(SdkConfig? config) {
    specialTag = config?.infoConfig?.specialTag;
    logEnabled = (logEnabled || config?.infoConfig?.normalInfo == 1);
    MobileAds.instance.initialize();
    controller.add(2);
  }

  String getLibVersion() {
    return "0.0.1";
  }

  bool connectionAvailable() {
    return _networkManager.isInternetAvailable();
  }
}

class EventHelper {
  EventHelper._(); // Private constructor

  static final EventHelper _instance = EventHelper._();

  static EventHelper get instance => _instance;

  attachEventHandler() {
    PlatformDispatcher.instance.onError = (error, stack) {
      return true;
    };
  }

  attachSentry() async {
  }
}
