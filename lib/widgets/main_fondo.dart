import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/valor.dart';
import '../routes.dart';
import '../models/carfoin_provider.dart';
import '../utils/fecha_util.dart';

class MainFondo extends StatelessWidget {
  const MainFondo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: PROVIDER carfoin ????
    //final carteraOn = context.read<CarfoinProvider>().getCartera;
    final carfoin = context.read<CarfoinProvider>();
    final fondoOn = context.watch<CarfoinProvider>().getFondo!;
    final valoresOn = context.watch<CarfoinProvider>().getValores;
    final operacionesOn = context.watch<CarfoinProvider>().getOperaciones;

    double? _getDiferencia() {
      if (valoresOn.length > 1) {
        var last = valoresOn.first.precio;
        var prev = valoresOn[1].precio;
        return last - prev;
      }
      return null;
    }

    double _getPrecioMin() {
      if (valoresOn.length < 2) {
        return 0.0;
      }
      final List<double> precios = valoresOn.reversed.map((entry) => entry.precio).toList();
      return precios.reduce((curr, next) => curr < next ? curr : next);
    }

    double _getPrecioMax() {
      if (valoresOn.length < 2) {
        return 0.0;
      }
      final List<double> precios = valoresOn.reversed.map((entry) => entry.precio).toList();
      return precios.reduce((curr, next) => curr > next ? curr : next);
    }

    String _getFechaMin() {
      if (valoresOn.length < 2) {
        return '';
      }
      final List<double> precios = valoresOn.reversed.map((entry) => entry.precio).toList();
      final List<int> fechas = valoresOn.reversed.map((entry) => entry.date).toList();
      return FechaUtil.epochToString(fechas[precios.indexOf(_getPrecioMin())], formato: 'dd/MM/yy');
    }

    String _getFechaMax() {
      if (valoresOn.length < 2) {
        return '';
      }
      final List<double> precios = valoresOn.reversed.map((entry) => entry.precio).toList();
      final List<int> fechas = valoresOn.reversed.map((entry) => entry.date).toList();
      return FechaUtil.epochToString(fechas[precios.indexOf(_getPrecioMax())], formato: 'dd/MM/yy');
    }

    double _getPrecioMedio() {
      if (valoresOn.length < 2) {
        return 0.0;
      }
      final List<double> precios = valoresOn.reversed.map((entry) => entry.precio).toList();
      return precios.reduce((a, b) => a + b) / precios.length;
    }

    double _getVolatilidad() {
      if (valoresOn.length < 2) {
        return 0.0;
      }
      var suma = 0.0;
      for (var valor in valoresOn) {
        suma += valor.precio;
      }
      var media = suma / valoresOn.length;
      var diferencialesCuadrados = 0.0;
      for (var valor in valoresOn) {
        //diferencialesCuadrados += pow(valor.precio - media, 2);
        diferencialesCuadrados += (valor.precio - media) * (valor.precio - media);
      }
      var varianza = diferencialesCuadrados / valoresOn.length;
      return sqrt(varianza);
    }

    double _getInversion() {
      if (operacionesOn.isEmpty) {
        return 0.0;
      }
      //var compras = <Operacion>[];
      //var ventas = <Operacion>[];
      var importeCompras = 0.0;
      var importeVentas = 0.0;
      for (var op in operacionesOn) {
        if (op.tipo == 1) {
          //compras.add(op);
          importeCompras += (op.precio * op.participaciones);
        } else {
          //ventas.add(op);
          importeVentas += (op.precio * op.participaciones);
        }
      }
      return importeCompras - importeVentas;
      /*for(var op in compras){
        importeCompras = importeCompras + (op.precio * op.participaciones);
      }
      for(var op in ventas){
        importeVentas = importeVentas + (op.precio * op.participaciones);
      }*/
    }

    double _getParticipaciones() {
      if (operacionesOn.isEmpty) {
        return 0.0;
      }
      var participaciones = 0.0;
      for (var op in operacionesOn) {
        if (op.tipo == 1) {
          participaciones += op.participaciones;
        } else {
          participaciones -= op.participaciones;
        }
      }
      return participaciones;
    }

    double _getPatrimonio() {
      if (operacionesOn.isEmpty) {
        return 0.0;
      }
      var participaciones = _getParticipaciones();
      return participaciones * valoresOn.first.precio;
    }

    double _getBalance() {
      if (operacionesOn.isEmpty) {
        return 0.0;
      }
      return _getPatrimonio() - _getInversion();
    }

    double _getRentabilidad() {
      if (operacionesOn.isEmpty) {
        return 0.0;
      }
      //return _getBalance() / _getInversion();
      return (valoresOn.first.precio - operacionesOn.first.precio) / operacionesOn.first.precio;
    }

    double _getTae() {
      if (operacionesOn.isEmpty) {
        return 0.0;
      }

      return pow(
              (_getPatrimonio() / _getInversion()),
              (365 /
                  (FechaUtil.epochToDate(valoresOn.first.date)
                      .difference(FechaUtil.epochToDate(operacionesOn.first.date))
                      .inDays))) -
          1;
    }

    List<DataColumn> _createColumns() {
      return const <DataColumn>[
        DataColumn(label: Text('FECHA')),
        DataColumn(label: Text('PART.')),
        DataColumn(label: Text('PRECIO')),
        DataColumn(label: Text('VALOR')),
        DataColumn(label: Text('')),
      ];
    }

    List<DataRow> _createRows() {
      return [
        for (var op in operacionesOn)
          DataRow(cells: [
            DataCell(Align(
              alignment: Alignment.centerRight,
              child: Text(FechaUtil.epochToString(op.date, formato: 'dd/MM/yy')),
            )),
            DataCell(Align(
              alignment: Alignment.centerRight,
              child: Text(
                NumberFormat.decimalPattern('es')
                    .format(op.tipo == 1 ? op.participaciones : op.participaciones * -1),
                style: TextStyle(color: op.tipo == 1 ? Colors.green : Colors.red),
              ),
            )),
            DataCell(Align(
              alignment: Alignment.centerRight,
              child: Text(NumberFormat.decimalPattern('es').format(op.precio)),
            )),
            DataCell(Align(
              alignment: Alignment.centerRight,
              child: Text(NumberFormat.decimalPattern('es')
                  .format(double.parse((op.participaciones * op.precio).toStringAsFixed(2)))),
            )),
            DataCell(IconButton(
              onPressed: () async {
                // TODO: mejor update ?
                await carfoin.eliminarValor(op.date);
                await carfoin.insertValor(Valor(date: op.date, precio: op.precio));
                await carfoin.updateValores();
              },
              icon: const Icon(Icons.delete_forever),
            )),
          ]),
        DataRow(
          color: MaterialStateColor.resolveWith((states) => Colors.blue),
          cells: [
            DataCell(Align(
              alignment: Alignment.centerRight,
              child: Text(
                FechaUtil.epochToString(valoresOn.first.date, formato: 'dd/MM/yy'),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
              ),
            )),
            DataCell(Align(
              alignment: Alignment.centerRight,
              child: Text(
                NumberFormat.decimalPattern('es').format(_getParticipaciones()),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
              ),
            )),
            DataCell(Align(
              alignment: Alignment.centerRight,
              child: Text(
                NumberFormat.decimalPattern('es').format(valoresOn.first.precio),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
              ),
            )),
            DataCell(Align(
              alignment: Alignment.centerRight,
              child: Text(
                NumberFormat.decimalPattern('es')
                    .format(double.parse(_getPatrimonio().toStringAsFixed(2))),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
              ),
            )),
            const DataCell(Text('')),
          ],
        ),
      ];
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(10),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                ListTile(
                  //contentPadding: const EdgeInsets.all(10),
                  leading: const Icon(Icons.assessment, size: 32),
                  title: Text(
                    fondoOn.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Text(
                    fondoOn.isin,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                valoresOn.isEmpty
                    ? const Text(
                        'Sin datos. Descarga el último valor o un intervalo de valores históricos.')
                    : Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              FechaUtil.epochToString(valoresOn.first.date),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${valoresOn.first.precio} ${fondoOn.divisa}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (_getDiferencia() != null)
                              Text(_getDiferencia()!.toStringAsFixed(2),
                                  style: TextStyle(
                                    color: _getDiferencia()! < 0 ? Colors.red : Colors.green,
                                  )),
                          ],
                        ),
                      ),
                if (valoresOn.isNotEmpty) const SizedBox(height: 20),
                if (valoresOn.length > 1)
                  Align(
                    alignment: Alignment.center,
                    child: FractionallySizedBox(
                      widthFactor: 0.8,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('Mínimo', style: TextStyle(fontSize: 18)),
                              const Spacer(),
                              Text(_getFechaMin(), style: const TextStyle(fontSize: 18)),
                              const Spacer(),
                              Text(
                                NumberFormat.decimalPattern('es').format(_getPrecioMin()),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text('Máximo', style: TextStyle(fontSize: 18)),
                              const Spacer(),
                              Text(_getFechaMax(), style: const TextStyle(fontSize: 18)),
                              const Spacer(),
                              Text(
                                NumberFormat.decimalPattern('es').format(_getPrecioMax()),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text('Media', style: TextStyle(fontSize: 18)),
                              const Spacer(),
                              Text(
                                NumberFormat.decimalPattern('es').format(_getPrecioMedio()),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text('Volatilidad', style: TextStyle(fontSize: 18)),
                              const Spacer(),
                              Text(
                                _getVolatilidad().toStringAsFixed(2),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.compare_arrows, size: 32),
                  title: Text('OPERACIONES', style: Theme.of(context).textTheme.titleLarge),
                  trailing: CircleAvatar(
                    backgroundColor: const Color(0xFFFFC107),
                    child: IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Color(0xFF0D47A1)),
                      onPressed: () => Navigator.of(context).pushNamed(RouteGenerator.mercadoPage),
                    ),
                  ),
                ),
                operacionesOn.isEmpty
                    ? const Text('Sin datos de operaciones.\n'
                        'Ordena transacciones en el mercado para seguir la evolución de tu inversión.')
                    : Column(
                        //crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FittedBox(
                            fit: BoxFit.fill,
                            child: DataTable(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              //headingRowHeight: 0,
                              columnSpacing: 20,
                              dataRowHeight: 70,
                              //horizontalMargin: 10,
                              headingRowColor:
                                  MaterialStateColor.resolveWith((states) => Colors.blue),
                              headingTextStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              dataTextStyle: const TextStyle(fontSize: 18, color: Colors.black),
                              columns: _createColumns(),
                              rows: _createRows(),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (operacionesOn.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.savings, size: 32), // Icons.balance
                    title: Text('BALANCE', style: Theme.of(context).textTheme.titleLarge),
                    trailing: Chip(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      backgroundColor: const Color(0xFF0D47A1),
                      avatar: const Icon(Icons.calendar_today, size: 20, color: Color(0xFFFFFFFF)),
                      label: Text(
                        FechaUtil.epochToString(
                          valoresOn.first.date,
                          formato: 'dd/MM/yy',
                        ),
                        style: const TextStyle(color: Color(0xFFFFFFFF)),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: FractionallySizedBox(
                      widthFactor: 0.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Text('Inversión', style: TextStyle(fontSize: 18)),
                              const Spacer(),
                              Text(
                                  NumberFormat.decimalPattern('es')
                                      .format(double.parse(_getInversion().toStringAsFixed(2))),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ))
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text('Resultado', style: TextStyle(fontSize: 18)),
                              const Spacer(),
                              Text(
                                  NumberFormat.decimalPattern('es')
                                      .format(double.parse(_getPatrimonio().toStringAsFixed(2))),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ))
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text('Rendimiento', style: TextStyle(fontSize: 18)),
                              const Spacer(),
                              Text(
                                  NumberFormat.decimalPattern('es')
                                      .format(double.parse(_getBalance().toStringAsFixed(2))),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: _getBalance() < 0 ? Colors.red : Colors.green,
                                    fontSize: 18,
                                  ))
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text('Rentabilidad', style: TextStyle(fontSize: 18)),
                              const Spacer(),
                              Text(
                                  NumberFormat.decimalPercentPattern(
                                    locale: 'es',
                                    decimalDigits: 2,
                                  ).format(_getRentabilidad()),
                                  style: TextStyle(
                                    color: _getBalance() < 0 ? Colors.red : Colors.green,
                                    fontSize: 18,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text('TAE', style: TextStyle(fontSize: 18)),
                              const Spacer(),
                              FittedBox(
                                child: Text(
                                    NumberFormat.decimalPercentPattern(
                                      locale: 'es',
                                      decimalDigits: 2,
                                    ).format(_getTae()),
                                    style: TextStyle(
                                      color: _getTae() < 0 ? Colors.red : Colors.green,
                                      fontSize: 18,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
