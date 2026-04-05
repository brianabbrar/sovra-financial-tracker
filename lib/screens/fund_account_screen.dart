import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/sovra_dialog.dart';

class FundAccountScreen extends StatefulWidget {
  const FundAccountScreen({super.key});

  @override
  State<FundAccountScreen> createState() => _FundAccountScreenState();
}

class _FundAccountScreenState extends State<FundAccountScreen> {
  final List<Map<String, dynamic>> _accounts = [
    {"name": "Main Vault", "suffix": "*8824", "balance": 12450000, "icon": Icons.account_balance_wallet, "color": const Color(0xFF0F172A)},
    {"name": "Bank BCA", "suffix": "*1092", "balance": 5200000, "icon": Icons.credit_card, "color": Colors.blue.shade900},
    {"name": "Cash / Tunai", "suffix": "Wallet", "balance": 450000, "icon": Icons.payments, "color": Colors.green},
  ];

  String _formatCurrency(num value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  // --- FUNGSI HAPUS ACCOUNT ---
  void _deleteAccount(int index) {
    setState(() {
      _accounts.removeAt(index);
    });
  }

  // --- BOTTOM SHEET TAMBAH ACCOUNT ---
  void _showAddAccountSheet() {
    String newName = "";
    String newSuffix = "";
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24, left: 24, right: 24
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            const Text("Add New Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildInputLabel("ACCOUNT NAME"),
            _buildSimpleInput("e.g. Bank Mandiri", (val) => newName = val),
            const SizedBox(height: 20),
            _buildInputLabel("ACCOUNT DETAILS / SUFFIX"),
            _buildSimpleInput("e.g. *1234 or Wallet", (val) => newSuffix = val),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                if (newName.isNotEmpty) {
                  setState(() {
                    _accounts.add({
                      "name": newName,
                      "suffix": newSuffix,
                      "balance": 0,
                      "icon": Icons.account_balance,
                      "color": Colors.grey.shade800
                    });
                  });
                  Navigator.pop(context); // Tutup Bottom Sheet
                  
                  // Tampilkan Sukses menggunakan SovraDialog
                  showDialog(
                    context: context,
                    builder: (context) => SovraDialog(
                      type: 'success',
                      title: 'Account Added',
                      message: '$newName telah berhasil ditambahkan ke daftar rekening kamu.',
                      primaryActionText: 'Mantap',
                      onPrimaryAction: () => Navigator.pop(context),
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)]),
                ),
                child: const Center(child: Text("Save Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Fund Accounts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final acc = _accounts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Dismissible(
              key: Key(acc['name'] + acc['suffix']),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                // Menggunakan SovraDialog untuk Konfirmasi Hapus
                return await showDialog<bool>(
                  context: context,
                  builder: (context) => SovraDialog(
                    type: 'failed', // Pakai failed karena untuk peringatan hapus
                    title: 'Hapus Rekening?',
                    message: 'Apakah anda yakin ingin menghapus ${acc['name']}? Data saldo terkait akan ikut terhapus.',
                    primaryActionText: 'Ya, Hapus Saja',
                    onPrimaryAction: () => Navigator.pop(context, true),
                    secondaryActionText: 'Batalkan',
                    onSecondaryAction: () => Navigator.pop(context, false),
                  ),
                );
              },
              onDismissed: (direction) => _deleteAccount(index),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "RELEASE TO DELETE",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
                  ],
                ),
              ),
              child: _buildAccountCard(acc),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAccountSheet,
        backgroundColor: const Color(0xFF0F172A),
        label: const Text("Add Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> acc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: acc['color'].withOpacity(0.1),
            child: Icon(acc['icon'], color: acc['color'], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(acc['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(acc['suffix'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatCurrency(acc['balance']), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Text("swipe to delete", style: TextStyle(color: Colors.grey, fontSize: 9, fontStyle: FontStyle.italic)),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_left_rounded, color: Colors.grey, size: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
  );

  Widget _buildSimpleInput(String hint, Function(String) onChanged) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(16)),
    child: TextField(
      onChanged: onChanged,
      decoration: InputDecoration(hintText: hint, border: InputBorder.none, hintStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
    ),
  );
}