import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:cv_ganerator/services/local_storage_service.dart';

/// Handles Google Play Billing: fetching live subscription prices and
/// running the purchase / restore flow for the Pro plans.
class BillingService extends ChangeNotifier {
  BillingService._internal();

  static final BillingService instance = BillingService._internal();

  static const String weeklyId = 'weekly_premium';
  static const String monthlyId = 'monthly_premium';
  static const String yearlyId = 'cv_yearly_premium';
  static const List<String> productIds = [weeklyId, monthlyId, yearlyId];

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _initialized = false;

  bool storeAvailable = false;
  bool isLoadingProducts = false;
  bool isPurchasePending = false;
  bool isPro = false;
  String? lastError;
  List<ProductDetails> products = const [];

  /// Set while we're re-checking the current entitlement against the store
  /// (e.g. on app start) to detect an expired/cancelled subscription.
  bool _sawActiveEntitlementDuringVerify = false;
  static const Duration _verifyWindow = Duration(seconds: 4);

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    isPro = LocalStorageService.instance.isProUser();

    try {
      storeAvailable = await _iap.isAvailable();
    } catch (_) {
      storeAvailable = false;
    }

    if (storeAvailable) {
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (Object error) {
          lastError = error.toString();
          notifyListeners();
        },
      );
      await loadProducts();
      unawaited(_verifyProStatus());
    } else {
      notifyListeners();
    }
  }

  /// Re-checks with the store (Play Billing) whether the previously granted
  /// subscription is still active. A cancelled subscription keeps working
  /// until its current billing period ends, and once it truly ends (or is
  /// refunded), the store stops returning it as an active purchase -- at
  /// that point we revoke local Pro access, so the app returns to its
  /// normal (ads, upgrade prompts) state automatically.
  Future<void> _verifyProStatus() async {
    final wasProBeforeVerify = isPro;
    _sawActiveEntitlementDuringVerify = false;
    try {
      await _iap.restorePurchases();
    } catch (_) {
      // Offline or store hiccup -- don't punish the user, keep the cached
      // local flag until we can verify again next launch.
      return;
    }
    await Future<void>.delayed(_verifyWindow);
    if (!_sawActiveEntitlementDuringVerify && wasProBeforeVerify) {
      await _revokePro();
    }
  }

  Future<void> loadProducts() async {
    if (!storeAvailable) return;
    isLoadingProducts = true;
    lastError = null;
    notifyListeners();
    try {
      final response = await _iap.queryProductDetails(productIds.toSet());
      if (response.error != null) {
        lastError = response.error!.message;
      }
      products = response.productDetails;
    } catch (e) {
      lastError = e.toString();
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  ProductDetails? productFor(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<void> buy(ProductDetails product) async {
    lastError = null;
    isPurchasePending = true;
    notifyListeners();
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      isPurchasePending = false;
      lastError = 'Could not start the purchase. Please try again.';
      notifyListeners();
    }
  }

  Future<void> restorePurchases() async {
    lastError = null;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      lastError = 'Could not restore purchases. Please try again.';
      notifyListeners();
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          isPurchasePending = true;
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          isPurchasePending = false;
          if (productIds.contains(purchase.productID)) {
            _sawActiveEntitlementDuringVerify = true;
          }
          await _grantPro();
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.error:
          isPurchasePending = false;
          lastError =
              purchase.error?.message ?? 'Purchase failed. Please try again.';
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.canceled:
          isPurchasePending = false;
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
      }
    }
    notifyListeners();
  }

  Future<void> _grantPro() async {
    isPro = true;
    await LocalStorageService.instance.setProUser(true);
    notifyListeners();
  }

  Future<void> _revokePro() async {
    isPro = false;
    await LocalStorageService.instance.setProUser(false);
    notifyListeners();
  }

  /// Debug-only helper to force Pro on/off from a developer toggle, without
  /// touching the real Play Billing flow. No-op in release builds so it can
  /// never be misused in production.
  Future<void> debugSetPro(bool value) async {
    if (!kDebugMode) return;
    isPro = value;
    await LocalStorageService.instance.setProUser(value);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
