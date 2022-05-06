import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cartera.dart';

class PageInputFondo extends StatefulWidget {
  final Cartera cartera;
  const PageInputFondo({Key? key, required this.cartera}) : super(key: key);

  @override
  State<PageInputFondo> createState() => _PageInputFondoState();
}

class _PageInputFondoState extends State<PageInputFondo> {
  late TextEditingController _controller;
  bool? _validIsin;
  bool _emptyIsin = true;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _validIsin = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Fondo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          ListTile(
            leading: const Icon(Icons.business_center),
            title: Text(widget.cartera.name),
            subtitle: const Text('Introduce el ISIN del nuevo Fondo'),
          ),
          ListTile(
            title: TextField(
              controller: _controller,
              onChanged: (text) {
                setState(() {
                  _validIsin = null;
                  if (text.isNotEmpty) {
                    _emptyIsin = false;
                  } else {
                    _emptyIsin = true;
                  }
                });
              },
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
              ],
              decoration: const InputDecoration(
                hintText: 'ISIN',
                border: OutlineInputBorder(),
                //errorText: _emptyIsin ? 'ISIN requerido.' : null,
              ),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    child: const Text('Validar'),
                    onPressed: () {
                      setState(() {
                        _validIsin = _checkIsin(_controller.value.text);
                      });
                    }),
                TextButton(
                    child: const Text('Buscar'),
                    onPressed: () {
                      print('Buscar');
                    }),
              ],
            ),
            trailing: _resultIsValid(),
          ),
          //if (!_emptyIsin)

          Text('Resultado BUSCAR: ENCONTRADO / NO ENCONTRADO'),
          const Text('¿Añadir el fondo a la cartera?'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    print('CANCELAR');
                  }),
              TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    print('ACEPTAR');
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Icon _resultIsValid() {
    if (_validIsin == true) {
      return const Icon(Icons.check_box, color: Colors.green);
    } else if (_validIsin == false) {
      return const Icon(Icons.disabled_by_default, color: Colors.red);
    } else {
      return const Icon(Icons.check_box_outline_blank);
    }
  }

  bool _checkIsin(String inputIsin) {
    var isin = inputIsin.trim().toUpperCase();
    if (isin.length != 12) {
      return false;
    }
    RegExp regExp = RegExp("^[A-Z]{2}[A-Z0-9]{9}");
    if (!regExp.hasMatch(isin)) {
      return false;
    }
    var digitos = <int>[];
    for (var char in isin.codeUnits) {
      if (char >= 65 && char <= 90) {
        final value = char - 55;
        digitos.add(value ~/ 10);
        digitos.add(value % 10);
      } else if (char >= 48 && char <= 57) {
        digitos.add(char - 48);
      } else {
        return false;
      }
    }
    digitos.removeLast();
    digitos = digitos.reversed.toList();
    var suma = 0;
    digitos.asMap().forEach((index, value) {
      if (index.isOdd) {
        suma += value;
      } else {
        var doble = value * 2;
        suma += doble < 9 ? doble : (doble ~/ 10) + (doble % 10);
      }
    });
    var valor = ((suma / 10).ceil() * 10);
    var dc = valor - suma;
    if (dc != int.parse(isin[11])) {
      return false;
    } else {
      return true;
    }
  }
}
