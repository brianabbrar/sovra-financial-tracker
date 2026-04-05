import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utilities/colors.dart';
import 'transfer_between_account.dart'; 
import 'fund_account_screen.dart';
import 'budget_limit_screen.dart'; 

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Helper untuk format Rupiah
  String _formatIDR(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildPortfolioCard(),
          const SizedBox(height: 24),

          // Action Buttons dengan Navigasi dan Efek Klik
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                Icons.send, 
                "TRANSFER", 
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TransferScreen()),
                  );
                },
              ),
              _buildActionButton(Icons.account_balance_wallet_outlined, "FUND ACCOUNT", () {
                // Tambahkan navigasi top-up di sini nanti
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FundAccountScreen()),
                );  
              }),
              _buildActionButton(Icons.track_changes, "BUDGET LIMIT", () {
                // Tambahkan navigasi bills di sini nanti
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BudgetLimitScreen()),
                );
              }),
            ],
          ),
          const SizedBox(height: 30),

          // --- SECTION: YOUR ACCOUNTS ---
          const Text(
            'Your Accounts',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: SovraColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAccountCard("Main Vault", _formatIDR(12450000), "*8824"),
                _buildAccountCard("Bank BCA", _formatIDR(5700000), "*1092"),
                _buildAccountCard("E-Wallet", _formatIDR(850000), "OVO"),
              ],
            ),
          ),
          const SizedBox(height: 30),

          const Text(
            'Ledger Activity',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: SovraColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          _buildTransactionItem(
            icon: Icons.business,
            color: SovraColors.secondary,
            title: "Tech Dynamics Corp",
            subtitle: "Gaji Bulanan",
            amount: "+ ${_formatIDR(8400000)}",
            date: "01 MAR",
            isIncome: true,
          ),
          _buildTransactionItem(
            icon: Icons.shopping_basket,
            color: SovraColors.tertiary,
            title: "Organic Grocer",
            subtitle: "Kebutuhan Pokok",
            amount: "- ${_formatIDR(184000)}",
            date: "28 FEB",
            isIncome: false,
          ),
          
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // Widget Kartu Akun dengan desain Gradient Primary
  Widget _buildAccountCard(String name, String balance, String info) {
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
        boxShadow: [
          BoxShadow(
            color: SovraColors.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                info,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              balance,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [SovraColors.primary, SovraColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: SovraColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PORTFOLIO VALUE',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 1.2,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatIDR(142500000),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                ',84',
                style: TextStyle(color: Colors.white60, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: SovraColors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '↗ +12.4% bulan ini',
              style: TextStyle(
                color: SovraColors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tombol Aksi dengan Efek Hover/Klik
  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: SovraColors.primary.withOpacity(0.1),
            child: Container(
              height: 70,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: SovraColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: SovraColors.primary,
          ),
        )
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
    required bool isIncome,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isIncome ? SovraColors.secondary : SovraColors.tertiary,
                ),
              ),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}