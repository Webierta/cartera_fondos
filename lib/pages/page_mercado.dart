import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/carfoin_provider.dart';
import '../models/fondo.dart';
import '../models/operacion.dart';
import '../routes.dart';
import '../services/api_service.dart';
import '../utils/fecha_util.dart';
import '../widgets/loading.dart';

class PageMercado extends StatefulWidget {
  const PageMercado({Key? key}) : super(key: key);
  @override
  State<PageMercado> createState() => _MercadoState();
}

class _MercadoState extends State<PageMercado> {
  late CarfoinProvider carfoin;
  late ApiService apiService;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _partController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool? _isValido = false;
  final _isSelected = <bool>[true, false];
  var _tipo = true;
  int _date = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  double _participaciones = 0;
  double _precio = 0;

  @override
  void initState() {
    carfoin = context.read<CarfoinProvider>();
    carfoin.openDb().whenComplete(() {
      apiService = ApiService();
      _dateController.text = FechaUtil.epochToString(_date);
      _partController.text = _participaciones.toString();
      _precioController.text = _precio.toString();
    });
    super.initState();
  }

  _resetControllers() {
    _dateController.text = FechaUtil.epochToString(DateTime.now().millisecondsSinceEpoch ~/ 1000);
    _partController.text = '0.0';
    _precioController.text = '0.0';
  }

  @override
  void dispose() {
    _dateController.dispose();
    _partController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var carteraOn = context.read<CarfoinProvider>().getCartera!;
    var fondoOn = context.read<CarfoinProvider>().getFondo!;
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.of(context).pushNamed(RouteGenerator.fondoPage, arguments: true);
            },
          ),
          title: const Text('Mercado')),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(10),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.poll, size: 32),
              title: Text(fondoOn.name),
              subtitle: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  avatar: const Icon(Icons.business_center),
                  label: Text(carteraOn.name),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FractionallySizedBox(
            widthFactor: 0.6,
            child: Center(
              child: FittedBox(
                child: ToggleButtons(
                  isSelected: _isSelected,
                  color: const Color(0xFF9E9E9E),
                  selectedColor: const Color(0xFF2196F3),
                  fillColor: const Color(0xFFBBDEFB),
                  borderColor: const Color(0xFF9E9E9E),
                  selectedBorderColor: const Color(0xFF2196F3),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  onPressed: (int index) {
                    setState(() {
                      _isSelected[0] = index == 0 ? true : false;
                      _isSelected[1] = index == 0 ? false : true;
                      _tipo = index == 0 ? true : false;
                    });
                    _resetControllers();
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'SUSCRIBIR',
                        style: TextStyle(fontWeight: _tipo ? FontWeight.bold : FontWeight.w300),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'REEMBOLSAR',
                        style: TextStyle(fontWeight: !_tipo ? FontWeight.bold : FontWeight.w300),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Form(
            key: _formKey,
            onChanged: () => setState(() => _isValido = _formKey.currentState?.validate()),
            child: Column(
              children: [
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: TextFormField(
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      errorStyle: TextStyle(height: 0),
                      labelText: 'Fecha',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    controller: _dateController,
                    validator: (value) {
                      return (value == null || value.isEmpty) ? 'Campo requerido' : null;
                    },
                    readOnly: true,
                    onTap: () async {
                      var fecha = await _selectDate(context);
                      if (fecha != null) {
                        setState(() {
                          // TODO: CONTROL OTRAS TIME ZONE PARA NO REPETIR DATE ??
                          // o epoch +/- 1 day ??
                          DateTime timeZone = fecha.add(const Duration(hours: 2));
                          _date = timeZone.millisecondsSinceEpoch ~/ 1000;
                          _dateController.text = FechaUtil.dateToString(date: fecha);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 30),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: TextFormField(
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      errorStyle: const TextStyle(fontSize: 0, height: 0),
                      labelText: 'Participaciones',
                      suffixIcon: Icon(_tipo ? Icons.add_shopping_cart : Icons.currency_exchange),
                      border: const OutlineInputBorder(),
                    ),
                    controller: _partController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'(^\-?\d*\.?\d*)'))
                    ],
                    keyboardType: TextInputType.number,
                    validator: (inputPart) {
                      if (inputPart == null ||
                          inputPart.isEmpty ||
                          double.tryParse(inputPart) == null ||
                          double.tryParse(inputPart)! <= 0.0) {
                        return 'Número de participaciones no válido.';
                      }
                      return null;
                    },
                    onTap: () => _partController.clear(),
                    onChanged: (value) {
                      setState(() => _participaciones = double.tryParse(value) ?? 0);
                    },
                  ),
                ),
                const SizedBox(height: 30),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: TextFormField(
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      errorStyle: const TextStyle(fontSize: 0, height: 0),
                      labelText: 'Precio',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.download, color: Color(0xFF2196F3)),
                        onPressed: () async {
                          Loading(context).openDialog(title: 'Obteniendo valor liquidativo...');
                          var precioApi = await _getPrecioApi(context, fondoOn);
                          if (!mounted) return;
                          Loading(context).closeDialog();
                          if (precioApi != null) {
                            setState(() {
                              _precio = precioApi;
                              _precioController.text = precioApi.toString();
                            });
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Dato no encontrado. Introduce el precio manualmente.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    controller: _precioController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'(^\-?\d*\.?\d*)'))
                    ],
                    keyboardType: TextInputType.number,
                    validator: (inputPrecio) {
                      if (inputPrecio == null ||
                          inputPrecio.isEmpty ||
                          double.tryParse(inputPrecio) == null ||
                          double.tryParse(inputPrecio)! <= 0) {
                        return 'Precio no válido.';
                      }
                      return null;
                    },
                    onTap: () {
                      if (_precioController.text == '0.0') {
                        _precioController.clear();
                      }
                    },
                    onChanged: (value) => setState(() => _precio = double.tryParse(value) ?? 0),
                  ),
                ),
                const SizedBox(height: 30),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Importe',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFD5D5D5),
                      filled: true,
                    ),
                    child: Text(
                      _isValido == true
                          ? NumberFormat.currency(locale: 'es', symbol: '')
                              .format(_participaciones * _precio)
                          : '0.0',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: ElevatedButton(
                    onPressed: _isValido == true ? () => _submit(context) : null,
                    child: const Text('ORDENAR'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // TODO: valores duplicados ??
      int tipoOp = _tipo ? 1 : 0;
      Operacion newOp =
          Operacion(tipo: tipoOp, date: _date, participaciones: _participaciones, precio: _precio);
      await carfoin.insertOperacion(newOp);
      if (!mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      Navigator.of(context).pushNamed(RouteGenerator.fondoPage);
    }
  }

  Future<DateTime?>? _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      locale: const Locale('es'),
      //initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2015, 1, 1),
      lastDate: DateTime.now(),
    );
    return picked;
  }

  Future<double?>? _getPrecioApi(BuildContext context, Fondo fondo) async {
    String fromAndTo = FechaUtil.epochToString(_date, formato: 'yyyy-MM-dd');
    final getDateApiRange = await apiService.getDataApiRange(fondo.isin, fromAndTo, fromAndTo);
    if (getDateApiRange != null && getDateApiRange.isNotEmpty) {
      return getDateApiRange.first.price;
    }
    return null;
  }
}
