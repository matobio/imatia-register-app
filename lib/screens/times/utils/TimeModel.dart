import 'package:intl/intl.dart';
import '../../../resources/utils/DateTimeUtils.dart' as dateTimeUtils;

class TimeModel {
  int presenceControlHoursId;
  int initDate;
  int endDate;
  String hours;
  String hoursDay;

  TimeModel(presenceControlHoursId, initDate, endDate, hours, hoursDay) {
    this.presenceControlHoursId = presenceControlHoursId;
    this.initDate = initDate;
    this.endDate = endDate;
    this.hours = hours;
    this.hoursDay = hoursDay;
  }

  String getDate() {
    if (this.initDate == null) {
      return "";
    }
    return DateFormat('yyyy/MM/dd').format(DateTime.fromMillisecondsSinceEpoch(this.initDate));
  }

  String getHoursDay() {
    return hoursDay == null ? "" : hoursDay;
  }

  String getDatePretty() {
    if (this.initDate == null) {
      return "";
    }
    DateTime date = DateTime.fromMillisecondsSinceEpoch(this.initDate);

    return dateTimeUtils.getDayOfWeekAsString(date.weekday) +
        " " +
        date.day.toString() +
        ", " +
        dateTimeUtils.getMonthAsString(date.month);
  }

  String getInitDate() {
    if (this.initDate == null) {
      return "";
    }
    return DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(this.initDate));
  }

  String getEndDate() {
    if (this.endDate == null) {
      return "";
    }
    return DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(this.endDate));
  }

  String getHours() {
    if (this.endDate == null) {
      return "";
    }
    return this.hours;
  }

  DateTime getInitDateWithoutTime() {
    if (this.initDate == null) {
      return null;
    }
    DateTime date = DateTime.fromMillisecondsSinceEpoch(this.initDate);
    return DateTime(date.year, date.month, date.day, 0, 0, 0);
  }
}
