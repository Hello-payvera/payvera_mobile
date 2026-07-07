class WalletModel {
  final String walletId;
  final String ownerUid;
  final double availableBalance;
  final double ledgerBalance;
  final String currency;
  final String status;
  final bool isFrozen;
  final double dailyLimit;
  final double monthlyLimit;

  WalletModel({
    required this.walletId,
    required this.ownerUid,
    required this.availableBalance,
    required this.ledgerBalance,
    required this.currency,
    required this.status,
    required this.isFrozen,
    required this.dailyLimit,
    required this.monthlyLimit,
  });

  Map<String, dynamic> toMap() {
    return {
      'walletId': walletId,
      'ownerUid': ownerUid,
      'availableBalance': availableBalance,
      'ledgerBalance': ledgerBalance,
      'currency': currency,
      'status': status,
      'isFrozen': isFrozen,
      'dailyLimit': dailyLimit,
      'monthlyLimit': monthlyLimit,
    };
  }
}