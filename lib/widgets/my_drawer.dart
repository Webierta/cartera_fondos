import 'package:flutter/material.dart';

import '../routes.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    //color: Colors.blue,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/drawer_header.png'),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.7,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            'CARFOIN',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: const Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w100,
                                ),
                          ),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.7,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            'CARTERA DE FONDOS DE INVERSIÓN',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: const Color(0xFFFFFFFF)),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Copyleft 2022',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: const Color(0xFFFFFFFF)),
                      ),
                      Text(
                        'Jesús Cuerda (Webierta)',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: const Color(0xFFFFFFFF)),
                      ),
                      Text(
                        'All Wrongs Reserved. Licencia GPLv3',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: const Color(0xFFFFFFFF)),
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
                const AboutListTile(
                  icon: Icon(Icons.code),
                  child: Text('About app'),
                  applicationIcon: Icon(Icons.local_play),
                  applicationName: 'My Cool App',
                  applicationVersion: '1.0.25',
                  applicationLegalese: '© 2022 Company',
                  aboutBoxChildren: [
                    ///Content goes here...
                  ],
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
          ),
          /*Container(
            color: Colors.black,
            width: double.infinity,
            height: 0.1,
          ),*/
          const Divider(color: Colors.grey),
          Container(
            padding: const EdgeInsets.all(10),
            child: Text('Versión 1.0.0', style: Theme.of(context).textTheme.labelSmall),
          ),
        ],
      ),
    );
  }
}
