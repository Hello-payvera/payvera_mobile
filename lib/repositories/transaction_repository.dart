import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/models/transaction.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<WalletTransaction>> watchTransactions(String uid) {
    return _firestore
        .collection('transactions')
        .where('participants', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    WalletTransaction.fromMap({"id": doc.id, ...doc.data()}),
              )
              .toList(),
        );
  }
}
