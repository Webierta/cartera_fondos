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
  Fondo? _newFondo;
  late SqliteService _sqlite;
  var fondos = <Fondo>[];

  _refreshFondos(Cartera cartera) async {
    final data = await _sqlite.getFondos(cartera);
    setState(() => fondos = data);
  }

  @override
  void initState() {
    _sqlite = SqliteService();
    _sqlite.initDB().whenComplete(() async {
      await _refreshFondos(widget.cartera);
    });
    super.initState();
  }

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cartera.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _refreshFondos(widget.cartera);
            Navigator.of(context).pushNamed(RouteGenerator.homePage);
          },
        ),
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
                        // ir a detalle de fondo: page_fondo
                        Navigator.of(context)
                            .pushNamed(RouteGenerator.fondoPage, arguments: fondos[index]);
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
                    _refreshFondos(widget.cartera);
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
            heroTag: 'edit',
            child: const Icon(Icons.search),
            onPressed: () async {
              final newFondo = await Navigator.of(context).pushNamed(RouteGenerator.inputFondo);
              //TODO: check exists fondo

              if (newFondo != null) {
                for (var fondo in fondos) {
                  if (fondo.isin == (newFondo as Fondo).isin) {
                    _show(context, (newFondo as Fondo).isin);
                    _newFondo = null;
                    break;
                  }
                }
                if (_newFondo != null) {
                  setState(() => _newFondo = newFondo as Fondo);
                  //_sqlite.createTableCartera(widget.cartera);
                  _sqlite.insertFondo(widget.cartera, _newFondo as Fondo);
                  _refreshFondos(widget.cartera);
                }
              }
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'search',
            child: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
