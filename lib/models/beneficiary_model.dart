class BeneficiaryModel {
  final String id;
  final String ownerUid;
  final String receiverUid;
  final String payveraId;
  final String fullName;
  final bool favorite;
  final DateTime lastTransfer;
  final int transferCount;

  const BeneficiaryModel({
    required this.id,
    required this.ownerUid,
    required this.receiverUid,
    required this.payveraId,
    required this.fullName,
    required this.favorite,
    required this.lastTransfer,
    required this.transferCount,
  });

  factory BeneficiaryModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return BeneficiaryModel(
      id: id,
      ownerUid: map['ownerUid'] ?? '',
      receiverUid: map['receiverUid'] ?? '',
      payveraId: map['payveraId'] ?? '',
      fullName: map['fullName'] ?? '',
      favorite: map['favorite'] ?? false,
      transferCount: map['transferCount'] ?? 0,
      lastTransfer:
          (map['lastTransfer'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'receiverUid': receiverUid,
      'payveraId': payveraId,
      'fullName': fullName,
      'favorite': favorite,
      'transferCount': transferCount,
      'lastTransfer': lastTransfer,
    };
  }
}
