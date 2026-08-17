import 'package:flutter/material.dart';
import 'package:cv_ganerator/services/ad_service.dart';

class AdNavigation {
  const AdNavigation._();

  static Future<void> openCreateResume(
    BuildContext context, {
    VoidCallback? onReturn,
  }) {
    return AdService.instance.showInterstitialThen(() {
      Navigator.pushNamed(context, '/create-resume').then((_) => onReturn?.call());
    });
  }
}
