class Fondo {
  final String isin;
  final String name;

  Fondo({required this.isin, required this.name});

  int participaciones = 0;
  var historicoValores = <DateTime, double>{};
  double _saldo = 0;
  // rentabilidad
  // otros índices

  double get saldo => _saldo;

  set saldo(double valorLiquidativo) {
    _saldo = participaciones * valorLiquidativo;
  }

  DateTime? fechaSubscribe;
  var reembolsos = <DateTime, int>{};
  var aportaciones = <DateTime, int>{};

  reembolsar(DateTime fecha, int cantidad) {
    participaciones = participaciones - cantidad;
    reembolsos[fecha] = cantidad;
  }

  aportar(DateTime fecha, int cantidad) {
    participaciones = participaciones + cantidad;
    aportaciones[fecha] = cantidad;
  }
}
