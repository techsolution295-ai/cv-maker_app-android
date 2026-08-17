import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/constants/strings.dart';
import 'package:cv_ganerator/services/ad_service.dart';
import 'package:cv_ganerator/services/local_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _minimumSplashDuration = Duration(seconds: 1);
  static const Duration _splashWithoutAdDuration = Duration(milliseconds: 3500);
  static const Duration _startupAdTimeout = Duration(seconds: 7);
  bool _adHandled = false;

  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  Future<void> _startFlow() async {
    final stopwatch = Stopwatch()..start();
    await Future<void>.delayed(_minimumSplashDuration);

    final onboardingCompleted =
        LocalStorageService.instance.isOnboardingCompleted();

    // First launch ever: skip the app-open ad here so it doesn't race the
    // ad network on a cold start. It keeps loading in the background
    // (kicked off from main()) and is shown right after onboarding finishes.
    if (!onboardingCompleted) {
      final elapsed = stopwatch.elapsed;
      if (elapsed < _splashWithoutAdDuration) {
        await Future<void>.delayed(_splashWithoutAdDuration - elapsed);
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    final hasAd = await AdService.instance.loadStartupAppOpenAd().timeout(
      _startupAdTimeout,
      onTimeout: () => false,
    );
    if (!mounted || _adHandled) return;

    if (hasAd) {
      _adHandled = true;
      await AdService.instance.showStartupAppOpenAdIfAvailable();
      if (!mounted) return;
    } else {
      final elapsed = stopwatch.elapsed;
      if (elapsed < _splashWithoutAdDuration) {
        await Future<void>.delayed(_splashWithoutAdDuration - elapsed);
      }
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/root');
  }

  // Palette pulled straight from the new app icon so the splash feels like
  // one continuous piece of art with it.
  static const Color _iconBlueLight = Color(0xFF1E86FF);
  static const Color _iconBlueDeep = Color(0xFF001C6E);
  static const Color _badgeGreen = Color(0xFF23C68B);
  static const Color _badgePurple = Color(0xFF8B5CF6);
  static const Color _badgeOrange = Color(0xFFFFA23A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _iconBlueLight,
              Color(0xFF0A4FE0),
              Color(0xFF042E9E),
              _iconBlueDeep,
            ],
            stops: [0.0, 0.4, 0.72, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Blueprint-style grid texture over the whole background — a nod
            // to the document/CV theme, giving depth without being loud.
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _BlueprintGridPainter(
                    lineColor: Colors.white.withOpacity(0.05),
                    boldLineColor: Colors.white.withOpacity(0.09),
                    dotColor: Colors.white.withOpacity(0.16),
                  ),
                ),
              ),
            ),

            // Two large, soft blurred blobs echoing the badge colors from the
            // icon, kept off to the sides so the center stays clean.
            Positioned(
              top: -90,
              right: -110,
              child: _SoftBlob(
                size: 300,
                color: _badgeGreen.withOpacity(0.24),
                duration: 5200.ms,
                moveY: -24,
              ),
            ),
            Positioned(
              bottom: -120,
              left: -100,
              child: _SoftBlob(
                size: 320,
                color: _badgePurple.withOpacity(0.26),
                duration: 6000.ms,
                moveY: 24,
              ),
            ),

            // A few tiny sparkles matching the icon's badge colors.
            _FloatingOrb(
              top: 190,
              right: 54,
              size: 8,
              color: _badgeOrange.withOpacity(0.9),
              duration: 2800.ms,
              moveY: -14,
            ),
            _FloatingOrb(
              bottom: 230,
              left: 50,
              size: 7,
              color: _badgeGreen.withOpacity(0.85),
              duration: 3200.ms,
              moveY: 14,
            ),
            _FloatingOrb(
              top: 260,
              left: 60,
              size: 6,
              color: Colors.white.withOpacity(0.6),
              duration: 2400.ms,
              moveY: -10,
            ),

            // Center branding.
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIcon(),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                  )
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 600.ms)
                      .slideY(begin: 0.4, end: 0, curve: Curves.easeOutCubic)
                      .then()
                      .shimmer(
                        duration: 1400.ms,
                        color: Colors.white.withOpacity(0.6),
                      ),
                  const SizedBox(height: 8),
                  Text(
                    'Build, polish & share your CV',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                  )
                      .animate()
                      .fadeIn(delay: 650.ms, duration: 600.ms)
                      .slideY(begin: 0.6, end: 0, curve: Curves.easeOut),
                ],
              ),
            ),

            // Bottom loader.
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: SpinKitThreeBounce(
                color: Colors.white.withOpacity(0.9),
                size: 26,
              ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Image.asset(
      'assets/images/appicon.png',
      width: 176,
      height: 176,
    )
        .animate()
        .scale(
          duration: 700.ms,
          curve: Curves.easeOutBack,
          begin: const Offset(0.6, 0.6),
          end: const Offset(1, 1),
        )
        .fadeIn(duration: 500.ms)
        .then()
        .shimmer(
          duration: 1600.ms,
          color: Colors.white.withOpacity(0.5),
        );
  }
}

class _BlueprintGridPainter extends CustomPainter {
  final Color lineColor;
  final Color boldLineColor;
  final Color dotColor;
  static const double _cell = 24;
  static const int _boldEvery = 4;
  static const double _dotRadius = 1.7;

  const _BlueprintGridPainter({
    required this.lineColor,
    required this.boldLineColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final thinPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    final boldPaint = Paint()
      ..color = boldLineColor
      ..strokeWidth = 1;
    final dotPaint = Paint()..color = dotColor;

    var col = 0;
    for (double x = 0; x <= size.width; x += _cell, col++) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        col % _boldEvery == 0 ? boldPaint : thinPaint,
      );
    }

    var row = 0;
    for (double y = 0; y <= size.height; y += _cell, row++) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        row % _boldEvery == 0 ? boldPaint : thinPaint,
      );
    }

    for (double y = 0; y <= size.height; y += _cell * _boldEvery) {
      for (double x = 0; x <= size.width; x += _cell * _boldEvery) {
        canvas.drawCircle(Offset(x, y), _dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BlueprintGridPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      oldDelegate.boldLineColor != boldLineColor ||
      oldDelegate.dotColor != dotColor;
}

class _SoftBlob extends StatelessWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double moveY;

  const _SoftBlob({
    required this.size,
    required this.color,
    required this.duration,
    required this.moveY,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0)],
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: moveY,
            duration: duration,
            curve: Curves.easeInOut,
          ),
    );
  }
}

class _FloatingOrb extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final Color color;
  final Duration duration;
  final double moveY;

  const _FloatingOrb({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
    required this.duration,
    required this.moveY,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: moveY, duration: duration, curve: Curves.easeInOut),
    );
  }
}

