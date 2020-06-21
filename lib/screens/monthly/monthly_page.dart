import 'package:flutter/material.dart';
import '../drawer.dart';
import '../../resources/utils/EmployeeDataGetter.dart';
import '../../resources/utils/MonthlyHours.dart';

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
  List<MonthlyHours> monthlyHours = new List();

  Future<List<MonthlyHours>> _queryTimes() async {
    return await getEmployeeMonthlyTimes(this.offset, this.pagesize);
  }

  void _getMoreData() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      List<MonthlyHours> times = await _queryTimes();
      this.offset = this.offset + this.pagesize;

      setState(() {
        isLoading = false;
        monthlyHours.addAll(times);
      });
    }
  }

  @override
  void initState() {
    this._getMoreData();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
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

  Widget _buildList() {
    return ListView.builder(
      itemCount: monthlyHours.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == monthlyHours.length) {
          return _buildProgressIndicator();
        } else {
          return _buildRow(monthlyHours[index]);
        }
      },
      controller: _scrollController,
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

  Widget _buildRow(MonthlyHours pair) {
    return Container(
        child: Padding(
      padding: EdgeInsets.only(),
      child: Column(
        children: <Widget>[
          _getMonthRow(pair),
          _getHoursRow(pair),
          Divider(),
        ],
      ),
    ));
  }

  Widget createField(String text, double fontSize, TextAlign textAlign,
      FontWeight fontWeight, Color color) {
    TextStyle style =
        TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color);
    if (text.startsWith("+")) {
      style = TextStyle(
          fontSize: fontSize, fontWeight: fontWeight, color: Colors.lightGreen);
    }
    if (text.startsWith("-")) {
      style = TextStyle(
          fontSize: fontSize, fontWeight: fontWeight, color: Colors.red);
    }
    return Row(
      children: <Widget>[
        Container(
          child: Padding(
            padding:
                EdgeInsets.only(left: 0.0, top: 2.0, right: 0.0, bottom: 2.0),
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

  Widget _getMonthRow(MonthlyHours pair) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10, bottom: 10),
          child: createField(pair.getMonthAndYear(), 25, TextAlign.start,
              FontWeight.bold, Colors.lightBlueAccent),
        )
      ],
    );
  }

  Widget _getHoursRow(MonthlyHours pair) {
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
                            createField("Real:", 18, TextAlign.start,
                                FontWeight.normal, Colors.white),
                            createField("Teórico:", 18, TextAlign.start,
                                FontWeight.normal, Colors.white),
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
                            createField(pair.realHours, 18, TextAlign.start,
                                FontWeight.bold, Colors.white),
                            createField(pair.theoricHours, 18, TextAlign.start,
                                FontWeight.bold, Colors.white),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Column(children: <Widget>[
                createField(pair.getDifference(), 18, TextAlign.start,
                    FontWeight.bold, Colors.white),
              ]),
            ],
          ),
        )
      ],
    );
  }
}
