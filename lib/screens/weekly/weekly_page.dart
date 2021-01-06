import 'package:flutter/material.dart';
import '../drawer.dart';
import '../../resources/utils/models/DayHours.dart';
import '../../resources/utils/EmployeesService.dart' as employeesService;
import 'StackedBarChart.dart';
import 'utils/WeeklyModel.dart';

const String KEY_INIT_DATE = "init_date";
const String KEY_END_DATE = "end_date";

class WeeklyPage extends StatefulWidget {
  WeeklyPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WeeklyPageState createState() => _WeeklyPageState();
}

class _WeeklyPageState extends State<WeeklyPage> {
  PageController _pageController;

  List<WeeklyModel> listOfTimes = new List();
  int weekCount = 0;

  Map<String, DateTime> _getDates() {
    DateTime initialDate = DateTime.now();
    initialDate = initialDate.subtract(Duration(days: this.weekCount * 7));

    // Get the first day of the week
    DateTime initDate = initialDate;
    for (int i = initDate.weekday; i > DateTime.monday; i--) {
      initDate = initDate.subtract(new Duration(days: 1));
    }
    initDate = DateTime(initDate.year, initDate.month, initDate.day);

    // Get the last day of the week
    DateTime endDate = initialDate;
    if (endDate.weekday > DateTime.friday) {
      for (int i = endDate.weekday; i > DateTime.friday; i--) {
        endDate = endDate.subtract(new Duration(days: 1));
      }
    } else {
      for (int i = endDate.weekday; i < DateTime.friday; i++) {
        endDate = endDate.add(new Duration(days: 1));
      }
    }
    endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    return {KEY_INIT_DATE: initDate, KEY_END_DATE: endDate};
  }

  void _getMoreData() async {
    Map<String, DateTime> dates = _getDates();
    DateTime initDate = dates[KEY_INIT_DATE];
    DateTime endDate = dates[KEY_END_DATE];

    List<DayHours> times = await _getData(initDate, endDate);
    weekCount = weekCount + 1;
    setState(() {
      listOfTimes.addAll([WeeklyModel(initDate, endDate, times)]);
    });
  }

  @override
  void initState() {
    this._getMoreData();

    super.initState();

    _pageController = PageController(initialPage: this.weekCount, keepPage: false);

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

  Future<List<DayHours>> _getData(DateTime initDate, DateTime endDate) async {
    return await employeesService.getEmployeeTimesMapped(initDate, endDate);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
              child: StackedBarChart(listOfTimes[index], index),
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
