import 'package:intl/intl.dart';

extension DateExt on DateTime {
  String dateFormat() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  String dateTimeFormat() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
  }
}
