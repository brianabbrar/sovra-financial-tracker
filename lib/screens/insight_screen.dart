import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  String _formatCurrency(num value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil lebar layar untuk menentukan ukuran donut yang dinamis
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // 1. GIANT DONUT CHART SECTION
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
                        // UKURAN RAKSASA: Mengikuti lebar layar dikurangi padding
                        height: screenWidth * 0.75, 
                        width: screenWidth * 0.75,
                        child: CustomPaint(
                          painter: DonutChartPainter(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("TOTAL SPENT", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1)),
                          const SizedBox(height: 12),
                          // Menggunakan FittedBox agar teks uang sebesar apapun tetap muat di dalam
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                _formatCurrency(4820500), 
                                style: const TextStyle(fontSize: 20, color: Color(0xFF0F172A))
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Legends
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildLegend("HOUSING", "45%", const Color(0xFF0F172A)),
                      _buildLegend("LIFESTYLE", "25%", const Color(0xFF64748B)),
                      _buildLegend("SAVINGS", "15%", const Color(0xFF22C55E)),
                      _buildLegend("DINING", "15%", const Color(0xFFEF4444)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text("Expense Breakdown", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            _buildBreakdownItem("Housing & Utilities", "Fixed monthly cost", 2169220, "+2.4%", Colors.blueGrey.shade50, Icons.home_rounded),
            _buildBreakdownItem("Dining & Groceries", "Variable spending", 723080, "-12%", Colors.orange.shade50, Icons.restaurant_rounded),
            _buildBreakdownItem("Lifestyle", "Entertainment & Subs", 1205120, "On track", Colors.purple.shade50, Icons.local_mall_rounded),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Monthly Budgets", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text("View Settings", style: TextStyle(color: Colors.blueGrey))),
              ],
            ),
            const SizedBox(height: 16),

            // 3. BUDGET PROGRESS
            _buildBudgetProgress("Food & Dining", 75, 450000, 600000, Colors.green),
            _buildBudgetProgress("Shopping", 92, 920000, 1000000, Colors.red),
            _buildBudgetProgress("Transport", 30, 120000, 400000, Colors.blue),
            
            // MARGIN BAWAH EXTRA (Sangat tinggi agar tidak terhalang floating button/navbar)
            const SizedBox(height: 150), 
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS (Sama seperti sebelumnya dengan sedikit tweak visual) ---

  Widget _buildLegend(String title, String percent, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(percent, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildBreakdownItem(String title, String subtitle, num amount, String status, Color bgColor, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, size: 22, color: Colors.black87),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatCurrency(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(status, style: TextStyle(color: status.contains('+') ? Colors.red : (status.contains('-') ? Colors.green : Colors.grey), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBudgetProgress(String title, int percent, num used, num total, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text("${_formatCurrency(used)} / ${_formatCurrency(total)}", style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              color: color,
            ),
          )
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    // Ketebalan garis ring donut disesuaikan dengan ukuran besar
    final strokeWidth = radius * 0.32; 
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;

    final data = [
      {'val': 0.45, 'color': const Color(0xFF0F172A)},
      {'val': 0.25, 'color': const Color(0xFF64748B)},
      {'val': 0.15, 'color': const Color(0xFF22C55E)},
      {'val': 0.15, 'color': const Color(0xFFEF4444)},
    ];

    for (var item in data) {
      final sweepAngle = (item['val'] as double) * 2 * math.pi;
      paint.color = item['color'] as Color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
        startAngle + 0.04, 
        sweepAngle - 0.08, 
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}