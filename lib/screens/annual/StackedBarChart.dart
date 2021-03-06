import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../../resources/utils/DateTimeUtils.dart';
import '../../resources/utils/models/MonthlyHours.dart';
import 'DonutAutoLabelChart.dart';
import 'utils/YearModel.dart';

class StackedBarChart extends StatelessWidget {
  final YearModel pageData;
  final int index;
  final double appBarHeight;

  StackedBarChart(this.pageData, this.index, this.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _getHeaderData(context),
          _getBarChartWidget(context),
        ],
      ),
    );
  }

  Widget _getBarChartWidget(BuildContext context) {
    return Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(10.0), child: _getBarChart())));
  }

  Widget _getHeaderData(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _getInfoDataWidget(),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    _getDonutChartWidget(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getInfoDataWidget() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 5, top: 5),
                alignment: AlignmentDirectional.centerStart,
                child: createField("Año " + this.pageData.year.toString(), 24, TextAlign.start, FontWeight.bold,
                    colorText: Colors.lightBlueAccent),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: 70,
                    child: Column(
                      children: <Widget>[
                        createField("Real:", 18, TextAlign.start, FontWeight.normal),
                        createField("Teórico:", 18, TextAlign.start, FontWeight.normal),
                      ],
                    ),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 120,
                        child: Column(
                          children: <Widget>[
                            createField(
                                pageData == null ? "" : pageData.getHoursString(pageData.getTotalYearRealHours()),
                                18,
                                TextAlign.start,
                                FontWeight.bold),
                            createField(
                                pageData == null ? "" : pageData.getHoursString(pageData.getTotalYearTheoricHours()),
                                18,
                                TextAlign.start,
                                FontWeight.bold),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(children: <Widget>[_getDifferenceRow()]),
        ],
      ),
    );
  }

  Widget _getDifferenceRow() {
    List<MonthlyHours> data = this.pageData.data;
    if (data == null || data.isEmpty) {
      return Text("");
    }
    data.sort((a, b) => a.month.compareTo(b.month));

    int currentYear = DateTime.now().year;
    int currentMonth = DateTime.now().month;
    int year = data.elementAt(this.pageData.data.length - 1).year;
    int lastMonthId = data.elementAt(this.pageData.data.length - 1).month;
    bool isCurrentYear = year >= currentYear;

    String initMonth = data.elementAt(0).getMonthString();
    // El ultimo mes desde el que calculamos las horas es el mes anterior (o el mes actual si estamos en el ultimo dia) o Diciembre en
    // caso de que estemos en un año anterior.
    // Si estamos en el año actual y estamos en un mes donde aun no hemos registrado tiempos cogemos el ultimo mes, si no el mes anterior.
    String lastMonth;
    int lastMonthToCalculate;

    if (isCurrentYear) {
      if (currentMonth == DateTime.january ||
          currentMonth > lastMonthId ||
          (currentMonth == lastMonthId && isLastLaborableDayOfMonthOrGreater(DateTime.now()))) {
        lastMonth = data.elementAt(this.pageData.data.length - 1).getMonthString();
        lastMonthToCalculate = data.elementAt(this.pageData.data.length - 1).month + 1;
      } else {
        lastMonth = data.elementAt(this.pageData.data.length - 2).getMonthString();
        lastMonthToCalculate = data.elementAt(this.pageData.data.length - 1).month;
      }
    } else {
      lastMonth = data.elementAt(this.pageData.data.length - 1).getMonthString();
      lastMonthToCalculate = data.elementAt(this.pageData.data.length - 1).month;
    }

    double totalTheoricHours = 0;
    double totalRealHours = 0;
    for (int i = 0; i < data.length; i++) {
      if (data.elementAt(i).month < lastMonthToCalculate || !isCurrentYear) {
        totalTheoricHours += data.elementAt(i).getTheoricHoursNumber();
        totalRealHours += data.elementAt(i).getRealHoursNumber();
      }
    }
    double hours = totalRealHours - totalTheoricHours;
    bool positive = hours >= 0;
    String differenceHours = (positive ? "+" : "") + this.pageData.getHoursString(hours);

    return Column(
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(left: 0.0, top: 20, right: 0.0, bottom: 2.0),
            child: Row(
              children: <Widget>[
                Text(
                  initMonth,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
                Icon(Icons.arrow_right),
                Text(
                  lastMonth,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
        Text(
          differenceHours,
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: positive ? Colors.lightGreen : Colors.red),
        ),
      ],
    );
  }

  Widget _getDonutChartWidget() {
    return Container(
      alignment: AlignmentDirectional.topCenter,
      constraints: BoxConstraints(maxWidth: 170),
      height: 170,
      padding: EdgeInsets.all(0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: DonutAutoLabelChart(this.pageData),
          )
        ],
      ),
    );
  }

  Widget createField(String text, double fontSize, TextAlign textAlign, FontWeight fontWeight, {Color colorText}) {
    return Row(
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(left: 0.0, top: 2.0, right: 0.0, bottom: 2.0),
            child: Text(
              text,
              textAlign: textAlign,
              style: TextStyle(
                  fontSize: fontSize, fontWeight: fontWeight, color: colorText != null ? colorText : Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Widget _getBarChart() {
    return charts.BarChart(
      _createSeries(),
      vertical: false,
      animate: true,
      barGroupingType: charts.BarGroupingType.stacked,
      barRendererDecorator: charts.BarLabelDecorator(),
      behaviors: [
        new charts.SeriesLegend(
          position: charts.BehaviorPosition.top,
          horizontalFirst: false,
          cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
          showMeasures: true,
          measureFormatter: (num value) {
            return value == null ? '' : parseHours(value);
          },
        ),
      ],
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
            labelStyle: charts.TextStyleSpec(fontSize: 18, color: charts.MaterialPalette.white),
            lineStyle: charts.LineStyleSpec(color: charts.MaterialPalette.white)),
      ),
      primaryMeasureAxis: new charts.NumericAxisSpec(
        renderSpec: new charts.GridlineRendererSpec(
          labelStyle: new charts.TextStyleSpec(
            fontSize: 18,
            color: charts.MaterialPalette.white,
          ),
          lineStyle: new charts.LineStyleSpec(color: charts.MaterialPalette.white),
        ),
        tickProviderSpec: charts.StaticNumericTickProviderSpec(
          <charts.TickSpec<num>>[
            charts.TickSpec<num>(0),
            charts.TickSpec<num>(60),
            charts.TickSpec<num>(120),
            charts.TickSpec<num>(180)
          ],
        ),
      ),
    );
  }

  List<charts.Series<MonthlyHours, String>> _createSeries() {
    List<MonthlyHours> realHours = this.pageData == null ? [] : this.pageData.data;
    if (realHours != null || realHours.isNotEmpty) {
      realHours.sort((a, b) => a.month.compareTo(b.month));
      realHours = realHours.reversed.toList();
    }
    return [
      charts.Series<MonthlyHours, String>(
        id: 'Horas registradas',
        domainFn: (MonthlyHours hours, _) => hours.getMonthString(),
        measureFn: (MonthlyHours hours, _) => hours.getRealHoursNumber(),
        data: realHours,
        labelAccessorFn: (MonthlyHours hours, _) => hours.getRealHours(),
        insideLabelStyleAccessorFn: (MonthlyHours hours, _) => charts.TextStyleSpec(
          color: charts.MaterialPalette.white,
        ),
        outsideLabelStyleAccessorFn: (MonthlyHours hours, _) => charts.TextStyleSpec(
          color: charts.MaterialPalette.white,
        ),
        colorFn: (MonthlyHours hours, _) => charts.MaterialPalette.blue.shadeDefault.darker,
      ),
    ];
  }
}
