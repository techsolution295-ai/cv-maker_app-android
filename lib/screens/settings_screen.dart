import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cv_ganerator/constants/app_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/constants/strings.dart';
import 'package:cv_ganerator/services/billing_service.dart';
import 'package:cv_ganerator/widgets/app_widgets.dart';

class SettingsScreen extends StatelessWidget {
  final bool showAppBar;

  const SettingsScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGoProCard(context),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildSettingsGroup([
            _SettingsItem(
              icon: Icons.support_agent_outlined,
              title: 'Support',
              onTap: _launchSupportEmail,
            ),
            _SettingsItem(
              icon: Icons.ios_share_rounded,
              title: 'Share App',
              onTap: _shareApp,
            ),
            _SettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: AppStrings.privacyPolicy,
              onTap: _launchPrivacy,
            ),
            _SettingsItem(
              icon: Icons.description_outlined,
              title: AppStrings.termsOfService,
              onTap: _launchTerms,
            ),
          ]),
          const SizedBox(height: AppDimensions.paddingMedium),
        ],
      ),
    );

    if (!showAppBar) return body;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppAppBar(title: AppStrings.settings),
      body: body,
    );
  }

  Widget _buildGoProCard(BuildContext context) {
    return AnimatedBuilder(
      animation: BillingService.instance,
      builder: (context, _) {
        final isPro = BillingService.instance.isPro;
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          child: InkWell(
            onTap: isPro ? null : () => Navigator.pushNamed(context, '/pro'),
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMedium),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                gradient: AppTheme.gradientBackground,
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.30),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const ProCrownIcon(
                      size: 22,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPro ? 'You\'re a Pro Member' : 'Upgrade to Pro',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isPro
                              ? 'Enjoy every premium feature, ad-free'
                              : 'Unlock templates, AI & remove ads',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPro
                          ? Icons.check_circle_rounded
                          : Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsGroup(List<_SettingsItem> items) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == items.length - 1 ? 0 : AppDimensions.paddingMedium,
            ),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: items[i],
            ),
          ),
      ],
    );
  }

  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _launchSupportEmail() => _launchUrl(AppLinks.supportEmailUri);
  void _launchPrivacy() => _launchUrl(AppLinks.privacyPolicy);
  void _launchTerms() => _launchUrl(AppLinks.termsOfService);

  void _shareApp() {
    Share.share(
      'Check out ${AppStrings.appName} \u2014 build a professional resume in minutes!\n${AppLinks.playStoreUrl}',
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  static const Color _accentColor = AppTheme.primaryColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: 14,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _accentColor, size: 20),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }
}
