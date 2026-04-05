import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

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
  File? _receiptImage;
  final ImagePicker _picker = ImagePicker();
  
  // Data Dummy Rekening
  final List<Map<String, dynamic>> _accounts = [
    {"name": "Main Vault", "suffix": "*8824", "balance": 12450000, "icon": Icons.account_balance_wallet, "color": Colors.black},
    {"name": "Bank BCA", "suffix": "*1092", "balance": 5200000, "icon": Icons.credit_card, "color": Colors.blue.shade900},
    {"name": "Cash / Tunai", "suffix": "Wallet", "balance": 450000, "icon": Icons.payments, "color": Colors.green},
  ];
  
  late Map<String, dynamic> selectedAccount;

  @override
  void initState() {
    super.initState();
    selectedAccount = _accounts[0];
  }

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
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _receiptImage = File(image.path));
    }
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
                  onPressed: onSecondary ?? () => Navigator.pop(context),
                  child: Text(secondaryText, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountPicker() {
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
              Text(isExpense ? "Pilih Rekening Sumber" : "Pilih Rekening Tujuan", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              ..._accounts.map((acc) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: acc['color'], child: Icon(acc['icon'], color: Colors.white, size: 20)),
                title: Text("${acc['name']} - ${acc['suffix']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Saldo: ${_formatCurrency(acc['balance'])}"),
                trailing: selectedAccount['name'] == acc['name'] ? const Icon(Icons.check_circle, color: Colors.blue) : null,
                onTap: () {
                  setState(() => selectedAccount = acc);
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Text("TOTAL AMOUNT", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 24),
                  _buildToggle(),
                  const SizedBox(height: 24),

                  // LOGIKA ADAPTIF FORM
                  _buildSectionLabel(isExpense ? "FROM ACCOUNT" : "TO ACCOUNT / DEPOSIT TO"),
                  _buildAccountSelector(),
                  const SizedBox(height: 24),

                  if (isExpense) ...[
                    _buildSectionLabel("SELECT CATEGORY"),
                    _buildCategoryGrid(),
                    const SizedBox(height: 24),
                  ],

                  _buildSectionLabel(isExpense ? "TRANSACTION DATE" : "INCOME DATE"),
                  _buildDatePicker(),
                  const SizedBox(height: 24),

                  _buildSectionLabel(isExpense ? "NOTE (OPTIONAL)" : "DESCRIPTION"),
                  _buildNoteInput(),
                  const SizedBox(height: 24),

                  if (isExpense) ...[
                    _buildSectionLabel("ATTACH RECEIPT"),
                    _buildAttachReceipt(),
                    const SizedBox(height: 32),
                  ],

                  _buildSaveButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSelector() {
    return GestureDetector(
      onTap: _showAccountPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: selectedAccount['color'], radius: 18, child: Icon(selectedAccount['icon'], color: Colors.white, size: 18)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${selectedAccount['name']} - ${selectedAccount['suffix']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Saldo: ${_formatCurrency(selectedAccount['balance'])}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.unfold_more, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(child: _toggleItem("Expense", Icons.arrow_downward, isExpense)),
          Expanded(child: _toggleItem("Income", Icons.arrow_upward, !isExpense)),
        ],
      ),
    );
  }

  Widget _toggleItem(String title, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => isExpense = title == "Expense"),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isActive ? (isExpense ? Colors.red : Colors.green) : Colors.grey),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        bool isSelected = selectedCategory == cat['name'];
        return GestureDetector(
          onTap: () => setState(() => selectedCategory = cat['name']),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? Border.all(color: const Color(0xFF101828), width: 2) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat['icon'], color: isSelected ? const Color(0xFF101828) : Colors.grey),
                const SizedBox(height: 8),
                Text(cat['name'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
        if (picked != null) setState(() => selectedDate = picked);
      },
      child: _fieldContainer(Icons.calendar_today, DateFormat('EEEE, d MMM yyyy').format(selectedDate)),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(20)),
      child: TextField(
        controller: _noteController,
        decoration: InputDecoration(
          icon: const Icon(Icons.notes, size: 20), 
          hintText: isExpense ? "What was this for?" : "Source of income...", 
          border: InputBorder.none
        ),
      ),
    );
  }

  Widget _buildAttachReceipt() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: _receiptImage != null 
          ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(_receiptImage!, fit: BoxFit.cover))
          : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 30), SizedBox(height: 8), Text("Attach Receipt", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () {
        _showSovraDialog(
          type: 'confirm',
          title: isExpense ? "Confirm Payment" : "Confirm Income",
          message: isExpense 
            ? "Are you sure you want to authorize this payment?"
            : "Are you sure you want to record this income?",
          primaryText: "Yes, Confirm",
          secondaryText: "Cancel",
          onPrimary: () {
            Navigator.pop(context);
            
            // Logika cek saldo hanya untuk Expense
            final bool isSuccess = isExpense 
              ? (int.tryParse(_amountController.text) ?? 0) <= selectedAccount['balance']
              : true; // Income selalu sukses simulasi

            _showSovraDialog(
              type: isSuccess ? 'success' : 'failed',
              title: isSuccess ? "Transaction Successful" : "Transaction Failed",
              message: isSuccess 
                ? "Your ${isExpense ? 'transfer' : 'income'} of Rp ${_amountController.text} has been processed."
                : "Insufficient funds in the selected account.",
              primaryText: "Done",
              onPrimary: () {
                Navigator.pop(context);
                if (isSuccess) Navigator.pop(context);
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.check_circle_outline, color: Colors.white), SizedBox(width: 12), Text("Save Transaction", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)));

  Widget _fieldContainer(IconData icon, String text) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(20)),
    child: Row(children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(text)]),
  );
}