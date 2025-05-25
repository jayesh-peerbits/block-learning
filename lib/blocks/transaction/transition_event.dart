
import '../../models/transaction.dart';

abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final Transaction transaction;
  AddTransaction(this.transaction);
}

class EditTransaction extends TransactionEvent {
  final Transaction transaction;
  EditTransaction(this.transaction);
}
