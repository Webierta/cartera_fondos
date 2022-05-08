import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../models/cartera.dart';
import '../models/fondo.dart';
import '../models/valor.dart';
import '../routes.dart';
import '../services/api_service.dart';
import '../services/sqlite_service.dart';

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
  bool _fondoRepe = false;

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
        icon: Icons.addchart,
        spacing: 8,
        spaceBetweenChildren: 4,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.list), //dns // list  //
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
    for (var fondo in fondos) {
      if (fondo.isin == newFondo.isin) {
        _showMsg(
          msg: 'El fondo con ISIN ${fondo.isin} ya existe en esta cartera.',
          color: Colors.red,
        );
        setState(() => _fondoRepe = true);
        break;
      } else {
        setState(() => _fondoRepe = false);
      }
    }
    if (_fondoRepe == false) {
      _sqlite.insertFondo(widget.cartera, newFondo);
      _refreshFondos();
      _showMsg(msg: 'Fondo añadido');
    }
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
      _showMsg(msg: 'Nada que eliminar');
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

  void _showMsg({
    required String msg,
    MaterialColor color = Colors.grey,
  }) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color),
      );
}
