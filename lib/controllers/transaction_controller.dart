import 'package:flutter/foundation.dart';

import '../core/models/transaction.dart';
import '../services/repositories/repository_provider.dart';

class TransactionController extends ChangeNotifier {
  List<WalletTransaction> transactions = [];

  bool loading = true;

  void start(String uid) {
    RepositoryProvider.transaction.watchTransactions(uid).listen((items) {
      transactions = items;
      loading = false;
      notifyListeners();
    });
  }
}
