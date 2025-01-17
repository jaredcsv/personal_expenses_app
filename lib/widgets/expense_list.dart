import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:personal_expenses_app/models/expense.dart';
import 'package:personal_expenses_app/screens/edit_expense_screen.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final Function(int id) onDelete;
  final Future<void> Function() reloadExpenses;

  ExpenseList({
    required this.expenses,
    required this.onDelete,
    required this.reloadExpenses,
  });

  Future<void> _showDeleteConfirmationDialog(BuildContext context, int id) async {
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
      onDelete(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return expenses.isEmpty
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
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    builder: (context) => EditExpenseScreen(
                                      initialName: expense.name,
                                      initialAmount: expense.amount,
                                      initialCategory: expense.category,
                                      initialDescription: expense.description,
                                      initialDate: expense.date,
                                      expenseId: expense.id!,
                                    ),
                                  ),
                                );
                                reloadExpenses();
                              } else if (value == 'delete') {
                                await _showDeleteConfirmationDialog(
                                    context, expense.id!);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit,
                                        color: Colors.black, size: 16),
                                    SizedBox(width: 6),
                                    Text('Edit',
                                        style: TextStyle(fontSize: 14)),
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
                                        style: TextStyle(fontSize: 14)),
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
          );
  }
}