import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../widgets/sovra_dialog.dart';
import '../models/wallet_model.dart';
import '../providers/bloc/wallet_bloc.dart';
import '../providers/bloc/wallet_event.dart';
import '../providers/bloc/wallet_state.dart';

class FundAccountScreen extends StatefulWidget {
  const FundAccountScreen({super.key});

  @override
  State<FundAccountScreen> createState() => _FundAccountScreenState();
}

class _FundAccountScreenState extends State<FundAccountScreen> {
  String _formatCurrency(num value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  // --- BOTTOM SHEET TAMBAH ACCOUNT ---
  void _showAddAccountSheet() {
    final TextEditingController nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const Text(
              "Add New Account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildInputLabel("ACCOUNT NAME"),
            _buildSimpleInput("e.g. Bank Mandiri", nameController),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                if (nameController.text.isNotEmpty) {
                  // Perubahan: Balance langsung diset ke 0
                  final newWallet = WalletModel(
                    walletName: nameController.text,
                    balance: 0,
                  );

                  context.read<WalletBloc>().add(AddWallet(newWallet));

                  Navigator.pop(context); // Tutup Bottom Sheet

                  showDialog(
                    context: context,
                    builder: (context) => SovraDialog(
                      type: 'success',
                      title: 'Account Added',
                      message:
                          '${nameController.text} telah berhasil disimpan dengan saldo awal Rp 0.',
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF334155)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Save Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
        title: const Text(
          "Dompet",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletLoaded) {
            final accounts = state.wallets;

            if (accounts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Belum ada rekening.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Klik tombol '+' untuk menambah.",
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final acc = accounts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Dismissible(
                    key: Key(acc.walletId.toString()),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      // 1. CEK SALDO: Jika tidak 0, blokir aksi hapus
                      if (acc.balance != 0) {
                        showDialog(
                          context: context,
                          builder: (context) => SovraDialog(
                            type: 'failed', // Pakai icon error/failed
                            title: 'Gagal Menghapus',
                            message:
                                'Dompet "${acc.walletName}" masih memiliki saldo ${_formatCurrency(acc.balance)}. \n\nKosongkan saldo terlebih dahulu (pindahkan atau catat sebagai pengeluaran) sebelum menghapus rekening ini.',
                            primaryActionText: 'Paham',
                            onPrimaryAction: () => Navigator.pop(context),
                          ),
                        );
                        return false; // Mengembalikan false agar Dismissible batal tergeser
                      }

                      // 2. Jika saldo 0, baru tampilkan konfirmasi hapus seperti biasa
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => SovraDialog(
                          type: 'failed', // Atau 'confirm' sesuai seleramu
                          title: 'Hapus Rekening?',
                          message:
                              'Apakah anda yakin ingin menghapus ${acc.walletName}?',
                          primaryActionText: 'Ya, Hapus',
                          onPrimaryAction: () => Navigator.pop(context, true),
                          secondaryActionText: 'Batal',
                          onSecondaryAction: () =>
                              Navigator.pop(context, false),
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      context.read<WalletBloc>().add(
                        DeleteWallet(acc.walletId!),
                      );
                    },
                    background: _buildDeleteBackground(),
                    child: _buildAccountCard(acc),
                  ),
                );
              },
            );
          }

          if (state is WalletError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAccountSheet,
        backgroundColor: const Color(0xFF0F172A),
        label: const Text(
          "Tambah Dompet",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
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
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 12),
          Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildAccountCard(WalletModel acc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF0F172A).withOpacity(0.1),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Color(0xFF0F172A),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acc.walletName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(acc.balance),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Text(
                    "geser untuk hapus",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.grey,
                    size: 14,
                  ),
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
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    ),
  );

  Widget _buildSimpleInput(String hint, TextEditingController controller) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      );
}
