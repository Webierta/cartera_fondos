import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:provider/provider.dart';

import '../models/cartera.dart';
import '../models/fondo.dart';
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
  bool _validText = false;
  var carteras = <Cartera>[]; //List<Cartera> carteras = []
  bool _isLoading = true;
  var fondos = <Fondo>[];
  Map<String, List<Fondo>> mapCarteras = {};

  _refreshCarteras() async {
    final data = await _sqlite.getCarteras();
    setState(() => carteras = data);
    for (var cartera in carteras) {
      _refreshFondos(cartera);
    }
  }

  _refreshFondos(Cartera cartera) async {
    final data = await _sqlite.getFondos(cartera);
    setState(() {
      fondos = data;
      mapCarteras[cartera.name] = fondos;
      _isLoading = false;
    });
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
                    onPressed: () {
                      //TODO: await en sqlite ??
                      if (_controller.value.text.trim().isNotEmpty) {
                        var _input = _controller.value.text;
                        /*INNECESARIO PORQUE NO SE ADMITEN ESTOS CARACTERES
                        var _alpha = _input.replaceAll(RegExp('[^a-zA-Z0-9_]'), '');
                        var _name = _alpha.startsWith(RegExp(r'[0-9]')) ? '_$_alpha' : _alpha;
                        _controller.value.text.replaceAll(RegExp('[^a-zA-Z0-9_]'), '');*/
                        _sqlite.insertCartera(Cartera(name: _input));
                        _sqlite.createTableCartera(Cartera(name: _input));
                        _refreshCarteras();
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () {
                  for (var cartera in carteras) {
                    _sqlite.deleteCartera(cartera);
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
            onPressed: () {
              _refreshCarteras();
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
                }
              }),
        ],
      ),
      drawer: const MyDrawer(),
      //carteras.isNotEmpty
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : carteras.isNotEmpty
              ? ListView.builder(
                  itemCount: carteras.length,
                  itemBuilder: (context, index) {
                    /*int numberFondos;
                var dataNumber = _sqlite.getNumberFondos(carteras[index]) ?? 0;
                setState(() {
                  numberFondos = dataNumber as int;
                });*/
                    //_getNFondos(carteras[index]);
                    //print(nFondos);
                    //int n = await _sqlite.getNumberFondos(carteras[index]);
                    //print(n);
                    int nFondos = mapCarteras[carteras[index].name]?.length ?? 0;
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      child: Card(
                        child: ListTile(
                          // numero de fondos,
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
                          onTap: () {
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
                        _sqlite.deleteCartera(carteras[index]);
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

  /*Future<void> _getNFondos(Cartera cartera) async {
    int number;
    var data = await _sqlite.getNumberFondos(cartera);
    number = data ?? 0;
    setState(() {
      numberFondos = number;
    });
    //return number;
  }*/
}
