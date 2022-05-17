import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/carfoin_provider.dart';
import '../models/cartera.dart';
import '../models/fondo.dart';
import '../models/valor.dart';
import '../routes.dart';
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
  final TextEditingController _precioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool? _isValido = false;
  bool _loading = false;

  final _isSelected = <bool>[true, false];
  var _tipo = true;
  int _date = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  double _participaciones = 0;
  double _precio = 0;

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
    _precioController.text = _precio.toString();
    super.initState();
  }

  _resetControllers() {
    _dateController.text = FechaUtil.epochToString(DateTime.now().millisecondsSinceEpoch ~/ 1000);
    _partController.text = '0.0';
    _precioController.text = '0.0';
  }

  _updateMercado() async {}

  @override
  void dispose() {
    _dateController.dispose();
    _partController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.of(context).pushNamed(RouteGenerator.fondoPage);
            },
          ),
          title: const Text('Mercado')),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  Text('Descargando valor liquidativo...'),
                ],
              ),
            )
          : ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 30),
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
                              style: TextStyle(
                                fontWeight: _tipo ? FontWeight.bold : FontWeight.w300,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'REEMBOLSAR',
                              style: TextStyle(
                                fontWeight: !_tipo ? FontWeight.bold : FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                        isSelected: _isSelected,
                        color: const Color(0xFF9E9E9E),
                        selectedColor: const Color(0xFF2196F3),
                        fillColor: const Color(0xFFBBDEFB),
                        borderColor: const Color(0xFF9E9E9E),
                        selectedBorderColor: const Color(0xFF2196F3),
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
                            _resetControllers();
                          });
                        },
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
                                _date = fecha.millisecondsSinceEpoch ~/ 1000;
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
                            suffixIcon:
                                Icon(_tipo ? Icons.add_shopping_cart : Icons.currency_exchange),
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
                          onTap: () => setState(() => _partController.clear()),
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
                              icon: const Icon(Icons.download, color: Colors.blue),
                              onPressed: () async {
                                //setState(() => _loading = true);
                                //await _getPrecioApi(context);
                                //_precioController.text = _precio.toString();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Procesando descarga...'),
                                    //backgroundColor: Colors.red,
                                    duration: Duration(days: 365),
                                  ),
                                );
                                var precioApi = await _getPrecioApi(context);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                //setState(() => _loading = false);
                                if (precioApi != null) {
                                  setState(() {
                                    _precio = precioApi;
                                    _precioController.text = precioApi.toString();
                                  });
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
                              //setState(() => _precioController.clear());
                            }
                          },
                          onChanged: (value) =>
                              setState(() => _precio = double.tryParse(value) ?? 0),
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
      Valor newValor = Valor(date: _date, precio: _precio);
      // TODO: valores duplicados ??
      // CHECK SI NO EXISTE (Y TAMBIEN CHECK DESDE PAGE FONDO)
      await _db.insertVL(carteraOn, fondoOn, newValor);
      await _compareLastValor();
      // TODO: remove or hide ??
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      Navigator.of(context).pushNamed(RouteGenerator.fondoPage);
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

  _getPrecioApi(BuildContext context) async {
    String fromAndTo = FechaUtil.epochToString(_date, formato: 'yyyy-MM-dd');
    final getDateApiRange = await apiService.getDataApiRange(fondoOn.isin, fromAndTo, fromAndTo);
    if (getDateApiRange != null && getDateApiRange.isNotEmpty) {
      /*setState(() {
        _precio = getDateApiRange.first.price;
        _precioController.text = getDateApiRange.first.price.toString();
      });*/
      return getDateApiRange.first.price;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dato no encontrado. Introduce el precio manualmente.'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  _compareLastValor() async {
    await _db.getValoresByOrder(carteraOn, fondoOn);
    var valores = _db.dbValoresByOrder;
    if (valores.isNotEmpty) {
      var lastValor = Valor(date: valores.first.date, precio: valores.first.precio);
      var lastPrecio = valores.first.precio;
      var lastDate = valores.first.date;
      if (fondoOn.lastDate == null) {
        fondoOn
          ..lastPrecio = lastPrecio
          ..lastDate = lastDate;
        await _db.insertDataApi(carteraOn, fondoOn, lastPrecio: lastPrecio, lastDate: lastDate);
        await _db.insertVL(carteraOn, fondoOn, lastValor);
        //await _updateValores();
        return true;
      } else if (fondoOn.lastDate! < lastDate) {
        fondoOn
          ..lastPrecio = lastPrecio
          ..lastDate = lastDate;
        _db.insertDataApi(carteraOn, fondoOn, lastPrecio: lastPrecio, lastDate: lastDate);
        _db.insertVL(carteraOn, fondoOn, lastValor);
        //await _updateValores();
        return true;
      } else {
        //await _updateValores();
        return false;
      }
    }
    //await _updateValores();
    return false;
  }
}
