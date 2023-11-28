import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getThousandSeparator(String? number) {
  final intNumber = number == null
      ? 0
      : number == 'null'
          ? 0
          : int.parse(number);
  final formatter = NumberFormat.decimalPattern('id_ID');
  var format = NumberFormat.currency(locale: "id");
  return formatter.format(intNumber);
}

String getCurrencySeparator(String? number) {
  final doubleNumber = number == null
      ? 0.0
      : number == 'null'
          ? 0.0
          : double.parse(number);
  final formatter = NumberFormat.decimalPattern('id_ID');
  return formatter.format(doubleNumber);
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: Colors.red,
    ),
  );
}
