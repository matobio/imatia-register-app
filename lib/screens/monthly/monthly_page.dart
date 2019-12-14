import 'package:flutter/material.dart';
import '../drawer.dart';
import '../../resources/utils/DateTimeUtils.dart';
import '../../resources/utils/EmployeeDataGetter.dart';

class MonthlyPage extends StatefulWidget {
  MonthlyPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MonthlyPageState createState() => _MonthlyPageState();
}

class _MonthlyPageState extends State<MonthlyPage> {

  int offset = 0;
  int pagesize = 20;
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;
  List<Model> names = new List();

  Future<List<Model>> _queryTimes()  async {
      
    Map<String,dynamic> data = await getMonthlyTimes(this.offset, this.pagesize);

    List<Model>  times = new List();
    List<dynamic> list = data['data']['month_numeric'];
    list = list == null ? new List() : list;
    for( var i = 0 ; i < list.length; i++ ) { 
      times.add(Model( data['data']['year'][i], data['data']['month_numeric'][i], data['data']['labor_hours'][i], data['data']['hours'][i] ));
    } 
    return times;
  }

  void _getMoreData() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      List<Model>  times = await _queryTimes();
      this.offset = this.offset + this.pagesize;

      setState(() {
        isLoading = false;
        names.addAll(times);
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: AppDrawer(),
      body: Container(
        child: _buildList(),
      ),
    );
  }
  

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: names.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == names.length) {
          return _buildProgressIndicator();
        } else {
          return _buildRow(names[index]);
        }
      },
      controller: _scrollController,
    );
  }

  Widget _buildRow(Model pair) {
    return Container(
      child: 
      Padding(
        padding: EdgeInsets.only(),
        child: Column(
          children: <Widget>[
            _getMonthRow(pair),
            _getHoursRow(pair),  
            Divider(),
          ],
        ),
      )
      
    );
  }

  Widget createField(String text, double fontSize, TextAlign textAlign, FontWeight fontWeight, Color color){

    TextStyle style = TextStyle(
      fontSize: fontSize, 
      fontWeight: fontWeight,
      color: color
    );
    if(text.startsWith("+")){
      style = TextStyle(
        fontSize: fontSize, 
        fontWeight: fontWeight, 
        color: Colors.lightGreen
      );
    }
    if(text.startsWith("-")){
      style = TextStyle(
        fontSize: fontSize, 
        fontWeight: fontWeight, 
        color: Colors.red
      );
    }
    return Row(
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(left : 0.0, top : 2.0, right : 0.0, bottom :2.0),
            child: Text(
              text,
              textAlign: textAlign,
              style: style,
            ),
          ),
        )
      ],
    );
  }

  Widget _getMonthRow(Model pair){
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10,bottom: 10),
          child: 
            createField(pair.getMonthAndYear(), 25, TextAlign.start, FontWeight.bold, Colors.lightBlueAccent),
        )
      ],
    );
  }

  

  Widget _getHoursRow(Model pair){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 90,
                        child: Column(
                          children: <Widget>[
                            createField("Real:", 18, TextAlign.start, FontWeight.normal, Colors.white),
                            createField("Teórico:", 18, TextAlign.start, FontWeight.normal, Colors.white),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 150,
                        child: Column(
                          children: <Widget>[
                            createField(pair.hours, 18, TextAlign.start, FontWeight.bold ,Colors.white),
                            createField(pair.laborHours, 18, TextAlign.start, FontWeight.bold ,Colors.white),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  createField(pair.getDifference(), 18, TextAlign.start, FontWeight.bold ,Colors.white),
                ]
              ),
            ],
          ),
        )
      ],
    );
  }


  
}


class Model {
   int year;
   int month;
   String laborHours;
   String hours;

  Model(year, month, laborHours, hours){
    this.year = year;
    this.month = month;
    this.laborHours = laborHours;
    this.hours = hours;
  }

  String getMonthAndYear(){

    String month = getMonthAsString(this.month);
    return month + " " + this.year.toString();
  }

  String getDifference(){

    String  diff = "";

    int realHours = 0;
    int theoricHours = 0;
    int realMinutes = 0;
    int theoricMinutes = 0;
    try{
      realHours = int.parse(this.laborHours.split("h")[0]);
      theoricHours = int.parse(this.hours.split("h")[0]);
      realMinutes = int.parse(this.laborHours.split("h")[1].replaceAll("min", "").trim());
      theoricMinutes = int.parse(this.hours.split("h")[1].replaceAll("min", "").trim());

    } catch(Exception){}

    double difference = (theoricHours * 60.0 + theoricMinutes) - (realHours * 60.0 + realMinutes);
    diff = difference > 0 ? "+":"-";

    int differenceInHours = difference ~/ 60;
    int differenceInMinutes = (difference.abs() % 60).toInt();

    diff = diff + differenceInHours.toString().replaceAll("-", "") + "h " + differenceInMinutes.toString() + "min";

    return diff;
  }
}