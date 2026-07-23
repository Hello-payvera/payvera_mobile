import '../../repositories/transaction_repository.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/wallet_repository.dart';

class RepositoryProvider {
  RepositoryProvider._();

  static final wallet = WalletRepository();

  static final user = UserRepository();

  static final transaction = TransactionRepository();
}
