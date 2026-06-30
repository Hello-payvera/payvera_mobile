import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String generatePayveraId(String fullName) {
    final cleaned = fullName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');

    final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(8);

    return '@$cleaned$suffix';
  }

  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String email,
  }) async {
    final walletId = 'wallet_$uid';
    final payveraId = generatePayveraId(fullName);

    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'fullName': fullName.trim(),
      'email': email.trim(),
      'phoneNumber': '',
      'payveraId': payveraId,
      'walletId': walletId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('wallets').doc(walletId).set({
      'walletId': walletId,
      'ownerUid': uid,
      'balance': 0.0,
      'currency': 'NGN',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getWallet(String walletId) {
    return _db.collection('wallets').doc(walletId).get();
  }
}