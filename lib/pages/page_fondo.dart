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
import '../utils/fecha_util.dart';
import '../widgets/grafico_chart.dart';
import '../widgets/loading_progress.dart';
import '../widgets/main_fondo.dart';
import '../widgets/tabla_fondo.dart';

enum Menu { editar, suscribir, reembolsar, eliminar, exportar }

class PageFondo extends StatefulWidget {
  const PageFondo({Key? key}) : super(key: key);

  @override
  State<PageFondo> createState() => _PageFondoState();
}

class _PageFondoState extends State<PageFondo> with SingleTickerProviderStateMixin {
  late CarfoinProvider carfoin;
  late Cartera carteraOn;
  late Fondo fondoOn;
  late Sqlite _db;
  late ApiService apiService;

  //int _selectedIndex = 0;
  //late bool _isLoading;
  late TabController _tabController;

  @override
  void initState() {
    //_isLoading = true;
    _tabController = TabController(vsync: this, length: 3);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      carfoin = Provider.of<CarfoinProvider>(context, listen: false);
      //carteraOn = carfoin.getCartera!;
    });
    carteraOn = context.read<CarfoinProvider>().getCartera!;
    fondoOn = context.read<CarfoinProvider>().getFondo!;

    _db = Sqlite();
    _db.openDb().whenComplete(() async {
      await _updateValores();
    });
    apiService = ApiService();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _updateValores() async {
    /*if (!_isLoading) {
      setState(() => _isLoading = true);
    }*/
    //await _db.getFondos(carteraOn.id);
    await _getFondos();
    //var tableFondo = fondoOn.isin + '_' + '${carteraOn.id}';
    var tableFondo = '_${carteraOn.id}' + fondoOn.isin;
    //await _db.createTableFondo(carteraOn, fondoOn);
    await _db.createTableFondo(tableFondo);
    /*await _db.getValoresByOrder(carteraOn, fondoOn).whenComplete(() => setState(() {
          //_isLoading = false;
          carfoin.setValores = _db.dbValoresByOrder;
        }));*/
    await _db.getValoresByOrder(tableFondo).whenComplete(() => setState(() {
          carfoin.setValores = _db.dbValoresByOrder;
        }));
    //TODO: SETSTATE ??
    //carfoin.setValores = _db.dbValoresByOrder;
    //TODO: si moneda, lastPrecio y LastDate == null hacer un update
    //if (fondoOn.moneda == null) {}
    //TODO: check si data no es null ??
    //TODO: ordenar primero por date ??
  }

  _getFondos() async {
    var tableCartera = '_${carteraOn.id}';
    await _db.getFondos(tableCartera);
  }

  _insertFondo() async {
    var tableCartera = '_${carteraOn.id}';
    Map<String, dynamic> row = {
      'isin': fondoOn.isin,
      'name': fondoOn.name,
      'divisa': fondoOn.divisa
    };
    await _db.insertFondo(tableCartera, row);
  }

  _insertValor(Valor valor) async {
    //var tableFondo = fondoOn.isin + '_' + '${carteraOn.id}';
    var tableFondo = '_${carteraOn.id}' + fondoOn.isin;
    Map<String, dynamic> row = {'date': valor.date, 'precio': valor.precio};
    await _db.insertVL(tableFondo, row);
  }

  _insertValores(List<Valor> valores) async {
    //var tableFondo = fondoOn.isin + '_' + '${carteraOn.id}';
    var tableFondo = '_${carteraOn.id}' + fondoOn.isin;
    for (var valor in valores) {
      Map<String, dynamic> row = {'date': valor.date, 'precio': valor.precio};
      await _db.insertVL(tableFondo, row);
    }
  }

  _deleteAllValores() async {
    //var tableFondo = fondoOn.isin + '_' + '${carteraOn.id}';
    var tableFondo = '_${carteraOn.id}' + fondoOn.isin;
    //await _db.deleteAllValores(tableFondo);
    await _db.eliminaTabla(tableFondo);
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
          ),
          if (divider) const Divider(color: Color(0xFFFFFFFF)), // PopMenuDivider
        ],
      ),
    );
  }

  SpeedDialChild _buildSpeedDialChild(BuildContext context,
      {required IconData icono, required String label, required Function action}) {
    return SpeedDialChild(
      child: Icon(icono),
      label: label,
      backgroundColor: const Color(0xFF2196F3),
      foregroundColor: const Color(0xFFFFFFFF),
      onTap: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        action(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //const listaTabs = [MainFondo(), TablaFondo(), GraficoChart()];
    //const List<IconData> iconsTab = [Icons.assessment, Icons.table_rows_outlined, Icons.timeline];
    //_isLoading ? const LoadingProgress(titulo: 'Cargando datos...')
    return FutureBuilder<bool>(
        future: _db.openDb(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingProgress(titulo: 'CARGANDO DATOS...');
          }

          if (snapshot.connectionState == ConnectionState.done) {
            // DefaultTabController(length: 3, child: Scaffold
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    // TODO: set carteraOn antes de navigator??
                    Navigator.of(context).pushNamed(RouteGenerator.carteraPage, arguments: true);
                  },
                ),
                title: Text(fondoOn.name),
                actions: [
                  PopupMenuButton(
                    color: const Color(0xFF2196F3),
                    offset: Offset(0.0, AppBar().preferredSize.height),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    itemBuilder: (ctx) => [
                      _buildMenuItem(Menu.editar, Icons.edit, divider: true),
                      _buildMenuItem(Menu.suscribir, Icons.login),
                      _buildMenuItem(Menu.reembolsar, Icons.logout, divider: true),
                      _buildMenuItem(Menu.eliminar, Icons.delete_forever),
                      _buildMenuItem(Menu.exportar, Icons.download),
                    ],
                    onSelected: (Menu item) {
                      //TODO: ACCIONES PENDIENTES
                      if (item == Menu.editar) {
                        print('EDITAR');
                        //TODO SUBPAGE de operar con suscribir y reembolsar
                      } else if (item == Menu.suscribir) {
                        print('SUSCRIBIR');
                        print(carteraOn.name);
                        print(fondoOn.name);
                      } else if (item == Menu.reembolsar) {
                        print('REEMBOLSAR');
                      } else if (item == Menu.eliminar) {
                        _deleteConfirm(context);
                      } else if (item == Menu.exportar) {
                        print('EXPORTAR');
                      }
                    },
                  ),
                ],
              ),
              //body: listaTabs.elementAt(_selectedIndex),
              body: TabBarView(
                controller: _tabController,
                children: const [MainFondo(), TablaFondo(), GraficoChart()],
              ),
              // bottomNavigationBar: BottomNavigationBar(
              bottomNavigationBar: BottomAppBar(
                color: const Color(0xFF0D47A1),
                shape: const CircularNotchedRectangle(),
                notchMargin: 5,
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  alignment: FractionalOffset.bottomLeft,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFFFFFFFF),
                    unselectedLabelColor: const Color(0x62FFFFFF),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.all(5.0),
                    indicatorColor: const Color(0xFF2196F3),
                    //padding: EdgeInsets.only(right: 60),
                    tabs: const [
                      Tab(icon: Icon(Icons.assessment, size: 32)),
                      Tab(icon: Icon(Icons.table_rows_outlined, size: 32)),
                      Tab(icon: Icon(Icons.timeline, size: 32)),
                    ],
                  ),
                ),
              ),
              /*bottomNavigationBar: BottomAppBar(
              color: const Color(0xFF2196F3),
              shape: const CircularNotchedRectangle(),
              notchMargin: 5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (var icon in iconsTab)
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          icon,
                          color: _selectedIndex == iconsTab.indexOf(icon)
                              ? const Color(0xFFFFFFFF)
                              : const Color(0x62FFFFFF), //Colors.white38,
                        ),
                        //padding: const EdgeInsets.only(left: 32.0, right: 32.0),
                        iconSize: 32,
                        onPressed: () {
                          setState(() {
                            _selectedIndex = iconsTab.indexOf(icon);
                          });
                        },
                      ),
                    ),
                  const Spacer(),
                ],
              ),
            ),*/
              floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
              floatingActionButton: SpeedDial(
                //animatedIcon: AnimatedIcons.menu_close,
                //activeIcon: Icons.refresh,
                icon: Icons.refresh,
                spacing: 8,
                spaceBetweenChildren: 4,
                overlayColor: Colors.blue,
                overlayOpacity: 0.2,
                children: [
                  _buildSpeedDialChild(context,
                      icono: Icons.date_range,
                      label: 'Descargar valores históricos',
                      action: _getRangeApi),
                  _buildSpeedDialChild(context,
                      icono: Icons.update, label: 'Actualizar último valor', action: _getDataApi),
                ],
              ),
            );
          }
          return const LoadingProgress(titulo: 'CARGANDO DATOS...');
        });
    //} DONE
    //} DONE
    //return const LoadingProgress(titulo: 'Recuperando valores...', subtitulo: 'Cargando...');
  }

  void _getDataApi(BuildContext context) async {
    /*if (!_isLoading) {
      setState(() => _isLoading = true);
    }*/
    final getDataApi = await apiService.getDataApi(fondoOn.isin);
    if (getDataApi != null) {
      var newValor = Valor(date: getDataApi.epochSecs, precio: getDataApi.price);
      // TODO: valor divisa ??
      //var newMoneda = getDataApi.market;
      //var newLastPrecio = getDataApi.price;
      //var newLastDate = getDataApi.epochSecs;
      //setState(() {
      //TODO: POSIBLE ERROR SI CHOCA CON VALOR INTRODUCIDO DESDE MERCADO CON FECHA ANTERIOR
      //fondoOn.divisa = newMoneda;
      /*fondoOn
        ..moneda = newMoneda
        ..lastPrecio = newLastPrecio
        ..lastDate = newLastDate;*/
      //});
      //TODO check newvalor repetido por date ??

      //TODO: ESTE INSERT DESORDENA LOS FONDOS (pone al final el actualizado)
      //await _db.insertDataApi(carteraOn, fondoOn,
      //    moneda: newMoneda, lastPrecio: newLastPrecio, lastDate: newLastDate);
      fondoOn.divisa = getDataApi.market;
      //Fondo newFondo = fondoOn;
      //newFondo.divisa = getDataApi.market;
      //await _db.insertFondo(carteraOn, fondoOn);
      //await _db.insertVL(carteraOn, fondoOn, newValor);
      await _insertFondo();
      await _insertValor(newValor);
      //.whenComplete(() => setState(() => msgLoading = 'Almacenando datos...'));
      /*setState(() {
        msgLoading = 'Datos almacenados...';
      });*/
      await _updateValores();
      /*if (_isLoading) {
        setState(() => _isLoading = false);
      }*/
      // TODO: BANNER
      //print(dataApi?.price);
    } else {
      //setState(() => loading = false);
      //setState(() => _isLoading = false);
      _showMsg(msg: 'Error en la descarga de datos.', color: Colors.red);
    }
  }

  void _getRangeApi(BuildContext context) async {
    final newRange = await Navigator.of(context).pushNamed(RouteGenerator.inputRange);
    if (newRange != null) {
      var range = newRange as DateTimeRange;
      //String from = DateFormat('yyyy-MM-dd').format(range.start);
      //String to = DateFormat('yyyy-MM-dd').format(range.end);
      String from = FechaUtil.dateToString(date: range.start, formato: 'yyyy-MM-dd');
      String to = FechaUtil.dateToString(date: range.end, formato: 'yyyy-MM-dd');
      /*setState(() {
        loading = true;
        msgLoading = 'Conectando...';
      });*/
      //setState(() => _isLoading = true);
      final getDateApiRange = await apiService.getDataApiRange(fondoOn.isin, to, from);
      //?.whenComplete(() => setState(() => msgLoading = 'Descargando datos...'));
      //final getDateApiRange = await apiService.getDataApiRange(fondoOn.isin, to, from);
      var newListValores = <Valor>[];
      if (getDateApiRange != null) {
        for (var dataApi in getDateApiRange) {
          newListValores.add(Valor(date: dataApi.epochSecs, precio: dataApi.price));
        }
        //await _db.insertListVL(carteraOn, fondoOn, newListValores);
        //.whenComplete(() => setState(() => msgLoading = 'Almacenando datos...'));
        await _insertValores(newListValores);
        await _updateValores();
        /*if (_isLoading) {
          setState(() => _isLoading = false);
        }*/
        // TODO set last valor (date y precio) desde VALORES cada vez en _updateValores
        //await _compareLastValor();
      } else {
        /*if (_isLoading) {
          setState(() => _isLoading = false);
        }*/
        _showMsg(msg: 'Error en la descarga de datos.', color: Colors.red);
      }
    }
  }

  //TODO: compare con un valor pasado como argumento
  /*Future<bool> _compareLastValor() async {
    await _db.getValoresByOrder(carteraOn, fondoOn);
    var valores = _db.dbValoresByOrder;
    if (valores.isNotEmpty) {
      var lastValor = Valor(date: valores.first.date, precio: valores.first.precio);
      var lastPrecio = valores.first.precio;
      var lastDate = valores.first.date;
      if (fondoOn.lastDate == null) {
        fondoOn
          ..lastPrecio = lastPrecio
          ..lastDate = lastDate;
        //await _db.insertDataApi(carteraOn, fondoOn, lastPrecio: lastPrecio, lastDate: lastDate);
        await _db.insertFondo(carteraOn, fondoOn);
        await _db.insertVL(carteraOn, fondoOn, lastValor);
        await _updateValores();
        return true;
      } else if (fondoOn.lastDate! < lastDate) {
        fondoOn
          ..lastPrecio = lastPrecio
          ..lastDate = lastDate;
        //_db.insertDataApi(carteraOn, fondoOn, lastPrecio: lastPrecio, lastDate: lastDate);
        await _db.insertFondo(carteraOn, fondoOn);
        await _db.insertVL(carteraOn, fondoOn, lastValor);
        await _updateValores();
        return true;
      } else {
        await _updateValores();
        return false;
      }
    }
    await _updateValores();
    return false;
  }*/

  void _deleteConfirm(BuildContext context) {
    if (_db.dbValoresByOrder.isEmpty) {
      _showMsg(msg: 'Nada que eliminar');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text('Eliminar todo'),
              content: const Text('Esto eliminará todos los valores almacenados del fondo.'),
              actions: [
                TextButton(
                  child: const Text('CANCELAR'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('ACEPTAR'),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF44336),
                    primary: const Color(0xFFFFFFFF),
                    //textStyle: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    //await _db.deleteAllValoresInFondo(carteraOn, fondoOn);
                    await _deleteAllValores();
                    await _updateValores();
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    //Navigator.of(context).pushNamed(RouteGenerator.fondoPage);
                    Navigator.of(context).pop();
                    //_tabController.animateTo(_tabController.index);
                  },
                ),
              ],
            );
          });
    }
  }

  void _showMsg({required String msg, MaterialColor color = Colors.grey}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }
}
