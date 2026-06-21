import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

enum PurchaseFlowStatus {
  success,
  cancelled,
  failed,
}

class PurchaseFlowResult {
  final PurchaseFlowStatus status;
  final String message;

  const PurchaseFlowResult({
    required this.status,
    required this.message,
  });
}

class _PendingPurchaseRequest {
  final Completer<PurchaseFlowResult> completer;
  final DateTime startedAt;

  _PendingPurchaseRequest()
      : completer = Completer<PurchaseFlowResult>(),
        startedAt = DateTime.now();

  bool get isStale {
    return DateTime.now().difference(startedAt) > const Duration(seconds: 45);
  }
}

class IAPService {
  IAPService._internal() {
    _purchaseSubscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {},
    );
  }

  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;

  final InAppPurchase _iap = InAppPurchase.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final Map<String, _PendingPurchaseRequest> _pendingPurchases = {};
  final List<String> _productIds = const [
    'credits_50',
    'credits_120',
    'credits_300',
  ];

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  // Keep the subscription alive for the singleton service lifetime.
  // ignore: unused_field
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  Future<List<ProductDetails>> loadProducts() async {
    final response = await _iap.queryProductDetails(_productIds.toSet());
    final products = [...response.productDetails];
    products.sort(
      (a, b) => _productIds.indexOf(a.id).compareTo(_productIds.indexOf(b.id)),
    );
    return products;
  }

  Future<PurchaseFlowResult> buy(ProductDetails product) async {
    final isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      return const PurchaseFlowResult(
        status: PurchaseFlowStatus.failed,
        message: 'Mağaza bağlantısı şu an kullanılamıyor.',
      );
    }

    final existingPendingPurchase = _pendingPurchases[product.id];
    if (existingPendingPurchase != null && !existingPendingPurchase.isStale) {
      return const PurchaseFlowResult(
        status: PurchaseFlowStatus.failed,
        message:
            'Bu satın alma isteği mağaza tarafında hâlâ işleniyor. Kısa süre sonra tekrar dene.',
      );
    }

    if (existingPendingPurchase != null && existingPendingPurchase.isStale) {
      _pendingPurchases.remove(product.id);
    }

    final recoveredPurchase = await _recoverOwnedProductIfNeeded(
      product.id,
      cleanIncompletePurchase: true,
    );
    if (recoveredPurchase != null) {
      return recoveredPurchase;
    }

    final pendingPurchase = _PendingPurchaseRequest();
    _pendingPurchases[product.id] = pendingPurchase;

    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      final started = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: false,
      );

      if (!started) {
        _pendingPurchases.remove(product.id);
        return const PurchaseFlowResult(
          status: PurchaseFlowStatus.failed,
          message: 'Satın alma başlatılamadı.',
        );
      }

      return pendingPurchase.completer.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          _pendingPurchases.remove(product.id);
          return const PurchaseFlowResult(
            status: PurchaseFlowStatus.failed,
            message: 'Satın alma doğrulaması zaman aşımına uğradı.',
          );
        },
      );
    } on PlatformException catch (e) {
      _pendingPurchases.remove(product.id);
      if (_isAndroidAlreadyOwnedError(e)) {
        final recoveredPurchase =
            await _recoverOwnedProductIfNeeded(product.id);
        if (recoveredPurchase != null) {
          return recoveredPurchase;
        }
      }

      return PurchaseFlowResult(
        status: PurchaseFlowStatus.failed,
        message: e.message ?? 'Satın alma şu an tamamlanamadı.',
      );
    } catch (_) {
      _pendingPurchases.remove(product.id);
      return const PurchaseFlowResult(
        status: PurchaseFlowStatus.failed,
        message: 'Satın alma şu an tamamlanamadı.',
      );
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.canceled:
          await _completePendingPurchaseIfNeeded(purchase);
          _completePurchaseResult(
            purchase.productID,
            const PurchaseFlowResult(
              status: PurchaseFlowStatus.cancelled,
              message: 'Satın alma iptal edildi.',
            ),
          );
          break;
        case PurchaseStatus.error:
          await _completePendingPurchaseIfNeeded(purchase);
          _completePurchaseResult(
            purchase.productID,
            PurchaseFlowResult(
              status: PurchaseFlowStatus.failed,
              message:
                  purchase.error?.message ?? 'Satın alma şu an tamamlanamadı.',
            ),
          );
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final result = await _verifyAndGrantPurchase(
            purchase,
            retryIncompletePurchase: true,
          );
          _completePurchaseResult(purchase.productID, result);
          break;
      }
    }
  }

  Future<PurchaseFlowResult> _verifyAndGrantPurchase(
    PurchaseDetails purchase, {
    bool retryIncompletePurchase = false,
  }) async {
    const maxAttempts = 4;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final result = await _verifyAndGrantPurchaseOnce(purchase);
      if (!retryIncompletePurchase ||
          !_isPurchaseNotCompletedResult(result) ||
          attempt == maxAttempts - 1) {
        return result;
      }

      await Future<void>.delayed(const Duration(milliseconds: 1500));
    }

    return const PurchaseFlowResult(
      status: PurchaseFlowStatus.failed,
      message: 'Satın alma doğrulanamadı.',
    );
  }

  Future<PurchaseFlowResult> _verifyAndGrantPurchaseOnce(
    PurchaseDetails purchase,
  ) async {
    try {
      final purchaseToken = purchase.verificationData.serverVerificationData;
      if (purchaseToken.trim().isEmpty) {
        throw Exception('Satın alma doğrulaması alınamadı.');
      }

      final result = await _callPurchaseVerifier(purchase);

      final data = Map<String, dynamic>.from(result.data as Map);
      final grantedCredits = (data['grantedCredits'] as num?)?.toInt() ?? 0;
      final alreadyGranted = data['alreadyGranted'] == true;

      await _consumeAndroidPurchaseIfNeeded(purchase);
      await _completePendingPurchaseIfNeeded(purchase);

      return PurchaseFlowResult(
        status: PurchaseFlowStatus.success,
        message: alreadyGranted
            ? 'Bu satın alma daha önce işlenmiş ve ürün temizlendi. Tekrar satın alabilirsin.'
            : '$grantedCredits kredi hesabina eklendi.',
      );
    } on FirebaseFunctionsException catch (e) {
      return PurchaseFlowResult(
        status: PurchaseFlowStatus.failed,
        message: e.message ?? 'Satın alma doğrulanamadı.',
      );
    } catch (_) {
      return const PurchaseFlowResult(
        status: PurchaseFlowStatus.failed,
        message: 'Satın alma doğrulanamadı.',
      );
    }
  }

  Future<void> _completePendingPurchaseIfNeeded(
      PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  Future<void> _consumeAndroidPurchaseIfNeeded(PurchaseDetails purchase) async {
    if (!_isAndroid) {
      return;
    }

    final androidAddition =
        _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    await androidAddition.consumePurchase(purchase);
  }

  Future<HttpsCallableResult<dynamic>> _callPurchaseVerifier(
    PurchaseDetails purchase,
  ) {
    if (_isIOS) {
      final callable = _functions.httpsCallable('verifyAndGrantApplePurchase');
      return callable.call({
        'productId': purchase.productID,
        'receiptData': purchase.verificationData.serverVerificationData,
        'transactionId': purchase.purchaseID ?? '',
        'purchaseId': purchase.purchaseID ?? '',
        'source': purchase.verificationData.source,
      });
    }

    final callable = _functions.httpsCallable('verifyAndGrantAndroidPurchase');
    return callable.call({
      'productId': purchase.productID,
      'purchaseToken': purchase.verificationData.serverVerificationData,
      'purchaseId': purchase.purchaseID ?? '',
      'source': purchase.verificationData.source,
    });
  }

  Future<PurchaseFlowResult?> _recoverOwnedProductIfNeeded(
    String productId, {
    bool cleanIncompletePurchase = false,
  }) async {
    if (!_isAndroid) {
      return null;
    }

    final androidAddition =
        _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final response = await androidAddition.queryPastPurchases();

    for (final purchase in response.pastPurchases) {
      if (purchase.productID != productId) {
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final result = await _verifyAndGrantPurchase(purchase);
        if (cleanIncompletePurchase && _isPurchaseNotCompletedResult(result)) {
          await _consumeAndroidPurchaseIfNeeded(purchase);
          await _completePendingPurchaseIfNeeded(purchase);
          return const PurchaseFlowResult(
            status: PurchaseFlowStatus.failed,
            message:
                'Google Play tarafında takılı kalan eski satın alma kaydı temizlendi. Lütfen tekrar satın almayı dene.',
          );
        }

        return result;
      } else {
        await _completePendingPurchaseIfNeeded(purchase);
      }
    }

    return null;
  }

  void _completePurchaseResult(String productId, PurchaseFlowResult result) {
    final pendingPurchase = _pendingPurchases.remove(productId);
    final completer = pendingPurchase?.completer;
    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }

  bool _isAndroidAlreadyOwnedError(PlatformException error) {
    final code = error.code.toLowerCase();
    final message = (error.message ?? '').toLowerCase();
    return code.contains('item_already_owned') ||
        code.contains('already_owned') ||
        message.contains('already own') ||
        message.contains('already owned') ||
        message.contains('zaten');
  }

  bool _isPurchaseNotCompletedResult(PurchaseFlowResult result) {
    return result.status == PurchaseFlowStatus.failed &&
        result.message.toLowerCase().contains('purchase is not completed');
  }
}
