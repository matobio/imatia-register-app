import 'package:elastic_hours/resources/utils/DateTimeUtils.dart';
import 'package:elastic_hours/resources/utils/DayHours.dart';
import 'package:elastic_hours/resources/utils/EmployeeDataGetter.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

import '../drawer.dart';

const int THEORIC_WEEK_HOURS = 40;
const String KEY_INIT_DATE = "init_date";
const String KEY_END_DATE = "end_date";

class WeeklyPage extends StatefulWidget {
  WeeklyPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WeeklyPageState createState() => _WeeklyPageState();
}

class _WeeklyPageState extends State<WeeklyPage> {

  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;
  Model pageData;

  Map<String,DateTime> getDates(){

    // Get the first day of the week
    DateTime initDate = DateTime.now();
    for(int i = initDate.weekday; i > DateTime.monday; i--){
      initDate = initDate.subtract(new Duration(days: 1));
    }
    initDate = DateTime(initDate.year, initDate.month, initDate.day);

    // Get the last day of the week
    DateTime endDate = DateTime.now();
    if(endDate.weekday > DateTime.friday){
      for(int i = endDate.weekday; i > DateTime.friday; i--){
        endDate = endDate.subtract(new Duration(days: 1));
      }
    }
    else{
      for(int i = endDate.weekday; i < DateTime.friday; i++){
        endDate = endDate.add(new Duration(days: 1));
      }
    }
    endDate = DateTime(endDate.year, endDate.month, endDate.day+1);

    return  {KEY_INIT_DATE: initDate, KEY_END_DATE: endDate};
  }

  void _getMoreData() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      Map<String,DateTime> dates = getDates();
      DateTime initDate = dates[KEY_INIT_DATE];
      DateTime endDate = dates[KEY_END_DATE];

      List<DayHours>  times = await _getData(initDate, endDate);
      setState(() {
        isLoading = false;
        this.pageData = Model(initDate, endDate, times);
      });
    }
  }

  @override
  void initState() {
   
    this._getMoreData();
   
    super.initState();
  
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==  _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  Future<List<DayHours>> _getData(DateTime initDate, DateTime endDate)  async {
    return await getEmployeeTimesMapped(initDate, endDate);
  }    

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: AppDrawer(),
      body: StackedBarChart(this.pageData, animate: true),
    );
  }

}

class StackedBarChart extends StatelessWidget {
  final bool animate;
  final Model pageData;

  StackedBarChart(this.pageData,  {this.animate});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.maxFinite,
      child: Stack(
        children: <Widget>[
          _getHeaderData(),
          _getBarChartWidget(),
        ],
      ),
    );
  }

  

  Widget _getBarChartWidget(){
    return Positioned(
      child: Align(
        alignment: FractionalOffset.center,
        child: 
          Container(
            alignment: AlignmentDirectional.bottomCenter,
            height: 400,
            padding: EdgeInsets.only(left: 10,top: 50, right: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: _getBarChart(),
                    )
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }

  Widget _getHeaderData(){
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _getInfoDataWidget(),
          Container(
            child:  
              Column(
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

  Widget _getInfoDataWidget(){
    return Container(
      child: 
        Column(
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
                            createField(pageData==null?"":pageData.getInitDateFormatted(), 18, TextAlign.start, FontWeight.normal),
                            createField(pageData==null?"":pageData.getEndDateFormatted(), 18, TextAlign.start, FontWeight.normal),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
  Widget _getDonutChartWidget(){
   return Container(
    alignment: AlignmentDirectional.topCenter,
    constraints: BoxConstraints( maxWidth: 170),
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

  Widget createField(String text, double fontSize, TextAlign textAlign, FontWeight fontWeight){
    return Row(
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(left : 0.0, top : 2.0, right : 0.0, bottom :2.0),
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

  Widget _getBarChart(){
    return  charts.BarChart(
      _createSeries(),
      animate: animate,
      barGroupingType: charts.BarGroupingType.stacked,
      barRendererDecorator: charts.BarLabelDecorator(),
      behaviors: [
        new charts.SeriesLegend(
          position: charts.BehaviorPosition.top,
          horizontalFirst: false,
          cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
          showMeasures: true,
          measureFormatter: (num value) {
            return value == null ? '-' : '${value}k';
          },

        ),
      ],
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle:  charts.TextStyleSpec(
            fontSize: 18, 
            color: charts.MaterialPalette.white
          ),
          lineStyle: charts.LineStyleSpec(
            color: charts.MaterialPalette.white
          )
        ),
      ),
      primaryMeasureAxis: new charts.NumericAxisSpec(
        renderSpec: new charts.GridlineRendererSpec(
          labelStyle: new charts.TextStyleSpec(
            fontSize: 18, 
            color: charts.MaterialPalette.white,
          ),
          lineStyle: new charts.LineStyleSpec(
            color: charts.MaterialPalette.white
          ),
        ),
        tickProviderSpec: charts.StaticNumericTickProviderSpec(
          <charts.TickSpec<num>>[
            charts.TickSpec<num>(0),
            charts.TickSpec<num>(2),
            charts.TickSpec<num>(4),
            charts.TickSpec<num>(6),
            charts.TickSpec<num>(8),
          ],
        ),
      ),
    );
  }

  List<charts.Series<DayHours, String>> _createSeries()  {

    final realHours = this.pageData == null ? new List<DayHours>() : this.pageData.data;

    return [
      charts.Series<DayHours, String>(
        id: 'Horas registradas',
        domainFn: (DayHours hours, _) => hours.parseWeekday(),
        measureFn: (DayHours hours, _) => hours.hours,
        data: realHours,
        labelAccessorFn: (DayHours hours, _) => hours.getHours(),
        insideLabelStyleAccessorFn: (DayHours hours, _) => charts.TextStyleSpec(
          color: charts.MaterialPalette.white,
        ),
        colorFn: (DayHours hours, _) => charts.MaterialPalette.blue.shadeDefault.darker,
      ),
    ];
  }

  String getWeekNumber(Model pageData){
    if(pageData == null){
      return "";
    }
    return pageData.initDate== null ? "" : getWeekOfYear(pageData.initDate ).toString();
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
        charts.PieChart(_createSampleData(),
            animate: true,
            defaultRenderer: new charts.ArcRendererConfig(
                arcWidth: 20,
            ),

        ),
        Center(
          child: Text(
            this.pageData == null ? "" : this.pageData.getTotalWeekHoursString(),
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.amber,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
  );
  }

  List<charts.Series<TotalHours, int>> _createSampleData() {
    List<TotalHours> data = new List();
    double realHours = pageData == null ? 0.0 : this.pageData.getTotalWeekHours();
    data.add(TotalHours(1, realHours > THEORIC_WEEK_HOURS.toDouble() ? THEORIC_WEEK_HOURS.toDouble() : realHours, charts.ColorUtil.fromDartColor(Colors.green)));
    data.add(TotalHours(2, realHours > THEORIC_WEEK_HOURS.toDouble() ? 0.0 :THEORIC_WEEK_HOURS.toDouble()-realHours, charts.MaterialPalette.gray.shade700));

    return [
      new charts.Series<TotalHours, int>(
        id: 'Hours',
        domainFn: (TotalHours hours, _) => hours.index,
        measureFn: (TotalHours hours, _) => hours.hours*100/THEORIC_WEEK_HOURS,
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

  TotalHours(this.index, this.hours,this.color);

  String getHours(){
    return hours == 0 ? "" : num.parse(hours.toStringAsFixed(2)).toString();
  }
}

class Model {

  final dateFormatter = DateFormat("yyyy/MM/dd");
  DateTime initDate;
  DateTime endDate;
  List<DayHours> data;

  Model(this.initDate, this.endDate, this.data);

  double getTotalWeekHours(){

    double hours = 0.0;
    for (DayHours e in data) {
      hours += e.hours;
    }
    return hours;
  }

  String getTotalWeekHoursString(){
    double hours = getTotalWeekHours();

    int differenceInHours = hours.toInt();
    int differenceInMinutes = (hours % 60).toInt();

    return differenceInHours.toString() + "h " + differenceInMinutes.toString() + "min";
  }

  String getInitDateFormatted(){
    return _getDateFormatted(this.initDate);
  }

  String getEndDateFormatted(){
    return _getDateFormatted(this.endDate);
  }

  String _getDateFormatted(DateTime date){
    return date == null ? "" : dateFormatter.format(date);
  }

  
}