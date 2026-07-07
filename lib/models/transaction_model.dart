import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  walletFunding,
  walletTransfer,
  payveraIdTransfer,
  bankTransfer,
  cardFunding,
  qrPayment,
  merchantPayment,
  billPayment,
  refund,
  reversal,
  fee,
}

enum TransactionDirection { credit, debit }

enum TransactionStatus {
  initiated,
  pending,
  processing,
  successful,
  failed,
  reversed,
  cancelled,
}

class TransactionModel {
  const TransactionModel({
    required this.transactionId,
    required this.reference,
    required this.walletId,
    required this.ownerUid,
    required this.type,
    required this.direction,
    required this.status,
    required this.amount,
    required this.fee,
    required this.currency,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.counterpartyWalletId,
    this.counterpartyPayveraId,
    this.provider,
    this.providerReference,
    this.failureCode,
    this.failureMessage,
    this.reversalOfTransactionId,
    this.idempotencyKey,
    this.completedAt,
  });

  final String transactionId;
  final String reference;

  final String walletId;
  final String ownerUid;

  final TransactionType type;
  final TransactionDirection direction;
  final TransactionStatus status;

  final double amount;
  final double fee;
  final String currency;

  final String description;

  final String? counterpartyWalletId;
  final String? counterpartyPayveraId;

  final String? provider;
  final String? providerReference;

  final String? failureCode;
  final String? failureMessage;

  final String? reversalOfTransactionId;
  final String? idempotencyKey;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  double get totalDebit => amount + fee;

  bool get isFinal =>
      status == TransactionStatus.successful ||
      status == TransactionStatus.failed ||
      status == TransactionStatus.reversed ||
      status == TransactionStatus.cancelled;

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'reference': reference,
      'walletId': walletId,
      'ownerUid': ownerUid,
      'type': type.name,
      'direction': direction.name,
      'status': status.name,
      'amount': amount,
      'fee': fee,
      'currency': currency,
      'description': description,
      'counterpartyWalletId': counterpartyWalletId,
      'counterpartyPayveraId': counterpartyPayveraId,
      'provider': provider,
      'providerReference': providerReference,
      'failureCode': failureCode,
      'failureMessage': failureMessage,
      'reversalOfTransactionId': reversalOfTransactionId,
      'idempotencyKey': idempotencyKey,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      'completedAt': completedAt == null
          ? null
          : Timestamp.fromDate(completedAt!),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      transactionId: map['transactionId'] as String? ?? '',
      reference: map['reference'] as String? ?? '',
      walletId: map['walletId'] as String? ?? '',
      ownerUid: map['ownerUid'] as String? ?? '',
      type: _transactionTypeFromString(map['type'] as String?),
      direction: _transactionDirectionFromString(map['direction'] as String?),
      status: _transactionStatusFromString(map['status'] as String?),
      amount: (map['amount'] as num? ?? 0).toDouble(),
      fee: (map['fee'] as num? ?? 0).toDouble(),
      currency: map['currency'] as String? ?? 'NGN',
      description: map['description'] as String? ?? '',
      counterpartyWalletId: map['counterpartyWalletId'] as String?,
      counterpartyPayveraId: map['counterpartyPayveraId'] as String?,
      provider: map['provider'] as String?,
      providerReference: map['providerReference'] as String?,
      failureCode: map['failureCode'] as String?,
      failureMessage: map['failureMessage'] as String?,
      reversalOfTransactionId: map['reversalOfTransactionId'] as String?,
      idempotencyKey: map['idempotencyKey'] as String?,
      createdAt: _dateTimeFromTimestamp(map['createdAt']),
      updatedAt: _dateTimeFromTimestamp(map['updatedAt']),
      completedAt: _dateTimeFromTimestamp(map['completedAt']),
    );
  }

  static TransactionType _transactionTypeFromString(String? value) {
    return TransactionType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => TransactionType.walletTransfer,
    );
  }

  static TransactionDirection _transactionDirectionFromString(String? value) {
    return TransactionDirection.values.firstWhere(
      (item) => item.name == value,
      orElse: () => TransactionDirection.debit,
    );
  }

  static TransactionStatus _transactionStatusFromString(String? value) {
    return TransactionStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => TransactionStatus.pending,
    );
  }

  static DateTime? _dateTimeFromTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}
