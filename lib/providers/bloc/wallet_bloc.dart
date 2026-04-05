import 'package:flutter_bloc/flutter_bloc.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';
import '../../repositories/wallet_repository.dart';
import '../../models/wallet_model.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository repository;

  WalletBloc({required this.repository}) : super(WalletInitial()) {
    
    // Logika Mengambil Data
    on<LoadWallets>((event, emit) async {
      emit(WalletLoading());
      try {
        // Ambil data secara paralel biar performa lebih kencang
        final results = await Future.wait([
          repository.fetchWallets(),
          repository.fetchLastMonthBalance(),
        ]);

        final wallets = results[0] as List<WalletModel>;
        final lastMonthTotal = results[1] as double;
        
        // FIX: Hapus kata 'const' di sini karena datanya dinamis
        emit(WalletLoaded(wallets, lastMonthBalance: lastMonthTotal));
      } catch (e) {
        // FIX: Hapus kata 'const' juga di bagian catch
        emit(WalletLoaded([], lastMonthBalance: 0.0));
        print("Gagal memuat data keuangan: $e");
      }
    });

    // Logika Menambah Dompet
    on<AddWallet>((event, emit) async {
      try {
        await repository.addWallet(event.wallet);
        // Panggil LoadWallets lagi buat refresh UI otomatis
        add(LoadWallets()); 
      } catch (e) {
        emit(WalletError("Gagal menambah dompet: $e"));
      }
    });

    // Logika Menghapus Dompet
    on<DeleteWallet>((event, emit) async {
      try {
        await repository.removeWallet(event.id);
        // Refresh data setelah hapus
        add(LoadWallets());
      } catch (e) {
        emit(WalletError("Gagal menghapus dompet: $e"));
      }
    });
  }
}