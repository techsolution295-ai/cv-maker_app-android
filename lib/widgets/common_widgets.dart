import 'package:flutter/material.dart';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/constants/dimensions.dart';

enum AppSnackType { success, error, info }

class AppSnackBar {
  const AppSnackBar._();

  static void success(BuildContext context, String message) =>
      _show(context, message, AppSnackType.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppSnackType.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, AppSnackType.info);

  static void _show(
    BuildContext context,
    String message,
    AppSnackType type,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    final config = _configFor(type);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.textDark,
        elevation: 6,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        content: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(config.icon, color: config.color, size: 18),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        color: pillColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(color: pillColor.withOpacity(0.3)),
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
