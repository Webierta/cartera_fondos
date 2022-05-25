import 'package:flutter/material.dart';

import 'cartera.dart';
import 'fondo.dart';
import 'operacion.dart';
import 'valor.dart';

class CarfoinProvider with ChangeNotifier {
  Cartera? _carteraOn;
  Fondo? _fondoOn;
  List<Valor> _valoresOn = <Valor>[];
  List<Operacion> _operacionesOn = <Operacion>[];

  Cartera? get getCartera => _carteraOn;
  Fondo? get getFondo => _fondoOn;
  List<Valor> get getValores => _valoresOn;
  List<Operacion> get getOperaciones => _operacionesOn;

  set setCartera(Cartera cartera) {
    _carteraOn = cartera;
    // TODO: ??????????????? QUITANDOLOLO NO REBUILD PAGE_HOME AL TAP PARA IR A PAGE CARTERA !!
    notifyListeners();
  }

  set setFondo(Fondo fondo) {
    _fondoOn = fondo;
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
}
