import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../blocks/transaction/transition_block.dart';
import '../blocks/transaction/transition_state.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expense Tracker')),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          return Column(
            children: [
              Text('Balance: ₹${state.balance.toStringAsFixed(2)}'),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: state.transactions.where((t) => t.type == 'Income').fold(0.0, (sum, t) => sum??0 + t.amount),
                        title: 'Income',
                        color: Colors.green,
                      ),
                      PieChartSectionData(
                        value: state.transactions.where((t) => t.type == 'Expense').fold(0.0, (sum, t) => sum??0 + t.amount),
                        title: 'Expense',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = state.transactions[index];
                    return ListTile(
                      title: Text(transaction.title),
                      subtitle: Text('${transaction.type}: ₹${transaction.amount}'),
                      trailing: Text(transaction.date.toString()),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen())),
        child: Icon(Icons.add),
      ),
    );
  }
}
