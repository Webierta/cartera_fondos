import 'package:flutter/material.dart';

import '../models/cartera.dart';
import '../routes.dart';
import '../services/sqlite_service.dart';
import '../widgets/my_drawer.dart';

class PageHome extends StatefulWidget {
  const PageHome({Key? key}) : super(key: key);

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late SqliteService _sqlite;
  late TextEditingController _controller;
  var carteras = <Cartera>[]; //List<Cartera> carteras = []

  _refreshCarteras() async {
    final data = await _sqlite.getCarteras();
    setState(() => carteras = data);
  }

  @override
  void initState() {
    _controller = TextEditingController();
    _sqlite = SqliteService();
    _sqlite.initDB().whenComplete(() async {
      await _refreshCarteras();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _carteraInput(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Nueva Cartera'),
            content: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Nombre',
                errorText: 'Nombre requerido',
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
                onPressed: () {
                  if (_controller.value.text.trim().isNotEmpty) {
                    _sqlite.insertCartera(Cartera(name: _controller.value.text));
                    _refreshCarteras();
                    _controller.clear();
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () {
                  for (var cartera in carteras) {
                    _sqlite.deleteCartera(cartera.name);
                  }
                  _refreshCarteras();
                  Navigator.of(context).pop();
                },
                child: const Text('ACEPTAR'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  primary: Colors.white,
                  //textStyle: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(child: Text('MIS CARTERAS')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
          PopupMenuButton<int>(
              color: Colors.blue,
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.sort_by_alpha),
                        SizedBox(width: 10),
                        Text('Por Nombre'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: const [
                        Icon(Icons.sort),
                        SizedBox(width: 10),
                        Text('Por Rentabilidad'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: 10),
                  PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: const [
                        Icon(Icons.save),
                        SizedBox(width: 10),
                        Text('Salvar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: Row(
                      children: const [
                        Icon(Icons.delete_forever),
                        SizedBox(width: 10),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 0) {
                  print('0');
                  _sqlite.orderByName(carteras);
                  _refreshCarteras();
                } else if (value == 1) {
                  print('1');
                } else if (value == 2) {
                  print('2');
                } else if (value == 3) {
                  print('3');
                  _deleteConfirm(context);
                  /*for (var cartera in carteras) {
                    _sqlite.deleteCartera(cartera.name);
                  }
                  _refreshCarteras();*/
                }
              }),
        ],
      ),
      drawer: const MyDrawer(),
      body: carteras.isNotEmpty
          ? ListView.builder(
              itemCount: carteras.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  child: Card(
                    child: ListTile(
                      // numero de fondos,
                      leading: const CircleAvatar(child: Text('5')),
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
                      onTap: () {
                        //Navigator.of(context).pushNamed(RouteGenerator.infoPage);
                        Navigator.of(context)
                            .pushNamed(RouteGenerator.carteraPage, arguments: carteras[index]);
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
                    _sqlite.deleteCartera(carteras[index].name);
                    _refreshCarteras();
                  },
                );
              },
            )
          : const Center(
              child: Text('No hay carteras guardadas.'),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _carteraInput(context);
        },
      ),
    );
  }
}