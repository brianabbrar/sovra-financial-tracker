import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../utilities/colors.dart';

class MutationHistoryScreen extends StatefulWidget {
  const MutationHistoryScreen({super.key});

  @override
  State<MutationHistoryScreen> createState() => _MutationHistoryScreenState();
}

class _MutationHistoryScreenState extends State<MutationHistoryScreen> {
  final DbHelper _dbHelper = DbHelper();
  final TextEditingController _searchController = TextEditingController();
  
  DateTimeRange? _selectedDateRange;
  String _searchQuery = "";

  String _formatCurrency(num value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  // Fungsi Query dengan Filter Tanggal & Search (Multi-Column: Kategori, Deskripsi, Wallet)
  Future<List<Map<String, dynamic>>> _getMutationData() async {
    final db = await _dbHelper.database;
    
    String query = '''
      SELECT r.*, w.wallet_name 
      FROM records r
      LEFT JOIN wallet w ON r.wallet_id = w.wallet_id
      WHERE 1=1
    ''';

    // Filter Search Fleksibel
    if (_searchQuery.isNotEmpty) {
      query += ''' 
        AND (
          r.category LIKE '%$_searchQuery%' OR 
          r.description LIKE '%$_searchQuery%' OR 
          w.wallet_name LIKE '%$_searchQuery%'
        )
      ''';
    }

    // Filter Rentang Tanggal
    if (_selectedDateRange != null) {
      String startDate = DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start);
      String endDate = DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end);
      query += " AND r.date BETWEEN '$startDate' AND '$endDate'";
    }

    // Urutan terbaru berdasarkan tanggal dan ID transaksi
    query += " ORDER BY r.date DESC, r.transaction_id DESC";
    return await db.rawQuery(query);
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F172A), 
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Riwayat Mutasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // --- HEADER FILTER & SEARCH ---
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 12),
                _buildDateSelector(),
              ],
            ),
          ),

          // --- LIST MUTASI ---
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getMutationData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return _buildMutationCard(data[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: const InputDecoration(
          hintText: "Cari kategori, ket., atau rekening...",
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey, size: 20),
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    String label = "Pilih Rentang Waktu";
    if (_selectedDateRange != null) {
      label = "${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}";
    }

    return GestureDetector(
      onTap: _pickDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.date_range_rounded, size: 16, color: Color(0xFF0F172A)),
                const SizedBox(width: 10),
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
            if (_selectedDateRange != null)
              GestureDetector(
                onTap: () => setState(() => _selectedDateRange = null),
                child: const Icon(Icons.cancel, size: 18, color: Colors.redAccent),
              )
            else
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMutationCard(Map<String, dynamic> item) {
    bool isIncome = item['type'] == 'income';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (isIncome ? SovraColors.secondary : SovraColors.tertiary).withOpacity(0.1),
            child: Icon(
              isIncome ? Icons.south_west : Icons.north_east,
              color: isIncome ? SovraColors.secondary : SovraColors.tertiary,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['category'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (item['description'] != null && item['description'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(item['description'], style: const TextStyle(color: Colors.black54, fontSize: 12, fontStyle: FontStyle.italic)),
                  ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${DateFormat('dd MMM yyyy').format(DateTime.parse(item['date']))} • ${item['wallet_name'] ?? 'Dompet Terhapus'}",
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${isIncome ? '+' : '-'} ${_formatCurrency(item['amount'])}",
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? "Belum ada riwayat mutasi" : "Data tidak ditemukan", 
            style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }
}