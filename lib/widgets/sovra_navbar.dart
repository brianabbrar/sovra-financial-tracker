import 'package:flutter/material.dart';
import '../utilities/colors.dart';

class SovraNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SovraNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNavItem(Icons.grid_view_rounded, "ASET", 0),
        _buildNavItem(Icons.history_edu_outlined, "MUTASI", 1),
        
        // Kasih space kosong di tengah untuk tombol ADD yang ada di Stack
        const SizedBox(width: 60),

        _buildNavItem(Icons.bar_chart_outlined, "ANALISIS", 2),
        _buildNavItem(Icons.info_outline, "ABOUT", 3),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = currentIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(15), // Efek hover membulat
          splashColor: SovraColors.primary.withOpacity(0.1), // Warna klik
          highlightColor: SovraColors.primary.withOpacity(0.05), // Warna hover
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? SovraColors.primary : Colors.grey.shade400,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isActive ? SovraColors.primary : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}