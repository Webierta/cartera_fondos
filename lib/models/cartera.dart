import 'fondo.dart';

class Cartera {
  var fondos = <Fondo>[];

  addFondo(Fondo fondo) {
    fondos.add(fondo);
  }

  removeFondo(Fondo fondo) {
    fondos.remove(fondo);
  }

  updateValores() {}
}
