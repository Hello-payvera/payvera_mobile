import 'package:flutter/foundation.dart';

import '../core/models/wallet.dart';
import '../services/repositories/repository_provider.dart';

class WalletController extends ChangeNotifier {
  Wallet? wallet;

  bool loading = true;

  String? error;

  void start(String uid) {
    RepositoryProvider.wallet
        .watchWallet(uid)
        .listen(
          (value) {
            wallet = value;
            loading = false;
            error = null;
            notifyListeners();
          },
          onError: (e) {
            error = e.toString();
            loading = false;
            notifyListeners();
          },
        );
  }

  double get availableBalance => wallet?.availableBalance ?? 0.0;

  double get ledgerBalance => wallet?.ledgerBalance ?? 0.0;

  String get currency => wallet?.currency ?? "NGN";
}
