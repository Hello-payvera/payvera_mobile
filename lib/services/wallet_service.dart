import 'dart:async';

class WalletService {
  double _balance = 25000.00;

  final StreamController<double> _balanceController =
      StreamController<double>.broadcast();

  WalletService() {
    _balanceController.add(_balance);
  }

  Stream<double> get balanceStream => _balanceController.stream;

  double get balance => _balance;

  Future<void> addMoney(double amount) async {
    await Future.delayed(const Duration(seconds: 2));

    _balance += amount;

    _balanceController.add(_balance);
  }

  Future<void> withdraw(double amount) async {
    await Future.delayed(const Duration(seconds: 2));

    _balance -= amount;

    _balanceController.add(_balance);
  }

  void dispose() {
    _balanceController.close();
  }
}
