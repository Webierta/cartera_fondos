import 'package:flutter/material.dart';

import '../models/cartera.dart';
import '../models/fondo.dart';
import '../routes.dart';
import '../services/sqlite_service.dart';

class PageCartera extends StatefulWidget {
  final Cartera cartera;

  const PageCartera({Key? key, required this.cartera}) : super(key: key);

  @override
  State<PageCartera> createState() => _PageCarteraState();
}

class _PageCarteraState extends State<PageCartera> {
  // Fondo? _newFondo;
  late SqliteService _sqlite;
  var fondos = <Fondo>[];
  bool _fondoRepe = false;

  _refreshFondos() async {
    final data = await _sqlite.getFondos(widget.cartera);
    setState(() => fondos = data);
  }

  @override
  void initState() {
    _sqlite = SqliteService();
    _sqlite.initDB().whenComplete(() async {
      await _refreshFondos();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        //titleSpacing: 0.0,

        /*title: Row(
          children: [
            const Icon(Icons.business_center),
            const SizedBox(width: 10),
            Text(widget.cartera.name),
          ],
        ),*/
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _refreshFondos();
            //ScaffoldMessenger.of(context).clearMaterialBanners();
            //ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            Navigator.of(context).pushNamed(RouteGenerator.homePage);
          },
        ),
        title: Text(widget.cartera.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // actualizar todos los fondos de la cartera
            },
          ),
        ],
      ),
      body: fondos.isNotEmpty
          ? ListView.builder(
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
                      onTap: () {
                        //ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
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
                    //_sqlite.deleteCartera(carteras[index].name);
                    //_refreshCarteras();
                    _sqlite.deleteFondo(widget.cartera, fondos[index]);
                    _refreshFondos();
                  },
                );
              },
            )
          /*? Card(
              child: ListTile(
                title: Text(_newFondo?.name ?? 'Nada'),
                subtitle: Text(_newFondo?.isin ?? 'No ISIN'),
              ),
            )*/
          : const Center(
              child: Text('No hay fondos guardados.'),
            ),
      //Text(_newFondo.name ?? 'Nada'),
      // body: lista de fondos (si hay)
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        children: [
          FloatingActionButton(
            heroTag: 'searchFondo',
            child: const Icon(Icons.search),
            onPressed: () async {
              //ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              final newFondo = await Navigator.of(context).pushNamed(RouteGenerator.inputFondo);
              if (newFondo != null) {
                for (var fondo in fondos) {
                  if (fondo.isin == (newFondo as Fondo).isin) {
                    //_show(context, (newFondo).isin);
                    //_showBanner(msg: 'El fondo con ISIN ${fondo.isin} ya existe en esta cartera.');
                    _showMsg(msg: 'El fondo con ISIN ${fondo.isin} ya existe en esta cartera.');
                    setState(() => _fondoRepe = true);
                    break;
                  } else {
                    setState(() => _fondoRepe = false);
                  }
                }
                if (_fondoRepe == false) {
                  //setState(() => _newFondo = newFondo as Fondo);
                  ////_sqlite.createTableCartera(widget.cartera);
                  //_sqlite.insertFondo(widget.cartera, _newFondo as Fondo);
                  _sqlite.insertFondo(widget.cartera, newFondo as Fondo);
                  _refreshFondos();

                  //_sqlite.createTableFondo(newFondo);

                  _showMsg(msg: 'Fondo añadido', icon: Icons.task_alt, color: Colors.blue);
                  //_showMsg(true);
                }
              } else {
                _showMsg(msg: 'Error al añadir el fondo');
                //_showMsg(false);
              }
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'addFondo',
            child: const Icon(Icons.addchart),
            onPressed: () {
              //ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
              //ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
            },
          ),
        ],
      ),
    );
  }

  /*void _showBanner({
    required String msg,
    IconData icon = Icons.error_outline,
    MaterialColor color = Colors.red,
  }) {
    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
    ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
      content: Text(msg),
      leading: Icon(icon),
      contentTextStyle: TextStyle(
        fontSize: 18,
        color: color,
        fontStyle: FontStyle.italic,
      ),
      actions: [
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () {
            ScaffoldMessenger.of(context).clearMaterialBanners();
          },
        ),
      ],
    ));
  }*/

  void _showMsg({
    required String msg,
    IconData icon = Icons.error_outline,
    MaterialColor color = Colors.red,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
    ));
  }
/*
  void _show(BuildContext ctx, String isin) {
    showDialog(
      context: ctx,
      builder: (context) {
        return Center(
          child: AlertDialog(
            title: const Text('Fondo repetido'),
            content: SingleChildScrollView(
              child: Text('El fondo con ISIN $isin ya existe en esta cartera.'),
            ),
            actions: [
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      },
    );
  }*/
}
