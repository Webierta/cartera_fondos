import 'package:flutter/material.dart';

//import '../routes.dart';
import '../routes.dart';
import '../services/preferences_service.dart';
import '../utils/k_constantes.dart';
import '../widgets/my_drawer.dart';

class PageSettings extends StatefulWidget {
  const PageSettings({Key? key}) : super(key: key);

  @override
  State<PageSettings> createState() => _PageSettingsState();
}

class _PageSettingsState extends State<PageSettings> {
  bool _isCarterasByOrder = false;
  bool _isFondosByOrder = false;
  bool _isAutoUpdate = true;

  getSharedPrefs() async {
    await PreferencesService.getBool(kKeyByOrderCarterasPref).then((value) {
      setState(() => _isCarterasByOrder = value);
    });
    await PreferencesService.getBool(kKeyByOrderFondosPref).then((value) {
      setState(() => _isFondosByOrder = value);
    });
    await PreferencesService.getBool(kKeyAutoUpdatePref).then((value) {
      setState(() => _isAutoUpdate = value);
    });
  }

  @override
  void initState() {
    getSharedPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                Navigator.of(context).pushNamed(RouteGenerator.homePage);
              },
            ),
          ],
          /* leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.of(context).pushNamed(RouteGenerator.homePage);
            },
          ),*/
          title: const Text('Ajustes'),
        ),
        drawer: const MyDrawer(),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          children: [
            const Text('Carteras'),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Carteras ordenadas por nombre'),
              trailing: Switch(
                value: _isCarterasByOrder,
                onChanged: (value) {
                  setState(() => _isCarterasByOrder = value);
                  PreferencesService.saveBool(kKeyByOrderCarterasPref, value);
                },
              ),
            ),
            const Divider(color: Colors.grey, height: 20),
            const Text('Fondos'),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Fondos ordenados por nombre'),
              subtitle: const Text('Por defecto se ordenan por fecha de creación o actualización'),
              trailing: Switch(
                value: _isFondosByOrder,
                onChanged: (value) {
                  setState(() => _isFondosByOrder = value);
                  PreferencesService.saveBool(kKeyByOrderFondosPref, value);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Actualizar último valor al añadir Fondo'),
              subtitle: const Text('Recomendado para obtener la divisa del fondo'),
              trailing: Switch(
                value: _isAutoUpdate,
                onChanged: (value) {
                  setState(() => _isAutoUpdate = value);
                  PreferencesService.saveBool(kKeyAutoUpdatePref, value);
                },
              ),
            ),
            const Divider(color: Colors.grey, height: 20),
          ],
        ),
      ),
    );
  }
}
