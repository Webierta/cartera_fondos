import 'package:flutter/material.dart';

class Fondo {
  final String isin;
  final String name;

  Fondo({required this.isin, required this.name});

  Map<String, dynamic> toMap() {
    return {'isin': isin, 'name': name};
  }

  Map<String, dynamic> toMapVL() {
    return {'date': valor, 'name': name};
  }

  int participaciones = 0;
  // enum ??
  String moneda = 'EUR';
  var valor = <int, double>{};
  final _historico = <Map<int, double>>[];
  double _patrimonio = 0;
  // rentabilidad
  // otros índices

  double get patrimonio => _patrimonio;

  set patrimonio(double valorLiquidativo) {
    _patrimonio = participaciones * valorLiquidativo;
  }

  List<Map<int, double>> get historico {
    return [..._historico];
  }

  addHistorico(int date, double vl) {
    _historico.add({date: vl});
  }

  int getLastDate() {
    Map<int, double> lastEntry = _historico.last;
    List<int> listDate = lastEntry.keys.toList();
    return listDate.first;
  }

  getLastValor() {
    Map<int, double> lastEntry = _historico.last;
    List<double> listVL = lastEntry.values.toList();
    return listVL.first;
  }

  Map<int, double> getValorByDate(int date) {
    return _historico[date];
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
