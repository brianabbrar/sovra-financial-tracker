import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart'; 
import '../models/wallet_model.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  factory DbHelper() => _instance;
  DbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'sovra_finance.db');
    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _onCreate,
      // Jika nanti tambah tabel, naikkan version dan pakai onUpgrade
    );
  }

  Future _onCreate(Database db, int version) async {
    // Tabel Utama Wallet
    await db.execute('''
      CREATE TABLE wallet (
        wallet_id INTEGER PRIMARY KEY AUTOINCREMENT,
        wallet_name TEXT NOT NULL,
        balance REAL DEFAULT 0
      )
    ''');

    // Tabel Records (Transaksi)
    await db.execute('''
      CREATE TABLE records (
        transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
        wallet_id INTEGER,
        type TEXT NOT NULL, 
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (wallet_id) REFERENCES wallet (wallet_id) ON DELETE CASCADE
      )
    ''');

    // Tabel Transfer antar Wallet
    await db.execute('''
      CREATE TABLE transfers (
        transfers_id INTEGER PRIMARY KEY AUTOINCREMENT,
        from_wallet_id INTEGER NOT NULL,
        to_wallet_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        notes TEXT,
        date TEXT NOT NULL,
        FOREIGN KEY (from_wallet_id) REFERENCES wallet (wallet_id),
        FOREIGN KEY (to_wallet_id) REFERENCES wallet (wallet_id)
      )
    ''');

    // Tabel History Saldo untuk Dashboard
    await db.execute('''
      CREATE TABLE balance_history (
        history_id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_balance REAL NOT NULL,
        recorded_date TEXT NOT NULL
      )
    ''');
  }

  // --- CRUD WALLET ---

  Future<int> insertWallet(WalletModel wallet) async {
    Database db = await database;
    return await db.insert('wallet', wallet.toMap());
  }

  Future<List<WalletModel>> getAllWallets() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('wallet');
    
    // FIX: Mapping dari Map ke Objek WalletModel agar tidak error
    return maps.map((e) => WalletModel.fromMap(e)).toList();
  }

  Future<int> updateWallet(WalletModel wallet) async {
    Database db = await database;
    return await db.update(
      'wallet',
      wallet.toMap(),
      where: 'wallet_id = ?',
      whereArgs: [wallet.walletId],
    );
  }

  Future<int> deleteWallet(int id) async {
    Database db = await database;
    return await db.delete('wallet', where: 'wallet_id = ?', whereArgs: [id]);
  }

  // --- BALANCE HISTORY & SNAPSHOT ---

  Future<double> getLastMonthBalance() async {
    try {
      Database db = await database;
      final now = DateTime.now();
      final lastDayPrevMonth = DateTime(now.year, now.month, 0); 
      final formattedDate = DateFormat('yyyy-MM-dd').format(lastDayPrevMonth);

      final result = await db.query(
        'balance_history',
        where: 'recorded_date <= ?',
        whereArgs: [formattedDate],
        orderBy: 'recorded_date DESC',
        limit: 1,
      );

      // FIX: Null safety agar tidak error 'Null is not a subtype of double'
      if (result.isNotEmpty && result.first['total_balance'] != null) {
        return (result.first['total_balance'] as num).toDouble();
      }
    } catch (e) {
      print("Error fetching history: $e");
    }
    return 0.0;
  }

  Future<void> saveBalanceSnapshot(double total) async {
    try {
      Database db = await database;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      await db.insert(
        'balance_history',
        {
          'total_balance': total,
          'recorded_date': today,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Error saving snapshot: $e");
    }
  }

  // --- TRANSACTIONAL LOGIC ---

  Future<bool> transferBalance({
    required int fromId,
    required int toId,
    required double amount,
    required String notes,
    required String date,
  }) async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        // 1. Kurangi Saldo Pengirim
        await txn.execute(
          'UPDATE wallet SET balance = balance - ? WHERE wallet_id = ?',
          [amount, fromId],
        );

        // 2. Tambah Saldo Penerima
        await txn.execute(
          'UPDATE wallet SET balance = balance + ? WHERE wallet_id = ?',
          [amount, toId],
        );

        // 3. Catat di tabel transfers
        await txn.insert('transfers', {
          'from_wallet_id': fromId,
          'to_wallet_id': toId,
          'amount': amount,
          'notes': notes,
          'date': date,
        });
      });
      return true;
    } catch (e) {
      print("Transfer Error: $e");
      return false;
    }
  }
}