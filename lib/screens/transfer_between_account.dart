import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import '../utilities/colors.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _amountController = TextEditingController(text: "0");
  final TextEditingController _noteController = TextEditingController();
  
  DateTime selectedDate = DateTime.now();

  // Data Dummy Rekening
  final List<Map<String, dynamic>> _accounts = [
    {"name": "Main Vault", "suffix": "*8824", "balance": 12450000, "icon": Icons.account_balance_wallet, "color": const Color(0xFF0F172A)},
    {"name": "Bank BCA", "suffix": "*1092", "balance": 5200000, "icon": Icons.credit_card, "color": Colors.blue.shade900},
    {"name": "Cash / Tunai", "suffix": "Wallet", "balance": 450000, "icon": Icons.payments, "color": Colors.green},
  ];

  late Map<String, dynamic> sourceAccount;
  late Map<String, dynamic> destinationAccount;

  @override
  void initState() {
    super.initState();
    sourceAccount = _accounts[0];
    destinationAccount = _accounts[1];
  }

  String _formatCurrency(num value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  // --- REUSABLE DIALOG (SAMA DENGAN ADD TRANSACTION) ---
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

  void _showAccountPicker(bool isSource) {
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
              Text(isSource ? "Pilih Rekening Sumber" : "Pilih Rekening Tujuan", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              ..._accounts.map((acc) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: acc['color'], child: Icon(acc['icon'], color: Colors.white, size: 20)),
                title: Text("${acc['name']} - ${acc['suffix']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Saldo: ${_formatCurrency(acc['balance'])}"),
                trailing: (isSource ? sourceAccount['name'] : destinationAccount['name']) == acc['name'] ? const Icon(Icons.check_circle, color: Colors.blue) : null,
                onTap: () {
                  setState(() => isSource ? sourceAccount = acc : destinationAccount = acc);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Internal Transfer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: INPUT AMOUNT ---
            Center(
              child: Column(
                children: [
                  const Text("TRANSFER AMOUNT", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
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

            // --- SECTION: FROM ACCOUNT ---
            _buildSectionLabel("FROM ACCOUNT"),
            _buildAccountSelector(sourceAccount, true),
            const SizedBox(height: 16),
            
            // Icon Panah Down
            const Center(child: Icon(Icons.arrow_downward_rounded, color: Colors.grey)),
            const SizedBox(height: 16),

            // --- SECTION: TO ACCOUNT ---
            _buildSectionLabel("TO ACCOUNT"),
            _buildAccountSelector(destinationAccount, false),
            const SizedBox(height: 32),

            // --- SECTION: DATE ---
            _buildSectionLabel("TRANSFER DATE"),
            _buildDatePicker(),
            const SizedBox(height: 24),

            // --- SECTION: NOTES ---
            _buildSectionLabel("NOTE (OPTIONAL)"),
            _buildNoteInput(),
            const SizedBox(height: 40),

            // --- SAVE/CONFIRM BUTTON ---
            _buildTransferButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelector(Map<String, dynamic> account, bool isSource) {
    return GestureDetector(
      onTap: () => _showAccountPicker(isSource),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: account['color'], radius: 18, child: Icon(account['icon'], color: Colors.white, size: 18)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${account['name']} - ${account['suffix']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Saldo: ${_formatCurrency(account['balance'])}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.unfold_more, color: Colors.grey),
          ],
        ),
      ),
    );
  }

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
        decoration: const InputDecoration(icon: Icon(Icons.notes, size: 20), hintText: "What is this transfer for?", border: InputBorder.none),
      ),
    );
  }

  Widget _buildTransferButton() {
    return GestureDetector(
      onTap: () {
        _showSovraDialog(
          type: 'confirm',
          title: "Confirm Transfer",
          message: "Are you sure you want to transfer ${_amountController.text} from ${sourceAccount['name']} to ${destinationAccount['name']}?",
          primaryText: "Yes, Transfer Now",
          secondaryText: "Cancel",
          onPrimary: () {
            Navigator.pop(context);
            
            // Logika Cek Saldo
            final int amount = int.tryParse(_amountController.text) ?? 0;
            final bool isSuccess = amount > 0 && amount <= sourceAccount['balance'];

            _showSovraDialog(
              type: isSuccess ? 'success' : 'failed',
              title: isSuccess ? "Transfer Successful" : "Transfer Failed",
              message: isSuccess 
                ? "Your transfer of Rp $amount has been processed. Funds are now secured."
                : "Insufficient funds in the selected account.",
              primaryText: "Return Home",
              onPrimary: () {
                Navigator.pop(context); // Tutup Dialog
                if (isSuccess) Navigator.pop(context); // Balik ke Dashboard
              },
            );
          },
        );
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)]),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: const Center(child: Text("Process Transfer", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildSectionLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)));
}