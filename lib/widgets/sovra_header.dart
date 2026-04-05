import 'package:flutter/material.dart';

class SovraHeader extends StatelessWidget {
  final String title;

  const SovraHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Teks Judul (Sovra)
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
          
          // Tombol Notifikasi (Rounded Square)
          // Container(
          //   padding: const EdgeInsets.all(10),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(15),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(0.05),
          //         blurRadius: 10,
          //         offset: const Offset(0, 4),
          //       ),
          //     ],
          //   ),
          //   child: const Icon(
          //     Icons.notifications_none_rounded,
          //     color: Color(0xFF101828),
          //     size: 26,
          //   ),
          // ),
        ],
      ),
    );
  }
}