import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cv_ganerator/constants/app_links.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/services/billing_service.dart';
import 'package:cv_ganerator/widgets/common_widgets.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({super.key});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  static const Color _bgTop = Color(0xFF102A4C);
  static const Color _bgBottom = Color(0xFF0B1E38);
  static const Color _gold = Color(0xFFF4C05A);

  final BillingService _billing = BillingService.instance;
  String _selectedProductId = BillingService.monthlyId;

  static const List<_PlanMeta> _planMeta = [
    _PlanMeta(
      productId: BillingService.weeklyId,
      name: 'Weekly',
      subtitle: 'Flexible short-term access',
      badge: null,
      icon: Icons.bolt_rounded,
    ),
    _PlanMeta(
      productId: BillingService.monthlyId,
      name: 'Monthly',
      subtitle: 'Full access, cancel anytime',
      badge: 'MOST POPULAR',
      icon: Icons.workspace_premium_rounded,
    ),
    _PlanMeta(
      productId: BillingService.yearlyId,
      name: 'Yearly',
      subtitle: 'Best long-term value',
      badge: 'BEST VALUE',
      icon: Icons.emoji_events_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _billing.addListener(_onBillingChanged);
    if (_billing.storeAvailable && _billing.products.isEmpty) {
      _billing.loadProducts();
    }
  }

  @override
  void dispose() {
    _billing.removeListener(_onBillingChanged);
    super.dispose();
  }

  void _onBillingChanged() {
    if (!mounted) return;
    final error = _billing.lastError;
    if (error != null) {
      AppSnackBar.error(context, error);
      _billing.lastError = null;
    }
    setState(() {});
  }

  ProductDetails? get _selectedProduct => _billing.productFor(_selectedProductId);

  @override
  Widget build(BuildContext context) {
    if (_billing.isPro) {
      return _AlreadyProView(gold: _gold, bgTop: _bgTop, bgBottom: _bgBottom);
    }

    return Scaffold(
      backgroundColor: _bgBottom,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_bgTop, _bgBottom],
              ),
            ),
          ),
          _buildDecorBlobs(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.paddingLarge,
                          0,
                          AppDimensions.paddingLarge,
                          AppDimensions.paddingSmall,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildHero(),
                              const SizedBox(height: AppDimensions.paddingSmall),
                              _buildBenefitsGrid(),
                              const SizedBox(height: AppDimensions.paddingMedium),
                              _buildPlans(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildBottomCta(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorBlobs() {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: _SoftBlob(color: _gold, size: 220, opacity: 0.16),
          ),
          Positioned(
            top: 220,
            left: -80,
            child: _SoftBlob(color: Color(0xFF2FA37C), size: 200, opacity: 0.14),
          ),
          Positioned(
            bottom: 40,
            right: -70,
            child: _SoftBlob(color: Color(0xFF1F5AA6), size: 220, opacity: 0.22),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingLarge,
        AppDimensions.paddingSmall,
        AppDimensions.paddingLarge,
        0,
      ),
      child: Row(
        children: [
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildHero() {
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: Image.asset(
            'assets/images/pro_hero.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.workspace_premium_rounded,
              size: 120,
              color: _gold,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 100.ms)
            .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack)
            .then()
            .moveY(begin: 0, end: -5, duration: 1600.ms, curve: Curves.easeInOut)
            .then()
            .moveY(begin: -5, end: 0, duration: 1600.ms, curve: Curves.easeInOut),
        const SizedBox(height: 4),
        Text(
          'Unlock Your Full Potential',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.15, end: 0),
        const SizedBox(height: 4),
        Text(
          'Unlimited templates, AI assistance & an ad-free experience.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            fontSize: 13,
            height: 1.35,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 280.ms),
      ],
    );
  }

  Widget _buildBenefitsGrid() {
    const items = [
      _Benefit(
        icon: Icons.dashboard_customize_rounded,
        title: 'All Templates',
        subtitle: '',
      ),
      _Benefit(
        icon: Icons.block_rounded,
        title: '100% Ad-Free',
        subtitle: '',
      ),
      _Benefit(
        icon: Icons.auto_awesome_rounded,
        title: 'AI Assistance',
        subtitle: '',
      ),
      _Benefit(
        icon: Icons.picture_as_pdf_rounded,
        title: 'Unlimited Exports',
        subtitle: '',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDimensions.paddingSmall,
      crossAxisSpacing: AppDimensions.paddingSmall,
      childAspectRatio: 2.6,
      children: [
        for (int i = 0; i < items.length; i++)
          _BenefitChip(benefit: items[i])
              .animate()
              .fadeIn(duration: 350.ms, delay: (280 + i * 80).ms)
              .slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildPlans() {
    if (!_billing.storeAvailable) {
      return _StoreUnavailableCard(
        onRetry: () => _billing.initialize(),
      ).animate().fadeIn(duration: 300.ms, delay: 650.ms);
    }

    return Column(
      children: [
        for (int i = 0; i < _planMeta.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == _planMeta.length - 1 ? 0 : AppDimensions.paddingSmall,
            ),
            child: _PlanCard(
              meta: _planMeta[i],
              product: _billing.productFor(_planMeta[i].productId),
              isLoading: _billing.isLoadingProducts && _billing.products.isEmpty,
              isSelected: _selectedProductId == _planMeta[i].productId,
              savingsLabel: _savingsLabelFor(_planMeta[i].productId),
              gold: _gold,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedProductId = _planMeta[i].productId);
              },
            ).animate().fadeIn(duration: 350.ms, delay: (700 + i * 100).ms).slideY(
                  begin: 0.08,
                  end: 0,
                ),
          ),
      ],
    );
  }

  String? _savingsLabelFor(String productId) {
    if (productId != BillingService.yearlyId) return null;
    final weekly = _billing.productFor(BillingService.weeklyId);
    final yearly = _billing.productFor(BillingService.yearlyId);
    if (weekly == null || yearly == null) return null;
    final weeklyAnnualCost = weekly.rawPrice * 52;
    if (weeklyAnnualCost <= 0) return null;
    final savings = (1 - (yearly.rawPrice / weeklyAnnualCost)) * 100;
    if (savings <= 0 || savings.isNaN) return null;
    return 'Save ${savings.round()}% vs weekly';
  }

  Widget _buildRestoreRow() {
    final linkStyle = TextStyle(
      color: Colors.white.withOpacity(0.72),
      fontSize: 11,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _launchUrl(AppLinks.privacyPolicy),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Privacy Policy', style: linkStyle),
            ),
          ),
        ),
        TextButton(
          onPressed: _billing.storeAvailable
              ? () {
                  HapticFeedback.selectionClick();
                  _billing.restorePurchases();
                  AppSnackBar.info(context, 'Checking for previous purchases...');
                }
              : null,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Restore Purchases',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _launchUrl(AppLinks.termsOfService),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Terms of Use', style: linkStyle),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCta() {
    final product = _selectedProduct;
    final meta = _planMeta.firstWhere((p) => p.productId == _selectedProductId);
    final canBuy = _billing.storeAvailable && product != null && !_billing.isPurchasePending;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingLarge,
        AppDimensions.paddingSmall,
        AppDimensions.paddingLarge,
        AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: _bgBottom,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canBuy
                        ? () {
                            HapticFeedback.mediumImpact();
                            _billing.buy(product);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      disabledBackgroundColor: _gold.withOpacity(0.4),
                      foregroundColor: const Color(0xFF1B2B3A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      ),
                      child: _billing.isPurchasePending
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B2B3A)),
                              ),
                            )
                          : FittedBox(
                              key: ValueKey(_selectedProductId),
                              fit: BoxFit.scaleDown,
                              child: Text(
                                product != null
                                    ? 'Continue \u00b7 ${product.price} / ${meta.name.toLowerCase()}'
                                    : 'Continue',
                                maxLines: 1,
                                softWrap: false,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                            ),
                    ),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scaleXY(
                  begin: 1.0,
                  end: 1.03,
                  duration: 1100.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 6),
            Text(
              'Cancel anytime \u00b7 Auto-renews until canceled',
              style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 10.5),
            ),
            const SizedBox(height: 6),
            _buildRestoreRow(),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _AlreadyProView extends StatelessWidget {
  final Color gold;
  final Color bgTop;
  final Color bgBottom;

  const _AlreadyProView({
    required this.gold,
    required this.bgTop,
    required this.bgBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBottom,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.16),
                    shape: BoxShape.circle,
                    border: Border.all(color: gold.withOpacity(0.4), width: 2),
                  ),
                  child: Icon(Icons.workspace_premium_rounded, color: gold, size: 52),
                ).animate().scale(duration: 450.ms, curve: Curves.easeOutBack),
                const SizedBox(height: AppDimensions.paddingLarge),
                const Text(
                  'You\'re a Pro Member!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 8),
                Text(
                  'You have full access to every premium template,\nan ad-free experience, and unlimited AI tools.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.4),
                ).animate().fadeIn(delay: 220.ms),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: const Color(0xFF1B2B3A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                      ),
                    ),
                    child: const Text('Awesome!',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  final _Benefit benefit;

  const _BenefitChip({required this.benefit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF4C05A).withOpacity(0.16),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
            ),
            child: Icon(benefit.icon, color: const Color(0xFFF4C05A), size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              benefit.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final _PlanMeta meta;
  final ProductDetails? product;
  final bool isLoading;
  final bool isSelected;
  final String? savingsLabel;
  final Color gold;
  final VoidCallback onTap;

  const _PlanCard({
    required this.meta,
    required this.product,
    required this.isLoading,
    required this.isSelected,
    required this.savingsLabel,
    required this.gold,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? gold.withOpacity(0.12) : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            border: Border.all(
              color: isSelected ? gold : Colors.white.withOpacity(0.1),
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? gold : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? gold : Colors.white.withOpacity(0.4),
                    width: 1.6,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, size: 15, color: Color(0xFF1B2B3A))
                    : null,
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          meta.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        if (meta.badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                            ),
                            child: Text(
                              meta.badge!,
                              style: const TextStyle(
                                color: Color(0xFF1B2B3A),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      savingsLabel ?? meta.subtitle,
                      style: TextStyle(
                        color: savingsLabel != null ? gold : Colors.white.withOpacity(0.55),
                        fontSize: 12,
                        fontWeight: savingsLabel != null ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                    )
                  : Text(
                      product?.price ?? '--',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreUnavailableCard extends StatelessWidget {
  final VoidCallback onRetry;

  const _StoreUnavailableCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, color: Colors.white.withOpacity(0.6), size: 30),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Store unavailable right now',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFF4C05A)),
            child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _SoftBlob({required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
        boxShadow: [
          BoxShadow(color: color.withOpacity(opacity * 0.6), blurRadius: 100, spreadRadius: 20),
        ],
      ),
    );
  }
}

class _PlanMeta {
  final String productId;
  final String name;
  final String subtitle;
  final String? badge;
  final IconData icon;

  const _PlanMeta({
    required this.productId,
    required this.name,
    required this.subtitle,
    required this.badge,
    required this.icon,
  });
}

class _Benefit {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
