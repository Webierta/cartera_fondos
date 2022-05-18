class Valor {
  final int date;
  final double precio;

  Valor({required this.date, required this.precio});

  Map<String, dynamic> toMap() {
    return {'date': date, 'precio': precio};
  }

  Map<DateTime, double> toMapLine() {
    return {DateTime.fromMillisecondsSinceEpoch(date * 1000): precio};
  }

  Map<int, double> toMapChart() {
    return {date: precio};
  }

  final _valores = <Valor>[];

  List<Valor> get valores {
    return [..._valores];
  }

  Valor? get lastValor {
    if (_valores.isNotEmpty) {
      return _valores.first;
    }
    return null;
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

/*double _getRentabilidad() {
    return rentabilidad;
  }

  double _getTae() {
    return tae;
  }*/
}
