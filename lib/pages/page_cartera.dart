import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../models/cartera.dart';
import '../models/fondo.dart';
import '../models/valor.dart';
import '../routes.dart';
import '../services/api_service.dart';
import '../services/sqlite.dart';
//import '../services/sqlite_service.dart';

enum MenuCartera { eliminar }

class PageCartera extends StatefulWidget {
  final Cartera cartera;
  const PageCartera({Key? key, required this.cartera}) : super(key: key);

  @override
  State<PageCartera> createState() => _PageCarteraState();
}

class _PageCarteraState extends State<PageCartera> {
  late Sqlite _db;
  //late SqliteService _sqlite;
  late ApiService apiService;

  var fondos = <Fondo>[];
  //bool _fondoRepe = false;

  bool _isUpdating = false;
  String _msgUpdating = '';

  @override
  void initState() {
    /*_sqlite = SqliteService();
    _sqlite.initDB().whenComplete(() async {
      await _refreshFondos();
    });*/
    _db = Sqlite();
    _db.openDb().whenComplete(() async {
      await _updateFondos();
    });
    apiService = ApiService();
    super.initState();
  }

  _updateFondos() async {
    await _db.getFondos(widget.cartera);
    //setState(() => fondos = _db.dbFondos);
    for (var fondo in _db.dbFondos) {
      await _db.createTableFondo(widget.cartera, fondo);
      await _getValoresFondo(fondo);
    }
    setState(() => fondos = _db.dbFondos);
  }

  /*_refreshFondos() async {
    final data = await _sqlite.getFondos(widget.cartera);
    setState(() => fondos = data);
    for (var fondo in fondos) {
      await _sqlite.createTableFondo(widget.cartera, fondo);
      await _getValoresFondo(fondo);
    }
  }*/

  _getValoresFondo(Fondo fondo) async {
    await _db.getValoresByOrder(widget.cartera, fondo);
    setState(() => fondo.addValores(_db.dbValoresByOrder));
    //List<Valor> getValores = await _sqlite.getValoresByOrder(widget.cartera, fondo);
    //setState(() => fondo.addValores(getValores));
  }

  double? _getLastPrecio(Fondo fondo) {
    // _sqlite.getValoresByOrder(widget.cartera, fondo);  MEJOR PARA AUTOACTUALIZARSE ??
    if (fondo.historico.isNotEmpty) {
      return fondo.historico.first.precio;
    } else {
      return null;
    }
  }

  double? _getDiferencia(Fondo fondo) {
    if (fondo.historico.length > 1) {
      var last = fondo.historico.first.precio;
      var prev = fondo.historico[1].precio;
      return last - prev;
    }
    return null;
  }

  Map<String, IconData> mapItemMenu = {
    MenuCartera.eliminar.name: Icons.delete_forever,
  };

  @override
  Widget build(BuildContext context) {
    /*List<Column> listItemMenu = mapItemMenu.entries
        .map((e) => Column(children: [
              ListTile(
                leading: Icon(e.value, color: Colors.white),
                title: Text(
                  '${e.key[0].toUpperCase()}${e.key.substring(1)}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ]))
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
        ]),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            //_refreshFondos();
            await _updateFondos();
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            Navigator.of(context).pushNamed(RouteGenerator.homePage);
          },
        ),
        title: Text(widget.cartera.name),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                refreshAll();
                //await _updateFondos();
              }),
          PopupMenuButton(
              color: Colors.blue,
              offset: Offset(0.0, AppBar().preferredSize.height),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              /*itemBuilder: (ctx) => listItemMenu
                  .asMap()
                  .entries
                  .map((e) => PopupMenuItem(value: MenuCartera.values[e.key], child: e.value))
                  .toList(),*/
              itemBuilder: (ctx) => [
                    for (var item in listItemMenu)
                      PopupMenuItem(
                        value: MenuCartera.values[listItemMenu.indexOf(item)],
                        child: item,
                      )
                  ],
              onSelected: (MenuCartera item) async {
                if (item == MenuCartera.eliminar) {
                  _deleteAllConfirm(context);
                }
              }),
        ],
      ),
      body: FutureBuilder<bool>(
        future: _db.openDb(), //TODO: otro future más específico para fondos ??
        builder: (context, snapshot) {
          if (_isUpdating) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  //Text('Actualizando fondos...'), // Text(_msgUpdating),
                  Text(_msgUpdating),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error}',
                  style: const TextStyle(fontSize: 18),
                ),
              );
            } else if (snapshot.hasData) {
              return fondos.isEmpty
                  ? const Center(child: Text('No hay fondos guardados.'))
                  : ListView.builder(
                      itemCount: fondos.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.assessment, size: 32),
                              title: Text(fondos[index].name),
                              subtitle: Text(fondos[index].isin),
                              trailing: Column(
                                children: [
                                  Text('${_getLastPrecio(fondos[index]) ?? ''}'),
                                  _getDiferencia(fondos[index]) != null
                                      ? Text(
                                          _getDiferencia(fondos[index])!.toStringAsFixed(2),
                                          style: TextStyle(
                                            color: _getDiferencia(fondos[index])! < 0
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                        )
                                      : const Text(''),
                                ],
                              ),
                              onTap: () {
                                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                Navigator.of(context).pushNamed(
                                  RouteGenerator.fondoPage,
                                  arguments: ScreenArguments(widget.cartera, fondos[index]),
                                );
                              },
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
                          onDismissed: (_) {
                            _db.deleteAllValoresInFondo(widget.cartera, fondos[index]);
                            _db.deleteFondoInCartera(widget.cartera, fondos[index]);
                            _updateFondos();
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
                Text('Actualizando fondos...'), // Text(_msgUpdating),
                //Text(_msgUpdating),
              ],
            ),
          );
        },
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        icon: Icons.addchart,
        spacing: 8,
        spaceBetweenChildren: 4,
        overlayColor: Colors.blue,
        overlayOpacity: 0.2,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.search, color: Colors.white),
            label: 'Buscar online por ISIN',
            backgroundColor: Colors.blue,
            onTap: () async {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              final newFondo = await Navigator.of(context).pushNamed(
                RouteGenerator.inputFondo,
                arguments: widget.cartera,
              );
              if (newFondo != null) {
                addFondo(newFondo as Fondo);
              } else {
                _showMsg(msg: 'Sin cambios en la cartera.');
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.storage), //dns // list  //
            label: 'Base de Datos local',
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            onTap: () async {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              final newFondo = await Navigator.of(context).pushNamed(RouteGenerator.searchFondo);
              if (newFondo != null) {
                addFondo(newFondo as Fondo);
              } else {
                _showMsg(msg: 'Sin cambios en la cartera.');
              }
            },
          ),
        ],
      ),
    );
  }

  addFondo(Fondo newFondo) async {
    var existe = [for (var fondo in fondos) fondo.isin].contains(newFondo.isin);
    /*var existe = Iterable<int>.generate(fondos.length)
        .toList()
        .map((idx) => fondos[idx].isin)
        .contains(newFondo.isin);*/
    //var existe = fondos.asMap().entries.map((entry) => entry.value.isin).toList().contains(newFondo.isin);
    /*var existe = false;
    for (var fondo in fondos) {
      if (fondo.isin == newFondo.isin) {
        existe = true;
        break;
      }
    }*/
    if (existe) {
      _showMsg(
        msg: 'El fondo con ISIN ${newFondo.isin} ya existe en esta cartera.',
        color: Colors.red,
      );
    } else {
      await _db.insertFondo(widget.cartera, newFondo);
      _updateFondos();
      _showMsg(msg: 'Fondo añadido');
    }
  }

  refreshAll() async {
    setState(() {
      _isUpdating = true;
      _msgUpdating = 'Iniciando descarga...';
    });
    await _db.getFondos(widget.cartera);
    if (_db.dbFondos.isNotEmpty) {
      for (var fondo in _db.dbFondos) {
        setState(() => _msgUpdating = 'Actualizando ${fondo.name}...');
        //TODO: NECESARIO ?
        //await _sqlite.createTableFondo(widget.cartera, fondo);
        await _db.createTableFondo(widget.cartera, fondo);
        final getDataApi = await apiService.getDataApi(fondo.isin);
        if (getDataApi != null) {
          var newValor = Valor(date: getDataApi.epochSecs, precio: getDataApi.price);
          var newMoneda = getDataApi.market;
          var newLastPrecio = getDataApi.price;
          var newLastDate = getDataApi.epochSecs;
          setState(() {
            fondo.moneda = newMoneda;
            fondo.lastPrecio = newLastPrecio;
            fondo.lastDate = newLastDate;
          });
          await _db.insertDataApi(widget.cartera, fondo,
              moneda: newMoneda, lastPrecio: newLastPrecio, lastDate: newLastDate);
          await _db.insertVL(widget.cartera, fondo, newValor);
          //await _updateFondos();
        } else {
          //_showMsg(msg: 'Error al actualizar el fondo ${fondo.name}');
          setState(() {
            //_isUpdating = false;
            _msgUpdating = 'Error al actualizar el fondo ${fondo.name}';
          });
        }
      }
      await _updateFondos();
      setState(() {
        _isUpdating = false;
        _msgUpdating = '';
      });
    } else {
      _showMsg(msg: 'Nada que actualizar');
      setState(() {
        _isUpdating = false;
        _msgUpdating = '';
      });
    }
  }

  void _deleteAllConfirm(BuildContext context) {
    if (fondos.isEmpty) {
      _showMsg(msg: 'Nada que eliminar');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text('Eliminar todo'),
              content: Text(
                  'Esto eliminará todos los fondos almacenados en la cartera ${widget.cartera.name}'),
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
                    for (var fondo in fondos) {
                      //await _sqlite.deleteAllValoresInFondo(widget.cartera, fondo);
                      //await _sqlite.deleteFondoInCartera(widget.cartera, fondo);
                      await _db.deleteAllValoresInFondo(widget.cartera, fondo);
                      await _db.deleteFondoInCartera(widget.cartera, fondo);
                    }
                    //await _refreshFondos();
                    await _updateFondos();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  void _showMsg({required String msg, MaterialColor color = Colors.grey}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color),
      );
}

/*

enum ItemMenuCartera { eliminar }

class PageCartera extends StatefulWidget {
  final Cartera cartera;
  const PageCartera({Key? key, required this.cartera}) : super(key: key);

  @override
  State<PageCartera> createState() => _PageCarteraState();
}

class _PageCarteraState extends State<PageCartera> {
  late SqliteService _sqlite;
  late ApiService apiService;

  var fondos = <Fondo>[];
  //bool _fondoRepe = false;

  bool _isUpdating = false;
  String _msgUpdating = '';

  @override
  void initState() {
    _sqlite = SqliteService();
    _sqlite.initDB().whenComplete(() async {
      await _refreshFondos();
    });
    apiService = ApiService();
    super.initState();
  }

  _refreshFondos() async {
    final data = await _sqlite.getFondos(widget.cartera);
    setState(() => fondos = data);
    for (var fondo in fondos) {
      await _sqlite.createTableFondo(widget.cartera, fondo);
      await _getValoresFondo(fondo);
    }
  }

  _getValoresFondo(Fondo fondo) async {
    List<Valor> getValores = await _sqlite.getValoresByOrder(widget.cartera, fondo);
    setState(() => fondo.addValores(getValores));
  }

  double? _getLastPrecio(Fondo fondo) {
    // _sqlite.getValoresByOrder(widget.cartera, fondo);  MEJOR PARA AUTOACTUALIZARSE ??
    if (fondo.historico.isNotEmpty) {
      return fondo.historico.first.precio;
    } else {
      return null;
    }
  }

  double? _getDiferencia(Fondo fondo) {
    if (fondo.historico.length > 1) {
      var last = fondo.historico.first.precio;
      var prev = fondo.historico[1].precio;
      return last - prev;
    }
    return null;
  }

  PopupMenuItem _buildMenuItem(String title, IconData iconData, int position) {
    return PopupMenuItem(
      value: position,
      child: Column(
        children: [
          Row(
            children: [
              Icon(iconData, color: Colors.white),
              const SizedBox(width: 10),
              Text(title),
            ],
          ),
        ],
      ),
    );
  }

  _onMenuItemSelected(int value) {
    if (value == ItemMenuCartera.eliminar.index) {
      _deleteAllConfirm(context);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _refreshFondos();
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            Navigator.of(context).pushNamed(RouteGenerator.homePage);
          },
        ),
        title: Text(widget.cartera.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshAll,
          ),
          PopupMenuButton(
            onSelected: (value) => _onMenuItemSelected(value as int),
            color: Colors.blue,
            offset: Offset(0.0, AppBar().preferredSize.height),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            itemBuilder: (ctx) => [
              _buildMenuItem(
                'Eliminar Todos',
                Icons.delete_forever,
                ItemMenuCartera.eliminar.index,
              ),
            ],
          ),
        ],
      ),
      body: fondos.isNotEmpty
          ? _isUpdating
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 10),
                      Text(_msgUpdating),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: fondos.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.assessment, size: 32),
                          title: Text(fondos[index].name),
                          subtitle: Text(fondos[index].isin),
                          trailing: Column(
                            children: [
                              //Text('${fondos[index].lastPrecio ?? '-'}'),
                              Text('${_getLastPrecio(fondos[index]) ?? ''}'),
                              _getDiferencia(fondos[index]) != null
                                  ? Text(
                                      _getDiferencia(fondos[index])!.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: _getDiferencia(fondos[index])! < 0
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    )
                                  : const Text(''),
                            ],
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                            Navigator.of(context).pushNamed(
                              RouteGenerator.fondoPage,
                              arguments: ScreenArguments(widget.cartera, fondos[index]),
                            );
                          },
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
                      onDismissed: (_) {
                        _sqlite.deleteAllValoresInFondo(widget.cartera, fondos[index]);
                        _sqlite.deleteFondoInCartera(widget.cartera, fondos[index]);
                        _refreshFondos();
                      },
                    );
                  },
                )
          : const Center(child: Text('No hay fondos guardados.')),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        icon: Icons.addchart,
        spacing: 8,
        spaceBetweenChildren: 4,
        overlayColor: Colors.blue,
        overlayOpacity: 0.2,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.search, color: Colors.white),
            label: 'Buscar online por ISIN',
            backgroundColor: Colors.blue,
            onTap: () async {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              final newFondo = await Navigator.of(context).pushNamed(
                RouteGenerator.inputFondo,
                arguments: widget.cartera,
              );
              if (newFondo != null) {
                addFondo(newFondo as Fondo);
              } else {
                _showMsg(msg: 'Sin cambios en la cartera.');
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.storage), //dns // list  //
            label: 'Base de Datos local',
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            onTap: () async {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              final newFondo = await Navigator.of(context).pushNamed(RouteGenerator.searchFondo);
              if (newFondo != null) {
                addFondo(newFondo as Fondo);
              } else {
                _showMsg(msg: 'Sin cambios en la cartera.');
              }
            },
          ),
        ],
      ),
      /*floatingActionButton: Wrap(
        direction: Axis.vertical,
        children: [
          FloatingActionButton(
            heroTag: 'searchFondo',
            child: const Icon(Icons.search),
            onPressed: () async {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              final newFondo = await Navigator.of(context).pushNamed(RouteGenerator.searchFondo);
              if (newFondo != null) {
                addFondo(newFondo as Fondo);
              } else {
                _showMsg(msg: 'Sin cambios en la cartera.');
              }
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'addFondo',
            child: const Icon(Icons.addchart),
            onPressed: () async {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              final newFondo = await Navigator.of(context).pushNamed(
                RouteGenerator.inputFondo,
                arguments: widget.cartera,
              );
              if (newFondo != null) {
                addFondo(newFondo as Fondo);
              } else {
                _showMsg(msg: 'Sin cambios en la cartera.');
              }
            },
          ),
        ],
      ),*/
    );
  }

  addFondo(Fondo newFondo) {
    var existe = false;
    for (var fondo in fondos) {
      if (fondo.isin == newFondo.isin) {
        existe = true;
        //setState(() => _fondoRepe = true);
        break;
      }
    }
    // else : setState(() => _fondoRepe = false);
    if (existe) {
      _showMsg(
        msg: 'El fondo con ISIN ${newFondo.isin} ya existe en esta cartera.',
        color: Colors.red,
      );
    } else {
      _sqlite.insertFondo(widget.cartera, newFondo);
      _refreshFondos();
      _showMsg(msg: 'Fondo añadido');
    }

    /*if (_fondoRepe == false) {
      _sqlite.insertFondo(widget.cartera, newFondo);
      _refreshFondos();
      _showMsg(msg: 'Fondo añadido');
    }*/
  }

  void refreshAll() async {
    setState(() {
      _isUpdating = true;
      _msgUpdating = 'Iniciando descarga...';
    });
    List<Fondo> allFondosCartera = await _sqlite.getFondos(widget.cartera);
    if (allFondosCartera.isNotEmpty) {
      for (var fondo in allFondosCartera) {
        _msgUpdating = 'Actualizando ${fondo.name}...';

        //TODO: NECESARIO ?
        await _sqlite.createTableFondo(widget.cartera, fondo);

        final getDataApi = await apiService.getDataApi(fondo.isin);
        if (getDataApi != null) {
          var newValor = Valor(date: getDataApi.epochSecs, precio: getDataApi.price);
          var newMoneda = getDataApi.market;
          var newLastPrecio = getDataApi.price;
          var newLastDate = getDataApi.epochSecs;
          setState(() {
            fondo.moneda = newMoneda;
            fondo.lastPrecio = newLastPrecio;
            fondo.lastDate = newLastDate;
          });
          _sqlite.insertDataApi(
            widget.cartera,
            fondo,
            moneda: newMoneda,
            lastPrecio: newLastPrecio,
            lastDate: newLastDate,
          );
          _sqlite.insertVL(widget.cartera, fondo, newValor);
          await _refreshFondos();
        } else {
          _showMsg(msg: 'Error al actualizar el fondo ${fondo.name}');
          setState(() {
            _isUpdating = false;
            _msgUpdating = '';
          });
        }
      }
    } else {
      _showMsg(msg: 'Nada que actualizar');
      setState(() {
        _isUpdating = false;
        _msgUpdating = '';
      });
    }
    setState(() {
      _isUpdating = false;
      _msgUpdating = '';
    });
  }

  void _deleteAllConfirm(BuildContext context) {
    if (fondos.isEmpty) {
      _showMsg(msg: 'Nada que eliminar');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text('Eliminar todo'),
              content: Text(
                  'Esto eliminará todos los fondos almacenados en la cartera ${widget.cartera.name}'),
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
                    for (var fondo in fondos) {
                      await _sqlite.deleteAllValoresInFondo(widget.cartera, fondo);
                      await _sqlite.deleteFondoInCartera(widget.cartera, fondo);
                    }
                    await _refreshFondos();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  void _showMsg({required String msg, MaterialColor color = Colors.grey}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color),
      );
}

* */
