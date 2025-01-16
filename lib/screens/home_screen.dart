import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:personal_expenses_app/data/database_helper.dart';
import 'package:personal_expenses_app/models/expense.dart';
import 'package:personal_expenses_app/screens/create_expense_screen.dart';
import 'package:personal_expenses_app/screens/edit_expense_screen.dart';

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

  Future<void> _showDeleteConfirmationDialog(int id) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          backgroundColor: Colors.white,
          content: Text(
              'Are you sure you want to delete this expense? This action is irreversible.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Yes
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteExpense(id);
    }
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
            // Total spend and "Add" button
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
                    backgroundColor:
                        Colors.lightBlue, // Set the background color
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
              child: _expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/img/no-transactions.png',
                            height: 150,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No Transactions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _expenses.length,
                      itemBuilder: (context, index) {
                        final expense = _expenses[index];
                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        expense.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      color: Colors.white,
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditExpenseScreen(
                                                initialName: expense.name,
                                                initialAmount: expense.amount,
                                                initialCategory:
                                                    expense.category,
                                                initialDescription:
                                                    expense.description,
                                                initialDate: expense.date,
                                                expenseId: expense.id!,
                                              ),
                                            ),
                                          );
                                          _loadExpenses();
                                        } else if (value == 'delete') {
                                          await _showDeleteConfirmationDialog(
                                              expense.id!);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit,
                                                  color: Colors.black,
                                                  size: 16),
                                              SizedBox(width: 6),
                                              Text('Edit',
                                                  style:
                                                      TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  color: Colors.red, size: 16),
                                              SizedBox(width: 6),
                                              Text('Delete',
                                                  style:
                                                      TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$${expense.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green[700],
                                  ),
                                ),
                                if (expense.description.isNotEmpty)
                                  Text(
                                    expense.description,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                Text(
                                  '${expense.category}, ${DateFormat.yMMMd().format(expense.date)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
