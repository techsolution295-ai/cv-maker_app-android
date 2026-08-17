import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/constants/strings.dart';
import 'package:cv_ganerator/services/ad_service.dart';
import 'package:cv_ganerator/services/billing_service.dart';
import 'package:cv_ganerator/services/local_storage_service.dart';
import 'package:cv_ganerator/widgets/banner_ad_widget.dart';
import 'package:cv_ganerator/widgets/common_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  double _page = 0;
  int _currentIndex = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: AppStrings.onboardingTitle1,
      subtitle: AppStrings.onboardingSubtitle1,
      imagePath: 'assets/images/resume1.png',
      icon: Icons.auto_awesome_rounded,
    ),
    _OnboardingData(
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
      imagePath: 'assets/images/resume3.png',
      icon: Icons.dashboard_customize_rounded,
    ),
    _OnboardingData(
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
      imagePath: 'assets/images/resume4.png',
      icon: Icons.psychology_alt_rounded,
    ),
    _OnboardingData(
      title: AppStrings.onboardingTitle4,
      subtitle: AppStrings.onboardingSubtitle4,
      imagePath: 'assets/images/resume2.png',
      icon: Icons.ios_share_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() => _page = _pageController.page ?? 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration:
                const BoxDecoration(gradient: AppTheme.gradientBackground),
          ),
          _buildDecorativeBlobs(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 720;
                      final isCompact = constraints.maxWidth < 360;
                      final horizontalPadding = isWide
                          ? AppDimensions.paddingXLarge
                          : AppDimensions.paddingLarge;
                      final maxContentWidth = isWide ? 760.0 : double.infinity;
                      final imageHeight =
                          isCompact ? 190.0 : (isWide ? 260.0 : 220.0);

                      return Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: maxContentWidth),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  AppDimensions.paddingSmall,
                                  horizontalPadding,
                                  0,
                                ),
                                child: _buildTopBar(),
                              ),
                              const SizedBox(height: AppDimensions.paddingSmall),
                              BannerAdWidget(
                                adUnitId: AdService.bannerAdUnitId,
                                backgroundColor: Colors.transparent,
                                borderColor: Colors.grey.shade300,
                              ),
                              Expanded(
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _pages.length,
                                  onPageChanged: (index) {
                                    HapticFeedback.selectionClick();
                                    setState(() => _currentIndex = index);
                                  },
                                  itemBuilder: (context, index) {
                                    final page = _pages[index];
                                    final delta =
                                        (_page - index).clamp(-1.0, 1.0);
                                    final scale = 1 - (delta.abs() * 0.08);
                                    final opacity = 1 - (delta.abs() * 0.5);

                                    return Padding(
                                      padding:
                                          EdgeInsets.all(horizontalPadding),
                                      child: Opacity(
                                        opacity: opacity.clamp(0.0, 1.0),
                                        child: Transform.scale(
                                          scale: scale.clamp(0.9, 1.0),
                                          child: _OnboardingPageCard(
                                            key: ValueKey(index),
                                            page: page,
                                            imageHeight: imageHeight,
                                            isActive: index == _currentIndex,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SmoothPageIndicator(
                                controller: _pageController,
                                count: _pages.length,
                                effect: ExpandingDotsEffect(
                                  activeDotColor: Colors.white,
                                  dotColor: Colors.white.withOpacity(0.35),
                                  dotHeight: 8,
                                  dotWidth: 8,
                                  expansionFactor: 3.2,
                                  spacing: 6,
                                ),
                              ),
                              const SizedBox(
                                  height: AppDimensions.paddingLarge),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                ),
                                child: _buildActionButton(),
                              ),
                              const SizedBox(
                                  height: AppDimensions.paddingLarge),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.article_outlined,
                color: AppTheme.primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Text(
              AppStrings.appName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          ),
          child: Text(
            '${_currentIndex + 1}/${_pages.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, end: 0);
  }

  Widget _buildDecorativeBlobs() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: _blob(180, Colors.white.withOpacity(0.10))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 1,
                  end: 1.15,
                  duration: 4000.ms,
                  curve: Curves.easeInOut,
                ),
          ),
          Positioned(
            top: 140,
            left: -80,
            child: _blob(220, Colors.white.withOpacity(0.08))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 1,
                  end: 1.1,
                  duration: 5000.ms,
                  curve: Curves.easeInOut,
                ),
          ),
          Positioned(
            bottom: -70,
            right: -50,
            child: _blob(200, Colors.white.withOpacity(0.09))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 1,
                  end: 1.12,
                  duration: 4500.ms,
                  curve: Curves.easeInOut,
                ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildActionButton() {
    final isLast = _currentIndex == _pages.length - 1;
    return SizedBox(
      height: AppDimensions.buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusLarge),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLast ? AppStrings.getStarted : AppStrings.next,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Icon(
              isLast
                  ? Icons.arrow_forward_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: 18,
            ),
          ],
        ),
      ),
    )
        .animate(key: ValueKey('button_$_currentIndex'))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.25, end: 0, curve: Curves.easeOutCubic);
  }

  static const Duration _startupAdTimeout = Duration(seconds: 5);

  Future<void> _handleNext() async {
    if (_currentIndex == _pages.length - 1) {
      await _completeOnboarding();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  // Onboarding is only shown on first launch, so the app-open ad (which
  // was skipped on the splash screen for a cold start) is shown here once
  // the user finishes, giving the ad network time to load in the background.
  // After the ad, the Pro screen is shown once; closing it lands on Home.
  Future<void> _completeOnboarding() async {
    await LocalStorageService.instance.setOnboardingCompleted(true);
    if (!mounted) return;

    final hasAd = await AdService.instance.loadStartupAppOpenAd().timeout(
      _startupAdTimeout,
      onTimeout: () => false,
    );
    if (!mounted) return;

    if (hasAd) {
      await AdService.instance.showStartupAppOpenAdIfAvailable();
      if (!mounted) return;
    }

    Navigator.pushReplacementNamed(context, '/root');
    if (!BillingService.instance.isPro) {
      Navigator.pushNamed(context, '/pro');
    }
  }
}

class _OnboardingPageCard extends StatelessWidget {
  final _OnboardingData page;
  final double imageHeight;
  final bool isActive;

  const _OnboardingPageCard({
    super.key,
    required this.page,
    required this.imageHeight,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      backgroundColor: Colors.white.withOpacity(0.97),
      borderRadius: AppDimensions.borderRadiusXLarge,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingLarge,
        AppDimensions.paddingXLarge,
        AppDimensions.paddingLarge,
        AppDimensions.paddingLarge,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    page.imagePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0.35),
                          ],
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Preview',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(duration: 450.ms, curve: Curves.easeOut)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppTheme.gradientBackground,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(page.icon, color: Colors.white, size: 26),
            )
                .animate(target: isActive ? 1 : 0)
                .fadeIn(delay: 120.ms, duration: 400.ms)
                .scale(
                  begin: const Offset(0.4, 0.4),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutBack,
                  delay: 120.ms,
                  duration: 450.ms,
                ),
          ),
          Transform.translate(
            offset: const Offset(0, -16),
            child: Column(
              children: [
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: AppTheme.textDark),
                )
                    .animate(target: isActive ? 1 : 0)
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.4,
                      end: 0,
                      delay: 200.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  page.subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
                    .animate(target: isActive ? 1 : 0)
                    .fadeIn(delay: 280.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.4,
                      end: 0,
                      delay: 280.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;
  final IconData icon;

  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.icon,
  });
}
