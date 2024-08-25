import 'package:banka/src/constants/utils.dart';
import 'package:banka/src/sqlite/banka_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // For formatting dates

class BankaTransactionDialog extends StatefulWidget {
  final String typeTransaction;
  const BankaTransactionDialog({super.key, required this.typeTransaction});

  @override
  State<BankaTransactionDialog> createState() => _BankaTransactionDialog();
}

class _BankaTransactionDialog extends State<BankaTransactionDialog> {
  String dropdownValue = 'Rent/Mortgage';
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isFormValid = false;

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateFormValidity);
    _dateController.addListener(_updateFormValidity);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _updateFormValidity() {
    setState(() {
      _isFormValid =
          _dateController.text.isNotEmpty && _amountController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Transaction'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            // Dropdown for Category
            DropdownButtonFormField<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 16,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items: expenseCategories
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Category',
              ),
            ),
            const SizedBox(
              height: 20, // Adds 20 pixels of vertical space
            ),
            SizedBox(
              width: 250,
              child: TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Payment Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ),
            const SizedBox(
              height: 20, // Adds 20 pixels of vertical space
            ),
            //amount field
            SizedBox(
              width: 250,
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Amount',
                    hintText: 'Enter Amount'),
              ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: _isFormValid
              ? () async {
                  int timestamp = DateTime.parse(_dateController.text)
                          .millisecondsSinceEpoch ~/
                      1000;
                  int amount = int.tryParse(_amountController.text) ?? 0;
                  final db = await BankaDatabase.instance.database;
                  await db.insert('transactions', {
                    'type': widget.typeTransaction,
                    'category': dropdownValue,
                    'paymentDate': timestamp,
                    'amount': amount,
                  });
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(
                        child: Text('Transaction added successfully'),
                      ),
                    ),
                  );
                }
              : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
