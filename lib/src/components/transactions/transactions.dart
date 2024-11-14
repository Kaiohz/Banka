import 'package:banka/src/components/dialog/banka_transaction_dialog.dart';
import 'package:banka/src/sqlite/model/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _salaryController = TextEditingController();
  double _totalTransactions = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  void _loadTransactions() {
    setState(() {
      _transactionsFuture = BankaDatabase.instance.transactions(type: widget.typeTransaction);
    });
  }

  Widget _buildSalaryInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _salaryController,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          labelText: 'Monthly Salary',
          hintText: 'Enter your monthly salary',
          prefixIcon: const Icon(Icons.euro),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          suffixText: '€',
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildRemainingAmount() {
    double salary = double.tryParse(_salaryController.text) ?? 0;
    double remaining = salary - _totalTransactions;
    
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 80.0,
      ),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Remaining:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${remaining.toStringAsFixed(2)} €',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: remaining >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalAmount() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 80.0,
      ),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Expenses:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_totalTransactions.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (widget.typeTransaction == 'Bills') _buildSalaryInput(),
          
          Expanded(
            child: FutureBuilder<List<BankaTransaction>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No transactions yet'),
                  );
                } else {
                  // Calculer le total des transactions
                  _totalTransactions = snapshot.data!.fold(
                    0, 
                    (sum, transaction) => sum + transaction.amount
                  );

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      BankaTransaction transaction = snapshot.data![index];
                      return ListTile(
                        leading: widget.icon,
                        title: Text(transaction.category),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${transaction.amount.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateTime.fromMillisecondsSinceEpoch(
                                      transaction.paymentDate * 1000)
                                  .toString()
                                  .split(' ')[0],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          
          // Afficher soit le remaining pour Bills, soit le total pour Expenses
          if (widget.typeTransaction == 'Bills')
            _buildRemainingAmount()
          else if (widget.typeTransaction == 'Expenses')
            _buildTotalAmount(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return BankaTransactionDialog(
                  typeTransaction: widget.typeTransaction);
            },
          );
          
          if (result == true) {
            _loadTransactions();
          }
        },
        label: const Text('Add transaction'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
