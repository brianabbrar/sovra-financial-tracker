import 'package:flutter/material.dart';
import 'package:sovra/screens/about_app.dart';
import '../utilities/colors.dart';
import '../widgets/sovra_header.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'add_transaction_screen.dart'; // Import file yang baru dibuat
import '../widgets/sovra_navbar.dart';
import 'insight_screen.dart';


class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  bool _isPressed = false;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const HistoryScreen(),
    const InsightScreen(),
    AboutPage(),
  ];

  // Fungsi untuk memunculkan modal tambah transaksi
  void _showAddTransaction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar modal bisa hampir full screen
      backgroundColor: Colors.transparent,
      builder: (context) => const FractionallySizedBox(
        heightFactor: 0.9, // Ketinggian modal 90% dari layar
        child: AddTransactionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: SovraColors.neutral,
      
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SovraHeader(title: "Sovra"),
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: Container(
        height: 100,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Navbar Background
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SovraNavbar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
            
            // Tombol ADD dengan Animasi & Fungsi Modal
            Positioned(
              top: 0, 
              child: GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) {
                  setState(() => _isPressed = false);
                  _showAddTransaction(); // Panggil modal saat dilepas
                },
                onTapCancel: () => setState(() => _isPressed = false),
                child: AnimatedScale(
                  scale: _isPressed ? 0.9 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF101828),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF101828).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "ADD", 
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF101828),
                        )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}