import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../models/carfoin_provider.dart';
import '../models/cartera.dart';
import '../models/fondo.dart';
import '../models/valor.dart';
import '../routes.dart';
import '../services/api_service.dart';
import '../services/sqlite.dart';

enum MenuCartera { ordenar, eliminar }

class PageCartera extends StatefulWidget {
  const PageCartera({Key? key}) : super(key: key);

  @override
  State<PageCartera> createState() => _PageCarteraState();
}

class _PageCarteraState extends State<PageCartera> {
  late Cartera carteraOn;
  late Sqlite _db;
  late ApiService apiService;

  var fondos = <Fondo>[];
  bool _isUpdating = false;
  String _msgUpdating = '';

  @override
  void initState() {
    carteraOn = context.read<CarfoinProvider>().getCartera!;
    _db = Sqlite();
    _db.openDb().whenComplete(() {
      _updateFondos();
    });
    apiService = ApiService();
    super.initState();
  }

  _updateFondos() async {
    await _db.getFondos(carteraOn);
    for (var fondo in _db.dbFondos) {
      await _db.createTableFondo(carteraOn, fondo);
      await _getValoresFondo(fondo);
    }
    setState(() => fondos = _db.dbFondos);
  }

  _getValoresFondo(Fondo fondo) async {
    await _db.getValoresByOrder(carteraOn, fondo);
    // TODO: setstate necesario????
    //setState(() => fondo.addValores(_db.dbValoresByOrder));
    fondo.addValores(_db.dbValoresByOrder);
  }

  List<Column> _buildListMenu(BuildContext context) {
    final Map<String, IconData> mapItemMenu = {
      MenuCartera.ordenar.name: Icons.sort_by_alpha,
      MenuCartera.eliminar.name: Icons.delete_forever,
    };
    return [
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
  }

  @override
  Widget build(BuildContext context) {
    final carfoin = Provider.of<CarfoinProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            Navigator.of(context).pushNamed(RouteGenerator.homePage);
          },
        ),
        title: Text(carteraOn.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshAll(context),
          ),
          PopupMenuButton(
              color: Colors.blue,
              offset: Offset(0.0, AppBar().preferredSize.height),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              itemBuilder: (ctx) {
                var listItemMenu = _buildListMenu(context);
                return [
                  for (var item in listItemMenu)
                    PopupMenuItem(
                      value: MenuCartera.values[listItemMenu.indexOf(item)],
                      child: item,
                    )
                ];
              },
              onSelected: (MenuCartera item) async {
                if (item == MenuCartera.ordenar) {
                  var fondosSort = <Fondo>[];
                  fondosSort = [...fondos];
                  fondosSort.sort((a, b) => a.name.compareTo(b.name));
                  if (listEquals(fondos, fondosSort)) {
                    _showMsg(msg: 'Nada que hacer: Los fondos ya están ordenados por nombre.');
                  } else {
                    _db.deleteAllFondosInCartera(carteraOn);
                    for (var fondo in fondosSort) {
                      _db.insertFondo(carteraOn, fondo);
                    }
                    _updateFondos();
                  }
                } else if (item == MenuCartera.eliminar) {
                  _deleteAllConfirm(context);
                }
              }),
        ],
      ),
      body: FutureBuilder<bool>(
        future: _db.openDb(), //TODO: otro future más específico para fondos ??
        builder: (context, snapshot) {
          // TODO: necesario ???
          if (_isUpdating) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  //Text('Recuperando fondos...'),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${_getLastPrecio(fondos[index]) ?? ''}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (_getDiferencia(fondos[index]) != null)
                                    Text(
                                      _getDiferencia(fondos[index])!.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: _getDiferencia(fondos[index])! < 0
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                carfoin.setFondo = fondos[index];
                                Navigator.of(context).pushNamed(RouteGenerator.fondoPage);
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
                          onDismissed: (_) {
                            _db.deleteAllValoresInFondo(carteraOn, fondos[index]);
                            _db.deleteFondoInCartera(carteraOn, fondos[index]);
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
                Text('Recuperando datos...'), // Text(_msgUpdating),
                //Text(_msgUpdating),
              ],
            ),
          );
        },
      ),
      floatingActionButton: SpeedDial(
        //animatedIcon: AnimatedIcons.menu_close,
        //activeIcon: Icons.add_chart,
        //animatedIcon: AnimatedIcons.menu_close,
        icon: Icons.addchart,
        spacing: 8,
        spaceBetweenChildren: 4,
        overlayColor: Colors.blue,
        overlayOpacity: 0.2,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.search),
            label: 'Buscar online por ISIN',
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            onTap: () async {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              final newFondo = await Navigator.of(context).pushNamed(RouteGenerator.inputFondo);
              newFondo != null
                  ? _addFondo(newFondo as Fondo)
                  : _showMsg(msg: 'Sin cambios en la cartera.');
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
              newFondo != null
                  ? _addFondo(newFondo as Fondo)
                  : _showMsg(msg: 'Sin cambios en la cartera.');
            },
          ),
        ],
      ),
    );
  }

  double? _getLastPrecio(Fondo fondo) {
    if (fondo.historico.isNotEmpty) {
      return fondo.historico.first.precio;
    }
    return null;
  }

  double? _getDiferencia(Fondo fondo) {
    if (fondo.historico.length > 1) {
      var last = fondo.historico.first.precio;
      var prev = fondo.historico[1].precio;
      return last - prev;
    }
    return null;
  }

  _addFondo(Fondo newFondo) async {
    var existe = [for (var fondo in _db.dbFondos) fondo.isin].contains(newFondo.isin);
    if (existe) {
      _showMsg(
        msg: 'El fondo con ISIN ${newFondo.isin} ya existe en esta cartera.',
        color: Colors.red,
      );
    } else {
      await _db.insertFondo(carteraOn, newFondo);
      _updateFondos();
      _showMsg(msg: 'Fondo añadido');
    }
  }

  _refreshAll(BuildContext context) async {
    var mapResultados = <String, Icon>{};
    setState(() {
      _isUpdating = true;
      _msgUpdating = 'Iniciando descarga...';
    });
    await _db.getFondos(carteraOn);
    if (_db.dbFondos.isNotEmpty) {
      for (var fondo in _db.dbFondos) {
        setState(() => _msgUpdating = 'Actualizando...\n${fondo.name}');
        //TODO: NECESARIO ?
        await _db.createTableFondo(carteraOn, fondo);
        final getDataApi = await apiService.getDataApi(fondo.isin);
        if (getDataApi != null) {
          var newValor = Valor(date: getDataApi.epochSecs, precio: getDataApi.price);
          var newMoneda = getDataApi.market;
          var newLastPrecio = getDataApi.price;
          var newLastDate = getDataApi.epochSecs;
          //setState(() {
          fondo
            ..moneda = newMoneda
            ..lastPrecio = newLastPrecio
            ..lastDate = newLastDate;
          //});
          await _db.insertDataApi(carteraOn, fondo,
              moneda: newMoneda, lastPrecio: newLastPrecio, lastDate: newLastDate);
          await _db.insertVL(carteraOn, fondo, newValor);
          mapResultados[fondo.name] = const Icon(Icons.check_box, color: Colors.green);
        } else {
          mapResultados[fondo.name] = const Icon(Icons.disabled_by_default, color: Colors.red);
          //_showMsg(msg: 'Error al actualizar el fondo ${fondo.name}');  ???
          // ESTO SE VE ALGUNA VEZ ??
          setState(() {
            _msgUpdating = 'Error al actualizar el fondo ${fondo.name}';
          });
        }
      }
      _updateFondos();
      setState(() {
        _isUpdating = false;
        _msgUpdating = '';
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: const EdgeInsets.all(10),
            title: const Text('Resultado'),
            actions: [
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
            content: SingleChildScrollView(
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var res in mapResultados.entries)
                      ListTile(dense: true, title: Text(res.key), trailing: res.value),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      _showMsg(msg: 'Nada que actualizar');
      setState(() {
        _isUpdating = false;
        _msgUpdating = '';
      });
    }
  }

  void _deleteAllConfirm(BuildContext context) {
    if (_db.dbFondos.isEmpty) {
      _showMsg(msg: 'Nada que eliminar');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text('Eliminar todo'),
              content: Text(
                  'Esto eliminará todos los fondos almacenados en la cartera ${carteraOn.name}'),
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
                    for (var fondo in _db.dbFondos) {
                      await _db.deleteAllValoresInFondo(carteraOn, fondo);
                      await _db.deleteFondoInCartera(carteraOn, fondo);
                    }
                    _updateFondos();
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
