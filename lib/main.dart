import 'package:banka/src/sqlite/banka_database.dart';
import 'package:flutter/material.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BankaDatabase.instance.database;
  runApp(const Banka());
}
