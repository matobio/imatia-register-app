import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../../resources/utils/DateTimeUtils.dart';
import '../../resources/utils/MonthlyHours.dart';
import '../../resources/utils/EmployeeDataGetter.dart';

import '../drawer.dart';

class AnnualPage extends StatefulWidget {
  AnnualPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AnnualPageState createState() => _AnnualPageState();
}

class _AnnualPageState extends State<AnnualPage> {
  PageController _pageController;

  List<Model> listOfTimes = new List();
  int yearCount = DateTime.now().year;
  num appBarHeight = 0;

  void _getMoreData() async {
    int year = yearCount;

    List<MonthlyHours> times = await _getData(year);
    if (times != null || times.isNotEmpty) {
      // times.sort((a, b) => a.month.compareTo(b.month));
      // times = times.reversed.toList();
    }

    yearCount = yearCount - 1;
    setState(() {
      listOfTimes.addAll([Model(year, times)]);
    });
  }

  @override
  void initState() {
    this._getMoreData();

    super.initState();

    _pageController = PageController(initialPage: this.yearCount, keepPage: false);

    _pageController.addListener(() {
      if (_pageController.position.pixels == _pageController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<MonthlyHours>> _getData(int year) async {
    return await getEmployeeAnnualTimesMapped(year);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    AppBar appbat = AppBar(title: Text(widget.title));
    appBarHeight = appbat.preferredSize.height;

    return Scaffold(
      appBar: appbat,
      drawer: AppDrawer(),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemCount: listOfTimes.length + 1,
        itemBuilder: (context, index) {
          if (index == listOfTimes.length) {
            return _buildProgressIndicator();
          } else {
            return Container(
              width: screenSize.width,
              height: screenSize.height,
              child: StackedBarChart(listOfTimes[index], index, this.appBarHeight),
            );
          }
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: 1.0,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class StackedBarChart extends StatelessWidget {
  final Model pageData;
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
      if (currentMonth > lastMonthId ||
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
    String differenceHours = (positive ? "+" : "-") + this.pageData.getHoursString(hours);

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
    List<MonthlyHours> realHours = this.pageData == null ? new List<MonthlyHours>() : this.pageData.data;
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

class DonutAutoLabelChart extends StatelessWidget {
  final Model pageData;

  DonutAutoLabelChart(this.pageData);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        charts.PieChart(
          _createSampleData(),
          animate: true,
          defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 20,
          ),
        ),
        Center(
          child: Text(
            this.pageData == null ? "" : this.pageData.getHoursString(this.pageData.getTotalYearRealHours()),
            style: TextStyle(fontSize: 12.0, color: Colors.amber, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  List<charts.Series<TotalHours, int>> _createSampleData() {
    List<TotalHours> data = new List();
    double realHours = this.pageData.getTotalYearRealHours();
    double theoricHours = this.pageData.getTotalYearTheoricHours();

    data.add(TotalHours(
        1, realHours > theoricHours ? theoricHours : realHours, charts.ColorUtil.fromDartColor(Colors.green)));
    data.add(
        TotalHours(2, realHours > theoricHours ? 0.0 : theoricHours - realHours, charts.MaterialPalette.gray.shade700));

    return [
      new charts.Series<TotalHours, int>(
        id: 'Hours',
        domainFn: (TotalHours hours, _) => hours.index,
        measureFn: (TotalHours hours, _) => hours.hours * 100 / theoricHours,
        data: data,
        labelAccessorFn: (TotalHours hours, _) => hours.getHours(),
        colorFn: (TotalHours hours, _) => hours.color,
      )
    ];
  }
}

class TotalHours {
  final int index;
  final double hours;
  final charts.Color color;

  TotalHours(this.index, this.hours, this.color);

  String getHours() {
    return hours == 0 ? "" : num.parse(hours.toStringAsFixed(2)).toString();
  }
}

class Model {
  int year;
  List<MonthlyHours> data;

  Model(this.year, this.data);

  double getTotalYearRealHours() {
    double hours = 0.0;
    for (MonthlyHours e in data) {
      hours += e.getRealHoursNumber();
    }
    return hours;
  }

  double getTotalYearTheoricHours() {
    double hours = 0.0;
    for (MonthlyHours e in data) {
      hours += e.getTheoricHoursNumber();
    }
    return hours;
  }

  String getHoursString(double hours) {
    int differenceInHours = hours.toInt();
    int differenceInMinutes = ((hours * 60) % 60).toInt();

    return differenceInHours.toString() + "h " + differenceInMinutes.toString() + "min";
  }
}
