import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_time_expense/blocks/transaction/transition_event.dart';
import 'package:real_time_expense/blocks/transaction/transition_state.dart';

import '../../models/transaction.dart' as transactionModel;
import '../../services/notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Box<transactionModel.Transaction> _localBox;

  TransactionBloc() : super(TransactionState.initial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<EditTransaction>(_onEditTransaction);
  }

  Future<void> _onLoadTransactions(LoadTransactions event, Emitter<TransactionState> emit) async {
    _localBox = await Hive.openBox<transactionModel.Transaction>('transactions');
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .get();
    final transactions = <transactionModel.Transaction>[];
    final docIds = <transactionModel.Transaction, String>{};
    for (var doc in snapshot.docs) {
      final transaction = transactionModel.Transaction.fromMap(doc.data());
      transactions.add(transaction);
      docIds[transaction] = doc.id;
    }
    emit(state.copyWith(
      transactions: transactions,
      balance: _calculateBalance(transactions),
      docIds: docIds,
    ));
  }

  Future<void> _onAddTransaction(AddTransaction event, Emitter<TransactionState> emit) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final transaction = transactionModel.Transaction(
      title: event.transaction.title,
      amount: event.transaction.amount,
      type: event.transaction.type,
      date: event.transaction.date,
      userId: userId,
    );
    final docRef = await _firestore.collection('transactions').add(transaction.toMap());
    await _localBox.add(transaction);
    if (transaction.amount > 10000) {
      NotificationService.showNotification(
        "Large Transaction",
        "Added ${transaction.type}: ${transaction.amount}",
      );
    }
    final newDocIds = Map<transactionModel.Transaction, String>.from(state.docIds);
    newDocIds[transaction] = docRef.id;
    emit(state.copyWith(
      transactions: [...state.transactions, transaction],
      balance: state.balance + (transaction.type == 'Income' ? transaction.amount : -transaction.amount),
      docIds: newDocIds,
    ));
  }

  Future<void> _onEditTransaction(EditTransaction event, Emitter<TransactionState> emit) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final updatedTransaction = transactionModel.Transaction(
      title: event.transaction.title,
      amount: event.transaction.amount,
      type: event.transaction.type,
      date: event.transaction.date,
      userId: userId,
    );

    final index = state.transactions.indexWhere((t) =>
    t.title == updatedTransaction.title &&
        t.amount == updatedTransaction.amount &&
        t.type == updatedTransaction.type &&
        t.date == updatedTransaction.date &&
        t.userId == userId);
    if (index == -1) return;

    final oldTransaction = state.transactions[index];
    final docId = state.docIds[oldTransaction];
    if (docId != null) {
      await _firestore.collection('transactions').doc(docId).set(updatedTransaction.toMap());
    }

    await _localBox.putAt(index, updatedTransaction);

    final updatedTransactions = List<transactionModel.Transaction>.from(state.transactions);
    updatedTransactions[index] = updatedTransaction;

    final oldAmount = oldTransaction.type == 'Income' ? oldTransaction.amount : -oldTransaction.amount;
    final newAmount = updatedTransaction.type == 'Income' ? updatedTransaction.amount : -updatedTransaction.amount;
    final newBalance = state.balance - oldAmount + newAmount;

    final newDocIds = Map<transactionModel.Transaction, String>.from(state.docIds);
    newDocIds.remove(oldTransaction);
    newDocIds[updatedTransaction] = docId!;

    if (updatedTransaction.amount > 10000) {
      NotificationService.showNotification(
        "Large Transaction Updated",
        "Updated ${updatedTransaction.type}: ${updatedTransaction.amount}",
      );
    }

    emit(state.copyWith(
      transactions: updatedTransactions,
      balance: newBalance,
      docIds: newDocIds,
    ));
  }

  double _calculateBalance(List<transactionModel.Transaction> transactions) {
    return transactions.fold(0, (sum, t) => sum + (t.type == 'Income' ? t.amount : -t.amount));
  }
}