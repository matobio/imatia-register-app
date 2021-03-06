import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../drawer.dart';
import '../../screens/times/utils/TimeModel.dart';
import '../../resources/utils/login/LoginService.dart' as loginService;
import '../../resources/utils/EmployeesService.dart' as employeesService;
import '../../resources/utils/NavigatorUtils.dart' as navigator;
import '../../resources/utils/DateTimeUtils.dart' as dateTimeUtils;

class CounterPage extends StatefulWidget {
  CounterPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int presenceControlHoursId;
  DateTime initDate, endDate;
  var _result;
  int totalDayMilis = 0;

  @override
  void initState() {
    loginService.checkLogin().then((result) async {
      if (result == false) {
        await loginService.login(context);
        _reloadPage();
      } else {
        _queryTimes().then((result) {
          setState(() {
            _result = 1;
          });
        });
      }
    });

    super.initState();
  }

  Future<void> _queryTimes() async {
    Map<String, dynamic> data = await employeesService.getEmployeeLastTime();

    if (data == null || data['code'] != 0) {
      loginService.login(context).then((result) {
        _reloadPage();
      });
    } else {
      this.presenceControlHoursId = data['data']['presence_control_hours_id'][0];
      this.initDate = new DateTime.fromMillisecondsSinceEpoch(data['data']['init_date'][0]);

      int endDateMiliseconds = data['data']['end_date'][0];
      if (endDateMiliseconds != null) {
        this.endDate = new DateTime.fromMillisecondsSinceEpoch(endDateMiliseconds);
      } else {
        this.endDate = null;
      }

      this.totalDayMilis = await employeesService.getTotalDayMilis();
    }
  }

  void _reloadPage() {
    navigator.goToCounterPage(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contador")),
      drawer: AppDrawer(),
      body: _createBody(context),
    );
  }

  Widget _createBody(BuildContext context) {
    if (_result == null) {
      return new Container();
    }
    return Center(
      child: Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                  child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                _createDatesRow(),
                _getTimerButton(),
                _createCounterField(),
              ])),
              Container(
                  child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                _createDayCounterField(),
              ]))
            ]),
      ),
    );
  }

  Widget _createDatesRow() {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            createField(_getInitDate(), 18, TextAlign.center, FontWeight.normal),
            createField(_getInitDateHour(), 60, TextAlign.end, FontWeight.bold),
          ],
        ),
        Column(
          children: <Widget>[
            createField("", 18, TextAlign.center, FontWeight.normal),
            Row(
              children: <Widget>[
                Container(
                  width: 50,
                  child: Text(
                    "-",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        Column(
          children: <Widget>[
            createField(_getEndDate(), 18, TextAlign.start, FontWeight.normal),
            createField(_getEndDateHour(), 60, TextAlign.start, FontWeight.bold),
          ],
        ),
      ],
    ));
  }

  Widget createField(String text, double fontSize, TextAlign textAlign, FontWeight fontWeight) {
    return Row(
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(left: 0.0, top: 10.0, right: 0.0, bottom: 0.0),
            child: Text(
              text == null ? "" : text,
              textAlign: textAlign,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _createCounterField() {
    return Container(
        // color: Colors.cyan,
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.symmetric(vertical: 0.0),
            child: StreamBuilder(
                stream: Stream.periodic(Duration(seconds: 1), (i) => i),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  return _createHourText(_getCounterTime());
                })),
      ],
    ));
  }

  Widget _createDayCounterField() {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.symmetric(vertical: 0.0),
            child: StreamBuilder(
                stream: Stream.periodic(Duration(seconds: 1), (i) => i),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  return Padding(
                      padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
                      child: Container(
                        child: Center(
                          child: Text(
                            _getTotalCounterTime(),
                            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                        ),
                      ));
                })),
      ],
    ));
  }

  Widget _createHourText(String text) {
    return Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
        child: Container(
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));
  }

  Widget _getTimerButton() {
    IconData icon = Icons.play_arrow;
    MaterialColor backgroundColor = Colors.green;
    if (this.endDate == null) {
      icon = Icons.stop;
      backgroundColor = Colors.red;
    }

    return Container(
        child: Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Center(
        child: SizedBox(
          width: 250.0,
          height: 250.0,
          child: FloatingActionButton(
            backgroundColor: backgroundColor,
            child: LayoutBuilder(builder: (context, constraint) {
              return Icon(icon, size: constraint.biggest.height);
            }),
            onPressed: () async {
              await _onPressTimerButton().then((result) {
                setState(() {
                  _result = 1;
                });
              });
            },
          ),
        ),
      ),
    ));
  }

  Future<void> _onPressTimerButton() async {
    if (_isStopped()) {
      this.initDate = DateTime.now(); // Esto para no esperar la llamada y que vaya renderizando
      this.endDate = null; // Esto para no esperar la llamada y que vaya renderizando
      _startTiming();
    } else {
      this.endDate = DateTime.now(); // Esto para no esperar la llamada y que vaya renderizando
      _stopTiming();
    }
  }

  Future<void> _startTiming() async {
    if (await employeesService.startTiming()) {
      await _queryTimes();
    } else {
      _reloadPage();
    }
  }

  Future<void> _stopTiming() async {
    if (await employeesService.stopTiming()) {
      await _queryTimes();
    } else {
      _reloadPage();
    }
  }

  bool _isStopped() {
    return this.endDate != null;
  }

  String _getCounterTime() {
    if (this.endDate != null) {
      return "";
    }
    Duration difference = DateTime.now().difference(this.initDate);

    return formatToTimer(difference);
  }

  String formatToTimer(Duration difference) {
    if (difference == null) {
      return "";
    }
    String hours = difference.inHours.toString().padLeft(2, '0');
    String minutes = difference.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = difference.inSeconds.remainder(60).toString().padLeft(2, '0');

    return "$hours:$minutes:$seconds";
  }

  String _getTotalCounterTime() {
    TimeModel date = TimeModel(null, DateTime.now().millisecondsSinceEpoch, null, null, null);

    return date.getDatePretty() + " - " + formatToTimer(calculateTotalDayTime());
  }

  Duration calculateTotalDayTime() {
    int milliseconds = this.totalDayMilis;
    if (!_isStopped()) {
      Duration time = DateTime.now().difference(this.initDate);
      milliseconds += time.inMilliseconds;
    }
    return Duration(milliseconds: milliseconds);
  }

  String _getInitDateHour() {
    return _formatDateToHour(this.initDate);
  }

  String _getEndDateHour() {
    return _formatDateToHour(this.endDate);
  }

  String _formatDateToHour(DateTime date) {
    if (date == null) {
      return "";
    }
    return DateFormat('HH:mm').format(date);
  }

  String _getInitDate() {
    return dateTimeUtils.formatDate(this.initDate);
  }

  String _getEndDate() {
    return dateTimeUtils.formatDate(this.endDate);
  }
}
