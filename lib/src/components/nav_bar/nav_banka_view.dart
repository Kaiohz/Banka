import 'package:banka/src/constants/utils.dart';
import 'package:flutter/material.dart';

/// Flutter code sample for [NavigationBar].

class NavigationBanka extends StatefulWidget {
  const NavigationBanka({super.key});

  @override
  State<NavigationBanka> createState() => _NavigationBankaState();
}

class _NavigationBankaState extends State<NavigationBanka> {
  int currentPageIndex = 0;

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
