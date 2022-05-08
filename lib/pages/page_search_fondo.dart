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
  //late TextEditingController _controller;
  final List<Map<String, dynamic>> _allFondos = [];
  //List _items = [];
  List<Map<String, dynamic>> _filterFondos = [];
  bool _isLoading = true;

  @override
  void initState() {
    //_controller = TextEditingController();
    readJson();
    _filterFondos = _allFondos;
    super.initState();
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/fondos_all.json');
    final data = await json.decode(response);
    setState(() {
      for (var item in data) {
        _allFondos.add(item);
      }
      _isLoading = false;
    });
  }

  /*@override
  void dispose() {
    //_controller.dispose();
    super.dispose();
  }*/

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allFondos;
    } else {
      results = _allFondos
          .where((fondo) =>
              fondo['name']?.toUpperCase().contains(enteredKeyword.toUpperCase()) ||
              fondo['isin']?.toUpperCase().contains(enteredKeyword.toUpperCase()))
          .toList();
    }
    setState(() => _filterFondos = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Fondo'),
      ),
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
            // _filterFondos.isNotEmpty
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _filterFondos.isNotEmpty
                      ? ListView.builder(
                          itemCount: _filterFondos.length,
                          itemBuilder: (context, index) => Card(
                            key: ValueKey(_filterFondos[index]['isin']),
                            color: Colors.amberAccent,
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              /*leading: Text(
                            _filterFondos[index]["isin"].toString(),
                            style: const TextStyle(fontSize: 24),
                          ),*/
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
                          'No results found',
                          style: TextStyle(fontSize: 24),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: TextField(
              //controller: _controller,
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      //_controller.clear();
                    },
                  ),
                  hintText: 'Buscar...',
                  border: InputBorder.none),
            ),
          ),
        ),
      ),
      body: _foundUsers.isNotEmpty
          ? ListView.builder(
              itemCount: _foundUsers.length,
              itemBuilder: (context, index) => Card(
                key: ValueKey(_foundUsers[index]["id"]),
                color: Colors.amberAccent,
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Text(
                    _foundUsers[index]["id"].toString(),
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(_foundUsers[index]['name']),
                  subtitle: Text('${_foundUsers[index]["age"].toString()} years old'),
                ),
              ),
            )
          : const Text(
              'No results found',
              style: TextStyle(fontSize: 24),
            ),
    );
  }*/
}
