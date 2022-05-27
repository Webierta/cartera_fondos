//import 'package:cartera_fondos/models/valor.dart';
import 'dart:math';

//import 'package:cartera_fondos/models/operacion.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../models/carfoin_provider.dart';
import '../utils/fecha_util.dart';

class MainFondo extends StatelessWidget {
  const MainFondo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: PROVIDER carfoin ????
    //final carteraOn = context.read<CarfoinProvider>().getCartera;
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
      return FechaUtil.epochToString(fechas[precios.indexOf(_getPrecioMin())]);
    }

    String _getFechaMax() {
      if (valoresOn.length < 2) {
        return '';
      }
      final List<double> precios = valoresOn.reversed.map((entry) => entry.precio).toList();
      final List<int> fechas = valoresOn.reversed.map((entry) => entry.date).toList();
      return FechaUtil.epochToString(fechas[precios.indexOf(_getPrecioMax())]);
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

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(10),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.all(10),
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
                          borderRadius: BorderRadius.circular(8),
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
                              Text(
                                _getDiferencia()!.toStringAsFixed(2),
                                style: TextStyle(
                                    color: _getDiferencia()! < 0 ? Colors.red : Colors.green),
                              ),
                          ],
                        ),
                      ),
                if (valoresOn.isNotEmpty) const SizedBox(height: 10),
                if (valoresOn.length > 1)
                  Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: 0.7,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('Mínimo'),
                              const Spacer(),
                              Text(_getFechaMin()),
                              const Spacer(),
                              Text(NumberFormat.decimalPattern('es').format(_getPrecioMin())),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Máximo'),
                              const Spacer(),
                              Text(_getFechaMax()),
                              const Spacer(),
                              Text(NumberFormat.decimalPattern('es').format(_getPrecioMax())),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Media'),
                              const Spacer(),
                              Text(NumberFormat.decimalPattern('es').format(_getPrecioMedio())),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Volatilidad'),
                              const Spacer(),
                              //Text(NumberFormat.decimalPattern('es').format(_getVolatilidad())),
                              Text(_getVolatilidad().toStringAsFixed(2)),
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
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('BALANCE ECONÓMICO', style: Theme.of(context).textTheme.titleMedium),
                    OutlinedButton.icon(
                      label: const Text('Mercado'),
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () => Navigator.of(context).pushNamed(RouteGenerator.mercadoPage),
                    ),
                  ],
                ),
                operacionesOn.isEmpty
                    ? const Text('Sin datos de operaciones.\n'
                        'Ordena transacciones en el mercado para seguir el rendimiento de tu inversión.')
                    : Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                'INVERSIÓN',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: 0.7,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text('Importe'),
                                      const Spacer(),
                                      Text(
                                        NumberFormat.decimalPattern('es').format(_getInversion()),
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Fecha inicio'),
                                      const Spacer(),
                                      Text(FechaUtil.epochToString(operacionesOn.first.date)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text('Valor inicio'),
                                      const Spacer(),
                                      Text(NumberFormat.decimalPattern('es')
                                          .format(operacionesOn.first.precio)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text('Participaciones'),
                                      const Spacer(),
                                      Text(NumberFormat.decimalPattern('es')
                                          .format(_getParticipaciones())),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                'RESULTADO',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: 0.7,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text('Importe'),
                                      const Spacer(),
                                      Text(
                                        NumberFormat.decimalPattern('es').format(_getPatrimonio()),
                                        //NumberFormat("#,###.0#", "es").format(_getPatrimonio()),
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text('Fecha'),
                                      const Spacer(),
                                      Text(FechaUtil.epochToString(valoresOn.first.date)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text('Valor liquidativo'),
                                      const Spacer(),
                                      RichText(
                                        text: TextSpan(
                                          text: NumberFormat.decimalPattern('es')
                                              .format(valoresOn.first.precio),
                                          style: DefaultTextStyle.of(context).style,
                                          children: <TextSpan>[
                                            const TextSpan(text: '('),
                                            TextSpan(
                                              /*text: (valoresOn.first.precio -
                                                      operacionesOn.first.precio)
                                                  .toStringAsFixed(2),*/
                                              text: NumberFormat.decimalPattern('es').format(
                                                  valoresOn.first.precio -
                                                      operacionesOn.first.precio),
                                              style: TextStyle(
                                                  color: valoresOn.first.precio -
                                                              operacionesOn.first.precio <
                                                          0
                                                      ? Colors.red
                                                      : Colors.green),
                                            ),
                                            const TextSpan(text: ')'),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text('BALANCE', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: 0.7,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text('Diferencia'),
                                      const Spacer(),
                                      Text(
                                        NumberFormat.decimalPattern('es').format(_getBalance()),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: _getBalance() < 0 ? Colors.red : Colors.green),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Rentabilidad'),
                                      const Spacer(),
                                      Text(
                                        NumberFormat.decimalPercentPattern(
                                                locale: 'es', decimalDigits: 2)
                                            .format(_getRentabilidad()),
                                        style: TextStyle(
                                            color: _getBalance() < 0 ? Colors.red : Colors.green),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('TAE'),
                                      const Spacer(),
                                      FittedBox(
                                        child: Text(
                                          NumberFormat.decimalPercentPattern(
                                                  locale: 'es', decimalDigits: 2)
                                              .format(_getTae()),
                                          //NumberFormat.compact(locale: 'es').format(_getTae()),
                                          style: TextStyle(
                                              color: _getTae() < 0 ? Colors.red : Colors.green),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'OPERACIONES',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                            ),
                            //color: Colors.blue, // Color(0xFFFFC107)
                            child: Row(
                              children: const [
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      'FECHA',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      'TIPO',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      'PART.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      'PRECIO',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
                                    )),
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                      'IMPORTE',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
                                    )),
                              ],
                            ),
                          ),
                          ListView.separated(
                            padding: const EdgeInsets.only(top: 14),
                            separatorBuilder: (context, index) => const Divider(
                                color: Color(0xFF9E9E9E), height: 24, indent: 10, endIndent: 10),
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: operacionesOn.length,
                            itemBuilder: (context, index) {
                              String tipoOp = operacionesOn[index].tipo == 1 ? 'S' : 'R';
                              return Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      FechaUtil.epochToString(operacionesOn[index].date),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(tipoOp,
                                        style: Theme.of(context).textTheme.labelSmall,
                                        textAlign: TextAlign.center),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      NumberFormat.decimalPattern('es')
                                          .format(operacionesOn[index].participaciones),
                                      //'${operacionesOn[index].participaciones}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      NumberFormat.decimalPattern('es')
                                          .format(operacionesOn[index].precio),
                                      //'${operacionesOn[index].precio}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      NumberFormat.decimalPattern('es').format(
                                          (operacionesOn[index].participaciones *
                                              operacionesOn[index].precio)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),

        /*Card(
          child: Column(
            children: [
              */ /*ListTile(
                title: fondoOn.participaciones > 0
                    //? Text('Patrimonio: ${fondoOn.participaciones * fondoOn.lastPrecio!}')
                    ? Text('Patrimonio: ${fondoOn.participaciones * valoresOn.first.precio}')
                    : const Text('Patrimonio: Sin datos'),
                subtitle: fondoOn.participaciones > 0
                    ? Text('Participaciones: ${fondoOn.participaciones}')
                    : const Text(
                        'Subscribe participaciones de este Fondo para seguir el rendimiento de tu inversión'),
                // TODO: nueva ventana con Fecha / participaciones y VL
                trailing: IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Color(0xFF2196F3)),
                  onPressed: () => Navigator.of(context).pushNamed(RouteGenerator.mercadoPage),
                ),
              ),*/ /*
              ElevatedButton(
                  child: const Icon(Icons.shopping_cart),
                  onPressed: () => Navigator.of(context).pushNamed(RouteGenerator.mercadoPage)),
              if (operacionesOn.isNotEmpty)
                Text('Participaciones: ${operacionesOn.first.participaciones}'),
              if (operacionesOn.isNotEmpty) Text('Participaciones: ${operacionesOn.first.tipo}'),
              const SizedBox(height: 10),
              */ /*if (fondoOn.participaciones != 0)
                const ListTile(
                  title: Text('Rendimiento:'),
                  isThreeLine: true,
                  subtitle: Text('Rentabilidad: \nTAE: '),
                ),*/ /*
            ],
          ),
        ),*/
      ],
    );
  }
}
