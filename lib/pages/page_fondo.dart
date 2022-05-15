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
import '../widgets/main_fondo.dart';
import '../widgets/tabla_fondo.dart';

enum Menu { editar, suscribir, reembolsar, eliminar, exportar }

class PageFondo extends StatefulWidget {
  const PageFondo({Key? key}) : super(key: key);

  @override
  State<PageFondo> createState() => _PageFondoState();
}

class _PageFondoState extends State<PageFondo> {
  late CarfoinProvider carfoin;
  late Cartera carteraOn;
  late Fondo fondoOn;
  late Sqlite _db;
  late ApiService apiService;

  bool loading = true;
  String msgLoading = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      carfoin = Provider.of<CarfoinProvider>(context, listen: false);
      //carteraOn = carfoin.getCartera!;
    });

    carteraOn = context.read<CarfoinProvider>().getCartera!;
    fondoOn = context.read<CarfoinProvider>().getFondo!;

    loading = true;
    msgLoading = 'Abriendo base de datos...';
    _db = Sqlite();
    _db.openDb().whenComplete(() async {
      await _updateValores();
    });
    apiService = ApiService();
    super.initState();
  }

  _updateValores() async {
    setState(() => loading = true);
    await _db.createTableFondo(carteraOn, fondoOn);
    setState(() => msgLoading = 'Cargando datos almacenados...');
    await _db.getValoresByOrder(carteraOn, fondoOn).whenComplete(() => setState(() {
          loading = false;
          msgLoading = '';
          carfoin.setValores = _db.dbValoresByOrder;
        }));
    //TODO: si moneda, lastPrecio y LastDate == null hacer un update
    if (fondoOn.moneda == null) {}
    //TODO: check si data no es null ??
    //TODO: ordenar primero por date ??
  }

  List<Column> _buildListMenu(BuildContext context) {
    final Map<String, IconData> mapItemMenu = {
      Menu.editar.name: Icons.edit,
      Menu.suscribir.name: Icons.login,
      Menu.reembolsar.name: Icons.logout,
      Menu.eliminar.name: Icons.delete_forever,
      Menu.exportar.name: Icons.download,
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
          if (item.key == Menu.editar.name || item.key == Menu.reembolsar.name)
            const PopupMenuDivider(height: 10),
        ])
    ];
  }

  @override
  Widget build(BuildContext context) {
    const listaTabs = [MainFondo(), TablaFondo(), GraficoChart()];
    const List<IconData> iconsTab = [Icons.assessment, Icons.table_rows_outlined, Icons.timeline];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            // TODO: set carteraOn antes de navigator??
            Navigator.of(context).pushNamed(RouteGenerator.carteraPage);
          },
        ),
        title: Text(fondoOn.name),
        actions: [
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
                  PopupMenuItem(value: Menu.values[listItemMenu.indexOf(item)], child: item)
              ];
            },
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
      body: loading
          ? Padding(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const LinearProgressIndicator(),
                  Text(msgLoading),
                ],
              ),
            )
          : listaTabs.elementAt(_selectedIndex),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
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
                    color: _selectedIndex == iconsTab.indexOf(icon) ? Colors.white : Colors.white38,
                  ),
                  //padding: const EdgeInsets.only(left: 32.0, right: 32.0),
                  iconSize: 32,
                  onPressed: () => setState(() => _selectedIndex = iconsTab.indexOf(icon)),
                ),
              ),
            const Spacer(),
          ],
        ),
      ),
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
          SpeedDialChild(
            child: const Icon(Icons.date_range), //dns // list  //
            label: 'Descargar valores históricos',
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            onTap: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              _getRangeApi(context);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.update), //dns // list  //
            label: 'Actualizar último valor',
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            onTap: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              _getDataApi();
            },
          ),
        ],
      ),
    );
  }

  void _getDataApi() async {
    //TODO: msg updating
    print('UPDATING...');
    final getDataApi = await apiService.getDataApi(fondoOn.isin);
    if (getDataApi != null) {
      var newValor = Valor(date: getDataApi.epochSecs, precio: getDataApi.price);
      var newMoneda = getDataApi.market;
      var newLastPrecio = getDataApi.price;
      var newLastDate = getDataApi.epochSecs;
      //setState(() {
      fondoOn
        ..moneda = newMoneda
        ..lastPrecio = newLastPrecio
        ..lastDate = newLastDate;
      //});

      _db.insertDataApi(carteraOn, fondoOn,
          moneda: newMoneda, lastPrecio: newLastPrecio, lastDate: newLastDate);
      //TODO check newvalor repetido por date ??
      _db.insertVL(carteraOn, fondoOn, newValor);
      _updateValores();
      // TODO: BANNER
      //print(dataApi?.price);
    } else {
      print('ERROR GET DATAAPI');
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
      setState(() {
        loading = true;
        msgLoading = 'Conectando...';
      });
      final getDateApiRange = await apiService
          .getDataApiRange(fondoOn.isin, to, from)
          ?.whenComplete(() => setState(() => msgLoading = 'Descargando datos...'));
      //final getDateApiRange = await apiService.getDataApiRange(fondoOn.isin, to, from);
      var newListValores = <Valor>[];
      if (getDateApiRange != null) {
        for (var dataApi in getDateApiRange) {
          newListValores.add(Valor(date: dataApi.epochSecs, precio: dataApi.price));
        }
        await _db
            .insertListVL(carteraOn, fondoOn, newListValores)
            .whenComplete(() => setState(() => msgLoading = 'Almacenando datos...'));

        //await _updateValores();
        /*setState(() {
          loading = false;
          msgLoading = '';
        });*/
        _compareLastValor();
      } else {
        setState(() => loading = false);
        _showMsg(msg: 'Error en la descarga de datos.', color: Colors.red);
        print('ERROR GET DATA API RANGE');
      }
    }
  }

  Future<bool> _compareLastValor() async {
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
        _db.insertDataApi(carteraOn, fondoOn, lastPrecio: lastPrecio, lastDate: lastDate);
        _db.insertVL(carteraOn, fondoOn, lastValor);
        _updateValores();
        return true;
      } else if (fondoOn.lastDate! < lastDate) {
        fondoOn
          ..lastPrecio = lastPrecio
          ..lastDate = lastDate;
        _db.insertDataApi(carteraOn, fondoOn, lastPrecio: lastPrecio, lastDate: lastDate);
        _db.insertVL(carteraOn, fondoOn, lastValor);
        _updateValores();
        return true;
      } else {
        _updateValores();
        return false;
      }
    }
    _updateValores();
    return false;

    //if(valores.first.date < fondoOn.lastDate){         }
  }

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
                    backgroundColor: Colors.red,
                    primary: Colors.white,
                    //textStyle: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    await _db.deleteAllValoresInFondo(carteraOn, fondoOn);
                    _updateValores();
                    Navigator.of(context).pop();
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
