import 'package:intl/intl.dart';

class Valor {
  final int date;
  final double precio;

  Valor({required this.date, required this.precio});

  Map<String, dynamic> toMap() {
    return {'date': date, 'precio': precio};
  }

  final _valores = <Valor>[];

  List<Valor> get valores {
    return [..._valores];
  }

  /*DateTime get fecha {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(date * 1000);
    //String fechaFormat = DateFormat('yyyy-MM-dd').format(dateTime);
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }*/

  int get valoresCount {
    return _valores.length;
  }

  //TODO: get último valor por date??

  addValor1(Valor valor) {
    _valores.add(valor);
  }

  addValor2(int newDate, double newPrecio) {
    _valores.add(Valor(date: newDate, precio: newPrecio));
  }

  updateValor() {}

  removeValor() {}

  exportarValores() {}
}
