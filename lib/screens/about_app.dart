import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SingleChildScrollView(
        // Tips: Tambahkan padding bawah di sini agar konten tidak mepet navbar
        padding: const EdgeInsets.only(bottom: 120.0), 
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Header Section ---
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/icon/sovran-icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sovra',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'THE SOVEREIGN FINANCIAL',
                style: TextStyle(
                  fontSize: 12, 
                  color: Colors.grey[600], 
                  letterSpacing: 2.0,
                ),
              ),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12, 
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600], 
                  letterSpacing: 2.0,
                ),
              ),
               Text(
                'Developed by Brianabbrar',
                style: TextStyle(
                  fontSize: 12, 
                  color: const Color.fromARGB(255, 255, 0, 0), 
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 40),

              // --- Mission Card ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: const Border(
                    left: BorderSide(color: Colors.black, width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TUJUAN KAMI',
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 20, 
                          color: Colors.black, 
                          fontWeight: FontWeight.w600, 
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'Memberdayakan Anda untuk menguasai takdir keuangan Anda melalui '),
                          TextSpan(text: 'presisi, ', style: TextStyle(color: Colors.green[700])),
                          TextSpan(text: 'keamanan, ', style: TextStyle(color: Colors.blue[700])),
                          const TextSpan(text: 'dan '),
                          TextSpan(text: 'pertumbuhan.', style: TextStyle(color: Colors.green[900])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Features List ---
              _buildFeatureItem(
                icon: Icons.bar_chart_rounded,
                iconColor: Colors.green,
                bgColor: const Color(0xFFE8F5E9),
                title: 'Budgeting Cerdas',
                desc: 'Kontrol penuh atas pengeluaran dengan analisis untuk keputusan keuangan yang lebih cerdas.',
              ),
              _buildFeatureItem(
                icon: Icons.show_chart_rounded,
                iconColor: Colors.white,
                bgColor: const Color(0xFF1A237E),
                title: 'Pelacakan Kekayaan Secara Real-time',
                desc: 'Sinkronisasi aset global dalam satu dasbor berkualitas tinggi.',
              ),
              _buildFeatureItem(
                icon: Icons.lock_outline_rounded,
                iconColor: Colors.red[900]!,
                bgColor: const Color(0xFFFFEBEE),
                title: 'Kemudahan Penggunaan Aplikasi',
                desc: 'Antarmuka yang intuitif dan desain yang elegan untuk pengalaman pengguna yang mulus.',
              ),

              // --- Margin Tambahan ---
              // SizedBox ini memastikan konten terakhir bisa di-scroll melewati tinggi Navbar
              const SizedBox(height: 40), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  desc, 
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}