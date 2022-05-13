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
  bool _isSortDesc = true;

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

  _changeSort() {
    setState(() {
      if (!_isSortDesc) {
        valoresCopy.sort((a, b) => b.date.compareTo(a.date));
      } else {
        valoresCopy.sort((a, b) => a.date.compareTo(b.date));
      }
      _isSortDesc = !_isSortDesc;
    });
  }

  /*DataCell(valoresCopy.length > (valoresCopy.indexOf(valor) + 1)
    ? Text(
      (valor.precio - valoresCopy[valoresCopy.indexOf(valor) + 1].precio.toStringAsFixed(2),
      style: TextStyle(
        color: valor.precio -
        valoresCopy[valoresCopy.indexOf(valor) + 1].precio < 0
          ? Colors.red
          : Colors.green,
      ),
      )
    : const Text(''))*/

  Text _diferencia(Valor valor) {
    //TODO: depende si está ordenada ASC (+1) o DESC (-1)
    if (_isSortDesc) {
      if (valoresCopy.length > (valoresCopy.indexOf(valor) + 1)) {
        var dif = valor.precio - valoresCopy[valoresCopy.indexOf(valor) + 1].precio;
        return Text(
          dif.toStringAsFixed(2),
          textAlign: TextAlign.center,
          style: TextStyle(color: dif < 0 ? Colors.red : Colors.green),
        );
      }
      return const Text('');
    } else {
      if (valoresCopy.length > (valoresCopy.indexOf(valor) - 1) && valoresCopy.indexOf(valor) > 0) {
        var dif = valor.precio - valoresCopy[valoresCopy.indexOf(valor) - 1].precio;
        return Text(
          dif.toStringAsFixed(2),
          textAlign: TextAlign.center,
          style: TextStyle(color: dif < 0 ? Colors.red : Colors.green),
        );
      }
      return const Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return valoresCopy.isEmpty
        ? const Center(child: Text('Sin datos'))
        : Column(
            children: [
              Container(
                color: Colors.amber,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: const Icon(Icons.swap_vert),
                        onPressed: () => _changeSort(),
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: Text(
                        'FECHA',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Expanded(
                        flex: 1,
                        child: Text(
                          'PRECIO',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    const Expanded(
                        flex: 1,
                        child: Text(
                          '+/-',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 14),
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.grey, height: 24, indent: 10, endIndent: 10),
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: valoresCopy.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            _isSortDesc ? '${valoresCopy.length - index}' : '$index',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            _epochFormat(valoresCopy[index].date),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Text(
                              '${valoresCopy[index].precio}',
                              textAlign: TextAlign.center,
                            )),
                        Expanded(flex: 1, child: _diferencia(valoresCopy[index])),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
  }

  /*@override
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
                ),
              )
            ],
          );
  }*/
}
