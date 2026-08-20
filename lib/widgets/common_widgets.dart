import 'package:flutter/material.dart';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/constants/dimensions.dart';

enum AppSnackType { success, error, info }

class AppSnackBar {
  const AppSnackBar._();

  static OverlayEntry? _entry;

  static void success(BuildContext context, String message) =>
      _show(context, message, AppSnackType.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppSnackType.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, AppSnackType.info);

  static void hide() {
    _entry?.remove();
    _entry = null;
  }

  static void _show(
    BuildContext context,
    String message,
    AppSnackType type,
  ) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    hide();
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();

    final config = _configFor(type);
    final media = MediaQuery.of(context);
    final scaffold = Scaffold.maybeOf(context);
    final hasAppBar = scaffold?.widget.appBar != null;
    final top = media.padding.top + (hasAppBar ? kToolbarHeight : 8) + 8;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _TopNotice(
        top: top,
        message: message,
        icon: config.icon,
        accent: config.color,
        onFinished: () {
          if (_entry == entry) hide();
        },
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  static _SnackConfig _configFor(AppSnackType type) {
    switch (type) {
      case AppSnackType.success:
        return const _SnackConfig(
          Icons.check_circle_rounded,
          AppTheme.successColor,
        );
      case AppSnackType.error:
        return const _SnackConfig(
          Icons.error_rounded,
          AppTheme.errorColor,
        );
      case AppSnackType.info:
        return const _SnackConfig(
          Icons.info_rounded,
          AppTheme.accentColor,
        );
    }
  }
}

class _SnackConfig {
  final IconData icon;
  final Color color;
  const _SnackConfig(this.icon, this.color);
}

class _TopNotice extends StatefulWidget {
  final double top;
  final String message;
  final IconData icon;
  final Color accent;
  final VoidCallback onFinished;

  const _TopNotice({
    required this.top,
    required this.message,
    required this.icon,
    required this.accent,
    required this.onFinished,
  });

  @override
  State<_TopNotice> createState() => _TopNoticeState();
}

class _TopNoticeState extends State<_TopNotice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    Future<void>.delayed(const Duration(milliseconds: 2400), () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Material(
              color: Colors.white,
              elevation: 8,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(widget.icon, color: widget.accent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? elevation;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? AppTheme.cardColor,
      elevation: elevation ?? AppDimensions.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppDimensions.borderRadiusLarge,
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppDimensions.paddingMedium),
        child: child,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: AppDimensions.paddingXSmall),
                Text(subtitle!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class InfoPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const InfoPill({
    super.key,
    required this.label,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pillColor = color ?? AppTheme.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(color: pillColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSizeSmall, color: pillColor),
          const SizedBox(width: AppDimensions.paddingSmall),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: pillColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
