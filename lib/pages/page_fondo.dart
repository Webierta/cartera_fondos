import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../models/carfoin_provider.dart';
import '../models/valor.dart';
import '../routes.dart';
import '../services/api_service.dart';
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
  late ApiService apiService;
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3);
    carfoin = context.read<CarfoinProvider>();
    carfoin.openDb().whenComplete(() async {
      await carfoin.updateValores();
    });
    apiService = ApiService();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      backgroundColor: const Color(0xFFFFC107),
      foregroundColor: const Color(0xFF0D47A1),
      onTap: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        action(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var carteraOn = context.watch<CarfoinProvider>().getCartera!;
    var fondoOn = context.watch<CarfoinProvider>().getFondo!;
    return FutureBuilder<bool>(
        future: carfoin.openDb(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
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
                title: Chip(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  backgroundColor: const Color(0xFF0D47A1),
                  avatar: const Icon(Icons.business_center),
                  label: Text(
                    carteraOn.name,
                    style: const TextStyle(color: Color(0xFFFFFFFF)),
                  ),
                ),
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
              body: TabBarView(
                controller: _tabController,
                children: const [MainFondo(), TablaFondo(), GraficoChart()],
              ),
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
                    tabs: const [
                      Tab(icon: Icon(Icons.assessment, size: 32)),
                      Tab(icon: Icon(Icons.table_rows_outlined, size: 32)),
                      Tab(icon: Icon(Icons.timeline, size: 32)),
                    ],
                  ),
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
              floatingActionButton: SpeedDial(
                icon: Icons.refresh,
                foregroundColor: const Color(0xFF0D47A1),
                backgroundColor: const Color(0xFFFFC107),
                spacing: 8,
                spaceBetweenChildren: 4,
                overlayColor: const Color(0xFF9E9E9E),
                overlayOpacity: 0.4,
                children: [
                  _buildSpeedDialChild(
                    context,
                    icono: Icons.date_range,
                    label: 'Descargar valores históricos',
                    action: _getRangeApi,
                  ),
                  _buildSpeedDialChild(
                    context,
                    icono: Icons.update,
                    label: 'Actualizar último valor',
                    action: _getDataApi,
                  ),
                ],
              ),
            );
          }
          return const LoadingProgress(titulo: 'CARGANDO DATOS...');
        });
  }

  _dialogProgress(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Loading(titulo: 'Descargando datos...');
      },
    );
  }

  void _getDataApi(BuildContext context) async {
    var fondoOn = context.read<CarfoinProvider>().getFondo!;
    _dialogProgress(context);
    final getDataApi = await apiService.getDataApi(fondoOn.isin);
    if (getDataApi != null) {
      var newValor = Valor(date: getDataApi.epochSecs, precio: getDataApi.price);
      fondoOn.divisa = getDataApi.market;
      //TODO: POSIBLE ERROR SI CHOCA CON VALOR INTRODUCIDO DESDE MERCADO CON FECHA ANTERIOR
      //TODO check newvalor repetido por date ??
      //TODO: ESTE INSERT DESORDENA LOS FONDOS (pone al final el actualizado)
      await carfoin.insertFondo();
      await carfoin.insertValor(newValor);
      await carfoin.updateValores();
      _pop();
      _showMsg(msg: 'Descarga de datos completada.');
    } else {
      _pop();
      _showMsg(msg: 'Error en la descarga de datos.', color: Colors.red);
    }
  }

  void _getRangeApi(BuildContext context) async {
    var fondoOn = context.read<CarfoinProvider>().getFondo!;
    final newRange = await Navigator.of(context).pushNamed(RouteGenerator.inputRange);
    if (newRange != null) {
      if (!mounted) return;
      _dialogProgress(context);
      var range = newRange as DateTimeRange;
      String from = FechaUtil.dateToString(date: range.start, formato: 'yyyy-MM-dd');
      String to = FechaUtil.dateToString(date: range.end, formato: 'yyyy-MM-dd');
      final getDateApiRange = await apiService.getDataApiRange(fondoOn.isin, to, from);
      var newListValores = <Valor>[];
      if (getDateApiRange != null) {
        for (var dataApi in getDateApiRange) {
          newListValores.add(Valor(date: dataApi.epochSecs, precio: dataApi.price));
        }
        await carfoin.insertValores(newListValores);
        await carfoin.updateValores();
        // TODO set last valor (date y precio) desde VALORES cada vez en _updateValores
        _pop();
        _showMsg(msg: 'Descarga de datos completada.');
      } else {
        _pop();
        _showMsg(msg: 'Error en la descarga de datos.', color: Colors.red);
      }
    }
  }

  void _deleteConfirm(BuildContext context) async {
    //var fondoOn = context.read<CarfoinProvider>().getFondo!;
    // TODO: necesario getValores si se usa provider watch ??
    //await carfoin.getValoresFondo(fondoOn);
    if (carfoin.getValores.isEmpty) {
      _showMsg(msg: 'Nada que eliminar');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text('Eliminar todo'),
              content: const Text('Esto eliminará todos los valores almacenados del fondo.'),
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
                    await carfoin.deleteAllValores();
                    await carfoin.updateValores();
                    _pop();
                    //_tabController.animateTo(_tabController.index);
                  },
                  child: const Text('ACEPTAR'),
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

  void _pop() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    Navigator.of(context).pop();
  }
}
