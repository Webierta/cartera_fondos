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
