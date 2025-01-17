import 'package:flutter/material.dart';
import 'package:personal_expenses_app/data/database_helper.dart';
import 'package:personal_expenses_app/models/expense.dart';
import 'package:personal_expenses_app/screens/create_expense_screen.dart';
import 'package:personal_expenses_app/widgets/expense_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];
  double _totalSpend = 0.0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await DatabaseHelper.instance.readAllExpenses();
    setState(() {
      _expenses = expenses..sort((a, b) => b.date.compareTo(a.date));
      _totalSpend = expenses.fold(0.0, (sum, item) => sum + item.amount);
    });
  }

  Future<void> _deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/img/expense-sight-logo.png',
              height: 32,
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Spend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\$${_totalSpend.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateExpenseScreen(),
                      ),
                    );
                    _loadExpenses();
                  },
                  label: Text(
                    'Add',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  icon: Icon(Icons.add, size: 24, color: Colors.white),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            Text(
              'Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ExpenseList(
                expenses: _expenses,
                onDelete: _deleteExpense,
                reloadExpenses: _loadExpenses,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
