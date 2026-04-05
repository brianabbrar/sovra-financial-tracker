import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../utilities/colors.dart';
import '../database/db_helper.dart'; // Import DbHelper
import 'transfer_between_account.dart'; 
import 'fund_account_screen.dart';
import '../providers/bloc/wallet_bloc.dart';
import '../providers/bloc/wallet_state.dart';
import '../models/wallet_model.dart';
import 'mutation_history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _formatIDR(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  // Fungsi untuk ambil 5 transaksi terbaru dari DB
  Future<List<Map<String, dynamic>>> _getRecentTransactions() async {
    final db = await DbHelper().database;
    return await db.rawQuery('''
      SELECT r.*, w.wallet_name 
      FROM records r
      LEFT JOIN wallet w ON r.wallet_id = w.wallet_id
      ORDER BY r.date DESC, r.transaction_id DESC
      LIMIT 5
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        List<WalletModel> wallets = [];
        double lastMonthBalance = 0;
        double currentTotal = 0;

        if (state is WalletLoaded) {
          wallets = state.wallets;
          lastMonthBalance = state.lastMonthBalance;
          currentTotal = wallets.fold(0, (sum, item) => sum + item.balance);
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildPortfolioCard(currentTotal, lastMonthBalance),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(Icons.send, "TRANSFER", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TransferScreen()));
                  }),
                  _buildActionButton(Icons.account_balance_wallet_outlined, "DOMPET", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FundAccountScreen()));
                  }),
                  _buildActionButton(Icons.receipt_long, "HISTORI", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MutationHistoryScreen()));
                  }),
                ],
              ),
              const SizedBox(height: 30),

              const Text(
                'Dompet Kamu',
                style: TextStyle(
                  fontFamily: 'Manrope', 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: SovraColors.primary
                ),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 110,
                child: wallets.isEmpty 
                  ? _buildEmptyWalletState()
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: wallets.length,
                      itemBuilder: (context, index) {
                        final wallet = wallets[index];
                        return _buildAccountCard(
                          wallet.walletName, 
                          _formatIDR(wallet.balance), 
                        );
                      },
                    ),
              ),
              const SizedBox(height: 30),

              const Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontFamily: 'Manrope', 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: SovraColors.primary
                ),
              ),
              const SizedBox(height: 16),

              // --- BAGIAN TRANSAKSI DINAMIS ---
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _getRecentTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  final transactions = snapshot.data ?? [];

                  if (transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          children: [
                            Icon(Icons.notes_rounded, color: Colors.grey[300], size: 40),
                            const SizedBox(height: 8),
                            Text("Belum ada aktivitas belanja", 
                              style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: transactions.map((tx) {
                      bool isIncome = tx['type'] == 'income';
                      return _buildTransactionItem(
                        icon: isIncome ? Icons.south_west : Icons.north_east,
                        color: isIncome ? SovraColors.secondary : SovraColors.tertiary,
                        title: tx['category'] ?? "Tanpa Kategori",
                        subtitle: (tx['description'] != null && tx['description'].toString().isNotEmpty) 
                                  ? tx['description'] 
                                  : (isIncome ? "Pemasukan" : "Pengeluaran"),
                        amount: "${isIncome ? '+' : '-'} ${_formatIDR(tx['amount'])}",
                        date: DateFormat('dd MMM').format(DateTime.parse(tx['date'])),
                        isIncome: isIncome,
                      );
                    }).toList(),
                  );
                },
              ),
              
              const SizedBox(height: 120),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPortfolioCard(double currentTotal, double lastMonthTotal) {
    double percentage = 0;
    if (lastMonthTotal > 0) {
      percentage = ((currentTotal - lastMonthTotal) / lastMonthTotal) * 100;
    }
    bool isGrowth = percentage >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SovraColors.primary, Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: SovraColors.primary.withOpacity(0.3), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VALUASI PORTOFOLIO',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5), 
              letterSpacing: 1.2, 
              fontSize: 12, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              _formatIDR(currentTotal),
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 32, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isGrowth ? SovraColors.secondary : Colors.redAccent).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              lastMonthTotal == 0 
                  ? 'Baru dimulai bulan ini' 
                  : '${isGrowth ? '↗' : '↘'} ${percentage.toStringAsFixed(1)}% vs bulan lalu',
              style: TextStyle(
                color: isGrowth ? SovraColors.secondary : Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWalletState() {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Text("Tambah dompet dulu", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ),
    );
  }

  Widget _buildAccountCard(String name, String balance) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [SovraColors.primary, SovraColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name, 
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), 
            overflow: TextOverflow.ellipsis
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              balance, 
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 70, width: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Icon(icon, color: SovraColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label, 
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SovraColors.primary)
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required IconData icon, 
    required Color color, 
    required String title, 
    required String subtitle, 
    required String amount, 
    required String date, 
    required bool isIncome
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1, overflow: TextOverflow.ellipsis
                ),
                Text(subtitle, 
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  maxLines: 1, overflow: TextOverflow.ellipsis
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 13, 
                  color: isIncome ? SovraColors.secondary : SovraColors.tertiary
                )
              ),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}