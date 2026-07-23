import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/models/wallet.dart';

class WalletRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Wallet> watchWallet(String uid) {
    return _firestore.collection('wallets').doc(uid).snapshots().map((doc) {
      final data = doc.data();

      if (data == null) {
        throw Exception("Wallet not found");
      }

      return Wallet.fromMap({"id": doc.id, ...data});
    });
  }

  Future<Wallet> getWallet(String uid) async {
    final doc = await _firestore.collection('wallets').doc(uid).get();

    if (!doc.exists) {
      throw Exception("Wallet not found");
    }

    return Wallet.fromMap({"id": doc.id, ...doc.data()!});
  }
}
