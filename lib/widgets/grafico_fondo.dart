import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
//import 'package:charts_flutter/src/text_element.dart';
//import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:intl/intl.dart';
//import 'dart:math';

import '../models/valor.dart';

class GraficoFondo extends StatefulWidget {
  final List<Valor> valores;
  const GraficoFondo({Key? key, required this.valores}) : super(key: key);

  @override
  State<GraficoFondo> createState() => _GraficoFondoState();
}

class _GraficoFondoState extends State<GraficoFondo> {
  //Valor? selectedValor;
  DateTime? selectedFecha;
  double? selectedPrecio;

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    if (selectedDatum.isNotEmpty) {
      var fecha = datefromEpoch(selectedDatum.first.datum.date);
      var precio = selectedDatum.first.datum.precio;
      setState(() {
        selectedFecha = fecha;
        selectedPrecio = precio;
      });
    }
  }

  DateTime datefromEpoch(int epoch) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  @override
  Widget build(BuildContext context) {
    List<double> precios = widget.valores.reversed.map((entry) => entry.precio).toList();
    var precioMedio = precios.reduce((a, b) => a + b) / precios.length;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        //ListView(
        //shrinkWrap: true,
        //physics: const ClampingScrollPhysics(),
        //padding: const EdgeInsets.all(8),
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            //)SizedBox(
            //height: MediaQuery.of(context).size.height / 1.35,
            child: charts.TimeSeriesChart(
              [
                charts.Series<Valor, DateTime>(
                  id: 'Valores',
                  colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                  domainFn: (Valor valor, _) => datefromEpoch(valor.date),
                  measureFn: (Valor valor, _) => valor.precio,
                  data: widget.valores,
                )
              ],
              dateTimeFactory: const charts.LocalDateTimeFactory(),
              defaultInteractions: true,
              defaultRenderer: charts.LineRendererConfig(
                includePoints: false,
                includeArea: true,
                stacked: true,
              ),
              animate: false,
              domainAxis: const charts.DateTimeAxisSpec(
                tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                  /*day: charts.TimeFormatterSpec(
                    format: 'd MMM',
                    transitionFormat: 'd MMM',
                  ),*/
                  month: charts.TimeFormatterSpec(
                    format: 'MMM yy',
                    transitionFormat: 'MMM yy',
                  ),
                ),
              ),
              primaryMeasureAxis: const charts.NumericAxisSpec(
                tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false),
                showAxisLine: true,
                renderSpec: charts.GridlineRendererSpec(
                  //lineStyle: LineStyleSpec(color: Color(0xFFFFCCBC), ),
                  labelAnchor: charts.TickLabelAnchor.after,
                  labelJustification: charts.TickLabelJustification.outside,
                  //labelOffsetFromAxisPx: -15,
                ),
              ),
              behaviors: [
                charts.ChartTitle(
                  selectedFecha != null
                      ? '${DateFormat('dd/MM/yy').format(selectedFecha!)}: $selectedPrecio'
                      : 'Histórico',
                ),
                charts.LinePointHighlighter(symbolRenderer: charts.CircleSymbolRenderer()),
                charts.LinePointHighlighter(
                  symbolRenderer: charts.CircleSymbolRenderer(),
                  showHorizontalFollowLine: charts.LinePointHighlighterFollowLineType.all,
                  showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.nearest,
                ),
                charts.RangeAnnotation([
                  charts.LineAnnotationSegment(
                    precioMedio,
                    charts.RangeAnnotationAxisType.measure,
                    startLabel: 'Valor medio: ${precioMedio.toStringAsFixed(2)}',
                    color: charts.MaterialPalette.red.shadeDefault,
                    strokeWidthPx: 1.0,
                    dashPattern: [1, 1],
                  ),
                ]),
              ],
              selectionModels: [
                charts.SelectionModelConfig(
                  type: charts.SelectionModelType.info,
                  changedListener: (charts.SelectionModel model) {
                    if (model.hasDatumSelection) {
                      //print(model.selectedSeries[0].measureFn(model.selectedDatum[0].index));
                      var fecha = datefromEpoch(model.selectedDatum.first.datum.date);
                      var precio = model.selectedDatum.first.datum.precio;
                      setState(() {
                        selectedFecha = fecha;
                        selectedPrecio = precio;
                      });
                    }
                  },
                )
              ],
            ),
          ),
          /*if (selectedFecha != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(DateFormat('dd/MM/yy').format(selectedFecha!)),
            ),
          if (selectedPrecio != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(selectedPrecio!.toStringAsFixed(2)),
            ),*/
        ],
      ),
    );
  }
}
