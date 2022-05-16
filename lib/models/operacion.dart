class Operacion {
  final bool tipo;
  final int date;
  final int participaciones;
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
  int totalParticipaciones = 0;
  double importe = 0;
  //double rentabilidad = 0;
  //double tae = 0;

  int _getTotalParticipaciones() {
    return totalParticipaciones;
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
