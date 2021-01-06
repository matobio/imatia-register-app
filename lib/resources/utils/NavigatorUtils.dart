import 'package:flutter/material.dart';
import '../../screens/counter/counter_page.dart';
import '../../screens/times/times_page.dart';
import '../../screens/weekly/weekly_page.dart';
import '../../screens/monthly/monthly_page.dart';
import '../../screens/annual/annual_page.dart';

Future goToCounterPage(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CounterPage(title: "Contador")),
  );
}

Future goToTimesPage(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => TimesPage(title: "Tiempos")),
  );
}

Future goToMonthlyPage(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MonthlyPage(title: "Mensual")),
  );
}

Future goToWeeklyPage(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => WeeklyPage(title: "Semanal")),
  );
}

Future goToAnnualPage(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AnnualPage(title: "Anual")),
  );
}
