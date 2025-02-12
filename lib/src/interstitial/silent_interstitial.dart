import 'package:andbeyondmedia/src/sdk/pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:andbeyondmedia/src/sdk/logger.dart';
import 'package:andbeyondmedia/src/sdk/config_provider.dart';
import 'package:andbeyondmedia/src/widgets/countdown_timer.dart';
import 'interstitial_config.dart';
import '../../andbeyondmedia.dart';

/// Manages the display of silent interstitial ads.
///
/// This class handles the lifecycle of silent interstitial ads, including
/// registering activities, initializing the ad system, loading ads, and
/// displaying them. It also manages timers for ad display and close delays.
class SilentInterstitial {
  /// Service for storing and retrieving data.
  late PreferencesHelper _storeService;

  /// Configuration for the silent interstitial ad.
  var _interstitialConfig = SilentInterstitialConfig();

  /// Timer for tracking active time.
  CountdownTimer? _activeTimeCounter;

  /// Timer for tracking close delay.
  CountdownTimer? _closeDelayTimer;

  /// Indicates if the ad system has been started.
  bool _started = false;

  /// Timer seconds.
  int _timerSeconds = 0;

  /// Tag for logging.
  String get _tag => "SilentInterstitial";

  /// Initializes the silent interstitial ad system.
  ///
  /// This method sets up the ad system, retrieves the configuration,
  /// and starts the ad display timer.
  void init() async {
    if (_started) return;
    _tag.log(() =>
        "setConfig:entry- Version:${AndBeyondMedia.instance.getLibVersion()}");
    _storeService = PreferencesHelper.instance;

    _storeService.init().then((_) {
      final _sdkConfig = ConfigProvider.instance.getConfig();
      final shouldBeActive = !(_sdkConfig == null || _sdkConfig.global != 1);
      if (!shouldBeActive) return;
      _interstitialConfig =
          _sdkConfig.silentInterstitialConfig ?? SilentInterstitialConfig();
      _addLifeCycleObserver();
      _started = true;
      _timerSeconds = _interstitialConfig.timer ?? 0;
      _tag.log(() => "setConfig :${_interstitialConfig.toJson()}");
      _resumeCounter();
    });
  }

  _addLifeCycleObserver() {
    final appLifecycleManager = AppLifecycleManager(listener: (state) {
      onStateChanged(state);
    });
    WidgetsBinding.instance.addObserver(appLifecycleManager);
  }

  /// Destroys the silent interstitial ad system.
  ///
  /// This method stops all timers and cleans up resources.
  void destroy() {
    _started = false;
    _activeTimeCounter?.cancel();
    _closeDelayTimer?.cancel();
  }

  /// Resumes the ad display counter.
  void _resumeCounter() {
    if (_started) {
      _startActiveCounter(_timerSeconds);
    }
  }

  /// Pauses the ad display counter.
  void _pauseCounter() {
    _activeTimeCounter?.cancel();
  }

  /// Starts the active counter for ad display.
  void _startActiveCounter(int seconds) {
    if (seconds <= 0) return;
    _activeTimeCounter?.cancel();
    _activeTimeCounter = CountdownTimer(
      duration: Duration(seconds: seconds),
      onRemainingTimeChanged: (remainingTime) {
        _timerSeconds--;
      },
      onTimerFinished: () {
        _timerSeconds = _interstitialConfig.timer ?? 0;
        _loadAd();
      },
    );
  }

  /// Handles app lifecycle events.
  void onStateChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resumeCounter();
    }
    if (state == AppLifecycleState.paused) {
      _pauseCounter();
    }
    if (state == AppLifecycleState.detached) {
      destroy();
    }
  }

  /// Loads an ad based on the configuration.
  void _loadAd() async {
    final lastInterShown = _storeService.getInt("last_inter", defaultValue: 0);
    if (DateTime.now().millisecondsSinceEpoch - lastInterShown >=
        (_interstitialConfig.loadFrequency ?? 0) * 1000) {
      _loadInterstitial();
    } else {
      _tag.log(() => "Frequency condition did not met.");
      _resumeCounter();
    }
  }

  /// Loads a standard interstitial ad.
  void _loadInterstitial() {
    _tag.log(
        () => "Loading interstitial with unit ${_interstitialConfig.adunit}");
    ABMInterstitialLoader(
        _interstitialConfig.adunit ?? "", AdLoadRequest().build(),
        (ABMInterstitialLoader ad) {
      _tag.log(() => "Interstitial ad has loaded and it should show now");
      _storeService.setInt("last_inter", DateTime.now().millisecondsSinceEpoch);
      ad.show();
      _resumeCounter();
    }, (err) {
      _tag.log(() => "Interstitial ad has failed and not trying custom now");
    }).load();
  }
}

class AppLifecycleManager with WidgetsBindingObserver {
  final Function(AppLifecycleState state) listener;

  AppLifecycleManager({required this.listener});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    listener(state);
  }
}
