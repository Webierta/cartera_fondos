import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/fondo.dart';

class PageInputRange extends StatefulWidget {
  final Fondo fondo;
  const PageInputRange({Key? key, required this.fondo}) : super(key: key);

  @override
  State<PageInputRange> createState() => _PageInputRangeState();
}

class _PageInputRangeState extends State<PageInputRange> {
  var _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 5)),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Descarga valores')),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.assessment),
                  title: Text(widget.fondo.name),
                  subtitle: const Text('Selecciona un intervalo de tiempo:'),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: InkWell(
                    onTap: () async {
                      await _datePicker(context, DatePickerEntryMode.inputOnly);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Fechas',
                      ),
                      child: FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${DateFormat('dd/MM/yyyy').format(_dateRange.start)} - '
                              '${DateFormat('dd/MM/yyyy').format(_dateRange.end)}',
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.date_range, color: Colors.blue),
                    onPressed: () {
                      _datePicker(context, DatePickerEntryMode.calendarOnly);
                    },
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Aceptar'),
                        onPressed: () {
                          var range = DateTimeRange(start: _dateRange.start, end: _dateRange.end);
                          Navigator.pop(context, range);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _datePicker(BuildContext context, DatePickerEntryMode mode) async {
    final DateTimeRange? newRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        //start: DateTime.now().subtract(const Duration(days: 5)),
        //end: DateTime.now(),
        start: _dateRange.start,
        end: _dateRange.end,
      ),
      //firstDate: DateTime(2019),
      firstDate: DateTime(2018, 1, 1),
      lastDate: DateTime.now(),
      //currentDate: DateTime.now(),
      //initialEntryMode: DatePickerEntryMode.inputOnly,
      //initialEntryMode = DatePickerEntryMode.calendarOnly,
      initialEntryMode: mode,
      locale: const Locale('es'),
      fieldStartLabelText: 'Desde',
      fieldEndLabelText: 'Hasta',
      fieldStartHintText: 'dd/mm/aaaa',
      fieldEndHintText: 'dd/mm/aaaa',
      cancelText: 'Cancelar',
      confirmText: 'OK',
      saveText: 'Aceptar',
      errorFormatText: 'Formato no válido.',
      errorInvalidText: 'Fuera de rango.',
      errorInvalidRangeText: 'Período no válido.',
    );

    if (newRange == null) {
      print('FECHAS NO SELECCIONADAS');
    } else {
      setState(() {
        _dateRange = newRange;
      });
    }
  }
}
