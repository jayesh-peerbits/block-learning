import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction {
@HiveField(0)
final String title;

@HiveField(1)
final double amount;

@HiveField(2)
final String type;

@HiveField(3)
final DateTime date;

@HiveField(4)
final String? userId; // Added for Firestore security

Transaction({
required this.title,
required this.amount,
required this.type,
required this.date,
this.userId,
});

Map<String, dynamic> toMap() {
return {
'title': title,
'amount': amount,
'type': type,
'date': date.toIso8601String(),
'userId': userId ?? FirebaseAuth.instance.currentUser?.uid,
};
}

factory Transaction.fromMap(Map<String, dynamic> map) {
return Transaction(
title: map['title'],
amount: map['amount'],
type: map['type'],
date: DateTime.parse(map['date']),
userId: map['userId'],
);
}
}
