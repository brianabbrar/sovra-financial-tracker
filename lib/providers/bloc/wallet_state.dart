import 'package:equatable/equatable.dart';
import '../../models/wallet_model.dart';

abstract class WalletState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final List<WalletModel> wallets;
  final double lastMonthBalance; // <--- TAMBAHAN: Untuk data pembanding dashboard

  WalletLoaded(this.wallets, {this.lastMonthBalance = 0.0});

  @override
  List<Object?> get props => [wallets, lastMonthBalance];
}

class WalletError extends WalletState {
  final String message;
  WalletError(this.message);

  @override
  List<Object?> get props => [message];
}