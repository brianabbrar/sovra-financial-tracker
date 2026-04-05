import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sovra/utilities/colors.dart';
// 1. Import MainWrapper (pastikan kamu sudah membuat file lib/screens/main_wrapper.dart)
import 'package:sovra/screens/main_wrapper.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(const SovraApp());
}

class SovraApp extends StatelessWidget {
  const SovraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sovra',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: SovraColors.neutral,
        // Font Manrope agar sesuai dengan desain yang kamu buat sebelumnya
        fontFamily: 'Manrope', 
        colorScheme: ColorScheme.fromSeed(
          seedColor: SovraColors.primary,
          primary: SovraColors.primary,
        ),
      ),
      // 2. Arahkan home ke MainWrapper, bukan ke DashboardScreen langsung
      home: const MainWrapper(), 
    );
  }
}