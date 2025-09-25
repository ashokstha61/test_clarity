import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class SubscriptionManagement {
  static final SubscriptionManagement _instance =
  SubscriptionManagement._internal();

  factory SubscriptionManagement() => _instance;

  SubscriptionManagement._internal();

  /// Present the RevenueCat paywall
  Future<PaywallResult> presentPaywall() async {
    try {
      final PaywallResult result = await RevenueCatUI.presentPaywall();

      switch (result) {
        case PaywallResult.purchased:
          print("✅ User completed purchase!");
          return PaywallResult.purchased;
        case PaywallResult.cancelled:
          print("❌ User cancelled paywall");
          return PaywallResult.cancelled;
        case PaywallResult.notPresented:
          print("⚠️ Paywall could not be presented");
          return PaywallResult.notPresented;
        case PaywallResult.error:
          print("⚠️ Error presenting paywall");
          return PaywallResult.error;
        case PaywallResult.restored:
          throw UnimplementedError();
      }
    } catch (e) {
      print("⚠️ Paywall error: $e");
      return PaywallResult.error;
    }
  }

  /// Present paywall with specific offering
  Future<PaywallResult> presentPaywallWithOffering(String offeringIdentifier) async {
    try {
      final PaywallResult result = await RevenueCatUI.presentPaywallIfNeeded(
        offeringIdentifier,
      );

      return result;
    } catch (e) {
      print("⚠️ Paywall error: $e");
      return PaywallResult.error;
    }
  }

  /// Fetch available offerings
  Future<List<Package>> fetchPackages() async {
    try {
      print("🔄 Fetching offerings...");
      final offerings = await Purchases.getOfferings();

      print("📦 Total offerings: ${offerings.all.length}");
      print("📦 Current offering: ${offerings.current?.identifier ?? 'null'}");

      if (offerings.current != null) {
        print("📦 Available packages: ${offerings.current!.availablePackages.length}");
        for (var package in offerings.current!.availablePackages) {
          print("   - ${package.identifier}: ${package.storeProduct.title}");
        }

        if (offerings.current!.availablePackages.isNotEmpty) {
          return offerings.current!.availablePackages;
        }
      } else {
        print("⚠️ No current offering found");
      }
    } catch (e) {
      print("⚠️ Error fetching offerings: $e");
    }
    return [];
  }

  /// Purchase a selected package
  Future<bool> purchase(Package package) async {
    try {
      final PurchaseResult purchaseResult = await Purchases.purchasePackage(package);

      // Get CustomerInfo from the PurchaseResult
      final CustomerInfo customerInfo = purchaseResult.customerInfo;

      final isPremium =
          customerInfo.entitlements.all["premium"]?.isActive ?? false;

      return isPremium;
    } catch (e) {
      print("⚠️ Purchase failed: $e");
      return false;
    }
  }

  /// Restore purchases (useful for iOS)
  Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      print("⚠️ Restore failed: $e");
    }
  }

  /// Check if user already has subscription
  Future<bool> hasPremiumAccess() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all["premium"]?.isActive ?? false;
    } catch (e) {
      print("⚠️ Failed to check entitlement: $e");
      return false;
    }
  }
}
