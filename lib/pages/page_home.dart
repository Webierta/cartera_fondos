import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:sqflite_common/sqlite_api.dart';

import '../models/cartera.dart';
import '../models/fondo.dart';
import '../routes.dart';
import '../services/sqlite.dart';
//import '../services/sqlite_service.dart';
import '../widgets/my_drawer.dart';

enum Menu { ordenar, exportar, eliminar }

class PageHome extends StatefulWidget {
  const PageHome({Key? key}) : super(key: key);

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late Sqlite _db;
  // VERSION _SQLITE
  //late SqliteService _sqlite;

  late TextEditingController _controller;
  bool _validText = false;

  var carteras = <Cartera>[];
  var fondos = <Fondo>[];
  Map<String, List<Fondo>> mapCarteraFondos = {};

  //bool _isLoading = true;

  @override
  void initState() {
    _controller = TextEditingController();
    // VERSION _SQLITE
    /*_sqlite = SqliteService();
    _sqlite.initDB().whenComplete(() async {
      await _refreshCarteras();
      _isLoading = false;
    });*/
    _db = Sqlite();
    _db.openDb().whenComplete(() async {
      await _updateDbCarteras();
    });
    super.initState();
  }

  _updateDbCarteras() async {
    await _db.getCarteras();
    setState(() => carteras = _db.dbCarteras);
    for (var cartera in carteras) {
      await _updateDbFondos(cartera);
    }
  }

  _updateDbFondos(Cartera cartera) async {
    await _db.getFondos(cartera);
    setState(() {
      fondos = _db.dbFondos;
      mapCarteraFondos[cartera.name] = fondos;
    });
  }

  // VERSION _SQLITE
  /*_refreshCarteras() async {
    final data = await _sqlite.getCarteras();
    setState(() => carteras = data);
    for (var cartera in carteras) {
      await _refreshFondos(cartera);
    }
  }
  _refreshFondos(Cartera cartera) async {
    final data = await _sqlite.getFondos(cartera);
    setState(() {
      fondos = data;
      mapCarteraFondos[cartera.name] = fondos;
    });
  }*/

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, IconData> mapItemMenu = {
    Menu.ordenar.name: Icons.sort_by_alpha,
    Menu.exportar.name: Icons.save,
    Menu.eliminar.name: Icons.delete_forever,
  };

  @override
  Widget build(BuildContext context) {
    /*List<Column> listItemMenu = mapItemMenu.entries
        .map((e) => Column(
              children: [
                ListTile(
                  leading: Icon(e.value, color: Colors.white),
                  title: Text(
                    '${e.key[0].toUpperCase()}${e.key.substring(1)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (e.key == Menu.ordenar.name) const PopupMenuDivider(height: 10),
              ],
            ))
        .toList();*/

    List<Column> listItemMenu = [
      for (var item in mapItemMenu.entries)
        Column(children: [
          ListTile(
            leading: Icon(item.value, color: Colors.white),
            title: Text(
              '${item.key[0].toUpperCase()}${item.key.substring(1)}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (item.key == Menu.ordenar.name) const PopupMenuDivider(height: 10),
        ])
    ];

    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(child: Text('MIS CARTERAS')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // VERSION _SQLITE
            //onPressed: () => _refreshCarteras(),
            onPressed: () => _updateDbCarteras(),
          ),
          PopupMenuButton(
            color: Colors.blue,
            offset: Offset(0.0, AppBar().preferredSize.height),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            /*itemBuilder: (ctx) => listItemMenu
                .asMap()
                .entries
                .map((e) => PopupMenuItem(value: Menu.values[e.key], child: e.value))
                .toList(),*/
            itemBuilder: (ctx) => [
              for (var item in listItemMenu)
                PopupMenuItem(value: Menu.values[listItemMenu.indexOf(item)], child: item)
            ],
            onSelected: (Menu item) async {
              //TODO: ACCIONES PENDIENTES
              if (item == Menu.ordenar) {
                // VERSION _SQLITE
                //_sqlite.orderByName(carteras);
                //_refreshCarteras();
                // TODO: execute db order
                //await _db.orderCarteras();
                var carterasSort = <Cartera>[];
                carterasSort = [...carteras];
                carterasSort.sort((a, b) => a.name.compareTo(b.name));
                /*for (var cartera in carteras) {
                  _db.deleteCarteraInCarteras(cartera);
                }*/
                _db.deleteAllCarteraInCarteras();
                for (var cartera in carterasSort) {
                  _db.insertCartera(cartera);
                }
                _updateDbCarteras();
                print('ORDENAR POR NOMBRE');
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
      body: FutureBuilder<bool>(
        future: _db.openDb(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error}',
                  style: const TextStyle(fontSize: 18),
                ),
              );
            } else if (snapshot.hasData) {
              return carteras.isEmpty
                  ? const Center(child: Text('No hay carteras guardadas.'))
                  : ListView.builder(
                      itemCount: carteras.length,
                      itemBuilder: (context, index) {
                        int nFondos = mapCarteraFondos[carteras[index].name]?.length ?? 0;
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.business_center_sharp, size: 32),
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
                              onTap: () => Navigator.of(context).pushNamed(
                                RouteGenerator.carteraPage,
                                arguments: carteras[index],
                              ),
                            ),
                          ),
                          background: Container(
                            color: Colors.red,
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            alignment: Alignment.centerRight,
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onDismissed: (_) async {
                            // VERSION _SQLITE
                            //await _deleteCartera(carteras[index]);
                            //await _refreshCarteras();
                            await _db.deleteCarteraInCarteras(carteras[index]);
                            await _updateDbCarteras();
                          },
                        );
                      },
                    );
            }
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Recuperando carteras...'),
              ],
            ),
          );
        },
      ),
      /*body: _isLoading
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Recuperando carteras...'),
              ],
            ))
          : carteras.isNotEmpty
              ? ListView.builder(
                  itemCount: carteras.length,
                  itemBuilder: (context, index) {
                    int nFondos = mapCarteraFondos[carteras[index].name]?.length ?? 0;
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.business_center_sharp, size: 32),
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
                          onTap: () => Navigator.of(context).pushNamed(
                            RouteGenerator.carteraPage,
                            arguments: carteras[index],
                          ),
                        ),
                      ),
                      background: Container(
                        color: Colors.red,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onDismissed: (_) async {
                        // VERSION _SQLITE
                        //await _deleteCartera(carteras[index]);
                        //await _refreshCarteras();
                        await _db.deleteCarteraInCarteras(carteras[index]);
                        await _updateDbCarteras();
                      },
                    );
                  },
                )
              : const Center(child: Text('No hay carteras guardadas.')),*/
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _carteraInput(context),
      ),
    );
  }

  Future<void> _carteraInput(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: const Text('Nueva Cartera'),
                content: TextField(
                  controller: _controller,
                  onChanged: (text) {
                    setState(() {
                      if (text.isNotEmpty) {
                        _validText = true;
                      } else {
                        _validText = false;
                      }
                    });
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                    FilteringTextInputFormatter.deny(RegExp(r'^[0-9]+')),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Nombre',
                    errorMaxLines: 4,
                    errorText: 'Nombre requerido. No debe empezar por un número.'
                        'No admite caracteres de puntuación ni símbolos.',
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('CANCELAR'),
                    onPressed: () {
                      _controller.clear();
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: const Text('ACEPTAR'),
                    style: TextButton.styleFrom(
                      backgroundColor: _validText ? Colors.blue : Colors.grey,
                      primary: Colors.white,
                      //textStyle: const TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_controller.value.text.trim().isNotEmpty) {
                        var _input = _controller.value.text;
                        /* INNECESARIO PORQUE NO SE ADMITEN ESTOS CARACTERES
                        var _alpha = _input.replaceAll(RegExp('[^a-zA-Z0-9_]'), '');
                        var _name = _alpha.startsWith(RegExp(r'[0-9]')) ? '_$_alpha' : _alpha;
                        _controller.value.text.replaceAll(RegExp('[^a-zA-Z0-9_]'), '');*/

                        var existe = [for (var cartera in carteras) cartera.name].contains(_input);
                        /*var existe = false;
                        for (var cartera in carteras) {
                          if (cartera.name == _input) {
                            existe = true;
                            break;
                          }
                        }*/
                        if (existe) {
                          _controller.clear();
                          Navigator.pop(context);
                          _showMsg(
                            msg: 'Ya existe una cartera con ese nombre.',
                            color: Colors.red,
                          );
                        } else {
                          await _db.insertCartera(Cartera(name: _input));
                          await _db.createTableCartera(Cartera(name: _input));
                          await _updateDbCarteras();
                          _controller.clear();
                          Navigator.pop(context);
                        }

                        /*if (await _db.existeTable(_input)) {
                          print('YA EXISTE');
                        } else {
                          await _db.insertCartera(Cartera(name: _input));
                          await _db.createTableCartera(Cartera(name: _input));
                          await _updateDbCarteras();
                          _controller.clear();
                          Navigator.pop(context);
                        }*/
                        //print(check);

                        // if carteras contains Cartera(name: _input) ...

                        // VERSION _SQLITE
                        /*await _sqlite.insertCartera(Cartera(name: _input));
                        await _sqlite.createTableCartera(Cartera(name: _input));
                        await _refreshCarteras();*/
                        //_controller.clear();
                        //Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            );
          });
        });
  }

  void _deleteConfirm(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Eliminar todo'),
            content: const Text('Esto eliminará todas las carteras y sus fondos.'),
            actions: [
              TextButton(
                child: const Text('CANCELAR'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('ACEPTAR'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  primary: Colors.white,
                  //textStyle: const TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  for (var cartera in carteras) {
                    await _deleteCartera(cartera);
                  }
                  // VERSION _SQLITE
                  //await _refreshCarteras();
                  await _updateDbCarteras();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _deleteCartera(Cartera cartera) async {
    // VERSION _SQLITE
    /*List<Fondo> allFondosCartera = await _sqlite.getFondos(cartera);
    if (allFondosCartera.isNotEmpty) {
      for (var fondo in allFondosCartera) {
        await _sqlite.deleteAllValoresInFondo(cartera, fondo);
      }
    }
    await _sqlite.deleteAllFondosInCartera(cartera);
    await _sqlite.deleteCarteraInCarteras(cartera);*/
    await _db.getFondos(cartera);
    if (_db.dbFondos.isNotEmpty) {
      for (var fondo in _db.dbFondos) {
        await _db.deleteAllValoresInFondo(cartera, fondo);
      }
    }
    await _db.deleteAllFondosInCartera(cartera);
    await _db.deleteCarteraInCarteras(cartera);
  }

  void _showMsg({required String msg, MaterialColor color = Colors.grey}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color),
      );
}
