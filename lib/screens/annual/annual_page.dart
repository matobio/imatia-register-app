import 'package:flutter/material.dart';
import '../drawer.dart';
import '../../resources/utils/models/MonthlyHours.dart';
import '../../resources/utils/EmployeesService.dart' as employeesService;
import 'StackedBarChart.dart';
import 'utils/YearModel.dart';

class AnnualPage extends StatefulWidget {
  AnnualPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AnnualPageState createState() => _AnnualPageState();
}

class _AnnualPageState extends State<AnnualPage> {
  PageController _pageController;

  List<YearModel> listOfTimes = new List();
  int yearCount = DateTime.now().year;
  num appBarHeight = 0;

  void _getMoreData() async {
    List<MonthlyHours> times = await _getData(yearCount);

    setState(() {
      listOfTimes.addAll([YearModel(yearCount, times)]);
      yearCount = yearCount - 1;
    });
  }

  @override
  void initState() {
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
    return await employeesService.getEmployeeAnnualTimesMapped(year);
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
