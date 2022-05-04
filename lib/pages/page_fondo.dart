import 'package:cartera_fondos/models/data_api_range.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cartera.dart';
import '../models/data_api.dart';
import '../models/fondo.dart';
import '../models/valor.dart';
import '../services/api_service.dart';
import '../services/sqlite_service.dart';

enum ItemMenuFondo { editar, suscribir, reembolsar, eliminar, exportar }

class PageFondo extends StatefulWidget {
  final Cartera cartera;
  final Fondo fondo;
  const PageFondo({Key? key, required this.cartera, required this.fondo}) : super(key: key);

  @override
  State<PageFondo> createState() => _PageFondoState();
}

class _PageFondoState extends State<PageFondo> {
  late SqliteService _sqlite;
  late ApiService apiService;

  var valores = <Valor>[];
  var valoresCopy = <Valor>[];
  // TODO lastValor ????? mejor lastPrecio + lastDate
  //Valor? lastValor;

  String? moneda;
  double? lastPrecio;
  int? lastDate;
  int participaciones = 0;

  bool loading = true;
  String msgLoading = '';

  int _currentSortColumn = 0;
  bool _isSortAsc = true;

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
    });

    /*if (valores.isNotEmpty) {
      //TODO: ordenar primero por date
      setState(() {
        lastValor = valores.last;
      });
    }*/
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
          if (position == 0 || position == 2)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: PopupMenuDivider(height: 10),
            ),
        ],
      ),
    );
  }

  // TODO: ACCIONES MENU
  _onMenuItemSelected(int value) {
    if (value == ItemMenuFondo.editar.index) {
      print('EDITAR');
    } else if (value == ItemMenuFondo.suscribir.index) {
      print('SUSCRIBIR');
    } else if (value == ItemMenuFondo.reembolsar.index) {
      print('REEMBOLSAR');
    } else if (value == ItemMenuFondo.eliminar.index) {
      print('ELIMINAR');
    } else if (value == ItemMenuFondo.exportar.index) {
      print('EXPORTAR');
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DETALLE FONDO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_repeat),
            onPressed: getRangeValores,
          ),
          PopupMenuButton(
            onSelected: (value) => _onMenuItemSelected(value as int),
            color: Colors.blue,
            offset: Offset(0.0, AppBar().preferredSize.height),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            itemBuilder: (ctx) => [
              _buildMenuItem('Editar', Icons.edit, ItemMenuFondo.editar.index),
              _buildMenuItem('Suscribir', Icons.login, ItemMenuFondo.suscribir.index),
              _buildMenuItem('Reembolsar', Icons.logout, ItemMenuFondo.reembolsar.index),
              _buildMenuItem('Eliminar datos', Icons.delete_forever, ItemMenuFondo.eliminar.index),
              _buildMenuItem('Exportar', Icons.download, ItemMenuFondo.exportar.index),
            ],
          ),
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(10),
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: const Icon(Icons.assessment, size: 32),
              title: Text(
                widget.fondo.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(
                widget.fondo.isin,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Text(
                    widget.fondo.moneda ?? '',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  title: valores.isEmpty
                      ? const Text('Precio: Sin datos')
                      : Center(
                          child: Text(
                            //'${widget.fondo.lastPrecio ?? ''}',
                            '${valores.first.precio}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                  subtitle: valores.isEmpty
                      ? const Text('Descarga el último valor liquidativo')
                      : Center(
                          child: Text(
                            //widget.fondo.lastDate != null
                            valores.isNotEmpty
                                ?
                                //_epochFormat(widget.fondo.lastDate!) : '',
                                _epochFormat(valores.first.date)
                                : '',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.blue),
                    onPressed: updateValor,
                  ),
                ),
                const SizedBox(height: 10),
                valores.isEmpty
                    ? const SizedBox(height: 0)
                    : ListTile(
                        title: participaciones > 0
                            ? Text('Patrimonio: ${participaciones * widget.fondo.lastPrecio!}')
                            : const Text('Patrimonio: Sin datos'),
                        subtitle: participaciones > 0
                            ? Text('Participaciones: $participaciones')
                            : const Text(
                                'Subscribe participaciones de este Fondo para seguir la evolución de tu inversión'),
                        // TODO: nueva ventana con Fecha / participaciones y VL
                        trailing: IconButton(
                          icon: const Icon(Icons.shopping_cart, color: Colors.blue),
                          onPressed: () {},
                        ),
                      ),
                const SizedBox(height: 10),
                participaciones == 0
                    ? const SizedBox(height: 0)
                    : ListTile(
                        title: Text('Rendimiento:'),
                        isThreeLine: true,
                        subtitle: Text('Rentabilidad: \nTAE: '),
                      ),
              ],
            ),
          ),
          //TODO: CARD -> Grafico
          const SizedBox(height: 10),
          loading
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
              : Card(
                  child: ListView(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          sortColumnIndex: _currentSortColumn,
                          sortAscending: _isSortAsc,
                          columnSpacing: 30,
                          //horizontalMargin: 0,
                          columns: [
                            DataColumn(
                                label: const Text('#'),
                                numeric: true,
                                onSort: (columnIndex, _) {
                                  setState(() {
                                    _currentSortColumn = columnIndex;
                                    if (!_isSortAsc) {
                                      valoresCopy.sort((a, b) => b.date.compareTo(a.date));
                                    } else {
                                      valoresCopy.sort((a, b) => a.date.compareTo(b.date));
                                    }
                                    _isSortAsc = !_isSortAsc;
                                  });
                                }),
                            const DataColumn(label: Text('FECHA'), numeric: true),
                            const DataColumn(label: Text('PRECIO'), numeric: true),
                            const DataColumn(label: Text('+/-'), numeric: true),
                          ],
                          rows: valoresCopy
                              .map((valor) => DataRow(cells: [
                                    //DataCell(Text('${valores.indexOf(valor)}')),
                                    DataCell(_isSortAsc
                                        ? Text('${valoresCopy.length - valoresCopy.indexOf(valor)}')
                                        : Text('${valoresCopy.indexOf(valor) + 1}')),
                                    DataCell(Text(_epochFormat(valor.date))),
                                    //TODO: control número de decimales: máx 5
                                    DataCell(Text('${valor.precio}')),
                                    _isSortAsc
                                        ? DataCell(valoresCopy.length >
                                                (valoresCopy.indexOf(valor) + 1)
                                            ? Text(
                                                (valor.precio -
                                                        valoresCopy[valoresCopy.indexOf(valor) + 1]
                                                            .precio)
                                                    .toStringAsFixed(2),
                                                style: valor.precio -
                                                            valoresCopy[
                                                                    valoresCopy.indexOf(valor) + 1]
                                                                .precio <
                                                        0
                                                    ? const TextStyle(color: Colors.red)
                                                    : const TextStyle(color: Colors.green),
                                              )
                                            : const Text(''))
                                        : DataCell(valoresCopy.length >
                                                    (valoresCopy.indexOf(valor) - 1) &&
                                                valoresCopy.indexOf(valor) > 0
                                            ? Text(
                                                (valoresCopy[valoresCopy.indexOf(valor) - 1]
                                                            .precio -
                                                        valor.precio)
                                                    .toStringAsFixed(2),
                                                style: valoresCopy[valoresCopy.indexOf(valor) - 1]
                                                                .precio -
                                                            valor.precio <
                                                        0
                                                    ? const TextStyle(color: Colors.red)
                                                    : const TextStyle(color: Colors.green),
                                              )
                                            : const Text('')),
                                  ]))
                              .toList(),
                        ),
                      )
                    ],
                  ),
                ),
        ],
      ),
      /*floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.event_repeat),
        onPressed: getRangeValores,
      ),*/
    );
  }

  void getRangeValores() async {
    setState(() {
      loading = true;
      msgLoading = 'Conectando...';
    });
    //ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
    /*final getDataApi = await apiService.getDataApi(widget.fondo.isin);
        if (getDataApi != null) {
        //dataApi = getDataApi;
        //widget.fondo.insertVL(dataApi?.epochSecs as int, dataApi?.price as double);
        var newValor = Valor(date: getDataApi.epochSecs, precio: getDataApi.price);
        //TODO check newvalor repetido por date ??
        setState(() => lastValor = newValor);
        _sqlite.insertVL(widget.fondo, newValor);
        _refreshValores(widget.fondo);*/
    final getDateApiRange = await apiService
        .getDataApiRange(widget.fondo.isin, 'to', 'from')
        ?.whenComplete(() => setState(() => msgLoading = 'Descargando datos...'));
    print(getDateApiRange?.length);
    var newListValores = <Valor>[];
    if (getDateApiRange != null) {
      /*for (var dataApi in getDateApiRange) {
            var newValor = Valor(date: dataApi.epochSecs, precio: dataApi.price);
            _sqlite.insertVL(widget.fondo, newValor);
            _refreshValores(widget.fondo);
          }*/
      for (var dataApi in getDateApiRange) {
        newListValores.add(Valor(date: dataApi.epochSecs, precio: dataApi.price));
      }
      await _sqlite
          .insertListVL(widget.cartera, widget.fondo, newListValores)
          .whenComplete(() => setState(() => msgLoading = 'Escribiendo datos...'));
      print('HECHO');
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

  void updateValor() async {
    // actualizar VL
    //TODO: msg updating
    final getDataApi = await apiService.getDataApi(widget.fondo.isin);
    if (getDataApi != null) {
      var newValor = Valor(date: getDataApi.epochSecs, precio: getDataApi.price);
      var newMoneda = getDataApi.market;
      var newLastPrecio = getDataApi.price;
      var newLastDate = getDataApi.epochSecs;
      setState(() {
        widget.fondo.moneda = newMoneda;
        moneda = newMoneda;
        widget.fondo.lastPrecio = newLastPrecio;
        lastPrecio = newLastPrecio;
        widget.fondo.lastDate = newLastDate;
        lastDate = newLastDate;
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

  String _epochFormat(int epoch) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    final DateFormat formatter = DateFormat('dd/MM/yy');
    return formatter.format(date);
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
