//import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/carfoin_provider.dart';
import '../models/cartera.dart';
//import '../models/fondo.dart';
import '../routes.dart';
import '../services/preferences_service.dart';
import '../services/sqlite.dart';
import '../utils/k_constantes.dart';
import '../widgets/loading_progress.dart';
import '../widgets/my_drawer.dart';

enum Menu { renombrar, ordenar, exportar, eliminar }

class PageHome extends StatefulWidget {
  const PageHome({Key? key}) : super(key: key);

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late Sqlite _db;
  late TextEditingController _controller;
  var carteras = <Cartera>[];
  bool _isCarterasByOrder = false;
  //Map<int, List<Fondo>> mapCarteraFondos = {};
  Map<int, int> mapIdCarteraNFondos = {};

  getSharedPrefs() async {
    await PreferencesService.getBool(kKeyByOrderCarterasPref).then((value) {
      setState(() => _isCarterasByOrder = value);
    });
  }

  @override
  void initState() {
    getSharedPrefs();
    _controller = TextEditingController();
    _db = Sqlite();
    _db.openDb().whenComplete(() async {
      await _updateDbCarteras();
    });
    super.initState();
  }

  _updateDbCarteras() async {
    //_byOrder ? await _db.getCarterasSort() : await _db.getCarteras();
    await _db.getCarteras(byOrder: _isCarterasByOrder);
    setState(() => carteras = _db.dbCarteras);
    for (var cartera in _db.dbCarteras) {
      await _updateDbFondos(cartera);
    }
  }

  _updateDbFondos(Cartera cartera) async {
    var tableCartera = '_${cartera.id}';
    //await _db.getFondos(tableCartera);
    //setState(() => mapCarteraFondos[cartera.id] = _db.dbFondos);
    await _db.getNumberFondos(tableCartera);
    setState(() => mapIdCarteraNFondos[cartera.id] = _db.dbNumFondos);
  }

  Future<int> _insertCartera(String name) async {
    Map<String, dynamic> row = {'input': name};
    final int id = await _db.insertCartera(row);
    return id;
  }

  _ordenarCarteras() async {
    /*List<Cartera> carterasSort = <Cartera>[];
    carterasSort = [...carteras];
    carterasSort.sort((a, b) => a.name.compareTo(b.name));
    if (listEquals(carteras, carterasSort)) {
      _showMsg(msg: 'Nada que hacer: Las carteras ya están ordenadas por nombre.');
    } else {*/
    setState(() => _isCarterasByOrder = !_isCarterasByOrder);
    //}
    PreferencesService.saveBool(kKeyByOrderCarterasPref, _isCarterasByOrder);
    await _updateDbCarteras();
    //}
  }

  /*_orderCarteras() async {
    //await _updateDbCarteras();
    List<Cartera> carterasSort = <Cartera>[];
    carterasSort = [...carteras];
    carterasSort.sort((a, b) => a.name.compareTo(b.name));
    // TODO: chequear si ya está ordenada
    //if (ListEquality().(carteras, carterasSort)) {}
    if (listEquals(carteras, carterasSort)) {
      _showMsg(msg: 'Nada que hacer: Las carteras ya están ordenadas por nombre.');
    } else {
      await await _clearCarfoin();
      for (var cartera in carterasSort) {
        int oldId = cartera.id;
        int newId = await _insertCartera(cartera.name);
        //Map<String, dynamic> row = {'name': cartera.name};
        //await _db.insertCartera(row);
        //await _createTableCartera(id);
        var nameTablas = await _db.getNameTables();
        for (var name in nameTablas) {
          if (name.startsWith('_$oldId')) {
            var newName = name.replaceFirst('_$oldId', '__$newId');
            await _db.renameTable(name, newName);
          }
        }
      }
      var nameTablas = await _db.getNameTables();
      for (var name in nameTablas) {
        if (name.startsWith('__')) {
          await _db.renameTable(name, name.substring(1));
        }
      }
      await _updateDbCarteras();
    }
  }*/

  _createTableCartera(int id) async {
    var tableCartera = '_$id';
    await _db.createTableCartera(tableCartera);
  }

  /*_clearCarfoin() async {
    //await _db.deleteAllCarteras();
    await _db.clearCarfoin();
  }*/

  /*_deleteAllValores(Cartera cartera, Fondo fondo) async {
    var tableFondo = '_${cartera.id}' + fondo.isin;
    //await _db.deleteAllValores(tableFondo);
    await _db.eliminaTabla(tableFondo);
  }*/

  _deleteCartera(Cartera cartera) async {
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PopupMenuItem<Menu> _buildMenuItem(Menu menu, IconData iconData, {bool divider = false}) {
    return PopupMenuItem(
      value: menu,
      child: Column(
        children: [
          ListTile(
            leading: Icon(iconData, color: const Color(0xFFFFFFFF)),
            title: Text(
              '${menu.name[0].toUpperCase()}${menu.name.substring(1)}',
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
            trailing: menu == Menu.ordenar
                ? Icon(
                    _isCarterasByOrder ? Icons.check_box : Icons.check_box_outline_blank,
                    color: const Color(0xFFFFFFFF),
                  )
                : null,
          ),
          if (divider == true) const Divider(color: Color(0xFFFFFFFF)), // PopMenuDivider
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carfoin = context.read<CarfoinProvider>();

    return FutureBuilder<bool>(
      future: _db.openDb(),
      builder: (context, snapshot) {
        /*if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingProgress(titulo: 'Recuperando carteras...', subtitulo: 'Cargando...');
        }*/
        if (snapshot.connectionState == ConnectionState.done) {
          // TODO: MANEJAR ESTO
          if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}', style: const TextStyle(fontSize: 18)),
            );
          } else if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: const FittedBox(child: Text('MIS CARTERAS')),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.of(context).pushNamed(RouteGenerator.settingsPage);
                    },
                  ),
                  PopupMenuButton(
                    color: Colors.blue,
                    offset: Offset(0.0, AppBar().preferredSize.height),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    itemBuilder: (ctx) => [
                      _buildMenuItem(Menu.renombrar, Icons.edit, divider: false),
                      _buildMenuItem(Menu.ordenar, Icons.sort_by_alpha, divider: true),
                      _buildMenuItem(Menu.exportar, Icons.save, divider: false),
                      _buildMenuItem(Menu.eliminar, Icons.delete_forever, divider: false),
                    ],
                    onSelected: (item) async {
                      //TODO: ACCIONES PENDIENTES
                      if (item == Menu.renombrar) {
                        print('RENAME');
                      } else if (item == Menu.ordenar) {
                        _ordenarCarteras();
                      } else if (item == Menu.exportar) {
                        print('EXPORTAR');
                      } else if (item == Menu.eliminar) {
                        _deleteConfirm(context);
                      }
                    },
                  ),
                ],
              ),
              drawer: const MyDrawer(),
              floatingActionButton: FloatingActionButton(
                backgroundColor: const Color(0xFFFFC107),
                child: const Icon(Icons.add, color: Color(0xFF0D47A1)),
                onPressed: () => _carteraInput(context),
              ),
              body: carteras.isEmpty
                  ? const Center(child: Text('No hay carteras guardadas.'))
                  : ListView.builder(
                      itemCount: carteras.length,
                      itemBuilder: (context, index) {
                        //int nFondos = mapCarteraFondos[carteras[index].id]?.length ?? 0;
                        int nFondos = mapIdCarteraNFondos[carteras[index].id] ?? 0;
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          child: Card(
                            child: ListTile(
                              //leading: const Icon(Icons.business_center, size: 32),
                              leading: Text('${carteras[index].id}'),
                              title: Text(carteras[index].name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Inversión: 2.156,23 €'),
                                  Text('Valor (12/04/2019): 4.5215,14 €'),
                                  Text('Rendimiento: +2.345,32 €'),
                                  Text('Rentabilidad: 10 %'),
                                ],
                              ),
                              trailing: CircleAvatar(child: Text('$nFondos')),
                              onTap: () {
                                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                //WidgetsBinding.instance?.addPostFrameCallback((_) {
                                carfoin.setCartera = carteras[index];
                                Navigator.of(context).pushNamed(RouteGenerator.carteraPage);
                                //});
                              },
                            ),
                          ),
                          background: Container(
                            color: Colors.red,
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            alignment: Alignment.centerRight,
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          onDismissed: (_) => _onDismissed(index),
                        );
                      },
                    ),
            );
          }
        }
        return const LoadingProgress(titulo: 'Actualizando carteras...');
      },
    );
  }

  _onDismissed(int index) async {
    // no elimina fondos de cartera fantasma
    //await _db.deleteCarteraInCarteras(carteras[index]);
    //await _deleteCartera(carteras[index]);
    var nameTablas = await _db.getNameTables();
    for (var name in nameTablas) {
      print(name);
    }
    print('ELIMINANDO ${carteras[index].id} ${carteras[index].name}');
    await _deleteCartera(carteras[index]);
    await _updateDbCarteras();
    var nameTablas2 = await _db.getNameTables();
    for (var name in nameTablas2) {
      print(name);
    }
  }

  Future<void> _carteraInput(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, TextEditingValue value, __) {
                  return SingleChildScrollView(
                    child: AlertDialog(
                      title: const Text('Nueva Cartera'),
                      content: TextField(
                        controller: _controller,
                        /*inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                          FilteringTextInputFormatter.deny(RegExp(r'^[0-9]+')),
                        ],*/
                        decoration: InputDecoration(
                          hintText: 'Nombre',
                          errorMaxLines: 4,
                          errorText: _errorText,
                        ),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text('CANCELAR'),
                          onPressed: () {
                            _controller.clear();
                            Navigator.pop(context);
                          },
                        ),
                        ElevatedButton(
                          child: const Text('ACEPTAR'),
                          onPressed: _controller.value.text.trim().isNotEmpty ? _submit : null,
                        ),
                      ],
                    ),
                  );
                });
          });
        });
  }

  String? get _errorText {
    final text = _controller.value.text.trim();
    if (text.isEmpty) {
      return 'Campo requerido';
    }
    /*if (text.startsWith('_')) {
      return 'Nombre no válido';
    }*/
    return null;
  }

  void _submit() async {
    if (_errorText == null) {
      var _input = _controller.value.text.trim();

      ///* INNECESARIO PORQUE NO SE ADMITEN ESTOS CARACTERES
      /*var _alpha = _input.replaceAll(RegExp('[^a-zA-Z0-9_]'), '');
      var _name = _alpha.startsWith(RegExp(r'[0-9]')) ? '_$_alpha' : _alpha;
      _controller.value.text.replaceAll(RegExp('[^a-zA-Z0-9_]'), '');*/
      //var existe = [for (var cartera in _db.dbCarteras) cartera.name].contains(_input);
      var existe = [for (var cartera in _db.dbCarteras) cartera.name].contains(_input);
      if (existe) {
        _controller.clear();
        Navigator.pop(context);
        _showMsg(msg: 'Ya existe una cartera con ese nombre.', color: Colors.red);
      } else {
        int id = await _insertCartera(_input);
        await _createTableCartera(id);
        await _updateDbCarteras();
        _controller.clear();
        Navigator.pop(context);
      }
    }
  }

  void _deleteConfirm(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Eliminar todo'),
            content: const Text('Esto eliminará todas las carteras y sus fondos.'),
            actions: [
              ElevatedButton(
                child: const Text('CANCELAR'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: const Text('ACEPTAR'),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336),
                  primary: const Color(0xFFFFFFFF),
                  //textStyle: const TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  var nameTablas = await _db.getNameTables();
                  for (var name in nameTablas) {
                    print(name);
                  }
                  for (var cartera in _db.dbCarteras) {
                    await _deleteCartera(cartera);
                  }
                  await _updateDbCarteras();
                  var nameTablas2 = await _db.getNameTables();
                  for (var name in nameTablas2) {
                    print(name);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _showMsg({required String msg, MaterialColor color = Colors.grey}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color),
      );
}
