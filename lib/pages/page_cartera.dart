import 'package:flutter/material.dart';

import '../models/cartera.dart';
import '../routes.dart';

class PageCartera extends StatefulWidget {
  final Cartera cartera;

  const PageCartera({Key? key, required this.cartera}) : super(key: key);

  @override
  State<PageCartera> createState() => _PageCarteraState();
}

class _PageCarteraState extends State<PageCartera> {
  String? _newFondo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cartera.name)),
      body: Text(_newFondo ?? 'Nada'),
      // body: lista de fondos (si hay)
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newFondo = await Navigator.of(context).pushNamed(RouteGenerator.inputFondo);
          setState(() {
            _newFondo = newFondo as String;
          });
          print(_newFondo);
          //_fondoInput(context);
        },
      ),
    );
  }
}
