import 'package:banka/src/sqlite/model/transaction.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BankaDatabase {
  static const String databaseName = 'banka.db';
  static final BankaDatabase instance = BankaDatabase._privateConstructor();

  Database? _database;

  BankaDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<List<BankaTransaction>> transactions() async {
    final db = await database;
    final List<Map<String, Object?>> transactionMaps =
        await db.query('transactions');

    return [
      for (final {
            'id': id as int,
            'type': type as String,
            'category': category as String,
            'paymenDate': paymentDate as int,
            'amount': ammount as int,
          } in transactionMaps)
        BankaTransaction(
            id: id,
            type: type,
            category: category,
            paymentDate: paymentDate,
            amount: ammount),
    ];
  }

  Future<void> insertTransaction(BankaTransaction transaction) async {
    final db = await database;
    db.insert('transactions', transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateDog(BankaTransaction transaction) async {
    final db = await database;
    await db.update(
      'dogs',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(BankaTransaction transaction) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);
    bool dbExists = await databaseExists(path);
    return await openDatabase(
      path,
      onCreate: (db, version) {
        if (!dbExists) {
          return db.execute(
            'CREATE TABLE IF NOT EXISTS transactions('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'type TEXT,'
            'category TEXT, '
            'paymentDate INTEGER, '
            'amount INTEGER)',
          );
        }
      },
      version: 1,
    );
  }
}
