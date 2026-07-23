import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/models/payvera_user.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<PayveraUser> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception("User not found");
    }

    return PayveraUser.fromMap(doc.data()!);
  }

  Future<PayveraUser?> findByPayveraId(String payveraId) async {
    final result = await _firestore
        .collection('users')
        .where("payveraId", isEqualTo: payveraId)
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return null;
    }

    return PayveraUser.fromMap(result.docs.first.data());
  }
}
