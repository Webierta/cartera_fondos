import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cartera.dart';
import '../models/fondo.dart';
import '../routes.dart';
import '../services/sqlite_service.dart';
import '../widgets/my_drawer.dart';

enum ItemMenu { sortAlpha, exportar, eliminar }

class PageHome extends StatefulWidget {
  const PageHome({Key? key}) : super(key: key);

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late SqliteService _sqlite;

  late TextEditingController _controller;
  bool _validText = false;

  var carteras = <Cartera>[];
  var fondos = <Fondo>[];
  Map<String, List<Fondo>> mapCarteraFondos = {};

  bool _isLoading = true;

  @override
  void initState() {
    _controller = TextEditingController();
    _sqlite = SqliteService();
    _sqlite.initDB().whenComplete(() async {
      await _refreshCarteras();
      _isLoading = false;
    });
    super.initState();
  }

  _refreshCarteras() async {
    final data = await _sqlite.getCarteras();
    setState(() => carteras = data);
    for (var cartera in carteras) {
      await _refreshFondos(cartera);
    }
  }

  _refreshFondos(Cartera cartera) async {
    final data = await _sqlite.getFondos(cartera);
    setState(() {
      fondos = data;
      mapCarteraFondos[cartera.name] = fondos;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PopupMenuItem _buildPopupMenuItem(String title, IconData iconData, int position) {
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
          if (position == 0)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: PopupMenuDivider(height: 10),
            ),
        ],
      ),
    );
  }

  _onMenuItemSelected(int value) {
    if (value == ItemMenu.sortAlpha.index) {
      _sqlite.orderByName(carteras);
      _refreshCarteras();
    } else if (value == ItemMenu.exportar.index) {
      print('EXPORTAR');
    } else if (value == ItemMenu.eliminar.index) {
      _deleteConfirm(context);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(child: Text('MIS CARTERAS')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshCarteras(),
          ),
          PopupMenuButton(
            onSelected: (value) => _onMenuItemSelected(value as int),
            color: Colors.blue,
            offset: Offset(0.0, AppBar().preferredSize.height),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            itemBuilder: (ctx) => [
              _buildPopupMenuItem('Por Nombre', Icons.sort_by_alpha, ItemMenu.sortAlpha.index),
              //_buildPopupMenuItem('Por Rentabilidad', Icons.sort, Options.sort.index),
              _buildPopupMenuItem('Exportar', Icons.save, ItemMenu.exportar.index),
              _buildPopupMenuItem('Eliminar', Icons.delete_forever, ItemMenu.eliminar.index),
            ],
          )
        ],
      ),
      drawer: const MyDrawer(),
      body: _isLoading
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Recuperando carteras...'),
              ],
            ))
          : carteras.isNotEmpty
              ? ListView.builder(
                  itemCount: carteras.length,
                  itemBuilder: (context, index) {
                    int nFondos = mapCarteraFondos[carteras[index].name]?.length ?? 0;
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.business_center_sharp, size: 32),
                          title: Text(carteras[index].name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Inversión: 2.156,23 €'),
                              Text('Valor (12/04/2019): 4.5215,14 €'),
                              Text('Rendimiento: +2.345,32 €'),
                              Text('Rentabilidad: 10 %'),
                            ],
                          ),
                          trailing: CircleAvatar(child: Text('$nFondos')),
                          onTap: () => Navigator.of(context).pushNamed(
                            RouteGenerator.carteraPage,
                            arguments: carteras[index],
                          ),
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
                      onDismissed: (_) async {
                        await _deleteCartera(carteras[index]);
                        await _refreshCarteras();
                      },
                    );
                  },
                )
              : const Center(child: Text('No hay carteras guardadas.')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _carteraInput(context),
      ),
    );
  }

  Future<void> _carteraInput(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: const Text('Nueva Cartera'),
                content: TextField(
                  controller: _controller,
                  onChanged: (text) {
                    setState(() {
                      if (text.isNotEmpty) {
                        _validText = true;
                      } else {
                        _validText = false;
                      }
                    });
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                    FilteringTextInputFormatter.deny(RegExp(r'^[0-9]+')),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Nombre',
                    errorMaxLines: 4,
                    errorText: 'Nombre requerido. No debe empezar por un número.'
                        'No admite caracteres de puntuación ni símbolos.',
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('CANCELAR'),
                    onPressed: () {
                      _controller.clear();
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: const Text('ACEPTAR'),
                    style: TextButton.styleFrom(
                      backgroundColor: _validText ? Colors.blue : Colors.grey,
                      primary: Colors.white,
                      //textStyle: const TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      //TODO: await en sqlite ??
                      if (_controller.value.text.trim().isNotEmpty) {
                        var _input = _controller.value.text;
                        /* INNECESARIO PORQUE NO SE ADMITEN ESTOS CARACTERES
                        var _alpha = _input.replaceAll(RegExp('[^a-zA-Z0-9_]'), '');
                        var _name = _alpha.startsWith(RegExp(r'[0-9]')) ? '_$_alpha' : _alpha;
                        _controller.value.text.replaceAll(RegExp('[^a-zA-Z0-9_]'), '');*/
                        await _sqlite.insertCartera(Cartera(name: _input));
                        await _sqlite.createTableCartera(Cartera(name: _input));
                        await _refreshCarteras();
                        _controller.clear();
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            );
          });
        });
  }

  void _deleteConfirm(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Eliminar todo'),
            content: const Text('Esto eliminará todas las carteras y sus fondos.'),
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
                  for (var cartera in carteras) {
                    await _deleteCartera(cartera);
                  }
                  await _refreshCarteras();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _deleteCartera(Cartera cartera) async {
    List<Fondo> allFondosCartera = await _sqlite.getFondos(cartera);
    if (allFondosCartera.isNotEmpty) {
      for (var fondo in allFondosCartera) {
        await _sqlite.deleteAllValoresInFondo(cartera, fondo);
      }
    }
    await _sqlite.deleteAllFondosInCartera(cartera);
    await _sqlite.deleteCarteraInCarteras(cartera);
    //await _refreshCarteras();
  }
}
