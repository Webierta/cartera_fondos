import 'package:flutter/material.dart';

import '../services/sqlite.dart';
import 'cartera.dart';
import 'fondo.dart';
import 'operacion.dart';
import 'valor.dart';

class CarfoinProvider with ChangeNotifier {
  Cartera? _carteraOn;
  Fondo? _fondoOn;
  List<Valor> _valoresOn = <Valor>[];
  List<Operacion> _operacionesOn = <Operacion>[];

  List<Fondo> _fondosList = <Fondo>[];

  Cartera? get getCartera => _carteraOn;
  Fondo? get getFondo => _fondoOn;
  List<Valor> get getValores => _valoresOn;
  List<Operacion> get getOperaciones => _operacionesOn;

  List<Fondo> get getFondos => _fondosList;

  set setCartera(Cartera cartera) {
    _carteraOn = cartera;
    notifyListeners();
  }

  set setFondo(Fondo fondo) {
    _fondoOn = fondo;
    notifyListeners();
  }

  set setFondos(List<Fondo> fondos) {
    _fondosList = fondos;
    notifyListeners();
  }

  set setValores(List<Valor> valores) {
    _valoresOn = valores;
    notifyListeners();
  }

  set setOperaciones(List<Operacion> operaciones) {
    _operacionesOn = operaciones;
    notifyListeners();
  }

  updateFondos(bool _isFondosByOrder) async {
    var _db = Sqlite();
    await _db.openDb();
    var tableCartera = '_${_carteraOn!.id}';
    await _db.getFondos(tableCartera, byOrder: _isFondosByOrder);
    for (var fondo in _db.dbFondos) {
      var tableFondo = '_${_carteraOn!.id}' + fondo.isin;
      await _db.createTableFondo(tableFondo);
      await _getValoresFondo(_db, fondo);
    }
    setFondos = _db.dbFondos;
    notifyListeners();
  }

  _getValoresFondo(Sqlite _db, Fondo fondo) async {
    var tableFondo = '_${_carteraOn!.id}' + fondo.isin;
    await _db.getValoresByOrder(tableFondo);
    fondo.addValores(_db.dbValoresByOrder);
  }

  updateValores() async {
    var _db = Sqlite();
    await _db.openDb();
    var tableCartera = '_${_carteraOn!.id}';
    await _db.getFondos(tableCartera);
    var tableFondo = '_${_carteraOn!.id}' + _fondoOn!.isin;
    await _db.createTableFondo(tableFondo);
    await _db.getValoresByOrder(tableFondo).whenComplete(() => setValores = _db.dbValoresByOrder);
    await _db
        .getOperacionesByOrder(tableFondo)
        .whenComplete(() => setOperaciones = _db.dbOperacionesByOrder);
    notifyListeners();
  }

  eliminarValor(int date) async {
    var _db = Sqlite();
    await _db.openDb();
    var tableFondo = '_${_carteraOn!.id}' + _fondoOn!.isin;
    await _db.deleteValor(tableFondo, date);
    notifyListeners();
  }
}
