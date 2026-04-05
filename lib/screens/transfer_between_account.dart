import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../providers/bloc/wallet_bloc.dart';
import '../providers/bloc/wallet_event.dart';
import '../providers/bloc/wallet_state.dart';
import '../models/wallet_model.dart';
import '../repositories/wallet_repository.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _amountController = TextEditingController(text: "0");
  final TextEditingController _noteController = TextEditingController();
  
  DateTime selectedDate = DateTime.now();
  
  // Awalnya null agar user dipaksa memilih
  WalletModel? sourceAccount;
  WalletModel? destinationAccount;

  String _formatCurrency(num value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  void _showSovraDialog({
    required String type,
    required String title,
    required String message,
    required String primaryText,
    required VoidCallback onPrimary,
    String? secondaryText,
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
                backgroundColor: type == 'success' ? Colors.green.withOpacity(0.1) : (type == 'failed' ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
                child: Icon(
                  type == 'success' ? Icons.check_circle : (type == 'failed' ? Icons.error : Icons.help_outline),
                  color: type == 'success' ? Colors.green : (type == 'failed' ? Colors.red : Colors.orange),
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, height: 1.5)),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: onPrimary,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)]),
                  ),
                  child: Center(child: Text(primaryText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
              if (secondaryText != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(secondaryText, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountPicker(List<WalletModel> wallets, bool isSource) {
    // Jika milih 'To', filter list agar akun 'From' tidak muncul
    final filteredWallets = isSource 
        ? wallets 
        : wallets.where((w) => w.walletId != sourceAccount?.walletId).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isSource ? "Pilih Rekening Sumber" : "Pilih Rekening Tujuan", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              ...filteredWallets.map((acc) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: Color(0xFF0F172A), child: Icon(Icons.account_balance_wallet, color: Colors.white, size: 20)),
                title: Text(acc.walletName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Saldo: ${_formatCurrency(acc.balance)}"),
                trailing: (isSource ? sourceAccount?.walletId : destinationAccount?.walletId) == acc.walletId ? const Icon(Icons.check_circle, color: Colors.blue) : null,
                onTap: () {
                  setState(() {
                    if (isSource) {
                      // Jika sumber berubah, reset tujuan
                      if (sourceAccount?.walletId != acc.walletId) {
                        sourceAccount = acc;
                        destinationAccount = null; 
                      }
                    } else {
                      destinationAccount = acc;
                    }
                  });
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        List<WalletModel> wallets = [];
        if (state is WalletLoaded) {
          wallets = state.wallets;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("Internal Transfer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: wallets.length < 2 
          ? const Center(child: Text("Minimal harus memiliki 2 dompet."))
          : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- INPUT AMOUNT ---
                Center(
                  child: Column(
                    children: [
                      const Text("NOMINAL TRANSFER", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(border: InputBorder.none, prefixText: "Rp ", prefixStyle: TextStyle(fontSize: 24, color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- FROM ACCOUNT ---
                _buildSectionLabel("DARI DOMPET"),
                _buildAccountSelector(sourceAccount, wallets, true, true),
                
                const SizedBox(height: 16),
                const Center(child: Icon(Icons.arrow_downward_rounded, color: Colors.grey)),
                const SizedBox(height: 16),

                // --- TO ACCOUNT ---
                _buildSectionLabel("KE DOMPET"),
                // Disabled jika From belum dipilih
                _buildAccountSelector(destinationAccount, wallets, false, sourceAccount != null),
                
                const SizedBox(height: 32),
                _buildSectionLabel("TANGGAL TRANSFER"),
                _buildDatePicker(),
                const SizedBox(height: 24),
                _buildSectionLabel("CATATAN (OPSIONAL)"),
                _buildNoteInput(),
                const SizedBox(height: 40),
                _buildTransferButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountSelector(WalletModel? account, List<WalletModel> wallets, bool isSource, bool isEnabled) {
    return GestureDetector(
      onTap: isEnabled ? () => _showAccountPicker(wallets, isSource) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFFF9FAFB) : Colors.grey.shade100, 
          borderRadius: BorderRadius.circular(20),
          border: !isEnabled ? Border.all(color: Colors.grey.shade200) : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isEnabled ? const Color(0xFF0F172A) : Colors.grey, 
              radius: 18, 
              child: Icon(Icons.account_balance_wallet, color: Colors.white, size: 18)
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account?.walletName ?? (isSource ? "Pilih Rekening Asal" : "Pilih Rekening Tujuan"), 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: isEnabled ? Colors.black : Colors.grey
                    )
                  ),
                  if (account != null)
                    Text("Saldo: ${_formatCurrency(account.balance)}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.unfold_more, color: isEnabled ? Colors.grey : Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  // ... (Widget _buildDatePicker, _buildNoteInput, dan _buildSectionLabel tetap sama) ...
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
        if (picked != null) setState(() => selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(20)),
        child: Row(children: [const Icon(Icons.calendar_today, size: 20), const SizedBox(width: 12), Text(DateFormat('EEEE, d MMM yyyy').format(selectedDate))]),
      ),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(20)),
      child: TextField(
        controller: _noteController,
        decoration: const InputDecoration(icon: Icon(Icons.notes, size: 20), hintText: "Ditransfer untuk apa?", border: InputBorder.none),
      ),
    );
  }

  Widget _buildTransferButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final double amount = double.tryParse(_amountController.text) ?? 0;

        if (sourceAccount == null || destinationAccount == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih rekening asal dan tujuan!")));
          return;
        }
        if (amount <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nominal harus lebih dari 0!")));
          return;
        }
        if (amount > sourceAccount!.balance) {
          _showSovraDialog(type: 'failed', title: "Saldo Kurang", message: "Saldo tidak mencukupi.", primaryText: "Oke", onPrimary: () => Navigator.pop(context));
          return;
        }

        _showSovraDialog(
          type: 'confirm',
          title: "Konfirmasi",
          message: "Transfer ${_formatCurrency(amount)} ke ${destinationAccount!.walletName}?",
          primaryText: "Kirim",
          secondaryText: "Batal",
          onPrimary: () async {
            Navigator.pop(context);
            final success = await context.read<WalletRepository>().processTransfer(
              fromId: sourceAccount!.walletId!,
              toId: destinationAccount!.walletId!,
              amount: amount,
              notes: _noteController.text,
              date: DateFormat('yyyy-MM-dd').format(selectedDate),
            );
            if (success) {
              if (mounted) context.read<WalletBloc>().add(LoadWallets());
              _showSovraDialog(type: 'success', title: "Berhasil", message: "Dana terkirim!", primaryText: "Selesai", onPrimary: () { Navigator.pop(context); Navigator.pop(context); });
            }
          },
        );
      },
      child: Container(
        width: double.infinity, height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(colors: sourceAccount != null && destinationAccount != null ? [Color(0xFF0F172A), Color(0xFF334155)] : [Colors.grey, Colors.grey]),
        ),
        child: const Center(child: Text("Proses Transfer", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildSectionLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)));
}