import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/sovra_dialog.dart';

class BudgetLimitScreen extends StatefulWidget {
  const BudgetLimitScreen({super.key});

  @override
  State<BudgetLimitScreen> createState() => _BudgetLimitScreenState();
}

class _BudgetLimitScreenState extends State<BudgetLimitScreen> {
  // Data dummy budget
  final List<Map<String, dynamic>> _budgets = [
    {"category": "Food", "icon": Icons.restaurant, "used": 450000, "limit": 600000, "color": Colors.green},
    {"category": "Shopping", "icon": Icons.shopping_bag, "used": 920000, "limit": 1000000, "color": Colors.red},
    {"category": "Transport", "icon": Icons.directions_bus, "used": 120000, "limit": 400000, "color": Colors.blue},
  ];

  // List kategori sesuai UI kamu
  final List<Map<String, dynamic>> _categories = [
    {"name": "FOOD", "icon": Icons.restaurant},
    {"name": "TRAVEL", "icon": Icons.directions_bus},
    {"name": "RETAIL", "icon": Icons.shopping_bag},
    {"name": "BILLS", "icon": Icons.bolt},
    {"name": "HEALTH", "icon": Icons.fitness_center},
    {"name": "FUN", "icon": Icons.stadium},
    {"name": "WORK", "icon": Icons.work},
    {"name": "OTHER", "icon": Icons.more_horiz},
  ];

  int _selectedCategoryIndex = 0;
  String _formatCurrency(num value) => NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);

  void _deleteBudget(int index) {
    setState(() {
      _budgets.removeAt(index);
    });
  }

  void _showAddBudgetSheet() {
    String amount = "";
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
              const Text("Set New Budget", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Text("SELECT CATEGORY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),
              
              // Category Grid Interaktif
              SizedBox(
                height: 180,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.9
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () => setSheetState(() => _selectedCategoryIndex = index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_categories[index]['icon'], size: 24, color: isSelected ? Colors.black : Colors.grey),
                            const SizedBox(height: 4),
                            Text(_categories[index]['name'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              const Text("MONTHLY LIMIT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              _buildAmountInput((val) => amount = val),
              const SizedBox(height: 32),
              _buildSaveButton(() {
                if (amount.isNotEmpty) {
                  final catName = _categories[_selectedCategoryIndex]['name'];
                  setState(() {
                    _budgets.add({
                      "category": catName,
                      "icon": _categories[_selectedCategoryIndex]['icon'],
                      "used": 0,
                      "limit": int.parse(amount),
                      "color": Colors.indigo,
                    });
                  });
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => SovraDialog(
                      type: 'success',
                      title: 'Budget Set!',
                      message: 'Target budget untuk $catName berhasil dibuat.',
                      primaryActionText: 'Oke',
                      onPrimaryAction: () => Navigator.pop(context),
                    ),
                  );
                }
              }),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Monthly Budgets", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white, foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _budgets.length,
        itemBuilder: (context, index) {
          final budget = _budgets[index];
          double percent = budget['used'] / budget['limit'];
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => SovraDialog(
                    type: 'failed',
                    title: 'Hapus Budget?',
                    message: 'Yakin ingin menghapus target budget ${budget['category']}?',
                    primaryActionText: 'Ya, Hapus',
                    onPrimaryAction: () => Navigator.pop(context, true),
                    secondaryActionText: 'Batal',
                    onSecondaryAction: () => Navigator.pop(context, false),
                  ),
                );
              },
              onDismissed: (direction) => _deleteBudget(index),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(24)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("RELEASE TO DELETE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    SizedBox(width: 12),
                    Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
                  ],
                ),
              ),
              child: _buildBudgetCard(budget, percent),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBudgetSheet,
        backgroundColor: const Color(0xFF0F172A),
        label: const Text("Set Budget", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.track_changes, color: Colors.white),
      ),
    );
  }

  Widget _buildBudgetCard(Map<String, dynamic> budget, double percent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18, backgroundColor: budget['color'].withOpacity(0.1),
                    child: Icon(budget['icon'], color: budget['color'], size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(budget['category'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              // Hint Teks "swipe to delete"
              Row(
                children: [
                  const Text("swipe to delete", style: TextStyle(color: Colors.grey, fontSize: 9, fontStyle: FontStyle.italic)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_left_rounded, color: Colors.grey, size: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent > 1.0 ? 1.0 : percent,
              minHeight: 8, backgroundColor: Colors.grey[100], color: budget['color'],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatCurrency(budget['used']), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text("of ${_formatCurrency(budget['limit'])}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput(Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(20)),
      child: TextField(
        onChanged: onChanged, keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(prefixText: "Rp ", border: InputBorder.none, hintText: "0"),
      ),
    );
  }

  Widget _buildSaveButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)]),
        ),
        child: const Center(child: Text("Save Budget Limit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }
}