import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_expenses_app/data/database_helper.dart';
import 'package:personal_expenses_app/models/expense.dart';

class EditExpenseScreen extends StatefulWidget {
  final int expenseId;
  final String initialName;
  final double initialAmount;
  final String initialCategory;
  final String initialDescription;
  final DateTime initialDate;

  EditExpenseScreen({
    required this.expenseId,
    required this.initialName,
    required this.initialAmount,
    required this.initialCategory,
    required this.initialDescription,
    required this.initialDate,
  });

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedCategory;

  final List<String> _categories = ['Food', 'Travel', 'Shopping', 'Health', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _amountController = TextEditingController(text: widget.initialAmount.toString());
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _selectedDate = widget.initialDate;
    _selectedCategory = widget.initialCategory;
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      final updatedExpense = Expense(
        id: widget.expenseId,
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        description: _descriptionController.text,
        date: _selectedDate,
      );

      await DatabaseHelper.instance.updateExpense(updatedExpense);

      Navigator.pop(context); // Regresa a la pantalla anterior
    }
  }

  void _onCancel() {
    Navigator.pop(context); // Cierra la pantalla sin hacer cambios
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
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
                  value: _selectedCategory,
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _pickDate,
                      child: Text('Pick Date'),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: _onCancel,
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: _onSave,
                      child: Text('Save'),
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
