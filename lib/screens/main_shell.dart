import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/constants/strings.dart';
import 'package:cv_ganerator/screens/home_screen.dart';
import 'package:cv_ganerator/screens/settings_screen.dart';
import 'package:cv_ganerator/screens/template_screen.dart';
import 'package:cv_ganerator/services/billing_service.dart';
import 'package:cv_ganerator/widgets/app_widgets.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final PageStorageBucket _bucket = PageStorageBucket();
  int _currentIndex = 0;

  // Tabs are mounted lazily -- only once the user actually visits them --
  // so e.g. the Templates tab's banner ad doesn't fire an ad request (in
  // parallel with Home's) before the user has ever opened that tab.
  final Set<int> _visitedIndices = {0};

  @override
  void initState() {
    super.initState();
    BillingService.instance.addListener(_onBillingChanged);
  }

  @override
  void dispose() {
    BillingService.instance.removeListener(_onBillingChanged);
    super.dispose();
  }

  void _onBillingChanged() {
    if (mounted) setState(() {});
  }

  List<_ShellTab> _buildTabs(BuildContext context) {
    final isPro = BillingService.instance.isPro;
    return [
      _ShellTab(
        title: 'Home',
        label: 'Home',
        titleWidget: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              'Build, polish, share',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
            ),
          ],
        ),
        showGradient: false,
        centerTitle: false,
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        body: const HomeScreen(showAppBar: false),
        actions: isPro
            ? null
            : [
                Padding(
                  padding: const EdgeInsets.only(
                    right: AppDimensions.paddingSmall,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/pro'),
                    tooltip: 'Go Pro',
                    icon: const ProCrownIcon(size: 32),
                  ),
                ),
              ],
      ),
      _ShellTab(
        title: AppStrings.templates,
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.dashboard_customize_rounded,
                color: AppTheme.primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Text(
              AppStrings.templates,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
            ),
          ],
        ),
        centerTitle: false,
        icon: Icons.dashboard_customize_outlined,
        activeIcon: Icons.dashboard_customize_rounded,
        body: const TemplateScreen(showAppBar: false),
        actions: isPro
            ? null
            : [
                Padding(
                  padding: const EdgeInsets.only(
                    right: AppDimensions.paddingSmall,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/pro'),
                    tooltip: 'Go Pro',
                    icon: const ProCrownIcon(size: 32),
                  ),
                ),
              ],
      ),
      _ShellTab(
        title: AppStrings.settings,
        label: AppStrings.settings,
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        body: const SettingsScreen(showAppBar: false),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _buildTabs(context);
    final tab = tabs[_currentIndex];
    return Scaffold(
      appBar: AppAppBar(
        title: tab.title,
        titleWidget: tab.titleWidget,
        actions: tab.actions,
        showGradient: tab.showGradient,
        centerTitle: tab.centerTitle,
      ),
      body: SafeArea(
        child: PageStorage(
          bucket: _bucket,
          child: IndexedStack(
            index: _currentIndex,
            children: [
              for (var i = 0; i < tabs.length; i++)
                KeyedSubtree(
                  key: PageStorageKey<String>('tab_$i'),
                  child: _visitedIndices.contains(i)
                      ? tabs[i].body
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        tabs: tabs,
        onTap: (index) => setState(() {
          _currentIndex = index;
          _visitedIndices.add(index);
        }),
      ),
      floatingActionButton: kDebugMode ? const _DebugProToggle() : null,
    );
  }
}

/// Debug-only floating switch to force Pro on/off while testing in-app
/// purchases, without going through the real Play Billing flow. This
/// widget is only ever built when `kDebugMode` is true, so it never
/// appears in a release build.
class _DebugProToggle extends StatelessWidget {
  const _DebugProToggle();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: BillingService.instance,
      builder: (context, _) {
        final isPro = BillingService.instance.isPro;
        return GestureDetector(
          onTap: () => BillingService.instance.debugSetPro(!isPro),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isPro ? Colors.green.shade600 : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPro ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isPro ? 'DEBUG: PRO ON' : 'DEBUG: PRO OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_ShellTab> tabs;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cardColor,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium,
        AppDimensions.paddingSmall,
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) {
            final tab = tabs[index];
            final isActive = index == currentIndex;
            final color = isActive ? AppTheme.primaryColor : AppTheme.textLight;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusLarge,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSmall,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusLarge,
                    ),
                    boxShadow: const [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        scale: isActive ? 1.08 : 1.0,
                        child: Icon(
                          isActive ? tab.activeIcon : tab.icon,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: color,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500,
                            ),
                        child: Text(
                          tab.label ?? tab.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShellTab {
  final String title;
  final String? label;
  final Widget? titleWidget;
  final IconData icon;
  final IconData activeIcon;
  final Widget body;
  final List<Widget>? actions;
  final bool showGradient;
  final bool centerTitle;

  const _ShellTab({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.body,
    this.actions,
    this.label,
    this.titleWidget,
    this.showGradient = false,
    this.centerTitle = true,
  });
}
