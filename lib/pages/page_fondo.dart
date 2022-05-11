//import 'package:cartera_fondos/models/data_api_range.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import '../models/cartera.dart';
//import '../models/data_api.dart';
import '../models/fondo.dart';
import '../models/valor.dart';
import '../routes.dart';
import '../services/api_service.dart';
import '../services/sqlite_service.dart';
import '../widgets/grafico_chart.dart';
import '../widgets/main_fondo.dart';
import '../widgets/tabla_fondo.dart';

enum ItemRefresh { update, getRange }
enum ItemMenuFondo { editar, suscribir, reembolsar, eliminar, exportar }

class PageFondo extends StatefulWidget {
  final Cartera cartera;
  final Fondo fondo;
  const PageFondo({Key? key, required this.cartera, required this.fondo}) : super(key: key);

  @override
  State<PageFondo> createState() => _PageFondoState();
}

class _PageFondoState extends State<PageFondo> {
  int _selectedIndex = 0;

  late SqliteService _sqlite;
  late ApiService apiService;

  var valores = <Valor>[];
  var valoresCopy = <Valor>[];

  bool loading = true;
  String msgLoading = '';

  var listaWidgets = <Widget>[];
  late ListView mainFondo;

  @override
  void initState() {
    _sqlite = SqliteService();
    loading = true;
    msgLoading = 'Abriendo base de datos...';
    _sqlite.initDB().whenComplete(() async {
      await _refreshValores();
    });
    apiService = ApiService();
    super.initState();
  }

  _refreshValores() async {
    setState(() {
      loading = true;
      valores = <Valor>[];
      valoresCopy = <Valor>[];
    });

    await _sqlite.createTableFondo(widget.cartera, widget.fondo);
    setState(() => msgLoading = 'Obteniendo datos...');
    final data = await _sqlite
        .getValoresByOrder(widget.cartera, widget.fondo)
        .whenComplete(() => setState(() {
              loading = false;
              msgLoading = '';
            }));
    //TODO: si moneda, lastPrecio y LastDate == null hacer un update
    if (widget.fondo.moneda == null) {}

    //TODO: check si data no es null ??
    setState(() {
      valores = data;
      valoresCopy = [...valores];
      listaWidgets.clear();
      listaWidgets.add(MainFondo(
        cartera: widget.cartera,
        fondo: widget.fondo,
        //refresh: refreshValores(),
      ));
      listaWidgets.add(TablaFondo(valores: valores));
      listaWidgets.add(GraficoChart(valores: valores));
      loading = false;
      msgLoading = '';
    });

    /*if (valores.isNotEmpty) {
      //TODO: ordenar primero por date
      setState(() {
        lastValor = valores.last;
      });
    }*/
  }

  /*_onMenuRefresh(int value) {
    if (value == ItemRefresh.update.index) {
      updateValor();
    } else if (value == ItemRefresh.getRange.index) {
      getRangeValores(context);
    } else {}
  }*/

  @override
  Widget build(BuildContext context) {
    const Map<String, IconData> itemMenu = {
      'Editar': Icons.edit,
      'Suscribir': Icons.login,
      'Reembolsar': Icons.logout,
      'Eliminar': Icons.delete_forever,
      'Exportar': Icons.download,
    };

    List<ListTile> listaItemMenu = itemMenu.entries
        .map((e) => ListTile(
              leading: Icon(e.value, color: Colors.white),
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _refreshValores();
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            Navigator.of(context).pushNamed(
              RouteGenerator.carteraPage,
              arguments: widget.cartera,
            );
          },
        ),
        // TODO: variable segun TAB ??
        title: Text(widget.fondo.name),
        actions: [
          PopupMenuButton(
            color: Colors.blue,
            offset: Offset(0.0, AppBar().preferredSize.height),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            itemBuilder: (ctx) => listaItemMenu
                .asMap()
                .entries
                .map((e) => PopupMenuItem(value: e.key, child: e.value))
                .toList(),
            onSelected: (value) {
              //TODO: ACCIONES PENDIENTES
              if (value == ItemMenuFondo.editar.index) {
                print('EDITAR');
                //TODO SUBPAGE de operar con suscribir y reembolsar
              } else if (value == ItemMenuFondo.suscribir.index) {
                print('SUSCRIBIR');
              } else if (value == ItemMenuFondo.reembolsar.index) {
                print('REEMBOLSAR');
              } else if (value == ItemMenuFondo.eliminar.index) {
                _deleteConfirm(context);
              } else if (value == ItemMenuFondo.exportar.index) {
                print('EXPORTAR');
              } else {}
            },
          ),
        ],
      ),
      body: loading || listaWidgets.length != 3
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
          : listaWidgets.elementAt(_selectedIndex),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Icons.assessment, Icons.table_rows_outlined, Icons.timeline]
              .asMap()
              .entries
              .map((item) => IconButton(
                    icon: Icon(
                      item.value,
                      color: _selectedIndex == item.key ? Colors.white : Colors.white38,
                    ),
                    padding: const EdgeInsets.only(left: 32.0),
                    iconSize: 32,
                    onPressed: () => setState(() => _selectedIndex = item.key),
                  ))
              .toList(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        icon: Icons.refresh,
        spacing: 8,
        spaceBetweenChildren: 4,
        overlayColor: Colors.blue,
        overlayOpacity: 0.2,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.date_range), //dns // list  //
            label: 'Valores históricos',
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            onTap: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              getRangeValores(context);
              // final newFondo = await Navigator.of(context).pushNamed(RouteGenerator.searchFondo);
              // if (newFondo != null) {
              //   addFondo(newFondo as Fondo);
              // } else {
              //   _showMsg(msg: 'Sin cambios en la cartera.');
              // }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.update), //dns // list  //
            label: 'Actualizar último valor',
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            onTap: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              updateValor();
              // final newFondo = await Navigator.of(context).pushNamed(RouteGenerator.searchFondo);
              // if (newFondo != null) {
              //   addFondo(newFondo as Fondo);
              // } else {
              //   _showMsg(msg: 'Sin cambios en la cartera.');
              // }
            },
          ),
        ],
      ),
    );
  }

  void updateValor() async {
    //TODO: msg updating
    print('UPDATING...');
    final getDataApi = await apiService.getDataApi(widget.fondo.isin);
    if (getDataApi != null) {
      var newValor = Valor(date: getDataApi.epochSecs, precio: getDataApi.price);
      var newMoneda = getDataApi.market;
      var newLastPrecio = getDataApi.price;
      var newLastDate = getDataApi.epochSecs;
      setState(() {
        widget.fondo.moneda = newMoneda;
        //moneda = newMoneda;
        widget.fondo.lastPrecio = newLastPrecio;
        //lastPrecio = newLastPrecio;
        widget.fondo.lastDate = newLastDate;
        //lastDate = newLastDate;
      });
      _sqlite.insertDataApi(
        widget.cartera,
        widget.fondo,
        moneda: newMoneda,
        lastPrecio: newLastPrecio,
        lastDate: newLastDate,
      );
      //TODO check newvalor repetido por date ??
      //setState(() => lastValor = newValor);
      _sqlite.insertVL(widget.cartera, widget.fondo, newValor);

      _refreshValores();
      // TODO: BANNER
      //print(dataApi?.price);
    } else {
      print('ERROR GET DATAAPI');
    }
  }

  void getRangeValores(BuildContext context) async {
    final newRange = await Navigator.of(context).pushNamed(
      RouteGenerator.inputRange,
      arguments: widget.fondo,
    );
    if (newRange != null) {
      var range = newRange as DateTimeRange;
      String from = DateFormat('yyyy-MM-dd').format(range.start);
      String to = DateFormat('yyyy-MM-dd').format(range.end);

      setState(() {
        loading = true;
        msgLoading = 'Conectando...';
      });
      final getDateApiRange = await apiService
          .getDataApiRange(widget.fondo.isin, to, from)
          ?.whenComplete(() => setState(() => msgLoading = 'Descargando datos...'));
      //print(getDateApiRange?.length);
      var newListValores = <Valor>[];
      if (getDateApiRange != null) {
        for (var dataApi in getDateApiRange) {
          newListValores.add(Valor(date: dataApi.epochSecs, precio: dataApi.price));
        }
        await _sqlite
            .insertListVL(widget.cartera, widget.fondo, newListValores)
            .whenComplete(() => setState(() => msgLoading = 'Escribiendo datos...'));
        await _refreshValores();
        setState(() {
          loading = false;
          msgLoading = '';
        });
      } else {
        setState(() => loading = false);
        print('ERROR GET DATA API RANGE');
      }
    }
  }

  void _deleteConfirm(BuildContext context) {
    if (valores.isEmpty) {
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
                    await _sqlite.deleteAllValoresInFondo(widget.cartera, widget.fondo);
                    await _refreshValores();
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
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }
}

/*Card(
            child: FutureBuilder<List<Valor>>(
              future: _getValores(widget.fondo),
              builder: (context, snapShot) {
                if (snapShot.connectionState == ConnectionState.done) {
                  if (snapShot.hasError) {
                    return const Text('ERROR recibiendo datos');
                  }
                  var index = 1;
                  if (snapShot.hasData) {
                    return SingleChildScrollView(
                      //scrollDirection: Axis.horizontal,
                      // TODO: columna diferencia con anterior
                      // TODO: posible salida por los lados (ver tabledata widget de la semana)
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('FECHA')),
                          DataColumn(label: Text('PRECIO')),
                        ],
                        rows: snapShot.data!.map<DataRow>((valor) {
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(Text('${index++}')),
                              DataCell(Text(_epochFormat(valor.date))),
                              DataCell(Text('${valor.precio}')),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),*/

/*class FABBottomAppBarItem {
  IconData iconData;
  String text;
  FABBottomAppBarItem({required this.iconData, required this.text});
}

class FABBottomAppBar extends StatefulWidget {
  final List<FABBottomAppBarItem> items;
  final ValueChanged<int> onTabSelected;

  const FABBottomAppBar({Key? key, required this.items, required this.onTabSelected})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => FABBottomAppBarState();
}

class FABBottomAppBarState extends State<FABBottomAppBar> {
  int _selectedIndex = 0;

  _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: items,
      ),
    );
  }

  Widget _buildTabItem({
    required FABBottomAppBarItem item,
    required int index,
    required ValueChanged<int> onPressed,
  }) {
    Color color = _selectedIndex == index ? Colors.blue : Colors.grey;
    return Padding(
      padding: const EdgeInsets.only(left: 28),
      child: SizedBox(
        height: 50,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(item.iconData, color: color),
                Text(item.text, style: TextStyle(color: color)),
                //padding: const EdgeInsets.only(left: 28.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/

/*
class FABBottomAppBarItem {
  IconData iconData;
  String text;
  FABBottomAppBarItem({required this.iconData, required this.text});
}

class FABBottomAppBar extends StatefulWidget {
  final List<FABBottomAppBarItem> items;
  // final String centerItemText;
  // final double height;
  // final double iconSize;
  // final Color backgroundColor;
  // final Color color;
  // final Color selectedColor;
  // final NotchedShape notchedShape;
  final ValueChanged<int> onTabSelected;

  FABBottomAppBar({
    Key? key,
    required this.items,
    // required this.centerItemText,
    // this.height = 60.0,
    // this.iconSize = 24.0,
    // required this.backgroundColor,
    // required this.color,
    // required this.selectedColor,
    // required this.notchedShape,
    required this.onTabSelected,
  }) : super(key: key) {
    assert(items.length == 2 || items.length == 4);
  }

  @override
  State<StatefulWidget> createState() => FABBottomAppBarState();
}

class FABBottomAppBarState extends State<FABBottomAppBar> {
  int _selectedIndex = 0;

  _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });
    items.insert(items.length >> 1, _buildMiddleTabItem());

    return BottomAppBar(
      shape: const CircularNotchedRectangle(), //widget.notchedShape,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: items,
      ),
      color: Colors.blue, //widget.backgroundColor,
    );
  }

  Widget _buildMiddleTabItem() {
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: widget.iconSize),
            Text(
              widget.centerItemText ?? '',
              style: const TextStyle(color: Colors.blue), //widget.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required FABBottomAppBarItem item,
    required int index,
    required ValueChanged<int> onPressed,
  }) {
    Color color = _selectedIndex == index ? widget.selectedColor : widget.color;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(item.iconData, color: color, size: widget.iconSize),
                Text(
                  item.text,
                  style: TextStyle(color: color),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/
