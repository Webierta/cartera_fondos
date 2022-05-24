import 'package:flutter/material.dart';

import '../routes.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    'Cartera de Fondos de Inversión',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Text(
                  'Versión 1.0.0',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Text(
                  'Copyleft 2022',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  'Jesús Cuerda (Webierta)',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  'All Wrongs Reserved. Licencia GPLv3',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(RouteGenerator.homePage);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ajustes'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(RouteGenerator.settingsPage);
            },
          ),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Info'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(RouteGenerator.infoPage);
            },
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('About'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(RouteGenerator.aboutPage);
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_cafe_outlined),
            title: const Text('Donar'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Salir'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
