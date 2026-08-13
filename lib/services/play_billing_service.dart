import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

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

  Future<bool> purchase(ProductDetails product, {String? accountName}) async {
    if (product is! GooglePlayProductDetails || product.offerToken == null) {
      _onMessage?.call(
        'Este plano não está disponível para assinatura no momento. Atualize o aplicativo e tente novamente.',
      );
      return false;
    }

    try {
      return await _store.buyNonConsumable(
        purchaseParam: GooglePlayPurchaseParam(
          productDetails: product,
          offerToken: product.offerToken,
          applicationUserName: obfuscatePlayAccountId(accountName),
        ),
      );
    } on PlatformException {
      _onMessage?.call(
        'Não foi possível abrir a assinatura no Google Play. Verifique se o aplicativo está atualizado e tente novamente.',
      );
      return false;
    }
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
        _onMessage?.call(playPurchaseErrorMessage(purchase.error));
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

String? obfuscatePlayAccountId(String? accountName) {
  final normalized = accountName?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;
  return sha256.convert(utf8.encode('aumiau:$normalized')).toString();
}

String playPurchaseErrorMessage(IAPError? error) {
  final technicalMessage = '${error?.code} ${error?.message}'.toLowerCase();
  if (technicalMessage.contains('developererror') ||
      technicalMessage.contains('developer_error')) {
    return 'Não foi possível iniciar a assinatura. Atualize o aplicativo pela Google Play e tente novamente.';
  }
  return 'Não foi possível concluir a compra pelo Google Play. Tente novamente em instantes.';
}
