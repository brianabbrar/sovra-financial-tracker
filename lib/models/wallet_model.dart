class WalletModel {
  final int? walletId;
  final String walletName;
  final double balance;

  WalletModel({
    this.walletId,
    required this.walletName,
    required this.balance,
  });

  // Perbaikan: Gunakan .toDouble() agar aman dari casting int ke double
  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      walletId: map['wallet_id'] as int?,
      walletName: map['wallet_name'] as String,
      balance: (map['balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'wallet_id': walletId,
      'wallet_name': walletName,
      'balance': balance,
    };
  }
}