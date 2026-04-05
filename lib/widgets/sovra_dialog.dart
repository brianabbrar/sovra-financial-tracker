import 'package:flutter/material.dart';

class SovraDialog extends StatelessWidget {
  final String type; // 'success', 'failed', 'confirm'
  final String title;
  final String message;
  final String primaryActionText;
  final VoidCallback onPrimaryAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;

  const SovraDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.primaryActionText,
    required this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    if (type == 'success') {
      icon = Icons.check_circle;
      iconColor = Colors.green;
      iconBg = Colors.green.withOpacity(0.1);
    } else if (type == 'failed') {
      icon = Icons.error;
      iconColor = Colors.red;
      iconBg = Colors.red.withOpacity(0.1);
    } else {
      icon = Icons.help;
      iconColor = Colors.brown;
      iconBg = Colors.brown.withOpacity(0.1);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: iconBg,
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            
            // Primary Button (Gradient)
            GestureDetector(
              onTap: onPrimaryAction,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)]),
                ),
                child: Center(
                  child: Text(primaryActionText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            
            if (secondaryActionText != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(secondaryActionText!, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              )
            ]
          ],
        ),
      ),
    );
  }
}