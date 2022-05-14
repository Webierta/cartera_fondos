import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:intl/intl.dart';

import '../models/carfoin_provider.dart';
//import '../models/cartera.dart';
//import '../models/fondo.dart';
//import '../models/valor.dart';
//import '../services/api_service.dart';
//import '../services/sqlite.dart';
import '../utils/fecha_util.dart';

/*class MainFondo extends StatefulWidget {
  //final Cartera cartera;
  //final Fondo fondo;
  //const MainFondo({Key? key, required this.cartera, required this.fondo}) : super(key: key);
  const MainFondo({Key? key}) : super(key: key);

  @override
  State<MainFondo> createState() => _MainFondoState();
}

class _MainFondoState extends State<MainFondo> {*/

class MainFondo extends StatelessWidget {
  const MainFondo({Key? key}) : super(key: key);
  //late Cartera carteraOn;
  //late Fondo fondoOn;
  //late List<Valor> valoresOn;

  //late Sqlite _db;
  //late ApiService apiService;
  //var valores = <Valor>[];
  //var valoresByOrder = <Valor>[];
  //var valoresCopy = <Valor>[];
  //bool loading = true;
  //String msgLoading = '';

  /*@override
  void initState() {
    carteraOn = context.read<CarfoinProvider>().getCartera!;
    fondoOn = context.read<CarfoinProvider>().getFondo!;
    valoresOn = context.read<CarfoinProvider>().getValores;
    */ /*loading = true;
    msgLoading = 'Abriendo base de datos...';
    _db = Sqlite();
    _db.openDb().whenComplete(() async {
      await _updateValores();
    });
    apiService = ApiService();*/ /*
    super.initState();
  }*/

  /*_updateValores() async {
    setState(() {
      valores = <Valor>[];
      valoresByOrder = <Valor>[];
      valoresCopy = <Valor>[];
    });

    await _db.createTableFondo(widget.cartera, widget.fondo);
    setState(() => msgLoading = 'Obteniendo datos...');
    //TODO: check si data no es null ??
    await _db.getValoresByOrder(widget.cartera, widget.fondo).whenComplete(() => setState(() {
          loading = false;
          msgLoading = '';
          valores = _db.dbValoresByOrder; // ???
          valoresByOrder = _db.dbValoresByOrder;
          valoresCopy = [...valores];
        }));
    //TODO: si moneda, lastPrecio y LastDate == null hacer un update
    if (widget.fondo.moneda == null) {}
    //TODO: ordenar primero por date para obtener valores.last si valores.isNotEmpty ??
  }*/

  @override
  Widget build(BuildContext context) {
    //TODO: PROVIDER carfoin ????
    //final carfoin = Provider.of<CarfoinProvider>(context);
    //final fondoOn = carfoin.getFondo;
    //final valoresOn = carfoin.getValores;
    //final carteraOn = context.read<CarfoinProvider>().getCartera;
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
            subtitle: Text(
              fondoOn.isin,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Text(
                  fondoOn.moneda ?? '',
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
                          //valores.isNotEmpty ? _epochFormat(valores.first.date) : '',
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
        if (valoresOn.isNotEmpty)
          Card(
            child: Column(
              children: [
                ListTile(
                  title: fondoOn.participaciones > 0
                      ? Text('Patrimonio: ${fondoOn.participaciones * fondoOn.lastPrecio!}')
                      : const Text('Patrimonio: Sin datos'),
                  subtitle: fondoOn.participaciones > 0
                      ? Text('Participaciones: ${fondoOn.participaciones}')
                      : const Text(
                          'Subscribe participaciones de este Fondo para seguir el rendimiento de tu inversión'),
                  // TODO: nueva ventana con Fecha / participaciones y VL
                  trailing: IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.blue),
                    onPressed: () {},
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
