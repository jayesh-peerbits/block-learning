import '../../models/transaction.dart';
import '../../models/transaction.dart' as transactionModel;

class TransactionState {
  final List<Transaction> transactions;
  final double balance;
  final Map<transactionModel.Transaction, String> docIds;

  TransactionState({
    required this.transactions,
    required this.balance,
    required this.docIds,
  });

  factory TransactionState.initial() =>
      TransactionState(transactions: [], balance: 0, docIds: {});

  TransactionState copyWith({
    List<Transaction>? transactions,
    double? balance,
    Map<transactionModel.Transaction, String>? docIds,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      balance: balance ?? this.balance,
      docIds: docIds ?? this.docIds,
    );
  }
}
