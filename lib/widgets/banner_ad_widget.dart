import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:cv_ganerator/services/billing_service.dart';

/// Reusable banner ad slot used across the app.
///
/// While the ad is loading -- or if it fails to load (e.g. the user has no
/// internet connection) -- a shimmering skeleton placeholder is shown
/// instead of collapsing the space to zero height. This keeps the layout
/// stable (no sudden pop-in/jump when the ad finishes loading) and gives a
/// polished, professional feel instead of a blank gap. Failed loads are
/// retried automatically in the background, so the ad appears on its own
/// as soon as connectivity/fill becomes available.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({
    super.key,
    required this.adUnitId,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
  });

  final String adUnitId;
  final EdgeInsets margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  static const Duration _retryDelay = Duration(seconds: 20);
  static const double _adHeight = 54;

  BannerAd? _bannerAd;
  bool _loaded = false;
  Timer? _retryTimer;

  bool get _isPro => BillingService.instance.isPro;

  @override
  void initState() {
    super.initState();
    BillingService.instance.addListener(_onProStatusChanged);
    if (!_isPro) {
      _load();
    }
  }

  void _onProStatusChanged() {
    if (!mounted) return;
    if (_isPro) {
      // Plan just became active -- drop any loaded/loading ad immediately.
      _retryTimer?.cancel();
      _bannerAd?.dispose();
      setState(() {
        _bannerAd = null;
        _loaded = false;
      });
    } else if (_bannerAd == null) {
      // Plan expired/cancelled -- resume showing ads.
      _load();
    }
  }

  void _load() {
    if (_isPro) return;
    final ad = BannerAd(
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('BannerAdWidget: ad loaded for "${widget.adUnitId}"');
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          // Surfaced via debugPrint (not gated by kDebugMode) so the real
          // failure reason (no-fill, network, invalid request, etc.) shows
          // up in `adb logcat` / `flutter run --release` even for a
          // release build, instead of silently retrying forever.
          debugPrint(
            'BannerAdWidget: failed to load ad "${widget.adUnitId}" -- '
            'code=${error.code} domain=${error.domain} message=${error.message}',
          );
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _loaded = false;
          });
          _scheduleRetry();
        },
      ),
    );
    _bannerAd = ad;
    ad.load();
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, () {
      if (!mounted || _isPro) return;
      _load();
    });
  }

  @override
  void dispose() {
    BillingService.instance.removeListener(_onProStatusChanged);
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pro members get a fully ad-free app -- no slot, no skeleton, no space.
    if (_isPro) return const SizedBox.shrink();

    final radius = widget.borderRadius;
    final border = radius != null
        ? Border.all(color: widget.borderColor ?? Colors.grey.shade300)
        : Border(
            top: BorderSide(color: widget.borderColor ?? Colors.grey.shade300),
            bottom:
                BorderSide(color: widget.borderColor ?? Colors.grey.shade300),
          );

    return SafeArea(
      top: false,
      child: Container(
        margin: widget.margin,
        width: double.infinity,
        height: _adHeight,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.white,
          border: border,
          borderRadius: radius != null ? BorderRadius.circular(radius) : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: (_loaded && _bannerAd != null)
              ? Center(
                  key: const ValueKey('ad'),
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                )
              : _BannerSkeleton(key: const ValueKey('skeleton')),
        ),
      ),
    );
  }
}

class _BannerSkeleton extends StatelessWidget {
  const _BannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _bone(width: 34, height: 34, radius: 8),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _bone(width: double.infinity, height: 10, radius: 4),
                const SizedBox(height: 6),
                _bone(width: 110, height: 8, radius: 4),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _bone(width: 54, height: 22, radius: 6),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: 1300.ms,
          color: Colors.white.withOpacity(0.55),
        );
  }

  Widget _bone({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
