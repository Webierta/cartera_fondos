import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:intl/intl.dart';

import '../models/carfoin_provider.dart';
import '../models/valor.dart';
import '../utils/fecha_util.dart';

class TablaFondo extends StatefulWidget {
  const TablaFondo({Key? key}) : super(key: key);

  @override
  State<TablaFondo> createState() => _TablaFondoState();
}
//TODO OBTENER VALORES DESDE AQUI??

class _TablaFondoState extends State<TablaFondo> {
  //var valoresOn = <Valor>[];
  bool _isSortDesc = true;

  /*@override
  void initState() {
    //final valoresOn = context.read<CarfoinProvider>().getValores;
    //valoresCopy = [...valoresOn];
    valoresOn = context.read<CarfoinProvider>().getValores;
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    final valoresOn = context.read<CarfoinProvider>().getValores;

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
                        flex: 2,
                        child: Text(
                          'FECHA',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
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
                  separatorBuilder: (context, index) => const Divider(
                      color: Color(0xFF9E9E9E), height: 24, indent: 10, endIndent: 10),
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: valoresOn.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text(
                              _isSortDesc ? '${valoresOn.length - index}' : '${index + 1}',
                              textAlign: TextAlign.center,
                            )),
                        Expanded(
                            flex: 2,
                            child: Text(
                              //_epochFormat(valoresCopy[index].date),
                              FechaUtil.epochToString(valoresOn[index].date),
                              textAlign: TextAlign.center,
                            )),
                        Expanded(
                            flex: 1,
                            child: Text(
                              '${valoresOn[index].precio}',
                              textAlign: TextAlign.center,
                            )),
                        Expanded(flex: 1, child: _diferencia(valoresOn[index])),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
  }
}
