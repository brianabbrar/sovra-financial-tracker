import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- WAJIB: Untuk benerin LocaleDataException
import 'package:sovra/utilities/colors.dart';
import 'package:sovra/screens/main_wrapper.dart'; 
import 'package:sovra/repositories/wallet_repository.dart';
import 'package:sovra/providers/bloc/wallet_bloc.dart';
import 'package:sovra/providers/bloc/wallet_event.dart';

void main() async { // <--- Tambahkan 'async' di sini
  // Pastikan inisialisasi Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();
  
  // SOLUSI ERROR: Inisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID', null); 

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
    return RepositoryProvider(
      create: (context) => WalletRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            // Inisialisasi WalletBloc dan langsung tarik data pas app dibuka
            create: (context) => WalletBloc(
              repository: RepositoryProvider.of<WalletRepository>(context),
            )..add(LoadWallets()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sovra',
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: SovraColors.neutral,
            fontFamily: 'Manrope', 
            colorScheme: ColorScheme.fromSeed(
              seedColor: SovraColors.primary,
              primary: SovraColors.primary,
            ),
          ),
          home: const MainWrapper(), 
        ),
      ),
    );
  }
}