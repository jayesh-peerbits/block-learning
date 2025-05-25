import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocks/transaction/transition_block.dart';
import '../blocks/transaction/transition_event.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatelessWidget {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Transaction')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: _amountController, decoration: InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Type'),
              items: ['Income', 'Expense'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (value) => _typeController.text = value!,
            ),
            ElevatedButton(
              onPressed: () {
                final transaction = Transaction(
                  title: _titleController.text,
                  amount: double.parse(_amountController.text),
                  type: _typeController.text,
                  date: DateTime.now(),
                );
                context.read<TransactionBloc>().add(AddTransaction(transaction));
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}