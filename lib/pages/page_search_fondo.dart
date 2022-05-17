import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/fondo.dart';

class PageSearchFondo extends StatefulWidget {
  const PageSearchFondo({Key? key}) : super(key: key);

  @override
  State<PageSearchFondo> createState() => _PageSearchFondoState();
}

class _PageSearchFondoState extends State<PageSearchFondo> {
  final List<Map<String, dynamic>> _allFondos = [];
  List<Map<String, dynamic>> _filterFondos = [];
  bool _isLoading = true;

  @override
  void initState() {
    readJson().whenComplete(() => _filterFondos = _allFondos);
    super.initState();
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/fondos.json');
    final data = await json.decode(response);
    for (var item in data) {
      _allFondos.add(item);
    }
    setState(() => _isLoading = false);
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    results = enteredKeyword.isEmpty
        ? _allFondos
        : _allFondos
            .where((fondo) =>
                fondo['name']?.toUpperCase().contains(enteredKeyword.toUpperCase()) ||
                fondo['isin']?.toUpperCase().contains(enteredKeyword.toUpperCase()))
            .toList();
    /*if (enteredKeyword.isEmpty) {
      results = _allFondos;
    } else {
      results = _allFondos
          .where((fondo) =>
              fondo['name']?.toUpperCase().contains(enteredKeyword.toUpperCase()) ||
              fondo['isin']?.toUpperCase().contains(enteredKeyword.toUpperCase()))
          .toList();
    }*/
    setState(() => _filterFondos = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Fondo')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) => _runFilter(value),
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Busca por ISIN o por nombre',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filterFondos.isNotEmpty
                      ? ListView.builder(
                          itemCount: _filterFondos.length,
                          itemBuilder: (context, index) => Card(
                            key: ValueKey(_filterFondos[index]['isin']),
                            color: Colors.amber,
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              title: Text(_filterFondos[index]['name']),
                              subtitle: Text(_filterFondos[index]['isin'].toString()),
                              onTap: () {
                                var fondo = Fondo(
                                    name: _filterFondos[index]['name'],
                                    isin: _filterFondos[index]['isin']);
                                Navigator.pop(context, fondo);
                              },
                            ),
                          ),
                        )
                      : const Text(
                          'No se ha encontrado coincidencia con ningún fondo.',
                          style: TextStyle(fontSize: 24),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
