import 'package:equatable/equatable.dart';
import '../../models/wallet_model.dart';

abstract class WalletEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event untuk memicu pengambilan data dari database
class LoadWallets extends WalletEvent {}

// Event untuk menambah dompet baru
class AddWallet extends WalletEvent {
  final WalletModel wallet;
  AddWallet(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

// Event untuk menghapus dompet berdasarkan ID
class DeleteWallet extends WalletEvent {
  final int id;
  DeleteWallet(this.id);

  @override
  List<Object?> get props => [id];
}