import 'package:cloud_functions/cloud_functions.dart';

import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';

import '../core/config/payment_config.dart';

class PaystackService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<bool> fundWallet({
    required BuildContext context,
    required String email,
    required double amount,
  }) async {
    bool success = false;

    final reference = "PV-${DateTime.now().millisecondsSinceEpoch}";

    await FlutterPaystackPlus.openPaystackPopup(
      context: context,
      customerEmail: email,
      amount: (amount * 100).toInt().toString(),
      reference: reference,
      secretKey: PaymentConfig.secretKey,
      currency: PaymentConfig.currency,
      callBackUrl: PaymentConfig.callbackUrl,
      onSuccess: () async {
        try {
          await _functions.httpsCallable('fundWallet').call({
            'amount': amount,
            'reference': reference,
          });

          success = true;
        } on FirebaseFunctionsException catch (e) {
          debugPrint(e.message);
        }
      },
      onClosed: () {},
    );

    return success;
  }
}
