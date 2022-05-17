import 'package:intl/intl.dart';

class FechaUtil {
  static String dateToString({required DateTime date, String formato = 'd/MM/yy'}) {
    // DateFormat.yMMM('es').format(dateTime)
    return DateFormat(formato, 'es').format(date);
  }

  static DateTime epochToDate(int epoch) {
    return DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
  }

  static String epochToString(int epoch, {String formato = 'd/MM/yy'}) {
    final DateTime date = epochToDate(epoch);
    return dateToString(date: date, formato: formato);
  }
}

/*String dateToStringYMD(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

String dateToStringDMY(DateTime date) {
  return DateFormat('d/MM/yy').format(date);
}

String dateToStringYM(DateTime date) {
  return DateFormat.yMMM('es').format(date);
}*/
