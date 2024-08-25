import 'package:banka/src/components/stats/stats.dart';
import 'package:banka/src/components/transactions/transactions.dart';
import 'package:flutter/material.dart';

final pages = <Widget>[
  const TransactionsPage(
      icon: Icon(Icons.receipt_long), typeTransaction: 'Bills'),
  const TransactionsPage(
    icon: Icon(Icons.payments),
    typeTransaction: 'Expenses',
  ),
  const StatsPage(),
];

List<String> expenseCategories = [
  'Rent/Mortgage',
  'Utilities',
  'Groceries',
  'Dining Out',
  'Transportation',
  'Healthcare',
  'Entertainment',
  'Shopping',
  'Education',
  'Investments',
  'Savings',
  'Travel',
  'Debt',
  'Insurance',
  'Miscellaneous',
];
