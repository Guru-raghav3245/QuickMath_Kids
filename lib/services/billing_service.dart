import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final billingServiceProvider = ChangeNotifierProvider<BillingService>((ref) {
  final billingService = BillingService();
  billingService.initialize();
  ref.onDispose(() => billingService.dispose());
  return billingService;
});

class BillingService extends ChangeNotifier {
  static const String _premiumProductId = 'premium_plan';
  static const String _premiumKey = 'is_premium';
  static const String _resetKey = 'is_reset';
  static final BillingService _instance = BillingService._internal();
  final InAppPurchase _iap = InAppPurchase.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isPremium = false;
  bool _isInitialized = false;
  bool _isReset = false;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  factory BillingService() => _instance;

  BillingService._internal();

  bool get isPremium => _isPremium;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Load cached status immediately (FAST)
      await _loadCachedStatus();
    } catch (e) {
      debugPrint('BillingService: Error loading cached status: $e');
      _isPremium = false;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }

    // 2. Perform network checks in background (SLOW)
    // We do not await this, so the app startup is not blocked.
    _performBackgroundVerification();
  }

  Future<void> _performBackgroundVerification() async {
    if (!Platform.isAndroid) {
      debugPrint('BillingService: This app only supports Android billing.');
      return;
    }

    final bool available;
    try {
      available = await _iap.isAvailable();
    } catch (e) {
      debugPrint('BillingService: Error checking billing availability: $e');
      return;
    }

    if (!available) {
      debugPrint(
          'BillingService: In-app purchase not available on this device');
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () {
        debugPrint('BillingService: Purchase stream done');
        _subscription?.cancel();
      },
      onError: (error) {
        debugPrint('BillingService: Purchase stream error: $error');
      },
    );

    // Verify actual purchase status with store
    await _verifyPurchaseStatus();
  }

  Future<void> _loadCachedStatus() async {
    final results = await Future.wait([
      _storage.read(key: _premiumKey),
      _storage.read(key: _resetKey),
    ]);
    String? localPremium = results[0];
    String? localReset = results[1];

    _isReset = localReset == 'true';

    if (_isReset) {
      _isPremium = false;
    } else {
      _isPremium = localPremium == 'true';
    }
    debugPrint('BillingService: Loaded cached premium status: $_isPremium');
  }

  Future<void> _verifyPurchaseStatus() async {
    String? localPremium = await _storage.read(key: _premiumKey);
    // _isReset is already loaded by _loadCachedStatus, but we re-read or use state
    // For safety in this background check, let's re-read or rely on current state.
    // To keep logic simple and self-contained for verification:
    String? localReset = await _storage.read(key: _resetKey);
    bool isReset = localReset == 'true';

    if (isReset) {
      _isPremium = false;
      await _storage.write(key: _premiumKey, value: 'false');
      await _storage.write(key: _resetKey, value: 'false');
      debugPrint('BillingService: Reset applied, premium revoked');
      notifyListeners();
      return;
    }

    bool isPurchased = false;
    final Completer<bool> completer = Completer<bool>();

    StreamSubscription<List<PurchaseDetails>>? tempSubscription;
    tempSubscription = _iap.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        debugPrint(
            'BillingService: Received purchase details: $purchaseDetailsList');
        for (var purchase in purchaseDetailsList) {
          if (purchase.productID == _premiumProductId) {
            if (purchase.status == PurchaseStatus.purchased ||
                purchase.status == PurchaseStatus.restored) {
              isPurchased = true;
              completer.complete(true);
              tempSubscription?.cancel();
              break;
            } else if (purchase.status == PurchaseStatus.error) {
              debugPrint('BillingService: Purchase error: ${purchase.error}');
              completer.complete(false);
              tempSubscription?.cancel();
              break;
            }
          }
        }
      },
      onDone: () {
        debugPrint('BillingService: Purchase stream done during restore');
        if (!completer.isCompleted) completer.complete(false);
      },
      onError: (error) {
        debugPrint('BillingService: Restore purchases error: $error');
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('BillingService: Error triggering restore purchases: $e');
      if (!completer.isCompleted) completer.complete(false);
    }

    await completer.future.timeout(const Duration(seconds: 15), onTimeout: () {
      debugPrint('BillingService: Restore purchases timed out');
      return false;
    }).catchError((e) {
      debugPrint('BillingService: Restore error caught: $e');
      return false;
    });

    await tempSubscription.cancel();

    if (isPurchased) {
      if (localPremium != 'true') {
        await _storage.write(key: _premiumKey, value: 'true');
      }
      _isPremium = true;
      _isReset = false;
      await _storage.write(key: _resetKey, value: 'false');
      debugPrint('BillingService: Premium status confirmed');
    } else {
      if (localPremium != 'false') {
        await _storage.write(key: _premiumKey, value: 'false');
      }
      _isPremium = false;
      _isReset = false;
      await _storage.write(key: _resetKey, value: 'false');
      debugPrint('BillingService: No premium purchase found');
    }
    notifyListeners();
  }

  Future<bool> purchasePremium(BuildContext context) async {
    if (!Platform.isAndroid) {
      _showSnackBar(context, 'Purchases are only supported on Android.');
      return false;
    }

    final bool available;
    try {
      available = await _iap.isAvailable();
    } catch (e) {
      debugPrint('BillingService: Error checking billing availability: $e');
      _showSnackBar(context, 'In-app purchases are not available.');
      return false;
    }

    if (!available) {
      _showSnackBar(context, 'In-app purchases are not available.');
      return false;
    }

    final ProductDetailsResponse response =
        await _iap.queryProductDetails({_premiumProductId});
    if (response.error != null || response.productDetails.isEmpty) {
      debugPrint('BillingService: Product query error: ${response.error}');
      _showSnackBar(context, 'Product not found. Please try again later.');
      return false;
    }

    final ProductDetails product = response.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      debugPrint('BillingService: Purchase error: $e');
      if (e.toString().contains('itemAlreadyOwned')) {
        _isPremium = true;
        _isReset = false;
        await _storage.write(key: _premiumKey, value: 'true');
        await _storage.write(key: _resetKey, value: 'false');
        debugPrint(
            'BillingService: Item already owned, premium status granted');
        notifyListeners();
        _showSnackBar(context, 'You already own Premium! Access granted.');
        return true;
      }
      _showSnackBar(context, 'Failed to initiate purchase. Please try again.');
      return false;
    }
  }

  Future<void> restorePurchase() async {
    _isReset = false;
    await _storage.write(key: _resetKey, value: 'false');
    await _verifyPurchaseStatus();
    notifyListeners();
  }

  Future<void> resetPremium() async {
    _isPremium = false;
    _isReset = true;
    await _storage.write(key: _premiumKey, value: 'false');
    await _storage.write(key: _resetKey, value: 'true');
    debugPrint('BillingService: Premium access reset locally');
    notifyListeners();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.productID == _premiumProductId) {
        switch (purchase.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            _isPremium = true;
            _isReset = false;
            _storage.write(key: _premiumKey, value: 'true');
            _storage.write(key: _resetKey, value: 'false');
            _iap.completePurchase(purchase);
            debugPrint(
                'BillingService: Premium purchased/restored successfully');
            notifyListeners();
            break;
          case PurchaseStatus.pending:
            debugPrint('BillingService: Purchase pending');
            break;
          case PurchaseStatus.error:
            debugPrint('BillingService: Purchase error: ${purchase.error}');
            break;
          case PurchaseStatus.canceled:
            debugPrint('BillingService: Purchase canceled');
            break;
        }
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
