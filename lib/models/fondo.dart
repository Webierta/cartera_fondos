import 'package:flutter/material.dart';

import 'valor.dart';

class Fondo {
  final String isin;
  final String name;

  Fondo({required this.isin, required this.name});

  Map<String, dynamic> toMap() {
    return {'isin': isin, 'name': name};
  }

  Map<String, dynamic> toMapDataApi() {
    return {
      'isin': isin,
      'name': name,
      'moneda': moneda,
      'lastPrecio': lastPrecio,
      'lastDate': lastDate
    };
  }

  Map<String, dynamic> toMapVL() {
    return {'date': valor, 'name': name};
  }

  String? moneda;
  double? lastPrecio;
  int? lastDate;
  int participaciones = 0;
  double? dif;

  //var valor = <int, double>{};
  late Valor valor;
  //final _historico = <Map<int, double>>[];
  final _historico = <Valor>[];
  double _patrimonio = 0;
  // rentabilidad
  // otros índices

  double get patrimonio => _patrimonio;

  set patrimonio(double valorLiquidativo) {
    _patrimonio = participaciones * valorLiquidativo;
  }

  /*List<Map<int, double>> get historico {
    return [..._historico];
  }*/
  List<Valor> get historico {
    return [..._historico];
  }

  /*addHistorico(int date, double vl) {
    _historico.add({date: vl});
  }*/
  addValor(Valor valor) {
    _historico.add(valor);
  }

  addValores(List<Valor> valores) {
    for (valor in valores) {
      _historico.add(valor);
    }
  }

  /*int getLastDate() {
    Map<int, double> lastEntry = _historico.last;
    List<int> listDate = lastEntry.keys.toList();
    return listDate.first;
  }*/
  int getLastDate() {
    Valor lastEntry = _historico.last;
    //List<int> listDate = lastEntry.keys.toList();
    //return listDate.first;
    return lastEntry.date;
  }

  /*getLastValor() {
    Map<int, double> lastEntry = _historico.last;
    List<double> listVL = lastEntry.values.toList();
    return listVL.first;
  }*/
  double getLastPrecio() {
    // getLastPrecio
    Valor lastEntry = _historico.last;
    //List<double> listVL = lastEntry.values.toList();
    //return listVL.first;
    return lastEntry.precio;
  }

  double? getDif() {
    if (_historico.length > 1) {
      var last = _historico.first.precio;
      var prev = _historico[1].precio;
      return last - prev;
    }
    return null;
  }

  /*Map<int, double> getValorByDate(int date) {
    return _historico[date];
  }*/
  Valor getValorByDate(int date) {
    //return _historico[date];
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
