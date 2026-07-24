import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/beneficiary_model.dart';

class BeneficiaryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  CollectionReference get _collection =>
      _firestore.collection('beneficiaries');

  Future<void> saveBeneficiary({
    required String receiverUid,
    required String payveraId,
    required String fullName,
  }) async {
    final uid = _auth.currentUser!.uid;

    final query = await _collection
        .where('ownerUid', isEqualTo: uid)
        .where('receiverUid', isEqualTo: receiverUid)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      await _collection.add({
        'ownerUid': uid,
        'receiverUid': receiverUid,
        'payveraId': payveraId,
        'fullName': fullName,
        'favorite': false,
        'transferCount': 1,
        'lastTransfer':
            FieldValue.serverTimestamp(),
      });
    } else {
      final doc = query.docs.first.reference;

      await doc.update({
        'transferCount':
            FieldValue.increment(1),
        'lastTransfer':
            FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<BeneficiaryModel>>
      recentBeneficiaries() {
    return _collection
        .where(
          'ownerUid',
          isEqualTo: _auth.currentUser!.uid,
        )
        .orderBy('lastTransfer',
            descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => BeneficiaryModel.fromMap(
                  doc.data()
                      as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Stream<List<BeneficiaryModel>>
      favoriteBeneficiaries() {
    return _collection
        .where(
          'ownerUid',
          isEqualTo: _auth.currentUser!.uid,
        )
        .where(
          'favorite',
          isEqualTo: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => BeneficiaryModel.fromMap(
                  doc.data()
                      as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<void> toggleFavorite(
    String beneficiaryId,
    bool value,
  ) async {
    await _collection
        .doc(beneficiaryId)
        .update({
      'favorite': value,
    });
  }
}
