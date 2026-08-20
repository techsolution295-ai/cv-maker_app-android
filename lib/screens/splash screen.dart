import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cv_ganerator/config/theme.dart';
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

  static const Color _logoBackground = Color(0xFFEEF2F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _logoBackground,
      body: ColoredBox(
        color: _logoBackground,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              _LogoMark()
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(0.88, 0.88),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutCubic,
                    duration: 700.ms,
                  ),
              const Spacer(flex: 2),
              SpinKitThreeBounce(
                color: AppTheme.primaryColor,
                size: 22,
              ).animate().fadeIn(delay: 400.ms, duration: 450.ms),
              const SizedBox(height: 14),
              Text(
                'Preparing your workspace',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
              ).animate().fadeIn(delay: 550.ms, duration: 450.ms),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Image.asset(
        'assets/images/splash_logo.png',
        width: 280,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
