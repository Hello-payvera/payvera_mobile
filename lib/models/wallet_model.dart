class WalletModel {
  final String walletId;
  final String ownerUid;
  final double balance;
  final String currency;
  final String status;

  WalletModel({
    required this.walletId,
    required this.ownerUid,
    required this.balance,
    required this.currency,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'walletId': walletId,
      'ownerUid': ownerUid,
      'balance': balance,
      'currency': currency,
      'status': status,
    };
  }
}