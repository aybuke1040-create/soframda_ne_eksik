import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
  final Map<String, Completer<PurchaseFlowResult>> _pendingPurchases = {};
  final List<String> _productIds = const [
    'credits_50',
    'credits_120',
    'credits_300',
  ];
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
        message: 'Magaza baglantisi su an kullanilamiyor.',
      );
    }

    if (_pendingPurchases.containsKey(product.id)) {
      return const PurchaseFlowResult(
        status: PurchaseFlowStatus.failed,
        message: 'Bu satin alma istegi zaten isleniyor.',
      );
    }

    final completer = Completer<PurchaseFlowResult>();
    _pendingPurchases[product.id] = completer;

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
          message: 'Satin alma baslatilamadi.',
        );
      }

      return completer.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          _pendingPurchases.remove(product.id);
          return const PurchaseFlowResult(
            status: PurchaseFlowStatus.failed,
            message: 'Satin alma dogrulamasi zaman asimina ugradi.',
          );
        },
      );
    } catch (_) {
      _pendingPurchases.remove(product.id);
      return const PurchaseFlowResult(
        status: PurchaseFlowStatus.failed,
        message: 'Satin alma su an tamamlanamadi.',
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
              message: 'Satin alma iptal edildi.',
            ),
          );
          break;
        case PurchaseStatus.error:
          await _completePendingPurchaseIfNeeded(purchase);
          _completePurchaseResult(
            purchase.productID,
            PurchaseFlowResult(
              status: PurchaseFlowStatus.failed,
              message: purchase.error?.message ??
                  'Satin alma su an tamamlanamadi.',
            ),
          );
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndGrantPurchase(purchase);
          break;
      }
    }
  }

  Future<void> _verifyAndGrantPurchase(PurchaseDetails purchase) async {
    try {
      final purchaseToken = purchase.verificationData.serverVerificationData;
      if (purchaseToken.trim().isEmpty) {
        throw Exception('Satin alma dogrulamasi alinamadi.');
      }

      final callable = _functions.httpsCallable('verifyAndGrantAndroidPurchase');
      final result = await callable.call({
        'productId': purchase.productID,
        'purchaseToken': purchaseToken,
        'purchaseId': purchase.purchaseID ?? '',
        'source': purchase.verificationData.source,
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final grantedCredits = (data['grantedCredits'] as num?)?.toInt() ?? 0;
      final alreadyGranted = data['alreadyGranted'] == true;

      await _completePendingPurchaseIfNeeded(purchase);

      _completePurchaseResult(
        purchase.productID,
        PurchaseFlowResult(
          status: PurchaseFlowStatus.success,
          message: alreadyGranted
              ? 'Bu satin alma daha once islenmis.'
              : '$grantedCredits kredi hesabina eklendi.',
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      _completePurchaseResult(
        purchase.productID,
        PurchaseFlowResult(
          status: PurchaseFlowStatus.failed,
          message: e.message ?? 'Satin alma dogrulanamadi.',
        ),
      );
    } catch (_) {
      _completePurchaseResult(
        purchase.productID,
        const PurchaseFlowResult(
          status: PurchaseFlowStatus.failed,
          message: 'Satin alma dogrulanamadi.',
        ),
      );
    }
  }

  Future<void> _completePendingPurchaseIfNeeded(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  void _completePurchaseResult(String productId, PurchaseFlowResult result) {
    final completer = _pendingPurchases.remove(productId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }
}
