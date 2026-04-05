import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../database/db_helper.dart'; // Sesuaikan path jika berbeda
import '../utilities/colors.dart';

class InsightScreen extends StatefulWidget {
  const InsightScreen({super.key});

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  final DbHelper _dbHelper = DbHelper();
  
  // State untuk filter
  String _selectedType = "Bulanan"; 
  String? _selectedValue; 
  
  List<String> _availableOptions = [];
  List<Map<String, dynamic>> _categoryBreakdown = [];
  double _totalSpent = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  // 1. Ambil daftar tanggal/bulan/tahun yang pernah ada transaksi expense
  Future<void> _loadFilters() async {
    setState(() => _isLoading = true);
    final db = await _dbHelper.database;
    List<String> options = [];

    // Query hanya mengambil data yang tipenya 'expense'
    if (_selectedType == "Harian") {
      final res = await db.rawQuery("SELECT DISTINCT date FROM records WHERE type = 'expense' ORDER BY date DESC");
      options = res.map((e) => e['date'].toString()).toList();
    } else if (_selectedType == "Bulanan") {
      final res = await db.rawQuery("SELECT DISTINCT strftime('%Y-%m', date) as month FROM records WHERE type = 'expense' ORDER BY month DESC");
      options = res.map((e) => e['month'].toString()).toList();
    } else {
      final res = await db.rawQuery("SELECT DISTINCT strftime('%Y', date) as year FROM records WHERE type = 'expense' ORDER BY year DESC");
      options = res.map((e) => e['year'].toString()).toList();
    }

    setState(() {
      _availableOptions = options;
      _selectedValue = options.isNotEmpty ? options.first : null;
    });
    
    if (_selectedValue != null) {
      _fetchInsightData();
    } else {
      setState(() {
        _totalSpent = 0;
        _categoryBreakdown = [];
        _isLoading = false;
      });
    }
  }

  // 2. Ambil data rincian kategori dari DB berdasarkan pilihan filter
  Future<void> _fetchInsightData() async {
    if (_selectedValue == null) return;
    
    final db = await _dbHelper.database;
    String whereClause = "";
    
    if (_selectedType == "Harian") {
      whereClause = "date = '$_selectedValue'";
    } else if (_selectedType == "Bulanan") {
      whereClause = "strftime('%Y-%m', date) = '$_selectedValue'";
    } else {
      whereClause = "strftime('%Y', date) = '$_selectedValue'";
    }

    // Hitung total per kategori
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT category, SUM(amount) as total_amount 
      FROM records 
      WHERE type = 'expense' AND $whereClause
      GROUP BY category 
      ORDER BY total_amount DESC
    ''');

    double sum = 0;
    for (var item in res) {
      sum += (item['total_amount'] as num).toDouble();
    }

    setState(() {
      _categoryBreakdown = res;
      _totalSpent = sum;
      _isLoading = false;
    });
  }

  // Daftar warna estetik untuk chart & list
  Color _getCategoryColor(int index) {
    List<Color> colors = [
      const Color(0xFFFF6B6B), // Pastel Red / Pink Cerah
      const Color(0xFF4ECDC4), // Turqoise Cerah
      const Color(0xFFFFD93D), // Kuning Cerah
      const Color(0xFF6BCB77), // Hijau Daun Muda
      const Color(0xFF4D96FF), // Biru Langit Cerah
      const Color(0xFF917FB3), // Ungu Lavender
      const Color(0xFFFF8E31), // Orange Cerah
    ];
    return colors[index % colors.length];
  }

  // Logic icon otomatis berdasarkan nama kategori
  IconData _getIconForCategory(String category) {
    String c = category.toLowerCase();
    if (c.contains('makan') || c.contains('food') || c.contains('minum')) return Icons.restaurant_rounded;
    if (c.contains('kost') || c.contains('rumah') || c.contains('listrik')) return Icons.home_rounded;
    if (c.contains('transpor') || c.contains('ojek') || c.contains('bensin')) return Icons.directions_car_rounded;
    if (c.contains('belanja') || c.contains('shop') || c.contains('mall')) return Icons.local_mall_rounded;
    if (c.contains('hiburan') || c.contains('nonton') || c.contains('game')) return Icons.videogame_asset_rounded;
    return Icons.category_rounded;
  }

  String _formatCurrency(num value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildTypeSelector(),
                const SizedBox(height: 16),
                _buildValueDropdown(),
                
                const SizedBox(height: 24),
                
                if (_totalSpent > 0) ...[
                  // --- GIANT DONUT CHART ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: screenWidth * 0.65, 
                              width: screenWidth * 0.65,
                              child: CustomPaint(
                                painter: DonutChartPainter(
                                  data: _categoryBreakdown,
                                  total: _totalSpent,
                                  colors: List.generate(_categoryBreakdown.length, (i) => _getCategoryColor(i)),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("TOTAL OUT", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                                const SizedBox(height: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      _formatCurrency(_totalSpent),
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildLegendsGrid(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text("Rincian Kategori", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // LIST RINCIAN DINAMIS
                  ...List.generate(_categoryBreakdown.length, (index) {
                    final item = _categoryBreakdown[index];
                    final double amount = (item['total_amount'] as num).toDouble();
                    final double percent = (amount / _totalSpent) * 100;
                    
                    return _buildBreakdownItem(
                      item['category'], 
                      "${percent.toStringAsFixed(1)}% dari total", 
                      amount, 
                      _getCategoryColor(index),
                      _getIconForCategory(item['category'])
                    );
                  }),
                ] else ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text("Tidak ada data pengeluaran", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                ],

                const SizedBox(height: 120), 
              ],
            ),
          ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: ["Harian", "Bulanan", "Tahunan"].map((type) {
          bool isSelected = _selectedType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedType = type);
                _loadFilters();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : [],
                ),
                child: Center(child: Text(type, style: TextStyle(color: isSelected ? SovraColors.primary : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildValueDropdown() {
    if (_availableOptions.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: _availableOptions.map((val) {
            String display = val;
            if (_selectedType == "Bulanan") display = DateFormat("MMMM yyyy", "id_ID").format(DateFormat("yyyy-MM").parse(val));
            else if (_selectedType == "Harian") display = DateFormat("dd MMMM yyyy", "id_ID").format(DateTime.parse(val));
            return DropdownMenuItem(value: val, child: Text(display, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)));
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedValue = val;
              _isLoading = true;
            });
            _fetchInsightData();
          },
        ),
      ),
    );
  }

  Widget _buildLegendsGrid() {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: List.generate(_categoryBreakdown.length, (index) {
        final item = _categoryBreakdown[index];
        final double percent = (item['total_amount'] / _totalSpent) * 100;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: _getCategoryColor(index), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(item['category'].toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text("${percent.toStringAsFixed(0)}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        );
      }),
    );
  }

  Widget _buildBreakdownItem(String title, String subtitle, num amount, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text(_formatCurrency(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}

// --- PAINTER DINAMIS ---
class DonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double total;
  final List<Color> colors;

  DonutChartPainter({required this.data, required this.total, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.35; 
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final double amount = (data[i]['total_amount'] as num).toDouble();
      final sweepAngle = (amount / total) * 2 * math.pi;
      
      paint.color = colors[i];
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
        startAngle + 0.05, // Spasi kecil antar segmen
        sweepAngle - 0.1, 
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) => 
    oldDelegate.data != data || oldDelegate.total != total;
}