import 'package:flutter/material.dart';
import 'package:personal_expenses_app/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Sight',
      theme: ThemeData(primarySwatch: Colors.lightBlue, fontFamily: 'Pavanam'),
      home: HomeScreen(),
    );
  }
}
