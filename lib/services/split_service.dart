import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/split_bill.dart';

class SplitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // collection reference
  CollectionReference get _splitsCollection =>
      _firestore.collection('users').doc(currentUserId).collection('split_bills');

  Future<void> addSplitBill(SplitBill bill) async {
    if (currentUserId == null) return;
    await _splitsCollection.add(bill.toMap());
  }

  Stream<QuerySnapshot<SplitBill>> getSplitBillsStream() {
    if (currentUserId == null) return const Stream.empty();
    return _splitsCollection
        .orderBy('date', descending: true)
        .withConverter<SplitBill>(
          fromFirestore: (snapshot, _) => SplitBill.fromFirestore(snapshot),
          toFirestore: (bill, _) => bill.toMap(),
        )
        .snapshots();
  }

  Future<void> deleteSplitBill(String id) async {
    await _splitsCollection.doc(id).delete();
  }
}
