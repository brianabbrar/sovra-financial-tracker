import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tambahkan intl di pubspec.yaml
import '../utilities/colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildFilterTabs(),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 30),
                  _buildSectionHeader("Hari Ini", "24 OKT"),
                  _buildTransactionItem(
                    "Apple Store",
                    "14:20 • Belanja",
                    "- ${_formatIDR(12990000)}", // Contoh: Rp 12.990.000
                    Icons.shopping_bag,
                    SovraColors.tertiary,
                    false,
                  ),
                  _buildTransactionItem(
                    "Freelance Payout",
                    "09:15 • Pendapatan",
                    "+ ${_formatIDR(4500000)}", // Contoh: Rp 4.500.000
                    Icons.account_balance_wallet,
                    SovraColors.secondary,
                    true,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader("Kemarin", "23 OKT"),
                  _buildTransactionItem(
                    "Gojek / Grab",
                    "21:40 • Transport",
                    "- ${_formatIDR(34500)}",
                    Icons.directions_car,
                    Colors.blue,
                    false,
                  ),
                  _buildTransactionItem(
                    "The Butcher's Son",
                    "19:30 • Makan",
                    "- ${_formatIDR(156200)}",
                    Icons.restaurant,
                    Colors.orange,
                    false,
                  ),
                  // Padding bawah extra agar tidak tertutup navbar melayang
                  const SizedBox(height: 130), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildFilterTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tabButton("Semua", true),
        const SizedBox(width: 8),
        _tabButton("Masuk", false),
        const SizedBox(width: 8),
        _tabButton("Keluar", false),
      ],
    );
  }

  Widget _tabButton(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? SovraColors.primary : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "RINGKASAN OKTOBER",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatIDR(4290000),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                ",00",
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _summarySmall("MASUK", "+ ${_formatIDR(12400000)}", SovraColors.secondary),
              const SizedBox(width: 30),
              _summarySmall("KELUAR", "- ${_formatIDR(8110000)}", Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summarySmall(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: SovraColors.primary,
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String sub,
    String amt,
    IconData icon,
    Color color,
    bool isIncome,
  ) {
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
            padding: const EdgeInsets.all(12),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            amt,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isIncome ? SovraColors.secondary : SovraColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}