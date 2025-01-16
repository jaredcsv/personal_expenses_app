import 'package:flutter/material.dart';
import 'package:personal_expenses_app/data/database_helper.dart';
import 'package:personal_expenses_app/models/expense.dart';

Widget buildTextFormField({
  required String label,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    keyboardType: keyboardType,
    validator: validator,
  );
}

Future<DateTime?> pickDate(BuildContext context) async {
  return await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
}

Future<bool> updateExpense({
  required int expenseId,
  required String name,
  required double amount,
  required String category,
  required String description,
  required DateTime date,
}) async {
  try {
    final updatedExpense = Expense(
      id: expenseId,
      name: name,
      amount: amount,
      category: category,
      description: description,
      date: date,
    );

    final result = await DatabaseHelper.instance.updateExpense(updatedExpense);
    return result > 0;
  } catch (e) {
    // Handle or log the error as necessary.
    return false;
  }
}

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
