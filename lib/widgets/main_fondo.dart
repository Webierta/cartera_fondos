//import 'package:cartera_fondos/models/valor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../models/carfoin_provider.dart';
import '../utils/fecha_util.dart';

class MainFondo extends StatelessWidget {
  const MainFondo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: PROVIDER carfoin ????
    final carteraOn = context.read<CarfoinProvider>().getCartera;
    final fondoOn = context.read<CarfoinProvider>().getFondo!;
    final valoresOn = context.read<CarfoinProvider>().getValores;

    double? _getDiferencia() {
      if (valoresOn.length > 1) {
        var last = valoresOn.first.precio;
        var prev = valoresOn[1].precio;
        return last - prev;
      }
      return null;
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(10),
      children: [
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: const Icon(Icons.assessment, size: 32),
            title: Text(
              fondoOn.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fondoOn.isin,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Chip(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  avatar: const Icon(Icons.business_center),
                  label: Text(carteraOn!.name),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Text(
                  //fondoOn.divisa ?? '',
                  fondoOn.divisa,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                title: valoresOn.isEmpty
                    ? const Text('Precio: Sin datos')
                    : Center(
                        child: Text(
                          '${valoresOn.first.precio}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                subtitle: valoresOn.isEmpty
                    ? const Text('Descarga el último valor liquidativo')
                    : Center(
                        child: Text(
                          valoresOn.isNotEmpty ? FechaUtil.epochToString(valoresOn.first.date) : '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                //TODO: DIF NO SE ACTUALIZA
                trailing: _getDiferencia() != null
                    ? Text(
                        _getDiferencia()!.toStringAsFixed(2),
                        style: TextStyle(color: _getDiferencia()! < 0 ? Colors.red : Colors.green),
                      )
                    : const Text(''),
              ),
            ],
          ),
        ),
        //if (valoresOn.isNotEmpty)
        Card(
          child: Column(
            children: [
              ListTile(
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
                  icon: const Icon(Icons.shopping_cart, color: Colors.blue),
                  onPressed: () {
                    Navigator.of(context).pushNamed(RouteGenerator.mercadoPage);
                  },
                ),
              ),
              const SizedBox(height: 10),
              if (fondoOn.participaciones != 0)
                const ListTile(
                  title: Text('Rendimiento:'),
                  isThreeLine: true,
                  subtitle: Text('Rentabilidad: \nTAE: '),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
