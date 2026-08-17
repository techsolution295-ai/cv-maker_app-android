import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:cv_ganerator/services/billing_service.dart';

class AdService {
  AdService._();

  static final AdService instance = AdService._();

  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/9257395921';

  static const String _releaseBannerAdUnitId =
      'ca-app-pub-6952052496235990/8478722403';
  static const String _releaseInterstitialAdUnitId =
      'ca-app-pub-6952052496235990/5090141731';
  static const String _releaseAppOpenAdUnitId =
      'ca-app-pub-6952052496235990/8712289604';

  /// Device IDs registered as AdMob test devices (see the "Use
  /// RequestConfiguration...setTestDeviceIds(...)" line Google prints to
  /// logcat on a new device). Registering a device here lets it request the
  /// LIVE ad unit IDs safely -- Google serves a clearly-marked test creative
  /// through the real ad unit's pipeline instead of an actual ad, so you can
  /// verify the live ad unit itself works without any policy/invalid-traffic
  /// risk from accidentally viewing/clicking a real ad while developing.
  static const List<String> _testDeviceIds = [
    'EBCC5C6724B6E9838AC594143D4B7BBF',
  ];

  /// TEMPORARY DEBUG SWITCH: set to `true` only while diagnosing a live
  /// ad-unit issue -- it forces every ad request (even in a debug build) to
  /// use the LIVE ad unit IDs instead of Google's generic test IDs. Safe
  /// only because the device(s) above are registered as test devices.
  /// Keep this `false` normally so everyday `flutter run` debugging uses
  /// Google's test IDs instead of the real ones.
  static const bool debugForceLiveAdUnitIds = false;

  static bool get _useLiveAdUnitIds =>
      kReleaseMode || (kDebugMode && debugForceLiveAdUnitIds);

  static String get bannerAdUnitId =>
      _useLiveAdUnitIds ? _releaseBannerAdUnitId : _testBannerAdUnitId;
  static String get interstitialAdUnitId => _useLiveAdUnitIds
      ? _releaseInterstitialAdUnitId
      : _testInterstitialAdUnitId;
  static String get appOpenAdUnitId =>
      _useLiveAdUnitIds ? _releaseAppOpenAdUnitId : _testAppOpenAdUnitId;

  InterstitialAd? _interstitialAd;
  AppOpenAd? _startupAppOpenAd;
  AppOpenAd? _resumeAppOpenAd;
  bool _initializing = false;
  bool _initialized = false;
  bool _isShowingInterstitial = false;
  bool _isShowingAppOpenAd = false;
  bool _isLoadingStartupAppOpenAd = false;
  bool _isLoadingResumeAppOpenAd = false;
  Completer<bool>? _startupAppOpenAdLoadCompleter;
  bool _wasBackgrounded = false;
  DateTime? _backgroundedAt;
  static const Duration _requiredBackgroundTime = Duration(seconds: 10);
  static const Duration _resumeShowDelay = Duration(milliseconds: 300);

  /// Pro members get a completely ad-free experience.
  bool get _isPro => BillingService.instance.isPro;

  Future<void> initialize() async {
    if (_initialized || _initializing) return;
    _initializing = true;
    await MobileAds.instance.initialize();
    if (_testDeviceIds.isNotEmpty) {
      // Registered regardless of build mode: this only changes what these
      // specific dev/test devices see (safe test creatives instead of real
      // ads through the live ad units), it never affects real users.
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: _testDeviceIds),
      );
    }
    _initialized = true;
    _initializing = false;
    _loadInterstitial();
    unawaited(loadStartupAppOpenAd());
    unawaited(loadResumeAppOpenAd());
  }

  void _loadInterstitial() {
    if (_isPro || _interstitialAd != null) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdService: interstitial loaded');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            'AdService: interstitial failed to load -- code=${error.code} '
            'domain=${error.domain} message=${error.message}',
          );
          _interstitialAd = null;
        },
      ),
    );
  }

  Future<void> loadResumeAppOpenAd() async {
    if (_isPro || _resumeAppOpenAd != null || _isLoadingResumeAppOpenAd) return;
    _isLoadingResumeAppOpenAd = true;

    await AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdService: resume app-open ad loaded');
          _isLoadingResumeAppOpenAd = false;
          _resumeAppOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            'AdService: resume app-open ad failed to load -- code=${error.code} '
            'domain=${error.domain} message=${error.message}',
          );
          _isLoadingResumeAppOpenAd = false;
          _resumeAppOpenAd = null;
        },
      ),
    );
  }

  Future<bool> loadStartupAppOpenAd() async {
    if (_isPro) return false;
    if (_startupAppOpenAd != null) return true;
    if (_isLoadingStartupAppOpenAd) {
      return _startupAppOpenAdLoadCompleter?.future ??
          Future<bool>.value(false);
    }
    _isLoadingStartupAppOpenAd = true;
    final completer = Completer<bool>();
    _startupAppOpenAdLoadCompleter = completer;

    await AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdService: startup app-open ad loaded');
          _isLoadingStartupAppOpenAd = false;
          _startupAppOpenAd = ad;
          _startupAppOpenAdLoadCompleter = null;
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            'AdService: startup app-open ad failed to load -- code=${error.code} '
            'domain=${error.domain} message=${error.message}',
          );
          _isLoadingStartupAppOpenAd = false;
          _startupAppOpenAd = null;
          _startupAppOpenAdLoadCompleter = null;
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );

    return completer.future;
  }

  Future<bool> showStartupAppOpenAdIfAvailable() async {
    if (_isPro) return false;
    final ad = _startupAppOpenAd;
    if (ad == null || _isShowingInterstitial || _isShowingAppOpenAd) {
      return false;
    }

    _startupAppOpenAd = null;
    _isShowingAppOpenAd = true;
    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback<AppOpenAd>(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isShowingAppOpenAd = false;
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _isShowingAppOpenAd = false;
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await ad.show();
    } catch (_) {
      _isShowingAppOpenAd = false;
      ad.dispose();
      if (!completer.isCompleted) completer.complete(false);
    }
    return completer.future;
  }

  void handleAppBackgrounded() {
    _backgroundedAt = DateTime.now();
    _wasBackgrounded = true;
    unawaited(loadResumeAppOpenAd());
  }

  Future<void> handleAppResumed() async {
    if (!_wasBackgrounded) return;
    _wasBackgrounded = false;
    if (_isPro) return;
    if (_isShowingInterstitial || _isShowingAppOpenAd) return;

    final backgroundedAt = _backgroundedAt;
    if (backgroundedAt == null) return;

    final awayDuration = DateTime.now().difference(backgroundedAt);
    if (awayDuration < _requiredBackgroundTime) return;

    await Future<void>.delayed(_resumeShowDelay);
    if (_resumeAppOpenAd == null) {
      await loadResumeAppOpenAd();
    }
    await _showResumeAppOpenAdIfAvailable();
  }

  Future<void> _showResumeAppOpenAdIfAvailable() async {
    final ad = _resumeAppOpenAd;
    if (ad == null || _isShowingAppOpenAd || _isShowingInterstitial) return;

    _resumeAppOpenAd = null;
    _isShowingAppOpenAd = true;
    final completer = Completer<void>();

    ad.fullScreenContentCallback = FullScreenContentCallback<AppOpenAd>(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isShowingAppOpenAd = false;
        unawaited(loadResumeAppOpenAd());
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _isShowingAppOpenAd = false;
        unawaited(loadResumeAppOpenAd());
        if (!completer.isCompleted) completer.complete();
      },
    );

    try {
      await ad.show();
    } catch (_) {
      _isShowingAppOpenAd = false;
      ad.dispose();
      unawaited(loadResumeAppOpenAd());
      if (!completer.isCompleted) completer.complete();
    }
    await completer.future;
  }

  Future<void> showInterstitialThen(FutureOr<void> Function() action) async {
    if (_isPro) {
      await Future<void>.sync(action);
      return;
    }

    final ad = _interstitialAd;
    if (ad == null || _isShowingInterstitial || _isShowingAppOpenAd) {
      await Future<void>.sync(action);
      _loadInterstitial();
      return;
    }

    _interstitialAd = null;
    _isShowingInterstitial = true;
    final completer = Completer<void>();

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isShowingInterstitial = false;
        _loadInterstitial();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _isShowingInterstitial = false;
        _loadInterstitial();
        if (!completer.isCompleted) completer.complete();
      },
    );

    try {
      await ad.show();
    } catch (_) {
      _isShowingInterstitial = false;
      ad.dispose();
      _loadInterstitial();
      if (!completer.isCompleted) completer.complete();
    }

    await completer.future;
    await Future<void>.sync(action);
  }
}
