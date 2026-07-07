import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String generatePayveraId(String fullName) {
    final cleaned = fullName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');

    final suffix =
        DateTime.now().millisecondsSinceEpoch.toString().substring(8);

    return '@$cleaned$suffix';
  }

  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String email,
  }) async {
    final userRef = _db.collection('users').doc(uid);
    final walletId = 'wallet_$uid';
    final walletRef = _db.collection('wallets').doc(walletId);
    final payveraId = generatePayveraId(fullName);

    final batch = _db.batch();

    batch.set(userRef, {
      'uid': uid,
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'phoneNumber': '',
      'payveraId': payveraId,
      'walletId': walletId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(walletRef, {
      'walletId': walletId,
      'ownerUid': uid,

      // Financial balances.
      // The mobile client must never directly modify these fields.
      'availableBalance': 0.0,
      'ledgerBalance': 0.0,

      'currency': 'NGN',
      'status': 'active',
      'isFrozen': false,

      // Temporary default limits.
      // Later these will come from KYC tier and server-side policy.
      'dailyLimit': 0.0,
      'monthlyLimit': 0.0,

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getWallet(String walletId) {
    return _db.collection('wallets').doc(walletId).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchWallet(String walletId) {
    return _db.collection('wallets').doc(walletId).snapshots();
  }
}