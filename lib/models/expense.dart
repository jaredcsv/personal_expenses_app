class Expense {
  final int? id;
  final String name;
  final String category;
  final String description;
  final double amount;
  final DateTime date;

  Expense({this.id, required this.name, required this.category, required this.description, required this.amount, required this.date});

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'],
        name: map['name'],
        category: map['category'],
        description: map['description'],
        amount: map['amount'],
        date: DateTime.parse(map['date']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
      };
}
