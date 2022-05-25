class Operacion {
  final int tipo;
  final int date;
  final double participaciones;
  final double precio;

  Operacion({
    required this.tipo,
    required this.date,
    required this.participaciones,
    required this.precio,
  });

  Map<String, dynamic> toMap() {
    return {'tipo': tipo, 'date': date, 'participaciones': participaciones, 'precio': precio};
  }

  String moneda = '';
  double inversion = 0;
  int participacionesActual = 0;
  double precioActual = 0;
  double importeActual = 0;
  //double rentabilidad = 0;
  //double tae = 0;

  int _getTotalParticipaciones() {
    return participacionesActual;
  }

  double _getInversion() {
    return participaciones * precio;
  }

  double _getImporte(double lastPrecio) {
    return participaciones * lastPrecio;
  }

  /*double _getRentabilidad() {
    return rentabilidad;
  }

  double _getTae() {
    return tae;
  }*/
}
