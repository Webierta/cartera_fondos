import 'package:cartera_fondos/models/data_api_range.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cartera.dart';
import '../models/data_api.dart';
import '../models/fondo.dart';
import '../models/valor.dart';
import '../services/api_service.dart';
import '../services/sqlite_service.dart';

class PageFondo extends StatefulWidget {
  final Cartera cartera;
  final Fondo fondo;
  const PageFondo({
    Key? key,
    required this.cartera,
    required this.fondo,
  }) : super(key: key);

  @override
  State<PageFondo> createState() => _PageFondoState();
}

class _PageFondoState extends State<PageFondo> {
  late SqliteService _sqlite;
  var valores = <Valor>[];
  Valor? lastValor;
  bool loading = true;
  String msgLoading = '';

  //var valores = [Valor(date: 123456, precio: 23.43), Valor(date: 431234, precio: 24.33)];

  //DataApi? dataApi;
  late ApiService apiService;
  //late apiData;

  _refreshValores() async {
    await _sqlite.createTableFondo(widget.cartera, widget.fondo);
    setState(() {
      msgLoading = 'Obteniendo datos...';
    });
    final data =
        await _sqlite.getValores(widget.cartera, widget.fondo).whenComplete(() => setState(() {
              loading = false;
              msgLoading = '';
            }));
    //TODO: check si data no es null ??
    setState(() => valores = data);
    if (valores.isNotEmpty) {
      //TODO: ordenar primero por date
      setState(() {
        lastValor = valores.last;
      });
    }
  }

  Future<List<Valor>> _getValores() async {
    return await _sqlite.getValores(widget.cartera, widget.fondo);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DETALLE FONDO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // actualizar VL
              final getDataApi = await apiService.getDataApi(widget.fondo.isin);
              if (getDataApi != null) {
                //dataApi = getDataApi;
                //widget.fondo.insertVL(dataApi?.epochSecs as int, dataApi?.price as double);
                var newValor = Valor(date: getDataApi.epochSecs, precio: getDataApi.price);
                //TODO check newvalor repetido por date ??
                setState(() => lastValor = newValor);
                _sqlite.insertVL(widget.cartera, widget.fondo, newValor);
                _refreshValores();
                // TODO: BANNER
                //print(dataApi?.price);
              } else {
                print('ERROR GET DATAAPI');
              }
            },
          ),
          PopupMenuButton<int>(
              color: Colors.blue,
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.edit),
                        SizedBox(width: 10),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: 10),
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.login),
                        SizedBox(width: 10),
                        Text('Aportar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.logout),
                        SizedBox(width: 10),
                        Text('Reembolsar'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: 10),
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.download_rounded),
                        SizedBox(width: 10),
                        Text('Exportar'),
                      ],
                    ),
                  ),
                ];
              }),
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              title: Text(
                widget.fondo.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(
                widget.fondo.isin,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: lastValor != null
                  ? Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //TODO: control número de decimales: máx 2
                          Text(
                            '${lastValor?.precio ?? ''}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            lastValor != null ? _epochFormat(lastValor!.date) : '',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          // ULTIMO VALOR
          /*Card(
            child: ListTile(
              title: Text('${valores.last.precio}'),
              subtitle: Text('${valores.last.date}'),
            ),
          ),*/
          /*Card(
            child: ListTile(
              title: Text('${widget.fondo.historico.last.keys}'),
              subtitle: Text('${widget.fondo.historico.last.entries}'),
              //subtitle: Text('${dataApi?.price ?? 'nada'}'),
            ),
          ),*/
          // ÍNDICES DE RENTABILIDAD
          //Card(),
          // GRÁFICO
          //Card(),
          // HISTORICO DE VALORES
          // FECHA - VL
          /*Card(
            child: valores.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: valores.length,
                    itemBuilder: (context, index) {
                      return DataTable(
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('FECHA')),
                          DataColumn(label: Text('PRECIO')),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(_epochFormat(valores[index].date))),
                            DataCell(Text('${valores[index].precio}')),
                          ]),
                        ],
                      );
                    },
                  )
                : const Text('Nada que mostrar'),
          ),*/
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
                          columns: const [
                            DataColumn(label: Text('#')),
                            DataColumn(label: Text('FECHA')),
                            DataColumn(label: Text('PRECIO')),
                            DataColumn(label: Text('+/-')),
                          ],
                          rows: valores
                              .map((valor) => DataRow(cells: [
                                    DataCell(Text('${valores.indexOf(valor)}')),
                                    DataCell(Text(_epochFormat(valor.date))),
                                    //TODO: control número de decimales: máx 5
                                    DataCell(Text('${valor.precio}')),
                                    DataCell(Text('-2.3')),
                                  ]))
                              .toList(),
                        ),
                      )
                    ],
                  ),
                ),

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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.update),
        onPressed: () async {
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
        },
      ),
    );
  }

  String _epochFormat(int epoch) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    final DateFormat formatter = DateFormat('dd/MM/yy');
    return formatter.format(date);
  }
}
