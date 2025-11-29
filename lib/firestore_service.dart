import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finance_app/models/transaction.dart' as app;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's UID
  String? get _uid => _auth.currentUser?.uid;

  // Get a reference to the user's transactions sub-collection
  CollectionReference<app.Transaction> get _transactionsRef {
    if (_uid == null) {
      throw Exception("User is not logged in.");
    }
    return _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .withConverter<app.Transaction>(
          fromFirestore: (snapshots, _) =>
              app.Transaction.fromFirestore(snapshots),
          toFirestore: (transaction, _) => transaction.toFirestore(),
        );
  }

  // Add a new transaction
  Future<void> addTransaction(app.Transaction transaction) async {
    await _transactionsRef.add(transaction);
  }

  // Get a stream of transactions
  Stream<QuerySnapshot<app.Transaction>> getTransactionsStream() {
    // Order by date in descending order to show the newest first
    return _transactionsRef.orderBy('date', descending: true).snapshots();
  }

  // Update an existing transaction
  Future<void> updateTransaction(
    String transactionId,
    app.Transaction transaction,
  ) async {
    await _transactionsRef.doc(transactionId).update(transaction.toFirestore());
  }

  // Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    await _transactionsRef.doc(transactionId).delete();
  }

  // Delete all transactions for the current user
  Future<void> deleteAllTransactions() async {
    if (_uid == null) {
      throw Exception("User is not logged in.");
    }

    final querySnapshot = await _transactionsRef.get();
    final batch = _db.batch();

    for (final doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
