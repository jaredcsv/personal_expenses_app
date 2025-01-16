import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_expenses_app/data/database_helper.dart';
import 'package:personal_expenses_app/utils/expense_form_helper.dart';
import '../models/expense.dart';

class CreateExpenseScreen extends StatefulWidget {
  @override
  _CreateExpenseScreenState createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends State<CreateExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;

  final List<String> _categories = [
    'Food',
    'Travel',
    'Shopping',
    'Health',
    'Other'
  ];

  Future<void> _onSave() async {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        name: _nameController.text,
        category: _selectedCategory!,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate ?? DateTime.now(),
      );

      final result = await DatabaseHelper.instance.createExpense(expense);
      if (result > 0) {
        Navigator.pop(context);
      } else {
        showErrorDialog(context, 'Failed to save expense.');
      }
    }
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Create Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextFormField(
                  label: 'Name',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                buildTextFormField(
                  label: 'Amount',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Category'),
                  dropdownColor: Colors.white,
                  value: _selectedCategory,
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                buildTextFormField(
                  label: 'Description',
                  controller: _descriptionController,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? 'Date: ${DateFormat.yMMMd().format(_selectedDate!)}'
                            : 'No date selected',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final date = await pickDate(context);
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      child: Text(
                        'Pick Date',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _onCancel,
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _onSave,
                      child: Text(
                        'Save',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
