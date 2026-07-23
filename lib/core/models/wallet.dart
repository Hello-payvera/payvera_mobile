class Wallet {
  final String id;
  final String ownerId;

  final double balance;
  final double availableBalance;
  final double ledgerBalance;

  final String currency;
  final bool isActive;

  const Wallet({
    required this.id,
    required this.ownerId,
    required this.balance,
    required this.availableBalance,
    required this.ledgerBalance,
    required this.currency,
    required this.isActive,
  });

  factory Wallet.fromMap(Map<String, dynamic> json) {
    final balance = (json['balance'] ?? 0 as num).toDouble();

    return Wallet(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      balance: balance,
      availableBalance: (json['availableBalance'] ?? balance as num).toDouble(),
      ledgerBalance: (json['ledgerBalance'] ?? balance as num).toDouble(),
      currency: json['currency'] ?? 'NGN',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'balance': balance,
      'availableBalance': availableBalance,
      'ledgerBalance': ledgerBalance,
      'currency': currency,
      'isActive': isActive,
    };
  }
}
