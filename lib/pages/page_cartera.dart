import 'package:flutter/material.dart';

import '../models/cartera.dart';
import '../models/fondo.dart';
import '../models/valor.dart';
import '../routes.dart';
import '../services/api_service.dart';
import '../services/sqlite_service.dart';

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
  //var valores = <Valor>[];

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
          //TODO: ADD PopupMenuButton :Eliminar
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
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        children: [
          FloatingActionButton(
            heroTag: 'searchFondo',
            child: const Icon(Icons.search),
            onPressed: () async {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              final newFondo = await Navigator.of(context).pushNamed(RouteGenerator.inputFondo);
              if (newFondo != null) {
                for (var fondo in fondos) {
                  if (fondo.isin == (newFondo as Fondo).isin) {
                    _showMsg(msg: 'El fondo con ISIN ${fondo.isin} ya existe en esta cartera.');
                    setState(() => _fondoRepe = true);
                    break;
                  } else {
                    setState(() => _fondoRepe = false);
                  }
                }
                if (_fondoRepe == false) {
                  _sqlite.insertFondo(widget.cartera, newFondo as Fondo);
                  _refreshFondos();
                  _showMsg(msg: 'Fondo añadido', icon: Icons.task_alt, color: Colors.blue);
                }
              } else {
                _showMsg(msg: 'Error al añadir el fondo');
              }
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'addFondo',
            child: const Icon(Icons.addchart),
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              //TODO: NUEVA VENTANA AÑADIR FONDO POR ISIN
            },
          ),
        ],
      ),
    );
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
          print('ERROR GET DATAAPI');
          setState(() {
            _isUpdating = false;
            _msgUpdating = '';
          });
        }
      }
    } else {
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

  void _showMsg({
    required String msg,
    IconData icon = Icons.error_outline,
    MaterialColor color = Colors.red,
  }) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color),
      );
}
