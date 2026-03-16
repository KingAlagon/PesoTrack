import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'peso_track.db');
    return openDatabase(path, version: 2, onCreate: _createDb, onUpgrade: _upgradeDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE savings_goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL,
        deadline TEXT,
        color INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE investments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        ticker TEXT,
        quantity REAL NOT NULL,
        buy_price REAL NOT NULL,
        current_price REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        limit_amount REAL NOT NULL,
        period TEXT NOT NULL
      )
    ''');

    await _createPiggyBankTable(db);
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createPiggyBankTable(db);
    }
  }

  Future<void> _createPiggyBankTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS piggy_bank (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL
      )
    ''');
  }

  // ── Expenses ──────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await database;
    return db.query('expenses', orderBy: 'date DESC');
  }

  Future<void> insertExpense(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('expenses', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateExpense(Map<String, dynamic> data) async {
    final db = await database;
    await db.update('expenses', data, where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // ── Savings Goals ─────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getSavingsGoals() async {
    final db = await database;
    return db.query('savings_goals', orderBy: 'name ASC');
  }

  Future<void> insertSavingsGoal(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('savings_goals', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSavingsGoal(Map<String, dynamic> data) async {
    final db = await database;
    await db.update('savings_goals', data, where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<void> deleteSavingsGoal(String id) async {
    final db = await database;
    await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  // ── Investments ───────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getInvestments() async {
    final db = await database;
    return db.query('investments', orderBy: 'date DESC');
  }

  Future<void> insertInvestment(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('investments', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateInvestment(Map<String, dynamic> data) async {
    final db = await database;
    await db.update('investments', data, where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<void> deleteInvestment(String id) async {
    final db = await database;
    await db.delete('investments', where: 'id = ?', whereArgs: [id]);
  }

  // ── Budgets ───────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getBudgets() async {
    final db = await database;
    return db.query('budgets', orderBy: 'category ASC');
  }

  Future<void> insertBudget(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('budgets', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateBudget(Map<String, dynamic> data) async {
    final db = await database;
    await db.update('budgets', data, where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // ── Piggy Bank ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getPiggyBank() async {
    final db = await database;
    final rows = await db.query('piggy_bank', limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> savePiggyBank(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('piggy_bank', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePiggyBank(Map<String, dynamic> data) async {
    final db = await database;
    await db.update('piggy_bank', data, where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<void> deletePiggyBank(String id) async {
    final db = await database;
    await db.delete('piggy_bank', where: 'id = ?', whereArgs: [id]);
  }
}
