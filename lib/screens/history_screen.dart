import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../utilities/colors.dart';
import '../providers/bloc/wallet_bloc.dart';
import '../providers/bloc/wallet_event.dart';
import '../providers/bloc/wallet_state.dart';
import '../database/db_helper.dart';
import '../widgets/sovra_dialog.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedFilter = "Semua";
  final DbHelper _dbHelper = DbHelper();

  String _formatIDR(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  String _getCurrentMonth() {
    return DateFormat('MMMM', 'id_ID').format(DateTime.now()).toUpperCase();
  }

  // --- LOGIC HAPUS TRANSAKSI & KALIBRASI SALDO ---
  Future<void> _deleteTransaction(Map<String, dynamic> data) async {
    final db = await _dbHelper.database;
    final int transactionId = data['transaction_id'];
    final int walletId = data['wallet_id'];
    final double amount = (data['amount'] as num).toDouble();
    final String type = data['type'];

    try {
      await db.transaction((txn) async {
        // 1. Hapus record
        await txn.delete('records', where: 'transaction_id = ?', whereArgs: [transactionId]);

        // 2. Kalibrasi saldo
        if (type == 'income') {
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
      });

      // 3. Refresh data secara menyeluruh
      if (mounted) {
        // Trigger Bloc untuk update saldo global
        context.read<WalletBloc>().add(LoadWallets());
        // Pakai setState untuk trigger FutureBuilder narik data record terbaru dari DB
        setState(() {});
      }
    } catch (e) {
      debugPrint("Gagal hapus transaksi: $e");
    }
  }

  Future<List<Map<String, dynamic>>> _getAllMonthlyRecords() async {
    final db = await _dbHelper.database;
    String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    // Ambil data bulan ini untuk summary
    return await db.rawQuery("SELECT * FROM records WHERE date LIKE '$currentMonth%'");
  }

  Future<List<Map<String, dynamic>>> _getFilteredRecords() async {
    final db = await _dbHelper.database;
    String baseQuery = '''
      SELECT r.*, w.wallet_name 
      FROM records r
      LEFT JOIN wallet w ON r.wallet_id = w.wallet_id
    ''';

    if (selectedFilter == "Masuk") {
      baseQuery += " WHERE r.type = 'income'";
    } else if (selectedFilter == "Keluar") {
      baseQuery += " WHERE r.type = 'expense'";
    }

    baseQuery += " ORDER BY r.date DESC, r.transaction_id DESC"; 
    return await db.rawQuery(baseQuery);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildFilterTabs(),
          const SizedBox(height: 20),
          
          Expanded(
            child: BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                return FutureBuilder<List<List<Map<String, dynamic>>>>(
                  future: Future.wait([
                    _getAllMonthlyRecords(),
                    _getFilteredRecords(),
                  ]),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final summaryRecords = snapshot.data![0];
                    final filteredRecords = snapshot.data![1];

                    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                    final yesterday = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));

                    final todayRecords = filteredRecords.where((r) => r['date'] == today).toList();
                    final yesterdayRecords = filteredRecords.where((r) => r['date'] == yesterday).toList();

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildMonthlySummaryCard(summaryRecords),
                        const SizedBox(height: 30),

                        if (todayRecords.isNotEmpty) ...[
                          _buildSectionHeader("Hari Ini", DateFormat('dd MMM').format(DateTime.now())),
                          ...todayRecords.map((data) => _buildDismissibleCard(data, true)),
                          const SizedBox(height: 20),
                        ],

                        if (yesterdayRecords.isNotEmpty) ...[
                          _buildSectionHeader("Kemarin", DateFormat('dd MMM').format(DateTime.now().subtract(const Duration(days: 1)))),
                          ...yesterdayRecords.map((data) => _buildDismissibleCard(data, false)),
                        ],

                        if (todayRecords.isEmpty && yesterdayRecords.isEmpty)
                          const Center(child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Text("Tidak ada mutasi yang sesuai filter", style: TextStyle(color: Colors.grey)),
                          )),

                        const SizedBox(height: 130), 
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleCard(Map<String, dynamic> data, bool isDeletable) {
    if (!isDeletable) return _buildTransactionCard(data);

    return Dismissible(
      // Pakai UniqueKey supaya Flutter merender ulang widget baru setelah hapus
      key: UniqueKey(), 
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => SovraDialog(
            type: 'confirm', 
            title: "Hapus Transaksi?",
            message: "Data transaksi akan dihapus dan saldo dompet akan dikembalikan secara otomatis.",
            primaryActionText: "Ya, Hapus",
            onPrimaryAction: () => Navigator.pop(context, true),
            secondaryActionText: "Batal",
            onSecondaryAction: () => Navigator.pop(context, false),
          ),
        );
      },
      onDismissed: (direction) => _deleteTransaction(data),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: _buildTransactionCard(data),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> data) {
    bool isIncome = data['type'] == 'income';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (isIncome ? SovraColors.secondary : SovraColors.tertiary).withOpacity(0.1),
            child: Icon(isIncome ? Icons.south_west : Icons.north_east, 
              color: isIncome ? SovraColors.secondary : SovraColors.tertiary, size: 18),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['category'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (data['description'] != null && data['description'].toString().isNotEmpty)
                  Text(data['description'], 
                    style: const TextStyle(color: Colors.black54, fontSize: 12, fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text("Dompet: ${data['wallet_name'] ?? 'Dompet Terhapus'}",
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text("${isIncome ? '+' : '-'} ${_formatIDR(data['amount'])}",
            style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? SovraColors.secondary : SovraColors.tertiary)),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryCard(List<Map<String, dynamic>> records) {
    double totalIncome = 0;
    double totalExpense = 0;
    for (var r in records) {
      if (r['type'] == 'income') totalIncome += r['amount'];
      else totalExpense += r['amount'];
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: SovraColors.primary, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("RINGKASAN ${_getCurrentMonth()}", style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 15),
          Text("- ${_formatIDR(totalExpense)}", style: const TextStyle(color: Color(0xFFFF5252), fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Total Pengeluaran", style: TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 12),
          Text("+ ${_formatIDR(totalIncome)}", style: const TextStyle(color: Color(0xFF69F0AE), fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Total Pemasukan", style: TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ["Semua", "Masuk", "Keluar"].map((label) {
        bool isActive = selectedFilter == label;
        return GestureDetector(
          onTap: () => setState(() => selectedFilter = label),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: isActive ? SovraColors.primary : Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}