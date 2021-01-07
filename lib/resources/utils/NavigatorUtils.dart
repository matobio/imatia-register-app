import 'package:flutter/material.dart';
import '../../screens/home_page.dart';
import '../../screens/counter/counter_page.dart';
import '../../screens/times/times_page.dart';
import '../../screens/weekly/weekly_page.dart';
import '../../screens/monthly/monthly_page.dart';
import '../../screens/annual/annual_page.dart';

Future goTo(BuildContext context, Widget widget) {
  return Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
}

Future goToHomePage(BuildContext context) {
  return goTo(context, MyHomePage());
}

Future goToCounterPage(BuildContext context) {
  return goTo(context, CounterPage(title: "Contador"));
}

Future goToTimesPage(BuildContext context) {
  return goTo(context, TimesPage(title: "Tiempos"));
}

Future goToMonthlyPage(BuildContext context) {
  return goTo(context, MonthlyPage(title: "Mensual"));
}

Future goToWeeklyPage(BuildContext context) {
  return goTo(context, WeeklyPage(title: "Semanal"));
}

Future goToAnnualPage(BuildContext context) {
  return goTo(context, AnnualPage(title: "Anual"));
}
