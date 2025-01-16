import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../data/database_helper.dart';

class ExpenseList extends StatefulWidget {
  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  List<Expense> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() {
      _isLoading = true;
    });

    final expenses = await DatabaseHelper.instance.readAllExpenses();
    setState(() {
      _expenses = expenses;
      _isLoading = false;
    });
  }

  Future<void> _deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    _fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_expenses.isEmpty) {
      return Center(
        child: Text(
          'No Transactions',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.attach_money, color: Colors.white),
              backgroundColor: Colors.blue,
            ),
            title: Text(expense.description),
            subtitle: Text('${expense.category} • ${expense.date.toLocal().toString().split(' ')[0]}'),
            trailing: Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            onTap: () {
              // Acción al tocar un elemento, como abrir una pantalla de detalles.
            },
            onLongPress: () async {
              // Confirmación para eliminar el gasto.
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Eliminar Gasto'),
                    content: Text('¿Estás seguro de que quieres eliminar este gasto?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Eliminar'),
                      ),
                    ],
                  );
                },
              );
              if (confirm == true) {
                _deleteExpense(expense.id!);
              }
            },
          ),
        );
      },
    );
  }
}