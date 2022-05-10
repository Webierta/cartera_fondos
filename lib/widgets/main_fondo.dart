import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cartera.dart';
import '../models/fondo.dart';
import '../models/valor.dart';
import '../services/api_service.dart';
import '../services/sqlite_service.dart';

class MainFondo extends StatefulWidget {
  final Cartera cartera;
  final Fondo fondo;
  const MainFondo({Key? key, required this.cartera, required this.fondo}) : super(key: key);

  @override
  State<MainFondo> createState() => _MainFondoState();
}

class _MainFondoState extends State<MainFondo> {
  late SqliteService _sqlite;
  late ApiService apiService;

  var valores = <Valor>[];
  var valoresCopy = <Valor>[];

  bool loading = true;
  String msgLoading = '';

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
    });
    /*if (valores.isNotEmpty) {
      //TODO: ordenar primero por date
      setState(() {
        lastValor = valores.last;
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
                      title: widget.fondo.participaciones > 0
                          ? Text(
                              'Patrimonio: ${widget.fondo.participaciones * widget.fondo.lastPrecio!}')
                          : const Text('Patrimonio: Sin datos'),
                      subtitle: widget.fondo.participaciones > 0
                          ? Text('Participaciones: ${widget.fondo.participaciones}')
                          : const Text(
                              'Subscribe participaciones de este Fondo para seguir la evolución de tu inversión'),
                      // TODO: nueva ventana con Fecha / participaciones y VL
                      trailing: IconButton(
                        icon: const Icon(Icons.shopping_cart, color: Colors.blue),
                        onPressed: () {},
                      ),
                    ),
              const SizedBox(height: 10),
              widget.fondo.participaciones == 0
                  ? const SizedBox(height: 0)
                  // TODO: GET DATOS REALES
                  : const ListTile(
                      title: Text('Rendimiento:'),
                      isThreeLine: true,
                      subtitle: Text('Rentabilidad: \nTAE: '),
                    ),
            ],
          ),
        ),
        //valores.length < 3 ? const SizedBox(height: 0) : Grafico(valores),
        //valores.length < 3 ? const SizedBox(height: 0) : Grafico(valores: valores),
        //const SizedBox(height: 10),
        ////valores.length < 3 ? const SizedBox(height: 0) : GraficoFondo(valores: valores),
        /*loading
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
              : valores.isEmpty
                  ? const SizedBox(height: 0)
                  : TablaFondo(valores: valores),*/
      ],
    );
  }

  void updateValor() async {
    //TODO: msg updating
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

  String _epochFormat(int epoch) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    final DateFormat formatter = DateFormat('dd/MM/yy');
    return formatter.format(date);
  }
}
