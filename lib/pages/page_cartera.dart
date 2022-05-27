import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../models/carfoin_provider.dart';
//import '../models/cartera.dart';
import '../models/fondo.dart';
import '../models/valor.dart';
import '../routes.dart';
import '../services/api_service.dart';
import '../services/preferences_service.dart';
//import '../services/sqlite.dart';
import '../utils/fecha_util.dart';
import '../utils/k_constantes.dart';
import '../widgets/loading_progress.dart';

enum MenuCartera { ordenar, eliminar }

class PageCartera extends StatefulWidget {
  const PageCartera({Key? key}) : super(key: key);

  @override
  State<PageCartera> createState() => _PageCarteraState();
}

class _PageCarteraState extends State<PageCartera> {
  late CarfoinProvider carfoin;
  //late Cartera carteraOn;
  //late Sqlite _db;
  late ApiService apiService;
  //var fondos = <Fondo>[];
  bool _isFondosByOrder = false;
  bool _isAutoUpdate = true;
  final GlobalKey _dialogKey = GlobalKey();
  String _loadingText = '';

  getSharedPrefs() async {
    await PreferencesService.getBool(kKeyByOrderFondosPref).then((value) {
      setState(() => _isFondosByOrder = value);
    });
    await PreferencesService.getBool(kKeyAutoUpdatePref).then((value) {
      setState(() => _isAutoUpdate = value);
    });
  }

  @override
  void initState() {
    getSharedPrefs();
    //carteraOn = context.read<CarfoinProvider>().getCartera!;
    /*_db = Sqlite();
    _db.openDb().whenComplete(() async {
      await _updateFondos();
    });*/
    carfoin = context.read<CarfoinProvider>();
    carfoin.openDb().whenComplete(() async {
      await carfoin.updateFondos(_isFondosByOrder);
    });

    apiService = ApiService();
    super.initState();
  }

  /*
  _updateFondos() async {
    await _getFondos();
    for (var fondo in _db.dbFondos) {
      var tableFondo = '_${carteraOn.id}' + fondo.isin;
      await _db.createTableFondo(tableFondo);
      await _getValoresFondo(fondo);
    }
    setState(() => fondos = _db.dbFondos);
  }

  _getFondos() async {
    var tableCartera = '_${carteraOn.id}';
    await _db.getFondos(tableCartera, byOrder: _isFondosByOrder);
  }

  _createTableFondo(Fondo fondo) async {
    var tableFondo = '_${carteraOn.id}' + fondo.isin;
    await _db.createTableFondo(tableFondo);
  }

  _insertFondo(Fondo fondo) async {
    var tableCartera = '_${carteraOn.id}';
    Map<String, dynamic> row = {'isin': fondo.isin, 'name': fondo.name, 'divisa': fondo.divisa};
    await _db.insertFondo(tableCartera, row);
  }

  _insertValor(Fondo fondo, Valor valor) async {
    var tableFondo = '_${carteraOn.id}' + fondo.isin;
    Map<String, dynamic> row = {'date': valor.date, 'precio': valor.precio};
    await _db.insertVL(tableFondo, row);
  }

  _getValoresFondo(Fondo fondo) async {
    var tableFondo = '_${carteraOn.id}' + fondo.isin;
    await _db.getValoresByOrder(tableFondo);
    // TODO: setstate necesario en addValores ????
    fondo.addValores(_db.dbValoresByOrder);
  }

  */ /*_deleteAllValores(Fondo fondo) async {
    //var tableFondo = fondo.isin + '_' + '${carteraOn.id}';
    var tableFondo = '_${carteraOn.id}' + fondo.isin;
    //await _db.deleteAllValores(tableFondo);
    await _db.eliminaTabla(tableFondo);
  }*/ /*

  _deleteFondo(Fondo fondo) async {
    var tableFondo = '_${carteraOn.id}' + fondo.isin;
    await _db.eliminaTabla(tableFondo);
    // TODO: get valores y drop ??
    var tableCartera = '_${carteraOn.id}';
    await _db.deleteFondo(tableCartera, fondo);
  }

  _deleteAllFondos() async {
    var tableCartera = '_${carteraOn.id}';
    //await _db.deleteAllFondos(tableCartera);
    await _db.eliminaTabla(tableCartera);
  }*/

  PopupMenuItem<MenuCartera> _buildMenuItem(MenuCartera menu, IconData iconData,
      {bool divider = false}) {
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
            trailing: menu == MenuCartera.ordenar
                ? Icon(
                    _isFondosByOrder ? Icons.check_box : Icons.check_box_outline_blank,
                    color: const Color(0xFFFFFFFF),
                  )
                : null,
          ),
          if (divider) const Divider(height: 10, color: Color(0xFFFFFFFF)), // PopMenuDivider
        ],
      ),
    );
  }

  SpeedDialChild _buildSpeedDialChild(BuildContext context,
      {required IconData icono, required String label, required String page}) {
    return SpeedDialChild(
      child: Icon(icono),
      label: label,
      backgroundColor: const Color(0xFFFFC107),
      foregroundColor: const Color(0xFF0D47A1),
      onTap: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        final newFondo = await Navigator.of(context).pushNamed(page);
        newFondo != null
            ? _addFondo(newFondo as Fondo)
            : _showMsg(msg: 'Sin cambios en la cartera.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //final carfoin = Provider.of<CarfoinProvider>(context);
    //final carfoin = context.read<CarfoinProvider>();
    final carfoin = context.read<CarfoinProvider>();
    var carteraOn = context.read<CarfoinProvider>().getCartera!;
    var fondos = context.watch<CarfoinProvider>().getFondos;

    // var valores = context.watch<CarfoinProvider>().getValoresFondo(fondos[index]);

    return FutureBuilder<bool>(
      //future: _db.openDb(), //TODO: otro future más específico para fondos ??
      future: carfoin.openDb(),
      builder: (context, snapshot) {
        /*if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingProgress(titulo: 'Recuperando fondos...', subtitulo: 'Cargando...');
        }*/
        if (snapshot.connectionState == ConnectionState.done) {
          /*WidgetsBinding.instance?.addPostFrameCallback((_) {
            Navigator.of(context, rootNavigator: true).pop();
          });*/
          // TODO : pendiente manejar error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error}',
                style: const TextStyle(fontSize: 18),
              ),
            );
          } else if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    Navigator.of(context).pushNamed(RouteGenerator.homePage);
                  },
                ),
                title: Text(carteraOn.name),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async => await _dialogUpdateAll(context),
                  ),
                  PopupMenuButton(
                    color: Colors.blue,
                    offset: Offset(0.0, AppBar().preferredSize.height),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    itemBuilder: (ctx) => [
                      _buildMenuItem(MenuCartera.ordenar, Icons.sort_by_alpha),
                      _buildMenuItem(MenuCartera.eliminar, Icons.delete_forever)
                    ],
                    onSelected: (MenuCartera item) async {
                      if (item == MenuCartera.ordenar) {
                        _ordenarFondos();
                      } else if (item == MenuCartera.eliminar) {
                        _deleteAllConfirm(context);
                      }
                    },
                  ),
                ],
              ),
              floatingActionButton: SpeedDial(
                //animatedIcon: AnimatedIcons.menu_close,
                //activeIcon: Icons.add_chart,
                //animatedIcon: AnimatedIcons.menu_close,
                icon: Icons.addchart,
                foregroundColor: const Color(0xFF0D47A1),
                backgroundColor: const Color(0xFFFFC107),
                spacing: 8,
                spaceBetweenChildren: 4,
                overlayColor: Colors.grey,
                overlayOpacity: 0.4,
                children: [
                  _buildSpeedDialChild(context,
                      icono: Icons.search,
                      label: 'Buscar online por ISIN',
                      page: RouteGenerator.inputFondo),
                  _buildSpeedDialChild(context,
                      icono: Icons.storage,
                      label: 'Base de Datos local',
                      page: RouteGenerator.searchFondo),
                ],
              ),
              body: fondos.isEmpty
                  ? const Center(child: Text('No hay fondos guardados.'))
                  : ListView.builder(
                      itemCount: fondos.length,
                      itemBuilder: (context, index) {
                        // TODO: obtener valor y diferencia de cada fondo
                        int? lastEpoch = _getLastDate(fondos[index]);
                        String lastDate =
                            lastEpoch != null ? FechaUtil.epochToString(lastEpoch) : '';
                        //var lastPrecio = _getLastPrecio(fondos[index]) ?? '';
                        String lastPrecio = '${_getLastPrecio(fondos[index]) ?? ''}';
                        double? diferencia = _getDiferencia(fondos[index]);

                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            alignment: Alignment.centerRight,
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          onDismissed: (_) async {
                            //_db.deleteAllValoresInFondo(carteraOn, fondos[index]);
                            //_db.deleteFondoInCartera(carteraOn, fondos[index]);
                            //await _deleteAllValores(fondos[index]);

                            //await _deleteFondo(fondos[index]);
                            //await _updateFondos();
                            await carfoin.deleteFondo(fondos[index]);
                            await carfoin.updateFondos(_isFondosByOrder);
                          },
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.assessment, size: 32),
                              title: Text(fondos[index].name),
                              subtitle: Text(fondos[index].isin),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(lastDate),
                                  Text(
                                    //'${_getLastPrecio(fondos[index]) ?? ''}',
                                    lastPrecio,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  //if (_getDiferencia(fondos[index]) != null)
                                  if (diferencia != null)
                                    Text(
                                      //_getDiferencia(fondos[index])!.toStringAsFixed(2),
                                      diferencia.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: diferencia < 0
                                            ? const Color(0xFFF44336)
                                            : const Color(0xFF4CAF50),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                // TODO : revisar
                                //WidgetsBinding.instance?.addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                carfoin.setFondo = fondos[index];
                                Navigator.of(context).pushNamed(RouteGenerator.fondoPage);
                                //});
                              },
                            ),
                          ),
                        );
                      },
                    ),
            );
          }
        }
        return const LoadingProgress(titulo: 'Recuperando fondos...', subtitulo: 'Cargando...');
      },
    );
  }

  _dialogUpdateAll(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          key: _dialogKey,
          builder: (context, setState) {
            // return Dialog(child: Loading(...); ???
            return Loading(
              titulo: 'ACTUALIZANDO FONDOS...',
              subtitulo: _loadingText,
            );
          },
        );
      },
    );
    var mapResultados = await _updateAll(context);
    Navigator.pop(context);
    mapResultados.isNotEmpty
        ? await _showResultados(mapResultados)
        : _showMsg(msg: 'Nada que actualizar');
  }

  _setStateDialog(String newText) {
    if (_dialogKey.currentState != null && _dialogKey.currentState!.mounted) {
      _dialogKey.currentState!.setState(() {
        _loadingText = newText;
      });
    }
  }

  Future<Map<String, Icon>> _updateAll(BuildContext context) async {
    _setStateDialog('Conectando...');
    var mapResultados = <String, Icon>{};
    //await _getFondos();
    await carfoin.getFondosCartera(_isFondosByOrder);
    //if (_db.dbFondos.isNotEmpty) {
    if (carfoin.getFondos.isNotEmpty) {
      //for (var fondo in _db.dbFondos) {
      for (var fondo in carfoin.getFondos) {
        _setStateDialog(fondo.name);
        //TODO: NECESARIO ?
        //await _createTableFondo(fondo);
        await carfoin.createTableFondo(fondo);
        final getDataApi = await apiService.getDataApi(fondo.isin);
        if (getDataApi != null) {
          var newValor = Valor(date: getDataApi.epochSecs, precio: getDataApi.price);
          //TODO valor divisa??
          fondo.divisa = getDataApi.market;
          // var newMoneda = getDataApi.market;
          //await _db.insertDataApi(carteraOn, fondo,
          //    moneda: newMoneda, lastPrecio: newLastPrecio, lastDate: newLastDate);
          //await _db.insertFondo(carteraOn, fondo);
          //await _db.insertVL(carteraOn, fondo, newValor);

          //await _insertFondo(fondo);
          //await _insertValor(fondo, newValor);
          await carfoin.insertFondoCartera(fondo);
          await carfoin.insertValorFondo(fondo, newValor);

          mapResultados[fondo.name] = const Icon(Icons.check_box, color: Colors.green);
        } else {
          mapResultados[fondo.name] = const Icon(Icons.disabled_by_default, color: Colors.red);
        }
      }
      //TODO: check si es necesario update (si no ha habido cambios porque todos los fondos han dado error)
      //await _updateFondos();
      await carfoin.updateFondos(_isFondosByOrder);
    }
    return mapResultados;
  }

  _showResultados(Map<String, Icon> mapResultados) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
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
          ),
        );
      },
    );
  }

  // double?
  double? _getLastPrecio(Fondo fondo) {
    //var fondos = context.watch<CarfoinProvider>().getFondos;
    /*await carfoin.getValoresFondo(fondo);
    var valoresFondo = carfoin.getValores;
    if (valoresFondo.isNotEmpty) {
      return valoresFondo.first.precio;
    }*/
    if (fondo.historico.isNotEmpty) {
      return fondo.historico.first.precio;
    }
    return null;
  }

  int? _getLastDate(Fondo fondo) {
    if (fondo.historico.isNotEmpty) {
      return fondo.historico.first.date;
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

  _getDataApi(Fondo fondo) async {
    //await _createTableFondo(fondo);
    await carfoin.createTableFondo(fondo);
    final getDataApi = await apiService.getDataApi(fondo.isin);
    if (getDataApi != null) {
      var newValor = Valor(date: getDataApi.epochSecs, precio: getDataApi.price);
      fondo.divisa = getDataApi.market;

      //await _insertFondo(fondo);
      //await _insertValor(fondo, newValor);
      await carfoin.insertFondoCartera(fondo);
      await carfoin.insertValorFondo(fondo, newValor);

      return true;
    } else {
      return false;
    }
  }

  _dialogAutoUpdate(BuildContext context, Fondo newFondo) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Loading(
          titulo: 'FONDO AÑADIDO',
          subtitulo: 'Cargando último valor...',
        );
      },
    );
    var update = await _getDataApi(newFondo);
    Navigator.pop(context);
    update
        ? _showMsg(msg: 'Fondo actualizado')
        : _showMsg(msg: 'Error al actualizar el fondo', color: Colors.red);
  }

  _addFondo(Fondo newFondo) async {
    //var existe = [for (var fondo in _db.dbFondos) fondo.isin].contains(newFondo.isin);
    var existe = [for (var fondo in carfoin.getFondos) fondo.isin].contains(newFondo.isin);
    if (existe) {
      _showMsg(
        msg: 'El fondo con ISIN ${newFondo.isin} ya existe en esta cartera.',
        color: Colors.red,
      );
    } else {
      //await _db.insertFondo(carteraOn, newFondo);

      //await _insertFondo(newFondo);
      await carfoin.insertFondoCartera(newFondo);

      //await _updateFondos();
      if (_isAutoUpdate) {
        await _dialogAutoUpdate(context, newFondo);
        //await _updateFondos();
      } else {
        _showMsg(msg: 'Fondo añadido');
      }
      //await _updateFondos();
      await carfoin.updateFondos(_isFondosByOrder);
    }
  }

  _ordenarFondos() async {
    setState(() {
      _isFondosByOrder = !_isFondosByOrder;
    });
    PreferencesService.saveBool(kKeyByOrderFondosPref, _isFondosByOrder);
    //await _updateFondos();
    await carfoin.updateFondos(_isFondosByOrder);
  }

  /*void _sortFondos() async {
    var fondosSort = <Fondo>[];
    fondosSort = [...fondos];
    fondosSort.sort((a, b) => a.name.compareTo(b.name));
    if (listEquals(fondos, fondosSort)) {
      _showMsg(msg: 'Nada que hacer: Los fondos ya están ordenados por nombre.');
    } else {
      //await _db.deleteAllFondosInCartera(carteraOn);
      await _deleteAllFondos();
      for (var fondo in fondosSort) {
        //await _db.insertFondo(carteraOn, fondo);
        await _insertFondo(fondo);
      }
      await _updateFondos();
    }
  }*/

  void _deleteAllConfirm(BuildContext context) {
    //if (_db.dbFondos.isEmpty) {
    if (carfoin.getFondos.isEmpty) {
      _showMsg(msg: 'Nada que eliminar');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            var carteraOn = context.read<CarfoinProvider>().getCartera!;
            return AlertDialog(
              title: const Text('Eliminar todo'),
              content: Text(
                  'Esto eliminará todos los fondos almacenados en la cartera ${carteraOn.name}'),
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
                    //for (var fondo in _db.dbFondos) {
                    for (var fondo in carfoin.getFondos) {
                      //await _db.deleteAllValoresInFondo(carteraOn, fondo);
                      //await _db.deleteFondoInCartera(carteraOn, fondo);
                      //await _deleteAllValores(fondo);
                      //await _deleteFondo(fondo);
                      await carfoin.deleteFondo(fondo);
                    }
                    //await _updateFondos();
                    await carfoin.updateFondos(_isFondosByOrder);
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
