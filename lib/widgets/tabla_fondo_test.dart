import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:intl/intl.dart';

import '../models/carfoin_provider.dart';
import '../models/valor.dart';
import '../utils/fecha_util.dart';

class TablaFondoTest extends StatefulWidget {
  const TablaFondoTest({Key? key}) : super(key: key);

  @override
  State<TablaFondoTest> createState() => _TablaFondoTestState();
}
//TODO OBTENER VALORES DESDE AQUI??

class _TablaFondoTestState extends State<TablaFondoTest> {
  bool _isSortDesc = true;

  @override
  Widget build(BuildContext context) {
    final valoresOn = context.read<CarfoinProvider>().getValores;

    Text _diferencia(Valor valor) {
      int index = _isSortDesc ? 1 : -1;
      bool condition = _isSortDesc
          ? valoresOn.length > (valoresOn.indexOf(valor) + 1)
          : valoresOn.length > (valoresOn.indexOf(valor) - 1) && valoresOn.indexOf(valor) > 0;

      if (condition) {
        var dif = valor.precio - valoresOn[valoresOn.indexOf(valor) + index].precio;
        return Text(
          dif.toStringAsFixed(2),
          textAlign: TextAlign.center,
          style: TextStyle(color: dif < 0 ? const Color(0xFFF44336) : const Color(0xFF4CAF50)),
        );
      }
      return const Text('');
    }

    _buildHeaderValue(int index) {
      return Row(
        children: [
          Expanded(
              flex: 1,
              child: Text(
                _isSortDesc ? '${valoresOn.length - index}' : '${index + 1}',
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: 3,
              child: Text(
                //_epochFormat(valoresCopy[index].date),
                FechaUtil.epochToString(valoresOn[index].date),
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: 3,
              child: Text(
                '${valoresOn[index].precio}',
                textAlign: TextAlign.center,
              )),
          Expanded(
            flex: 2,
            child: _diferencia(valoresOn[index]),
          ),
        ],
      );
    }

    _buildExpandedValue(int index) {
      return Row(
        children: [
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                print('EDITAR');
              }),
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                print('ELLIMINAR');
              }),
        ],
      );
    }

    List<Item> generateItems(int itemCount) {
      return List<Item>.generate(itemCount, (int index) {
        return Item(
          headerValue: _buildHeaderValue(index),
          expandedValue: _buildExpandedValue(index),
        );
      });
    }

    final List<Item> _data = generateItems(valoresOn.length);

    _changeSort() {
      //setState(() {
      if (!_isSortDesc) {
        valoresOn.sort((a, b) => b.date.compareTo(a.date));
      } else {
        valoresOn.sort((a, b) => a.date.compareTo(b.date));
      }
      setState(() => _isSortDesc = !_isSortDesc);
      //});
    }

    //final valoresCopy = context.read<CarfoinProvider>().getValores;
    return valoresOn.isEmpty
        ? const Center(child: Text('Sin datos'))
        : Column(
            children: [
              Container(
                color: const Color(0xFFFFC107),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.swap_vert),
                          onPressed: () => _changeSort(),
                        )),
                    const Expanded(
                        flex: 3,
                        child: Text(
                          'FECHA',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    const Expanded(
                        flex: 3,
                        child: Text(
                          'PRECIO',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    const Expanded(
                        flex: 2,
                        child: Text(
                          '+/-',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    const Expanded(
                      flex: 1,
                      child: Text(''),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  child: ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        //_data[index].isExpanded = !isExpanded;
                        //_data[index].isExpanded = !_data[index].isExpanded;
                        _data[index].isExpanded = true;
                      });
                    },
                    children: _data.map((Item item) {
                      return ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return _buildHeaderValue(_data.indexOf(item));
                        },
                        body: const Text('EDITAR O ELIMINAR'),
                        //_buildExpandedValue(_data.indexOf(item)),
                        isExpanded: item.isExpanded,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
  }
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  Widget expandedValue;
  Widget headerValue;
  bool isExpanded;
}
