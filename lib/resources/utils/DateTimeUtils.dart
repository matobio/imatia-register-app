import 'package:intl/intl.dart';

int getDayOfYear(DateTime date){
  // final diff = date.difference(new DateTime(date.year, 1, 1, 0, 0));
  // return diff.inDays;

  return int.parse(DateFormat("D").format(date));
}

int getWeekOfYear(DateTime date){
  return ((getDayOfYear(date) - date.weekday + 10) / 7).floor();
}