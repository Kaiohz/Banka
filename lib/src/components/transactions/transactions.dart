import 'package:banka/src/components/dialog/banka_transaction_dialog.dart';
import 'package:banka/src/sqlite/model/transaction.dart';
import 'package:flutter/material.dart';
import 'package:banka/src/sqlite/banka_database.dart';

class TransactionsPage extends StatefulWidget {
  final Icon icon;
  final String typeTransaction;
  const TransactionsPage(
      {super.key, required this.icon, required this.typeTransaction});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late Future<List<BankaTransaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = BankaDatabase.instance.transactions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BankaTransaction>>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return Center(
            child: FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return BankaTransactionDialog(
                        typeTransaction: widget.typeTransaction);
                  },
                );
              },
              label: const Text('Add transaction'),
              icon: const Icon(Icons.add),
            ),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              BankaTransaction transaction = snapshot.data![index];
              return ListTile(
                leading: widget.icon,
                title: Text(transaction
                    .category), // Assuming Transaction has a categoryName field
                subtitle: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Your ListTile content here
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
