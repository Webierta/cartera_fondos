import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:charts_flutter/src/text_element.dart';
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:intl/intl.dart';
import 'dart:math';

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

  _onSelectionChanged(SelectionModel model) {
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
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(8),
      children: [
        SizedBox(
          height: 300,
          child: TimeSeriesChart(
            [
              Series<Valor, DateTime>(
                id: 'Valores',
                colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
                //domainFn: (Valor valor, _) => valor.fecha,
                domainFn: (Valor valor, _) => datefromEpoch(valor.date),
                measureFn: (Valor valor, _) => valor.precio,
                data: widget.valores,
              )
            ],
            /*domainAxis: charts.NumericAxisSpec(
              tickProviderSpec: charts.StaticNumericTickProviderSpec(staticTicks),
              tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                      (measure) => exp(measure).round().toString()),
            ),*/
            behaviors: [LinePointHighlighter(symbolRenderer: CircleSymbolRenderer())],
            domainAxis: const DateTimeAxisSpec(
              tickFormatterSpec: AutoDateTimeTickFormatterSpec(
                /*day: charts.TimeFormatterSpec(
                  format: 'd MMM',
                  transitionFormat: 'd MMM',
                ),*/
                month: TimeFormatterSpec(
                  format: 'MMM yy',
                  transitionFormat: 'MMM yy',
                ),
              ),
            ),
            dateTimeFactory: const LocalDateTimeFactory(),
            defaultInteractions: true,
            defaultRenderer: LineRendererConfig(
              includePoints: false,
              includeArea: true,
              stacked: true,
            ),
            animate: false,
            /*selectionModels: [
              charts.SelectionModelConfig(
                type: charts.SelectionModelType.info,
                updatedListener: _onSelectionChanged,
                changedListener: _onSelectionChanged,
                //listener: _onSelectionChanged,
              ),
            ],*/

            primaryMeasureAxis: const NumericAxisSpec(
              tickProviderSpec: BasicNumericTickProviderSpec(zeroBound: false),
              showAxisLine: true,
              renderSpec: GridlineRendererSpec(
                //lineStyle: LineStyleSpec(color: Color(0xFFFFCCBC), ),
                labelAnchor: TickLabelAnchor.after,
                labelJustification: TickLabelJustification.outside,
                //labelOffsetFromAxisPx: -15,
              ),
            ),

            /*behaviors: [
              LinePointHighlighter(symbolRenderer: charts.CircleSymbolRenderer()),
              //charts.SlidingViewport(),
              //charts.PanAndZoomBehavior(),
              ChartTitle(
                'Evolución histórica',
                behaviorPosition: BehaviorPosition.top,
              ),
              //charts.SeriesLegend(position: charts.BehaviorPosition.bottom),
              LinePointHighlighter(
                showHorizontalFollowLine: LinePointHighlighterFollowLineType.all,
                showVerticalFollowLine: LinePointHighlighterFollowLineType.all, // nearest
              ),
              //charts.SelectNearest(eventTrigger: charts.SelectionTrigger.tapAndDrag),
            ],*/

            selectionModels: [
              SelectionModelConfig(changedListener: (SelectionModel model) {
                if (model.hasDatumSelection) {
                  //print(model.selectedSeries[0].measureFn(model.selectedDatum[0].index));
                  var fecha = datefromEpoch(model.selectedDatum.first.datum.date);
                  var precio = model.selectedDatum.first.datum.precio;
                  print(fecha);
                  print(precio);
                  /*setState(() {
                    selectedFecha = fecha;
                    selectedPrecio = precio;
                  });*/
                }
              })
            ],
          ),
        ),
        if (selectedFecha != null)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(DateFormat('dd/MM/yy').format(selectedFecha!)),
          ),
        if (selectedPrecio != null)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(selectedPrecio!.toStringAsFixed(2)),
          ),
      ],
    );
  }
}
