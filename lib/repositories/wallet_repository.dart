// ignore_for_file: dead_code, dead_null_aware_expression

import '../database/db_helper.dart';
import '../models/wallet_model.dart';
import 'package:sqflite/sqflite.dart';

class WalletRepository {
  final DbHelper _dbHelper = DbHelper();

  Future<List<WalletModel>> fetchWallets() async {
    return await _dbHelper.getAllWallets();
  }

  Future<double> fetchLastMonthBalance() async {
    try {
      return await _dbHelper.getLastMonthBalance();
    } catch (e) {
      return 0.0;
    }
  }

  Future<int> addWallet(WalletModel wallet) async {
    final result = await _dbHelper.insertWallet(wallet);
    await _updateBalanceSnapshot();
    return result;
  }

  Future<int> editWallet(WalletModel wallet) async {
    final result = await _dbHelper.updateWallet(wallet);
    await _updateBalanceSnapshot();
    return result;
  }

  Future<int> removeWallet(int id) async {
    final result = await _dbHelper.deleteWallet(id);
    await _updateBalanceSnapshot();
    return result;
  }

  Future<void> _updateBalanceSnapshot() async {
    final wallets = await _dbHelper.getAllWallets();
    // Null safety check pada balance
    final double total = wallets.fold(
      0.0,
      (sum, item) => sum + (item.balance ?? 0.0) ,
    );
    await _dbHelper.saveBalanceSnapshot(total);
  }

  Future<bool> processTransfer({
    required int fromId,
    required int toId,
    required double amount,
    required String notes,
    required String date,
  }) async {
    final success = await _dbHelper.transferBalance(
      fromId: fromId,
      toId: toId,
      amount: amount,
      notes: notes,
      date: date,
    );
    if (success) await _updateBalanceSnapshot();
    return success;
  }

  // --- FIX: Pakai nama tabel 'records' ---
  Future<bool> addTransaction({
    required int walletId,
    required double amount,
    required String type,
    required String category,
    required String date,
    required String note,
    String? imagePath,
  }) async {
    final Database db = await _dbHelper.database;

    try {
      return await db.transaction((txn) async {
        // Nama tabel 'records' sesuai DbHelper lo
        await txn.insert('records', {
          'wallet_id': walletId,
          'type': type.toLowerCase(),
          'category': category,
          'amount': amount,
          'description': note,
          'date': date,
          // 'created_at' otomatis terisi oleh default value di DB
        });

        // Update saldo wallet
        if (type.toUpperCase() == 'EXPENSE') {
          await txn.rawUpdate(
            'UPDATE wallet SET balance = balance - ? WHERE wallet_id = ?',
            [amount, walletId],
          );
        } else {
          await txn.rawUpdate(
            'UPDATE wallet SET balance = balance + ? WHERE wallet_id = ?',
            [amount, walletId],
          );
        }
        return true;
      });
    } catch (e) {
      print("Error addTransaction: $e");
      return false;
    } finally {
      await _updateBalanceSnapshot();
    }
  }

  // Di dalam class WalletRepository
  Future<List<Map<String, dynamic>>> fetchAllRecords() async {
    final db = await _dbHelper.database;
    // Urutkan berdasarkan tanggal terbaru
    return await db.query('records', orderBy: 'date DESC');
  }
}
