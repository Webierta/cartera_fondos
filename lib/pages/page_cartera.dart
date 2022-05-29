import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../models/carfoin_provider.dart';
import '../models/fondo.dart';
import '../models/valor.dart';
import '../routes.dart';
import '../services/api_service.dart';
import '../services/preferences_service.dart';
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
  bool _isFondosByOrder = false;
  bool _isAutoUpdate = true;
  late ApiService apiService;
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
    carfoin = context.read<CarfoinProvider>();
    carfoin.openDb().whenComplete(() async {
      await carfoin.updateFondos(_isFondosByOrder);
    });
    apiService = ApiService();
    super.initState();
  }

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
    final carfoin = context.read<CarfoinProvider>();
    var carteraOn = context.read<CarfoinProvider>().getCartera!;
    var fondos = context.watch<CarfoinProvider>().getFondos;

    return FutureBuilder<bool>(
      future: carfoin.openDb(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
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
                        int? lastEpoch = _getLastDate(fondos[index]);
                        String lastDate =
                            lastEpoch != null ? FechaUtil.epochToString(lastEpoch) : '';
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
                                    lastPrecio,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (diferencia != null)
                                    Text(
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
                                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                carfoin.setFondo = fondos[index];
                                Navigator.of(context).pushNamed(RouteGenerator.fondoPage);
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
            return Loading(titulo: 'ACTUALIZANDO FONDOS...', subtitulo: _loadingText);
          },
        );
      },
    );
    var mapResultados = await _updateAll(context);
    _pop();
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
    await carfoin.getFondosCartera(_isFondosByOrder);
    if (carfoin.getFondos.isNotEmpty) {
      for (var fondo in carfoin.getFondos) {
        _setStateDialog(fondo.name);
        //TODO: NECESARIO  createTable ?
        await carfoin.createTableFondo(fondo);
        final getDataApi = await apiService.getDataApi(fondo.isin);
        if (getDataApi != null) {
          var newValor = Valor(date: getDataApi.epochSecs, precio: getDataApi.price);
          //TODO valor divisa??
          fondo.divisa = getDataApi.market;
          await carfoin.insertFondoCartera(fondo);
          await carfoin.insertValorFondo(fondo, newValor);
          mapResultados[fondo.name] = const Icon(Icons.check_box, color: Colors.green);
        } else {
          mapResultados[fondo.name] = const Icon(Icons.disabled_by_default, color: Colors.red);
        }
      }
      //TODO: check si es necesario update (si no ha habido cambios porque todos los fondos han dado error)
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

  double? _getLastPrecio(Fondo fondo) {
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
    await carfoin.createTableFondo(fondo);
    final getDataApi = await apiService.getDataApi(fondo.isin);
    if (getDataApi != null) {
      var newValor = Valor(date: getDataApi.epochSecs, precio: getDataApi.price);
      fondo.divisa = getDataApi.market;
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
        return const Loading(titulo: 'FONDO AÑADIDO', subtitulo: 'Cargando último valor...');
      },
    );
    var update = await _getDataApi(newFondo);
    _pop();
    update
        ? _showMsg(msg: 'Fondo actualizado')
        : _showMsg(msg: 'Error al actualizar el fondo', color: Colors.red);
  }

  _addFondo(Fondo newFondo) async {
    var existe = [for (var fondo in carfoin.getFondos) fondo.isin].contains(newFondo.isin);
    if (existe) {
      _showMsg(
        msg: 'El fondo con ISIN ${newFondo.isin} ya existe en esta cartera.',
        color: Colors.red,
      );
    } else {
      await carfoin.insertFondoCartera(newFondo);
      if (_isAutoUpdate) {
        if (!mounted) return;
        await _dialogAutoUpdate(context, newFondo);
      } else {
        _showMsg(msg: 'Fondo añadido');
      }
      await carfoin.updateFondos(_isFondosByOrder);
    }
  }

  _ordenarFondos() async {
    setState(() => _isFondosByOrder = !_isFondosByOrder);
    PreferencesService.saveBool(kKeyByOrderFondosPref, _isFondosByOrder);
    await carfoin.updateFondos(_isFondosByOrder);
  }

  void _deleteAllConfirm(BuildContext context) {
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCELAR'),
                ),
                ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF44336),
                    primary: const Color(0xFFFFFFFF),
                  ),
                  onPressed: () async {
                    for (var fondo in carfoin.getFondos) {
                      await carfoin.deleteFondo(fondo);
                    }
                    await carfoin.updateFondos(_isFondosByOrder);
                    _pop();
                  },
                  child: const Text('ACEPTAR'),
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

  void _pop() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    Navigator.of(context).pop();
  }
}
