import 'package:flutter/material.dart';
import 'package:banka/src/components/stats/stats.dart';
import 'package:banka/src/components/transactions/transactions.dart';
import 'package:flutter/material.dart';

/// Flutter code sample for [NavigationBar].

class NavigationBanka extends StatefulWidget {
  const NavigationBanka({super.key});

  @override
  State<NavigationBanka> createState() => _NavigationBankaState();
}

class _NavigationBankaState extends State<NavigationBanka> {
  int currentPageIndex = 0;

  final pages = <Widget>[
  const TransactionsPage(
      icon: Icon(Icons.receipt_long), typeTransaction: 'Bills'),
  const TransactionsPage(
    icon: Icon(Icons.payments),
    typeTransaction: 'Expenses',
  ),
  const StatsPage(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Bills',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.query_stats),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
