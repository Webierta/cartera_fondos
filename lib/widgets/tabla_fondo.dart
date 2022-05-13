import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/valor.dart';

class TablaFondo extends StatefulWidget {
  final List<Valor> valores;
  const TablaFondo({Key? key, required this.valores}) : super(key: key);

  @override
  State<TablaFondo> createState() => _TablaFondoState();
}
//TODO OBTENER VALORES DESDE AQUI??

class _TablaFondoState extends State<TablaFondo> {
  var valoresCopy = <Valor>[];
  int _currentSortColumn = 0;
  bool _isSortAsc = true;

  @override
  void initState() {
    valoresCopy = [...widget.valores];
    super.initState();
  }

  String _epochFormat(int epoch) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    final DateFormat formatter = DateFormat('dd/MM/yy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return widget.valores.isEmpty
        ? const Center(child: Text('Sin datos'))
        : ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortColumnIndex: _currentSortColumn,
                  sortAscending: _isSortAsc,
                  columnSpacing: 30,
                  //horizontalMargin: 0,
                  columns: [
                    DataColumn(
                        label: const Text('#'),
                        numeric: true,
                        onSort: (columnIndex, _) {
                          setState(() {
                            _currentSortColumn = columnIndex;
                            if (!_isSortAsc) {
                              valoresCopy.sort((a, b) => b.date.compareTo(a.date));
                            } else {
                              valoresCopy.sort((a, b) => a.date.compareTo(b.date));
                            }
                            _isSortAsc = !_isSortAsc;
                          });
                        }),
                    const DataColumn(label: Text('FECHA'), numeric: true),
                    const DataColumn(label: Text('PRECIO'), numeric: true),
                    const DataColumn(label: Text('+/-'), numeric: true),
                  ],
                  rows: [
                    for (var valor in valoresCopy)
                      DataRow(
                        cells: [
                          //DataCell(Text('${valores.indexOf(valor)}')),
                          DataCell(_isSortAsc
                              ? Text('${valoresCopy.length - valoresCopy.indexOf(valor)}')
                              : Text('${valoresCopy.indexOf(valor) + 1}')),
                          DataCell(Text(_epochFormat(valor.date))),
                          //TODO: control número de decimales: máx 5
                          DataCell(Text('${valor.precio}')),
                          _isSortAsc
                              ? DataCell(valoresCopy.length > (valoresCopy.indexOf(valor) + 1)
                                  ? Text(
                                      (valor.precio -
                                              valoresCopy[valoresCopy.indexOf(valor) + 1].precio)
                                          .toStringAsFixed(2),
                                      style: TextStyle(
                                        color: valor.precio -
                                                    valoresCopy[valoresCopy.indexOf(valor) + 1]
                                                        .precio <
                                                0
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    )
                                  : const Text(''))
                              : DataCell(valoresCopy.length > (valoresCopy.indexOf(valor) - 1) &&
                                      valoresCopy.indexOf(valor) > 0
                                  ? Text(
                                      (valoresCopy[valoresCopy.indexOf(valor) - 1].precio -
                                              valor.precio)
                                          .toStringAsFixed(2),
                                      style: valoresCopy[valoresCopy.indexOf(valor) - 1].precio -
                                                  valor.precio <
                                              0
                                          ? const TextStyle(color: Colors.red)
                                          : const TextStyle(color: Colors.green),
                                    )
                                  : const Text('')),
                        ],
                      )
                  ],
                  /*rows: valoresCopy
                      .map((valor) => DataRow(cells: [
                            //DataCell(Text('${valores.indexOf(valor)}')),
                            DataCell(_isSortAsc
                                ? Text('${valoresCopy.length - valoresCopy.indexOf(valor)}')
                                : Text('${valoresCopy.indexOf(valor) + 1}')),
                            DataCell(Text(_epochFormat(valor.date))),
                            //TODO: control número de decimales: máx 5
                            DataCell(Text('${valor.precio}')),
                            _isSortAsc
                                ? DataCell(valoresCopy.length > (valoresCopy.indexOf(valor) + 1)
                                    ? Text(
                                        (valor.precio -
                                                valoresCopy[valoresCopy.indexOf(valor) + 1].precio)
                                            .toStringAsFixed(2),
                                        style: valor.precio -
                                                    valoresCopy[valoresCopy.indexOf(valor) + 1]
                                                        .precio <
                                                0
                                            ? const TextStyle(color: Colors.red)
                                            : const TextStyle(color: Colors.green),
                                      )
                                    : const Text(''))
                                : DataCell(valoresCopy.length > (valoresCopy.indexOf(valor) - 1) &&
                                        valoresCopy.indexOf(valor) > 0
                                    ? Text(
                                        (valoresCopy[valoresCopy.indexOf(valor) - 1].precio -
                                                valor.precio)
                                            .toStringAsFixed(2),
                                        style: valoresCopy[valoresCopy.indexOf(valor) - 1].precio -
                                                    valor.precio <
                                                0
                                            ? const TextStyle(color: Colors.red)
                                            : const TextStyle(color: Colors.green),
                                      )
                                    : const Text('')),
                          ]))
                      .toList(),*/
                ),
              )
            ],
          );
  }
}
