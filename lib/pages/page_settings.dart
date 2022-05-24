import 'package:flutter/material.dart';

//import '../routes.dart';
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

  getSharedPrefs() async {
    await PreferencesService.getIsByOrder(kKeyByOrderCarterasPref).then((value) {
      setState(() => _isCarterasByOrder = value);
    });
    await PreferencesService.getIsByOrder(kKeyByOrderFondosPref).then((value) {
      setState(() => _isFondosByOrder = value);
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
          /*leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              //ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.of(context).pushNamed(RouteGenerator.homePage);
            },
          ),*/
          title: const Text('Ajustes'),
        ),
        drawer: const MyDrawer(),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Carteras ordenadas por nombre'),
              trailing: Switch(
                value: _isCarterasByOrder,
                onChanged: (value) {
                  setState(() => _isCarterasByOrder = value);
                  PreferencesService.saveIsByOrder(kKeyByOrderCarterasPref, value);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Fondos ordenados por nombre'),
              trailing: Switch(
                value: _isFondosByOrder,
                onChanged: (value) {
                  setState(() => _isFondosByOrder = value);
                  PreferencesService.saveIsByOrder(kKeyByOrderFondosPref, value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
