import 'package:flutter/material.dart';

import 'fondo.dart';

class Cartera with ChangeNotifier {
  final String name;
  Cartera({required this.name});

  Map<String, dynamic> toMap() {
    return {'name': name};
  }

  final _fondos = <Fondo>[];
  //List get fondos => _fondos;
  List<Fondo> get fondos {
    return [..._fondos];
  }

  int get fondosCount {
    return _fondos.length;
  }

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

class Carteras with ChangeNotifier {
  //final String name;
  //Cartera({required this.name});
  /*Map<String, dynamic> toMap() {
    return {'name': name};
  }*/

  final List<Cartera> _carteras = [];

  List<Cartera> get carteras {
    return [..._carteras];
  }

  int get carterasCount {
    return _carteras.length;
  }

  addCartera(Cartera cartera) {
    _carteras.add(cartera);
    notifyListeners();
  }

  removeCartera(Cartera cartera) {
    _carteras.remove(cartera);
    notifyListeners();
  }
}

//var fondos = <Fondo>[];
// rentabilidad

/*  addFondo(Fondo fondo) {
    fondos.add(fondo);
  }

  removeFondo(Fondo fondo) {
    fondos.remove(fondo);
  }

  updateCartera() {
    for (var fondo in fondos) {
      fondo.update();
    }
  }

  backup() {
    // salvar a database sql
    // nombreCartera.db
  }

  remove() {}*/
