import 'package:flutter/material.dart';

import 'fondo.dart';

class CarteraProvider with ChangeNotifier {
  final _fondos = <Fondo>[];

  List get fondos => _fondos;

  addFondo(Fondo fondo) {
    _fondos.add(fondo);
    notifyListeners();
  }

  removeFondo(Fondo fondo) {
    _fondos.remove(fondo);
    notifyListeners();
  }

  updateCartera() {
    for (var fondo in _fondos) {
      fondo.update();
    }
    notifyListeners();
  }

  backup() {
    // salvar a database sql
    // nombreCartera.db
  }

  remove() {
    notifyListeners();
  }
}
