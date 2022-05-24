import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/carfoin_provider.dart';
//import '../models/cartera.dart';
import '../models/fondo.dart';
import '../services/api_service.dart';

class PageInputFondo extends StatefulWidget {
  //final Cartera cartera;
  //const PageInputFondo({Key? key, required this.cartera}) : super(key: key);
  const PageInputFondo({Key? key}) : super(key: key);

  @override
  State<PageInputFondo> createState() => _PageInputFondoState();
}

class _PageInputFondoState extends State<PageInputFondo> {
  late TextEditingController _controller;
  late ApiService apiService;

  bool? _validIsin;
  Fondo? locatedFond;
  bool _buscando = false;
  bool? _errorDataApi;

  @override
  void initState() {
    _controller = TextEditingController();
    apiService = ApiService();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _validIsin = null;
    _errorDataApi = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var carteraOn = context.read<CarfoinProvider>().getCartera!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Fondo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  //leading: const Icon(Icons.business_center),
                  //title: Text(carteraOn.name),
                  //subtitle: const Text('Introduce el ISIN del nuevo Fondo'),
                  leading: const Icon(Icons.add_chart, size: 32),
                  title: const Text('Introduce el ISIN del nuevo Fondo'),
                  subtitle: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      avatar: const Icon(Icons.business_center),
                      label: Text(carteraOn.name),
                    ),
                  ),
                ),
                ListTile(
                  title: TextField(
                    controller: _controller,
                    onChanged: (text) {
                      setState(() {
                        _validIsin = null;
                        _errorDataApi = null;
                      });
                    },
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))],
                    decoration: const InputDecoration(
                      hintText: 'ISIN',
                      border: OutlineInputBorder(),
                      //errorText: _emptyIsin ? 'ISIN requerido.' : null,
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //ElevatedButton.icon(onPressed: onPressed, icon: icon, label: label)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.security),
                        label: const Text('Validar'),
                        onPressed: _controller.text.isNotEmpty
                            ? () => setState(() => _validIsin = _checkIsin(_controller.value.text))
                            : null,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar'),
                        onPressed: _controller.text.isEmpty
                            ? null
                            : () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                if (_checkIsin(_controller.value.text)) {
                                  setState(() {
                                    _validIsin = true;
                                    _buscando = true;
                                  });
                                  locatedFond = await _searchIsin(_controller.value.text);
                                  setState(() => _buscando = false);
                                } else {
                                  setState(() => _validIsin = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Código ISIN no válido.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                  trailing: _resultIsValid(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _resultSearch(),
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

  Widget _resultSearch() {
    if (_buscando) {
      return const Center(child: CircularProgressIndicator());
    } else {
      if (_errorDataApi == false) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.assessment),
            title: Text(locatedFond!.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('¿Añadir a la cartera?'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          setState(() {
                            _validIsin = null;
                            _errorDataApi = null;
                          });
                        }),
                    TextButton(
                        child: const Text('Aceptar'),
                        onPressed: () {
                          var fondo = Fondo(name: locatedFond!.name, isin: locatedFond!.isin);
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          Navigator.pop(context, fondo);
                        }),
                  ],
                ),
              ],
            ),
          ),
        );
      } else if (_errorDataApi == true) {
        return const Center(child: Text('Fondo no encontrado'));
      } else {
        return const Text('');
      }
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

  Future<Fondo> _searchIsin(String inputIsin) async {
    final getDataApi = await apiService.getDataApi(inputIsin);
    if (getDataApi != null) {
      setState(() => _errorDataApi = false);
      return Fondo(name: getDataApi.name, isin: inputIsin);
    } else {
      setState(() => _errorDataApi = true);
      return Fondo(name: 'Fondo no encontrado', isin: inputIsin);
    }
  }
}
