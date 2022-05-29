import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/carfoin_provider.dart';
import '../routes.dart';
import '../services/preferences_service.dart';
import '../utils/k_constantes.dart';
import '../widgets/loading_progress.dart';
import '../widgets/my_drawer.dart';

enum Menu { renombrar, ordenar, exportar, eliminar }

class PageHome extends StatefulWidget {
  const PageHome({Key? key}) : super(key: key);
  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late CarfoinProvider carfoin;
  bool _isCarterasByOrder = false;
  late TextEditingController _controller;

  getSharedPrefs() async {
    await PreferencesService.getBool(kKeyByOrderCarterasPref).then((value) {
      setState(() => _isCarterasByOrder = value);
    });
  }

  @override
  void initState() {
    getSharedPrefs();
    _controller = TextEditingController();
    carfoin = context.read<CarfoinProvider>();
    carfoin.openDb().whenComplete(() async {
      await carfoin.updateDbCarteras(_isCarterasByOrder);
    });
    super.initState();
  }

  _ordenarCarteras() async {
    setState(() => _isCarterasByOrder = !_isCarterasByOrder);
    PreferencesService.saveBool(kKeyByOrderCarterasPref, _isCarterasByOrder);
    await carfoin.updateDbCarteras(_isCarterasByOrder);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PopupMenuItem<Menu> _buildMenuItem(Menu menu, IconData iconData, {bool divider = false}) {
    return PopupMenuItem(
      value: menu,
      child: Column(
        children: [
          ListTile(
            leading: Icon(iconData, color: const Color(0xFFFFFFFF)),
            title: Text(
              '${menu.name[0].toUpperCase()}${menu.name.substring(1)}',
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
            trailing: menu == Menu.ordenar
                ? Icon(
                    _isCarterasByOrder ? Icons.check_box : Icons.check_box_outline_blank,
                    color: const Color(0xFFFFFFFF),
                  )
                : null,
          ),
          if (divider == true) const Divider(color: Color(0xFFFFFFFF)), // PopMenuDivider
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carfoin = context.read<CarfoinProvider>();
    var carteras = context.watch<CarfoinProvider>().getCarteras;
    return FutureBuilder<bool>(
      future: carfoin.openDb(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // TODO: MANEJAR ESTO ?
          if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}', style: const TextStyle(fontSize: 18)),
            );
          } else if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: const FittedBox(child: Text('MIS CARTERAS')),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.of(context).pushNamed(RouteGenerator.settingsPage);
                    },
                  ),
                  PopupMenuButton(
                    color: Colors.blue,
                    offset: Offset(0.0, AppBar().preferredSize.height),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    itemBuilder: (ctx) => [
                      _buildMenuItem(Menu.renombrar, Icons.edit, divider: false),
                      _buildMenuItem(Menu.ordenar, Icons.sort_by_alpha, divider: true),
                      _buildMenuItem(Menu.exportar, Icons.save, divider: false),
                      _buildMenuItem(Menu.eliminar, Icons.delete_forever, divider: false),
                    ],
                    onSelected: (item) async {
                      //TODO: ACCIONES PENDIENTES
                      if (item == Menu.renombrar) {
                        print('RENAME');
                      } else if (item == Menu.ordenar) {
                        _ordenarCarteras();
                      } else if (item == Menu.exportar) {
                        print('EXPORTAR');
                      } else if (item == Menu.eliminar) {
                        _deleteConfirm(context);
                      }
                    },
                  ),
                ],
              ),
              drawer: const MyDrawer(),
              floatingActionButton: FloatingActionButton(
                backgroundColor: const Color(0xFFFFC107),
                child: const Icon(Icons.add, color: Color(0xFF0D47A1)),
                onPressed: () => _carteraInput(context),
              ),
              body: carteras.isEmpty
                  ? const Center(child: Text('No hay carteras guardadas.'))
                  : ListView.builder(
                      itemCount: carteras.length,
                      itemBuilder: (context, index) {
                        int nFondos = carfoin.getMapIdCarteraNFondos[carteras[index].id] ?? 0;
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: const Color(0xFFF44336),
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            alignment: Alignment.centerRight,
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(Icons.delete, color: Color(0xFFFFFFFF)),
                            ),
                          ),
                          onDismissed: (_) => _onDismissed(index),
                          child: Card(
                            child: ListTile(
                              //leading: const Icon(Icons.business_center, size: 32),
                              leading: Text('${carteras[index].id}'),
                              title: Text(carteras[index].name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  // TDO: RECUPERAR DATOS REALES
                                  Text('Inversión: 2.156,23 €'),
                                  Text('Valor (12/04/2019): 4.5215,14 €'),
                                  Text('Rendimiento: +2.345,32 €'),
                                  Text('Rentabilidad: 10 %'),
                                ],
                              ),
                              trailing: CircleAvatar(child: Text('$nFondos')),
                              onTap: () {
                                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                carfoin.setCartera = carteras[index];
                                Navigator.of(context).pushNamed(RouteGenerator.carteraPage);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            );
          }
        }
        return const LoadingProgress(titulo: 'Actualizando carteras...');
      },
    );
  }

  _onDismissed(int index) async {
    var carteras = carfoin.getCarteras;
    await carfoin.deleteCartera(carteras[index]);
    await carfoin.updateDbCarteras(_isCarterasByOrder);
  }

  Future<void> _carteraInput(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, TextEditingValue value, __) {
                  return SingleChildScrollView(
                    child: AlertDialog(
                      title: const Text('Nueva Cartera'),
                      content: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Nombre',
                          errorMaxLines: 4,
                          errorText: _errorText,
                        ),
                      ),
                      actions: <Widget>[
                        OutlinedButton(
                          child: const Text('CANCELAR'),
                          onPressed: () {
                            _controller.clear();
                            Navigator.pop(context);
                          },
                        ),
                        ElevatedButton(
                          onPressed: _controller.value.text.trim().isNotEmpty ? _submit : null,
                          child: const Text('ACEPTAR'),
                        ),
                      ],
                    ),
                  );
                });
          });
        });
  }

  String? get _errorText {
    final text = _controller.value.text.trim();
    if (text.isEmpty) {
      return 'Campo requerido';
    }
    /*if (text.startsWith('_')) {
      return 'Nombre no válido';
    }*/
    return null;
  }

  void _submit() async {
    if (_errorText == null) {
      var _input = _controller.value.text.trim();
      // INNECESARIO PORQUE NO SE ADMITEN ESTOS CARACTERES
      /*var _alpha = _input.replaceAll(RegExp('[^a-zA-Z0-9_]'), '');
      var _name = _alpha.startsWith(RegExp(r'[0-9]')) ? '_$_alpha' : _alpha;
      _controller.value.text.replaceAll(RegExp('[^a-zA-Z0-9_]'), '');*/
      var existe = [for (var cartera in carfoin.getCarteras) cartera.name].contains(_input);
      if (existe) {
        _controller.clear();
        _pop();
        _showMsg(msg: 'Ya existe una cartera con ese nombre.', color: Colors.red);
      } else {
        int id = await carfoin.insertCartera(_input);
        await carfoin.createTableCartera(id);
        await carfoin.updateDbCarteras(_isCarterasByOrder);
        _controller.clear();
        _pop();
      }
    }
  }

  void _deleteConfirm(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Eliminar todo'),
            content: const Text('Esto eliminará todas las carteras y sus fondos.'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCELAR'),
              ),
              ElevatedButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336),
                  primary: const Color(0xFFFFFFFF),
                ),
                onPressed: () async {
                  for (var cartera in carfoin.getCarteras) {
                    await carfoin.deleteCartera(cartera);
                  }
                  await carfoin.updateDbCarteras(_isCarterasByOrder);
                  _pop();
                },
                child: const Text('ACEPTAR'),
              ),
            ],
          );
        });
  }

  void _showMsg({required String msg, MaterialColor color = Colors.grey}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color),
      );

  void _pop() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    Navigator.of(context).pop();
  }
}
