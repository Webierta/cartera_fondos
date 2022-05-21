import 'package:flutter/material.dart';

enum Menu { renombrar, ordenar, exportar, eliminar }
enum MenuCartera { ordenar, eliminar }
enum MenuFondo { editar, suscribir, reembolsar, eliminar, exportar }

class PopMenu<T> extends StatelessWidget {
  final T menu;
  final IconData iconData;
  final bool divider;
  const PopMenu({Key? key, required this.menu, required this.iconData, required this.divider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var name = (menu as Menu).name;
    return PopupMenuItem<T>(
      value: menu,
      child: Column(
        children: [
          ListTile(
            leading: Icon(iconData, color: Colors.white),
            title: Text(
              '${name[0].toUpperCase()}${name.substring(1)}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (divider) const Divider(height: 10, color: Colors.white), // PopMenuDivider
        ],
      ),
    );
  }
}
