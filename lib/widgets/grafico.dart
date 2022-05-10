//import 'dart:math';
//import 'package:fl_chart/fl_chart.dart';
import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
//import 'package:fl_chart/fl_chart.dart';

import '../models/valor.dart';

class Grafico extends StatelessWidget {
  final List<Valor> valores;
  const Grafico({Key? key, required this.valores}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<double> precios = valores.reversed.map((entry) => entry.precio).toList();
    List<int> fechas = valores.reversed.map((entry) => entry.date).toList();
    var fecha1 = fechas.first;
    var fecha2 = fechas.last;
    var precioMin = precios.reduce((curr, next) => curr < next ? curr : next);
    var precioMax = precios.reduce((curr, next) => curr > next ? curr : next);
    var precioMedio = precios.reduce((a, b) => a + b) / precios.length;

    return ClipPath(
      clipper: const ShapeBorderClipper(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        width: double.infinity,
        child: Chart(
          state: ChartState.line(
            ChartData.fromList(
              precios.map((e) => BubbleValue<void>(e)).toList(),
              axisMax: precioMax + 0.5,
              axisMin: precioMin - 0.5,
            ),
            behaviour: const ChartBehaviour(
              isScrollable: true,
            ),
            /*backgroundDecorations: [
              GridDecoration(
                verticalAxisStep: 10,
                horizontalAxisStep: 1,
              ),
            ],*/
            backgroundDecorations: [
              HorizontalAxisDecoration(
                axisStep: 1,
                showLines: true,
                lineWidth: 0.2,
                lineColor: Colors.grey,
              ),
              VerticalAxisDecoration(
                showLines: true,
                lineWidth: 0.2,
                legendFontStyle: Theme.of(context).textTheme.caption?.copyWith(
                      fontSize: 8,
                      color: Colors.blue,
                    ),
                legendPosition: VerticalLegendPosition.bottom,
                axisStep: 10,
                lineColor: Colors.grey,
              ),
              TargetLineDecoration(
                target: 125,
                targetLineColor: Colors.blue,
                lineWidth: 1,
              ),
            ],
            foregroundDecorations: [
              SparkLineDecoration(
                lineColor: Colors.red,
                lineWidth: 2,
                smoothPoints: true,
              ),
            ],
          ),
        ),
      ),
    );

    /*return ClipPath(
      clipper: const ShapeBorderClipper(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        width: double.infinity,
        height: MediaQuery.of(context).size.height / 3,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.1),
          border: Border(
            bottom: BorderSide(color: Color(0xFF1565C0), width: 1.5),
            left: BorderSide(color: Color(0xFF1565C0), width: 1.5),
          ),
        ),
        child: Chart(
          state: ChartState.line(
            ChartData.fromList(
              precios.map((e) => BubbleValue<void>(e)).toList(),
              axisMax: precioMin - 0.01,
            ),
            */ /*itemOptions: BubbleItemOptions(
              colorForValue: (_, value, [min]) {
                horaValor++;
                if (horaValor > 23) {
                  horaValor = 0;
                }
                if (value != null) {
                  if (hora == horaValor) {
                    return Colors.white;
                  }
                }
                return Colors.transparent;
              },
            ),*/ /*
            itemOptions: const BubbleItemOptions(color: Colors.transparent),
            backgroundDecorations: [
              HorizontalAxisDecoration(
                axisStep: 0.01,
                showLines: true,
                lineWidth: 0.1,
              ),
              VerticalAxisDecoration(
                showLines: true,
                lineWidth: 0.1,
                legendFontStyle: Theme.of(context)
                    .textTheme
                    .caption
                    ?.copyWith(fontSize: 10, color: Colors.white54),
                legendPosition: VerticalLegendPosition.bottom,
                axisStep: 1.0,
                showValues: true,
              ),
              */ /*TargetLineDecoration(
                target: dataHoy.calcularPrecioMedio(dataHoy.preciosHora),
                targetLineColor: Colors.blue,
                lineWidth: 1,
              ),*/ /*
            ],
            foregroundDecorations: [
              SparkLineDecoration(
                lineColor: Colors.white,
                lineWidth: 2,
                smoothPoints: true,
              ),
            ],
          ),
        ),
      ),
    );*/

    /*   return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Chart<void>(
        height: 600.0,
        state: ChartState(
          ChartData.fromList(
            valores.map((e) => BubbleValue<void>(e.precio)).toList(),
            //axisMax: 8.0,
          ),
          itemOptions: const BubbleItemOptions(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            maxBarWidth: 4.0,
          ),
          backgroundDecorations: [
            GridDecoration(
              verticalAxisStep: 1,
              horizontalAxisStep: 1,
            ),
          ],
          foregroundDecorations: [
            BorderDecoration(borderWidth: 5.0),
            SparkLineDecoration(),
          ],
        ),
      ),
    );*/
  }
}

/*class Grafico extends StatelessWidget {
  const Grafico({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}*/

/*class SimpleTimeSeriesChart extends StatelessWidget {
  //final List<charts.Series<Valor, DateTime>> seriesList;
  final bool animate;
  final List<Valor> valores;

  const SimpleTimeSeriesChart(this.valores, {Key? key, required this.animate}) : super(key: key);

  */ /*factory SimpleTimeSeriesChart.withSampleData() {
    return SimpleTimeSeriesChart(
      _createSampleData(),
      animate: false,
    );
  }*/ /*

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      //seriesList,
      _createSampleData2(),
      animate: animate,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  List<charts.Series<Valor, DateTime>> _createSampleData2() {
    final data = valores;
    return [
      charts.Series<Valor, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        //domainFn: (Valor sales, _) => sales.date,
        domainFn: (Valor sales, _) => DateTime.fromMillisecondsSinceEpoch(sales.date * 1000),
        measureFn: (Valor sales, _) => sales.precio,
        data: data,
      )
    ];
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<Valor, DateTime>> _createSampleData() {
    final data = [
      Valor(date: DateTime(2017, 9, 19).millisecondsSinceEpoch, precio: 5),
      Valor(date: DateTime(2017, 9, 26).millisecondsSinceEpoch, precio: 25),
      Valor(date: DateTime(2017, 10, 3).millisecondsSinceEpoch, precio: 100),
      Valor(date: DateTime(2017, 10, 10).millisecondsSinceEpoch, precio: 75),
    ];

    return [
      charts.Series<Valor, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        //domainFn: (Valor sales, _) => sales.date,
        domainFn: (Valor sales, _) => DateTime.fromMillisecondsSinceEpoch(sales.date * 1000),
        measureFn: (Valor sales, _) => sales.precio,
        data: data,
      )
    ];
  }
}*/

/*class Grafico extends StatelessWidget {
  final List<Valor> data;

  const Grafico({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<charts.Series<Valor, String>> series = [
      charts.Series(
          id: "developers",
          data: data,
          domainFn: (Valor series, _) => series.date,
          measureFn: (Valor series, _) => series.precio,
          //colorFn: (Valor series, _) => series.barColor)
    ];

    return charts.Barchart(series, animate: true);
  }
}*/

/*class Grafico extends StatelessWidget {
  final List<Valor> valores;
  //final bool isPositiveChange;

  const Grafico(this.valores, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final minY = valores.map((valor) => valor.precio).reduce(min);
    //final maxY = valores.map((valor) => valor.precio).reduce(max);

    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          //borderData: FlBorderData(show: false),
          //minY: minY,
          //minX: 0,
          //maxY: maxY,
          borderData: FlBorderData(
            border: const Border(
              bottom: BorderSide(),
              left: BorderSide(),
            ),
          ),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 22,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                //interval: 1,
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: valores.map((valor) => FlSpot(valor.date.toDouble(), valor.precio)).toList(),
              isCurved: false,
              //color: isPositiveChange ? Colors.green : Colors.red,
              dotData: FlDotData(
                show: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/

/*
Widget _grafico() {
  final spots = valores.reversed
      .toList()
      .asMap()
      .entries
      .map((element) => FlSpot(
    element.key.toDouble(),
    element.value.precio,
  ))
      .toList();

  return LineChart(
    LineChartData(
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        */
/*bottomTitles: AxisTitles(
            sideTitles: bottomTitles,
          ),*/ /*

        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        */
/*leftTitles: AxisTitles(
            sideTitles: leftTitles(),
          ),*/ /*

      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
        ),
      ],
    ),
    //swapAnimationDuration: Duration(milliseconds: 150), // Optional
    //swapAnimationCurve: Curves.linear, // Optional
  );
}*/
