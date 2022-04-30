import 'package:flutter/material.dart';

class Fondo {
  final String isin;
  final String name;

  Fondo({required this.isin, required this.name});

  Map<String, dynamic> toMap() {
    return {'isin': isin, 'name': name};
  }

  int participaciones = 0;
  var historicoValores = <DateTime, double>{};
  double _patrimonio = 0;
  // rentabilidad
  // otros índices

  double get patrimonio => _patrimonio;

  set patrimonio(double valorLiquidativo) {
    _patrimonio = participaciones * valorLiquidativo;
  }

  update() {
    // get fecha + VL
    // historicoValores[fecha] = VL
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

  exportar() {
    // exportar a csv
    // isin.csv
  }
}
