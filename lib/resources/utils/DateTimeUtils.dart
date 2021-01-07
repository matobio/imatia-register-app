import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  if (date == null) {
    return "";
  }
  return DateFormat('yyyy/MM/dd').format(date);
}

String parseHours(num hours) {
  if (hours != null) {
    int totalMinutes = ((hours % 1) * 60).toInt();
    int totalHours = hours.toInt();
    return totalHours.toString() + "h " + totalMinutes.toString() + "min";
  }
  return '';
}

int getDayOfYear(DateTime date) {
  return int.parse(DateFormat("D").format(date));
}

int getWeekOfYear(DateTime date) {
  return ((getDayOfYear(date) - date.weekday + 10) / 7).floor();
}

String getMonthAsString(int monthNumber) {
  String month = "";
  switch (monthNumber) {
    case 1:
      month = "Enero";
      break;
    case 2:
      month = "Febrero";
      break;
    case 3:
      month = "Marzo";
      break;
    case 4:
      month = "Abril";
      break;
    case 5:
      month = "Mayo";
      break;
    case 6:
      month = "Junio";
      break;
    case 7:
      month = "Julio";
      break;
    case 8:
      month = "Agosto";
      break;
    case 9:
      month = "Septiembre";
      break;
    case 10:
      month = "Octubre";
      break;
    case 11:
      month = "Noviembre";
      break;
    case 12:
      month = "Diciembre";
      break;
    default:
  }
  return month;
}

String getDayOfWeekAsString(int weekday) {
  String day = "";

  switch (weekday) {
    case 1:
      day = "Lunes";
      break;
    case 2:
      day = "Martes";
      break;
    case 3:
      day = "Miércoles";
      break;
    case 4:
      day = "Jueves";
      break;
    case 5:
      day = "Viernes";
      break;
    case 6:
      day = "Sábado";
      break;
    case 7:
      day = "Domingo";
      break;
    default:
  }
  return day;
}

bool isLastLaborableDayOfMonthOrGreater(DateTime date) {
  DateTime lastDayOfMonth = getLastLaborableDayOfMonth(new DateTime(date.year, date.month, date.day, 0, 0, 0, 0));
  return date.compareTo(lastDayOfMonth) >= 0;
}

DateTime getLastLaborableDayOfMonth(DateTime date) {
  DateTime lastDayOfMonth = getLastDayOfMonth(date);
  DateTime firstDayOfMonth = new DateTime(lastDayOfMonth.year, lastDayOfMonth.month, 1);

  while (lastDayOfMonth.isAfter(firstDayOfMonth)) {
    if (lastDayOfMonth.weekday != DateTime.saturday && lastDayOfMonth.weekday != DateTime.sunday) {
      break;
    }
    lastDayOfMonth = lastDayOfMonth.subtract(new Duration(days: 1));
  }
  return lastDayOfMonth;
}

DateTime getLastDayOfMonth(DateTime date) {
  return (date.month < 12) ? new DateTime(date.year, date.month + 1, 0) : new DateTime(date.year + 1, 1, 0);
}

double getTheoricWorkingHours(int year, int month) {
  if (year != null && month != null) {
    if (month == DateTime.july || month == DateTime.august) {
      return 35;
    }
    if (year < 2021) {
      return 40;
    }
  }
  return 41;
}
