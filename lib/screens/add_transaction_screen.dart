import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import path disesuaikan dengan folder 'providers/bloc' lo
import '../models/wallet_model.dart';
import '../repositories/wallet_repository.dart';
import '../providers/bloc/wallet_bloc.dart';
import '../providers/bloc/wallet_event.dart';
import '../providers/bloc/wallet_state.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // State Form
  bool isExpense = true;
  final TextEditingController _amountController = TextEditingController(text: "0");
  final TextEditingController _noteController = TextEditingController();

  // State Pilihan
  String selectedCategory = "FOOD";
  DateTime selectedDate = DateTime.now();

  // State untuk Wallet yang dipilih
  WalletModel? selectedAccount;

  // Daftar Kategori
  final List<Map<String, dynamic>> _categories = [
    {"name": "FOOD", "icon": Icons.restaurant_menu},
    {"name": "TRAVEL", "icon": Icons.directions_bus},
    {"name": "RETAIL", "icon": Icons.shopping_bag},
    {"name": "BILLS", "icon": Icons.bolt},
    {"name": "HEALTH", "icon": Icons.fitness_center},
    {"name": "FUN", "icon": Icons.stadium},
    {"name": "WORK", "icon": Icons.work},
    {"name": "OTHER", "icon": Icons.more_horiz},
  ];

  String _formatCurrency(num value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  void _showAccountPicker(List<WalletModel> wallets) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isExpense ? "Pilih Rekening Sumber" : "Pilih Rekening Tujuan",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              if (wallets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text("Belum ada data dompet.")),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: wallets
                        .map(
                          (acc) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF0F172A),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              acc.walletName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Saldo: ${_formatCurrency(acc.balance)}",
                            ),
                            trailing: selectedAccount?.walletId == acc.walletId
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.blue,
                                  )
                                : null,
                            onTap: () {
                              setState(() => selectedAccount = acc);
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showSovraDialog({
    required String type,
    required String title,
    required String message,
    required String primaryText,
    required VoidCallback onPrimary,
    String? secondaryText,
    VoidCallback? onSecondary,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: type == 'success'
                    ? Colors.green.withOpacity(0.1)
                    : (type == 'failed'
                        ? Colors.red.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1)),
                child: Icon(
                  type == 'success'
                      ? Icons.check_circle
                      : (type == 'failed' ? Icons.error : Icons.help_outline),
                  color: type == 'success'
                      ? Colors.green
                      : (type == 'failed' ? Colors.red : Colors.orange),
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: onPrimary,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF334155)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      primaryText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              if (secondaryText != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onSecondary ?? () => Navigator.pop(context),
                  child: Text(
                    secondaryText,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        List<WalletModel> wallets = [];
        if (state is WalletLoaded) {
          wallets = state.wallets;
          if (selectedAccount == null && wallets.isNotEmpty) {
            selectedAccount = wallets[0];
          }
        }

        // Kunci perbaikan: Wrap dengan Padding + MediaQuery viewInsets
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            // Batasi tinggi maksimal agar tidak overflow layar
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Biar tinggi dinamis sesuai isi
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // INPUT AMOUNT
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                "TOTAL NOMINAL",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  prefixText: "Rp ",
                                  prefixStyle: TextStyle(
                                    fontSize: 24,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // TOGGLE EXPENSE/INCOME
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _toggleItem(
                                  "Pengeluaran",
                                  Icons.arrow_downward,
                                  isExpense,
                                ),
                              ),
                              Expanded(
                                child: _toggleItem(
                                  "Pemasukan",
                                  Icons.arrow_upward,
                                  !isExpense,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // PILIH AKUN
                        _buildSectionLabel(
                          isExpense ? "DARI DOMPET" : "KE DOMPET",
                        ),
                        GestureDetector(
                          onTap: () => _showAccountPicker(wallets),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color(0xFF0F172A),
                                  radius: 18,
                                  child: Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedAccount?.walletName ?? "Pilih Rekening",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Saldo: ${_formatCurrency(selectedAccount?.balance ?? 0)}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(Icons.unfold_more, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // KATEGORI
                        if (isExpense) ...[
                          _buildSectionLabel("Pilih Kategori"),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              bool isSelected = selectedCategory == cat['name'];
                              return GestureDetector(
                                onTap: () => setState(
                                  () => selectedCategory = cat['name'],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(20),
                                    border: isSelected
                                        ? Border.all(
                                            color: const Color(0xFF101828),
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        cat['icon'],
                                        color: isSelected
                                            ? const Color(0xFF101828)
                                            : Colors.grey,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        cat['name'],
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.black : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        // TANGGAL & CATATAN
                        _buildSectionLabel("TANGGAL TRANSAKSI"),
                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => selectedDate = picked);
                            }
                          },
                          child: _fieldContainer(
                            Icons.calendar_today,
                            DateFormat('EEEE, d MMM yyyy').format(selectedDate),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildSectionLabel("CATATAN (OPSIONAL)"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.notes, size: 20),
                              hintText: "What was this for?",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // TOMBOL SAVE
                        _buildSaveButton(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _toggleItem(String title, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() {
        isExpense = (title == "Pengeluaran");
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? (isExpense ? Colors.red : Colors.green)
                  : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final double amount = double.tryParse(_amountController.text) ?? 0;

        if (amount <= 0) {
          _showSovraDialog(
            type: 'failed',
            title: "Nominal Salah",
            message: "Masukkan nominal transaksi yang valid lebih dari 0.",
            primaryText: "Oke",
            onPrimary: () => Navigator.pop(context),
          );
          return;
        }

        if (selectedAccount == null) return;

        if (isExpense && (selectedAccount!.balance < amount)) {
          _showSovraDialog(
            type: 'failed',
            title: "Saldo Kurang",
            message:
                "Saldo di ${selectedAccount!.walletName} tidak mencukupi.\n\nSisa: ${_formatCurrency(selectedAccount!.balance)}",
            primaryText: "Atur Nominal",
            onPrimary: () => Navigator.pop(context),
          );
          return;
        }

        _showSovraDialog(
          type: 'confirm',
          title: "Confirm Transaction",
          message: "Simpan transaksi ${isExpense ? 'pengeluaran' : 'pemasukan'} sebesar ${_formatCurrency(amount)}?",
          primaryText: "Yes, Save",
          secondaryText: "Cancel",
          onPrimary: () async {
            Navigator.pop(context);

            final bool success = await context.read<WalletRepository>().addTransaction(
                  walletId: selectedAccount!.walletId!,
                  amount: amount,
                  type: isExpense ? 'EXPENSE' : 'INCOME',
                  category: isExpense ? selectedCategory : 'INCOME',
                  date: DateFormat('yyyy-MM-dd').format(selectedDate),
                  note: _noteController.text,
                );

            if (success) {
              if (mounted) {
                context.read<WalletBloc>().add(LoadWallets());
              }
              Navigator.pop(context);
            }
          },
        );
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF334155)],
          ),
        ),
        child: const Center(
          child: Text(
            "Simpan Transaksi",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      );

  Widget _fieldContainer(IconData icon, String text) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(text)],
        ),
      );
}