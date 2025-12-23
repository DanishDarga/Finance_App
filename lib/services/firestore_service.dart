import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget.dart';
import '../models/bill.dart';
import '../models/investment.dart';
import '../models/transaction.dart' as app;
import '../models/category_data.dart';

/// Service for handling Firestore database operations
class FirestoreService {
  FirestoreService._();

  static final FirestoreService _instance = FirestoreService._();
  factory FirestoreService() => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's UID
  String? get _uid => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _uid != null;

  /// Get a reference to the user's transactions sub-collection
  CollectionReference<app.Transaction> get _transactionsRef {
    if (_uid == null) {
      throw Exception('User is not logged in.');
    }
    return _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .withConverter<app.Transaction>(
          fromFirestore: (snapshot, _) =>
              app.Transaction.fromFirestore(snapshot),
          toFirestore: (transaction, _) => transaction.toFirestore(),
        );
  }

  /// Get a reference to the user's bills sub-collection
  CollectionReference<Bill> get _billsRef {
    if (_uid == null) {
      throw Exception('User is not logged in.');
    }
    return _db
        .collection('users')
        .doc(_uid)
        .collection('bills')
        .withConverter<Bill>(
          fromFirestore: (snapshot, options) =>
              Bill.fromFirestore(snapshot, options),
          toFirestore: (bill, _) => bill.toFirestore(),
        );
  }

  /// Get a reference to the user's budgets sub-collection
  CollectionReference<Budget> get _budgetsRef {
    if (_uid == null) {
      throw Exception('User is not logged in.');
    }
    return _db
        .collection('users')
        .doc(_uid)
        .collection('budgets')
        .withConverter<Budget>(
          fromFirestore: (snapshot, options) =>
              Budget.fromFirestore(snapshot, options),
          toFirestore: (budget, _) => budget.toFirestore(),
        );
  }

  /// Get a reference to the user's investments sub-collection
  CollectionReference<Investment> get _investmentsRef {
    if (_uid == null) {
      throw Exception('User is not logged in.');
    }
    return _db
        .collection('users')
        .doc(_uid)
        .collection('investments')
        .withConverter<Investment>(
          fromFirestore: (snapshot, options) =>
              Investment.fromFirestore(snapshot, options),
          toFirestore: (investment, _) => investment.toFirestore(),
        );
  }

  // ==================== Transactions ====================

  /// Add a new transaction
  Future<void> addTransaction(app.Transaction transaction) async {
    await _transactionsRef.add(transaction);
  }

  /// Get a stream of transactions
  Stream<QuerySnapshot<app.Transaction>> getTransactionsStream({
    String orderBy = 'date',
    bool descending = true,
  }) {
    return _transactionsRef
        .orderBy(orderBy, descending: descending)
        .snapshots();
  }

  /// Update an existing transaction
  Future<void> updateTransaction(
    String transactionId,
    app.Transaction transaction,
  ) async {
    await _transactionsRef.doc(transactionId).update(transaction.toFirestore());
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    await _transactionsRef.doc(transactionId).delete();
  }

  /// Delete all transactions for the current user
  Future<void> deleteAllTransactions() async {
    if (_uid == null) {
      throw Exception('User is not logged in.');
    }

    final querySnapshot = await _transactionsRef.get();
    final batch = _db.batch();

    for (final doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Auto-categorize all transactions for the current user.
  /// This reads all transaction documents, runs the lightweight classifier,
  /// and updates the Firestore `category` field when the computed category
  /// differs from the stored one.
  Future<void> autoCategorizeAllTransactions() async {
    if (_uid == null) throw Exception('User is not logged in.');

    final snapshot = await _transactionsRef.get();
    final batch = _db.batch();
    var hasUpdates = false;

    for (final doc in snapshot.docs) {
      final tx = doc.data();
      // tx is app.Transaction thanks to converter
      final computed = CategoryData.autoCategorize(tx.title, tx.amount);
      final stored = tx.category;
      if (computed != stored) {
        batch.update(doc.reference, {
          'category': CategoryData.categoryToString(computed),
        });
        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      await batch.commit();
    }
  }

  // ==================== Bills ====================

  /// Add a new bill
  Future<DocumentReference<Bill>> addBill(Bill bill) async {
    return await _billsRef.add(bill);
  }

  /// Get a stream of bills
  Stream<QuerySnapshot<Bill>> getBillsStream() {
    return _billsRef.orderBy('dueDate', descending: false).snapshots();
  }

  /// Update an existing bill
  Future<void> updateBill(String billId, Map<String, dynamic> data) async {
    await _billsRef.doc(billId).update(data);
  }

  /// Delete a bill
  Future<void> deleteBill(String billId) async {
    await _billsRef.doc(billId).delete();
  }

  // ==================== Budgets ====================

  /// Set or update a budget for a specific month
  Future<void> setBudget(Budget budget) async {
    final docId = '${budget.year}-${budget.month.toString().padLeft(2, '0')}';
    await _budgetsRef.doc(docId).set(budget);
  }

  /// Get a stream of budget for a specific month and year
  Stream<Budget?> getBudgetForMonth(int year, int month) {
    final docId = '$year-${month.toString().padLeft(2, '0')}';
    return _budgetsRef.doc(docId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  // ==================== Investments ====================

  /// Add a new investment
  Future<void> addInvestment(Investment investment) async {
    await _investmentsRef.add(investment);
  }

  /// Get a stream of investments
  Stream<QuerySnapshot<Investment>> getInvestmentsStream() {
    return _investmentsRef
        .orderBy('purchaseDate', descending: true)
        .snapshots();
  }

  /// Update an existing investment
  Future<void> updateInvestment(
    String investmentId,
    Investment investment,
  ) async {
    await _investmentsRef.doc(investmentId).update(investment.toFirestore());
  }

  /// Delete an investment
  Future<void> deleteInvestment(String investmentId) async {
    await _investmentsRef.doc(investmentId).delete();
  }
}
