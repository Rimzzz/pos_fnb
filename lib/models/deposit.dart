import 'dart:convert';

class Deposit {
  final String transaksi;
  final String pendapatan;
  final String pengeluaran;
  final String setoran;

  Deposit({
    required this.transaksi,
    required this.pendapatan,
    required this.pengeluaran,
    required this.setoran,
  });

  factory Deposit.fromJson(String jsonString) {
    final jsonMap = jsonDecode(jsonString);
    return Deposit.fromMap(jsonMap);
  }

  factory Deposit.fromMap(Map<String, dynamic> json) {
    return Deposit(
      transaksi: json['transaksi'],
      pendapatan: json['pendapatan'],
      pengeluaran: json['pengeluaran'],
      setoran: json['setoran'],
    );
  }
}
