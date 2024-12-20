library andbeyondmedia;

import 'dart:async';
import 'dart:ui';

import 'package:andbeyondmedia/src/sdk/ConfigProvider.dart';
import 'package:andbeyondmedia/src/sdk/Logger.dart';
import 'package:andbeyondmedia/src/sdk/NetworkManager.dart';
import 'package:andbeyondmedia/src/sdk/SDKConfig.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
      print('Error outside of Flutter framework: $error');
      print('Stack trace: $stack');
      return true;
    };
  }

  attachSentry() async {
    await SentryFlutter.init((options) {
      options.dsn =
          'https://1ff34dec1694fa8c067f81f747a62375@o4505753409421312.ingest.us.sentry.io/4505753410732032';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      // Note: Profiling alpha is available for iOS and macOS since SDK version 7.12.0
      options.profilesSampleRate = 1.0;
    });
  }
}
