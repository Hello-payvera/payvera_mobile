class PayveraUser {
  final String uid;
  final String payveraId;
  final String fullName;
  final String email;

  const PayveraUser({
    required this.uid,
    required this.payveraId,
    required this.fullName,
    required this.email,
  });

  factory PayveraUser.fromMap(Map<String, dynamic> json) {
    return PayveraUser(
      uid: json['uid'],
      payveraId: json['payveraId'],
      fullName: json['fullName'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'payveraId': payveraId,
      'fullName': fullName,
      'email': email,
    };
  }
}
