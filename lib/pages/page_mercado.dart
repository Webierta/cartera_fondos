import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/carfoin_provider.dart';
import '../models/cartera.dart';
import '../models/fondo.dart';
import '../services/api_service.dart';
import '../services/sqlite.dart';
import '../utils/fecha_util.dart';

class PageMercado extends StatefulWidget {
  const PageMercado({Key? key}) : super(key: key);

  @override
  State<PageMercado> createState() => _MercadoState();
}

class _MercadoState extends State<PageMercado> {
  late Sqlite _db;
  late ApiService apiService;
  late Cartera carteraOn;
  late Fondo fondoOn;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _partController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool? _isValido = false;

  final _isSelected = <bool>[true, false];
  var _tipo = true;
  int _date = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  int _participaciones = 0;

  @override
  void initState() {
    carteraOn = context.read<CarfoinProvider>().getCartera!;
    fondoOn = context.read<CarfoinProvider>().getFondo!;
    _db = Sqlite();
    _db.openDb().whenComplete(() async {
      await _updateMercado();
    });
    apiService = ApiService();
    _dateController.text = FechaUtil.epochToString(_date);
    _partController.text = _participaciones.toString();
    super.initState();
  }

  _updateMercado() async {}

  @override
  void dispose() {
    _dateController.dispose();
    _partController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mercado')),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 50),
        children: [
          FractionallySizedBox(
            widthFactor: 0.6,
            child: Center(
              child: FittedBox(
                child: ToggleButtons(
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
                  isSelected: _isSelected,
                  color: Colors.grey,
                  selectedColor: Colors.blue,
                  fillColor: Colors.blue[100],
                  borderColor: Colors.grey,
                  selectedBorderColor: Colors.blue,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  onPressed: (int index) {
                    setState(() {
                      if (index == 0) {
                        _isSelected[0] = true;
                        _isSelected[1] = false;
                        _tipo = true;
                      } else if (index == 1) {
                        _isSelected[0] = false;
                        _isSelected[1] = true;
                        _tipo = false;
                      }
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Form(
            key: _formKey,
            onChanged: () => setState(() => _isValido = _formKey.currentState?.validate()),
            child: Column(
              children: [
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    controller: _dateController,
                    //initialValue: FechaUtil.epochToString(_date),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido.';
                      }
                      return null;
                    },
                    /*onChanged: (value) {
                      setState(() {
                        _dateController.text = value.toString();
                      });
                    },*/
                    onTap: () async {
                      var fecha = await _selectDate(context);
                      if (fecha != null) {
                        setState(() {
                          _date = fecha.millisecondsSinceEpoch ~/ 1000;
                          _dateController.text = FechaUtil.dateToString(date: fecha);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 40),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Participaciones',
                      suffixIcon: Icon(_tipo ? Icons.add_shopping_cart : Icons.currency_exchange),
                      border: const OutlineInputBorder(),
                    ),
                    controller: _partController,
                    //inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9]+|\s"))],
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
                    keyboardType: TextInputType.number,
                    //initialValue: _participaciones.toString(),
                    //keyboardType: , numeros
                    //initialValue: , si compra 0 si venta total participaciones disponibles ??
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null ||
                          int.parse(value) < 1) {
                        return '';
                      }
                      return null;
                    },
                    onTap: () {
                      setState(() {
                        _partController.clear();
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _participaciones = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                //const Spacer(),
                const SizedBox(height: 30),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: ElevatedButton(
                    onPressed: _isValido == true ? () => _submit(context) : null,
                    child: const Text('Ordenar'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      print(_tipo);
      print(FechaUtil.epochToString(_date));
      print(_participaciones);
      // obtener precio en dateMercado (APIRange con fechas +- cercanas)
      //var to = _date + 2 days;
      //var from _date - 2 days;
      //apiService.getDataApiRange(fondoOn.isin, to, from)

      // escribir en db los datos CarteraOn FondoOn

      // actualizar UI
    }
  }

  Future<DateTime?>? _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      //initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      /*setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat.yMd().format(selectedDate);
      });*/
      return picked;
    }
    return null;
  }
}
