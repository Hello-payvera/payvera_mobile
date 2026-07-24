import 'package:cloud_functions/cloud_functions.dart';
import '../core/utils/logger.dart';

class TransferService {
  Future<Map<String, dynamic>> internalTransfer({
    required String receiverPayveraId,
    required double amount,
    String description = '',
  }) async {
    Logger.info("Calling internalTransfer");
    Logger.info("Host: ${FirebaseFunctions.instance.app.name}");

    final callable = FirebaseFunctions.instance.httpsCallable(
      'internalTransfer',
    );

    final response = await callable.call({
      'receiverPayveraId': receiverPayveraId,
      'amount': amount,
      'description': description,
      'idempotencyKey': DateTime.now().millisecondsSinceEpoch.toString(),
    });

    Logger.success("Transfer completed");
    Logger.info(response.data.toString());

    return Map<String, dynamic>.from(response.data);
  }
}
