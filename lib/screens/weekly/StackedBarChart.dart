import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../../resources/utils/DateTimeUtils.dart';
import '../../resources/utils/models/DayHours.dart';
import 'utils/WeeklyModel.dart';
import 'DonutAutoLabelChart.dart';

class StackedBarChart extends StatelessWidget {
  final WeeklyModel pageData;
  final int index;

  StackedBarChart(this.pageData, this.index);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _getHeaderData(),
          _getBarChartWidget(context),
        ],
      ),
    );
  }

  Widget _getBarChartWidget(BuildContext context) {
    return Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(10.0), child: _getBarChart())));
  }

  Widget _getHeaderData() {
    return Container(
      padding: EdgeInsets.all(10),
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
                padding: EdgeInsets.only(bottom: 5),
                alignment: AlignmentDirectional.centerStart,
                child: createField("Semana " + this.getWeekNumber(this.pageData), 24, TextAlign.start, FontWeight.bold),
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
                        createField("Desde:", 18, TextAlign.start, FontWeight.normal),
                        createField("Hasta:", 18, TextAlign.start, FontWeight.normal),
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
                        width: 140,
                        constraints: BoxConstraints(maxWidth: 100),
                        child: Column(
                          children: <Widget>[
                            createField(pageData == null ? "" : pageData.getInitDateFormatted(), 18, TextAlign.start,
                                FontWeight.normal),
                            createField(pageData == null ? "" : pageData.getEndDateFormatted(), 18, TextAlign.start,
                                FontWeight.normal),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 5),
                alignment: AlignmentDirectional.centerStart,
                child: createFieldHoursRemaining(pageData),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Row createFieldHoursRemaining(WeeklyModel pageData) {
    double hours = pageData.getRemainingHours();

    Color color = hours > 0 ? Colors.red : Colors.lightGreen;

    String hoursFormatted = pageData.formatHours(hours);
    hoursFormatted = hours > 0 ? "-" + hoursFormatted : "+" + hoursFormatted;

    return Row(
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(left: 0.0, top: 5.0, right: 0.0, bottom: 2.0),
            child: Text(
              hoursFormatted,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        )
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

  Widget createField(String text, double fontSize, TextAlign textAlign, FontWeight fontWeight) {
    return Row(
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(left: 0.0, top: 2.0, right: 0.0, bottom: 2.0),
            child: Text(
              text,
              textAlign: textAlign,
              style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
            ),
          ),
        )
      ],
    );
  }

  Widget _getBarChart() {
    return charts.BarChart(
      _createSeries(),
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
        tickProviderSpec: getNumericTickSpec(pageData.getYear(), pageData.getMonth()),
      ),
    );
  }

  charts.StaticNumericTickProviderSpec getNumericTickSpec(int year, int month) {
    if (year != null && month != null) {
      if (month == DateTime.july || month == DateTime.august) {
        return charts.StaticNumericTickProviderSpec(
          <charts.TickSpec<num>>[
            charts.TickSpec<num>(0),
            charts.TickSpec<num>(1),
            charts.TickSpec<num>(2.5),
            charts.TickSpec<num>(4),
            charts.TickSpec<num>(5.5),
            charts.TickSpec<num>(7),
          ],
        );
      }
      if (year < 2021) {
        return charts.StaticNumericTickProviderSpec(
          <charts.TickSpec<num>>[
            charts.TickSpec<num>(0),
            charts.TickSpec<num>(2),
            charts.TickSpec<num>(4),
            charts.TickSpec<num>(6),
            charts.TickSpec<num>(8),
          ],
        );
      }
    }
    return charts.StaticNumericTickProviderSpec(
      <charts.TickSpec<num>>[
        charts.TickSpec<num>(0),
        charts.TickSpec<num>(1),
        charts.TickSpec<num>(3),
        charts.TickSpec<num>(5),
        charts.TickSpec<num>(7),
        charts.TickSpec<num>(8.5),
      ],
    );
  }

  List<charts.Series<DayHours, String>> _createSeries() {
    final realHours = this.pageData == null ? [] : this.pageData.data;

    return [
      charts.Series<DayHours, String>(
        id: 'Horas registradas',
        domainFn: (DayHours hours, _) => hours.parseWeekday(),
        measureFn: (DayHours hours, _) => hours.hours,
        data: realHours,
        labelAccessorFn: (DayHours hours, _) => hours.getHoursFormatted(),
        insideLabelStyleAccessorFn: (DayHours hours, _) => charts.TextStyleSpec(
          color: charts.MaterialPalette.white,
        ),
        colorFn: (DayHours hours, _) => charts.MaterialPalette.blue.shadeDefault.darker,
      ),
    ];
  }

  String getWeekNumber(WeeklyModel pageData) {
    if (pageData == null) {
      return "";
    }
    return pageData.initDate == null ? "" : getWeekOfYear(pageData.initDate).toString();
  }
}
