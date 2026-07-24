enum TransactionFilterType {
  all,
  credit,
  debit,
}

class TransactionFilter {
  const TransactionFilter({
    this.search = '',
    this.type = TransactionFilterType.all,
    this.status,
    this.transactionType,
  });

  final String search;
  final TransactionFilterType type;
  final String? status;
  final String? transactionType;

  TransactionFilter copyWith({
    String? search,
    TransactionFilterType? type,
    String? status,
    String? transactionType,
  }) {
    return TransactionFilter(
      search: search ?? this.search,
      type: type ?? this.type,
      status: status ?? this.status,
      transactionType:
          transactionType ?? this.transactionType,
    );
  }
}
