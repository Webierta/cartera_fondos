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

  List<Cartera> _carterasList = <Cartera>[];
  Map<int, int> _mapIdCarteraNFondos = {};
  List<Fondo> _fondosList = <Fondo>[];

  Cartera? get getCartera => _carteraOn;
  Fondo? get getFondo => _fondoOn;
  List<Valor> get getValores => _valoresOn;
  List<Operacion> get getOperaciones => _operacionesOn;

  List<Cartera> get getCarteras => _carterasList;
  Map<int, int> get getMapIdCarteraNFondos => _mapIdCarteraNFondos;
  //int get getNFondos => _nFondos;
  List<Fondo> get getFondos => _fondosList;

  set setCartera(Cartera cartera) {
    _carteraOn = cartera;
    notifyListeners();
  }

  set setFondo(Fondo fondo) {
    _fondoOn = fondo;
    notifyListeners();
  }

  set setCarteras(List<Cartera> carteras) {
    _carterasList = carteras;
    notifyListeners();
  }

  set setFondos(List<Fondo> fondos) {
    _fondosList = fondos;
    notifyListeners();
  }

  /*set setNFondos(int nFondos) {
    _nFondos = nFondos;
    notifyListeners();
  }*/

  set setValores(List<Valor> valores) {
    _valoresOn = valores;
    notifyListeners();
  }

  set setOperaciones(List<Operacion> operaciones) {
    _operacionesOn = operaciones;
    notifyListeners();
  }

  Future<bool> openDb() async {
    var _db = Sqlite();
    return await _db.openDb();
  }

  updateDbCarteras(bool _isCarterasByOrder) async {
    var _db = Sqlite();
    await _db.openDb();
    await _db.getCarteras(byOrder: _isCarterasByOrder);
    setCarteras = _db.dbCarteras;
    for (var cartera in _db.dbCarteras) {
      await updateDbFondos(cartera);
    }
    notifyListeners();
  }

  updateDbFondos(Cartera cartera) async {
    var _db = Sqlite();
    await _db.openDb();
    var tableCartera = '_${cartera.id}';
    await _db.getNumberFondos(tableCartera);
    //setNFondos = _db.dbNumFondos;
    _mapIdCarteraNFondos[cartera.id] = _db.dbNumFondos;
    notifyListeners();
  }

  getNumberFondos(Cartera cartera) async {
    var _db = Sqlite();
    await _db.openDb();
    var tableCartera = '_${cartera.id}';
    return await _db.getNumberFondos(tableCartera);
  }

  Future<int> insertCartera(String name) async {
    var _db = Sqlite();
    await _db.openDb();
    Map<String, dynamic> row = {'input': name};
    final int id = await _db.insertCartera(row);
    notifyListeners();
    return id;
  }

  createTableCartera(int id) async {
    var _db = Sqlite();
    await _db.openDb();
    var tableCartera = '_$id';
    await _db.createTableCartera(tableCartera);
    notifyListeners();
  }

  deleteCartera(Cartera cartera) async {
    var _db = Sqlite();
    await _db.openDb();
    var tableCartera = '_${cartera.id}';
    await _db.getFondos(tableCartera);
    if (_db.dbFondos.isNotEmpty) {
      for (var fondo in _db.dbFondos) {
        //await _db.deleteAllValoresInFondo(cartera, fondo);
        //await _deleteAllValores(cartera, fondo);
        var tableFondo = '_${cartera.id}' + fondo.isin;
        await _db.eliminaTabla(tableFondo);
      }
    }
    //await _db.deleteAllFondos(tableCartera);
    await _db.eliminaTabla(tableCartera);
    await _db.deleteCartera(cartera);
    notifyListeners();
  }

  updateFondos(bool _isFondosByOrder) async {
    //await getFondosCartera(_isFondosByOrder);
    var _db = Sqlite();
    await _db.openDb();
    var tableCartera = '_${_carteraOn!.id}';
    await _db.getFondos(tableCartera, byOrder: _isFondosByOrder);
    for (var fondo in _db.dbFondos) {
      var tableFondo = '_${_carteraOn!.id}' + fondo.isin;
      await _db.createTableFondo(tableFondo);
      await getValoresFondo(fondo);
    }
    setFondos = _db.dbFondos;
    notifyListeners();
  }

  getFondosCartera(bool _isFondosByOrder) async {
    var _db = Sqlite();
    await _db.openDb();
    var tableCartera = '_${_carteraOn!.id}';
    await _db.getFondos(tableCartera, byOrder: _isFondosByOrder);
    setFondos = _db.dbFondos;
    notifyListeners();
  }

  createTableFondo(Fondo fondo) async {
    var _db = Sqlite();
    await _db.openDb();
    var tableFondo = '_${_carteraOn!.id}' + fondo.isin;
    await _db.createTableFondo(tableFondo);
    notifyListeners();
  }

  insertFondoCartera(Fondo fondo) async {
    var _db = Sqlite();
    await _db.openDb();
    var tableCartera = '_${_carteraOn!.id}';
    Map<String, dynamic> row = {'isin': fondo.isin, 'name': fondo.name, 'divisa': fondo.divisa};
    await _db.insertFondo(tableCartera, row);
    notifyListeners();
  }

  insertValorFondo(Fondo fondo, Valor valor) async {
    var _db = Sqlite();
    await _db.openDb();
    var tableFondo = '_${_carteraOn!.id}' + fondo.isin;
    Map<String, dynamic> row = {'date': valor.date, 'precio': valor.precio};
    await _db.insertVL(tableFondo, row);
    notifyListeners();
  }

  getValoresFondo(Fondo fondo) async {
    var _db = Sqlite();
    await _db.openDb();
    var tableFondo = '_${_carteraOn!.id}' + fondo.isin;
    await _db.getValoresByOrder(tableFondo);
    fondo.addValores(_db.dbValoresByOrder);
    // TODO : necesario notity ??
    notifyListeners();
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

  /*getFondosDb() async {
    var _db = Sqlite();
    await _db.openDb();
    var tableCartera = '_${_carteraOn!.id}';
    await _db.getFondos(tableCartera);
    notifyListeners();
  }*/

  insertFondo() async {
    var _db = Sqlite();
    await _db.openDb();
    var tableCartera = '_${_carteraOn!.id}';
    Map<String, dynamic> row = {
      'isin': _fondoOn!.isin,
      'name': _fondoOn!.name,
      'divisa': _fondoOn!.divisa
    };
    await _db.insertFondo(tableCartera, row);
    notifyListeners();
  }

  deleteFondo(Fondo fondo) async {
    var _db = Sqlite();
    await _db.openDb();
    var tableFondo = '_${_carteraOn!.id}' + fondo.isin;
    await _db.eliminaTabla(tableFondo);
    // TODO: get valores y drop ??
    var tableCartera = '_${_carteraOn!.id}';
    await _db.deleteFondo(tableCartera, fondo);
    notifyListeners();
  }

  // TODO: REVISAR SI SE USA
  deleteAllFondos() async {
    var _db = Sqlite();
    await _db.openDb();
    var tableCartera = '_${_carteraOn!.id}';
    //await _db.deleteAllFondos(tableCartera);
    await _db.eliminaTabla(tableCartera);
    notifyListeners();
  }

  insertValor(Valor valor) async {
    var _db = Sqlite();
    await _db.openDb();
    var tableFondo = '_${_carteraOn!.id}' + _fondoOn!.isin;
    Map<String, dynamic> row = {'date': valor.date, 'precio': valor.precio};
    await _db.insertVL(tableFondo, row);
    notifyListeners();
  }

  insertValores(List<Valor> valores) async {
    var _db = Sqlite();
    await _db.openDb();
    var tableFondo = '_${_carteraOn!.id}' + _fondoOn!.isin;
    for (var valor in valores) {
      Map<String, dynamic> row = {'date': valor.date, 'precio': valor.precio};
      await _db.insertVL(tableFondo, row);
    }
    notifyListeners();
  }

  deleteAllValores() async {
    var _db = Sqlite();
    await _db.openDb();
    var tableFondo = '_${_carteraOn!.id}' + _fondoOn!.isin;
    await _db.eliminaTabla(tableFondo);
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
