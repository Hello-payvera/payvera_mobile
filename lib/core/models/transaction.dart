class WalletTransaction {
  final String id;
  final String senderId;
  final String receiverId;
  final double amount;
  final String reference;
  final String status;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.reference,
    required this.status,
    required this.createdAt,
  });

  factory WalletTransaction.fromMap(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      amount: (json['amount'] as num).toDouble(),
      reference: json['reference'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'reference': reference,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
