import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class TransferService {
  Future<Map<String, dynamic>> internalTransfer({
    required String receiverPayveraId,
    required double amount,
    String description = '',
  }) async {
    debugPrint("Calling internalTransfer...");
    debugPrint("Host: ${FirebaseFunctions.instance.app.name}");

    final callable = FirebaseFunctions.instance.httpsCallable(
      'internalTransfer',
    );

    final response = await callable.call({
      'receiverPayveraId': receiverPayveraId,
      'amount': amount,
      'description': description,
      'idempotencyKey': DateTime.now().millisecondsSinceEpoch.toString(),
    });

    debugPrint("Function returned:");
    debugPrint(response.data.toString());

    return Map<String, dynamic>.from(response.data);
  }
}
