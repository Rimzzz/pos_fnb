import 'dart:convert';

class Rekening {
  String rekening_code;
  String rekening_name;
  Rekening({
    required this.rekening_code,
    required this.rekening_name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Rekening &&
        other.rekening_code == rekening_code &&
        other.rekening_name == rekening_name;
  }

  @override
  int get hashCode => rekening_code.hashCode ^ rekening_name.hashCode;
}
