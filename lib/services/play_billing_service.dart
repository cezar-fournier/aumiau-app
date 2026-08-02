import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

typedef PlayPurchaseVerifier =
    Future<bool> Function(String productId, String purchaseToken);

class PlayBillingService {
  static const productIds = <String>{'family_monthly', 'family_yearly'};

  final InAppPurchase _store = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  PlayPurchaseVerifier? _verifier;
  ValueChanged<String>? _onMessage;

  bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> initialize({
    required PlayPurchaseVerifier verifier,
    required ValueChanged<String> onMessage,
  }) async {
    _verifier = verifier;
    _onMessage = onMessage;
    if (!supported || _subscription != null) return;
    _subscription = _store.purchaseStream.listen(
      _handlePurchases,
      onError: (_) => _onMessage?.call(
        'Não foi possível receber a atualização da compra no Google Play.',
      ),
    );
  }

  Future<Map<String, ProductDetails>> loadProducts() async {
    if (!supported || !await _store.isAvailable()) return const {};
    final response = await _store.queryProductDetails(productIds);
    if (response.error != null) {
      _onMessage?.call('Não foi possível consultar os planos no Google Play.');
    }
    return {for (final product in response.productDetails) product.id: product};
  }

  Future<bool> purchase(ProductDetails product, {String? accountName}) {
    return _store.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: product,
        applicationUserName: accountName,
      ),
    );
  }

  Future<void> restore() => _store.restorePurchases();

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        _onMessage?.call(
          'A compra está pendente de confirmação pelo Google Play.',
        );
        continue;
      }
      if (purchase.status == PurchaseStatus.error) {
        _onMessage?.call(
          purchase.error?.message ?? 'Não foi possível concluir a compra.',
        );
        continue;
      }
      if (purchase.status == PurchaseStatus.canceled) {
        _onMessage?.call('Compra cancelada.');
        continue;
      }
      if (purchase.status != PurchaseStatus.purchased &&
          purchase.status != PurchaseStatus.restored) {
        continue;
      }
      final token = purchase.verificationData.serverVerificationData;
      final verified =
          token.isNotEmpty &&
          await (_verifier?.call(purchase.productID, token) ??
              Future<bool>.value(false));
      if (!verified) {
        _onMessage?.call(
          'A compra não pôde ser validada pelo servidor. Use Restaurar compras para tentar novamente.',
        );
        continue;
      }
      if (purchase.pendingCompletePurchase) {
        await _store.completePurchase(purchase);
      }
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
