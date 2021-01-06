import 'package:intl/intl.dart';
import '../../../resources/utils/models/DayHours.dart';
import '../../../resources/utils/DateTimeUtils.dart' as dateTimeUtils;

class WeeklyModel {
  final dateFormatter = DateFormat("yyyy/MM/dd");
  DateTime initDate;
  DateTime endDate;
  List<DayHours> data;

  WeeklyModel(this.initDate, this.endDate, this.data);

  int getYear() {
    return initDate.year;
  }

  int getMonth() {
    return initDate.month;
  }

  double getTheoricWeekHours() {
    return dateTimeUtils.getTheoricWorkingHours(this.initDate.year, this.initDate.month);
  }

  double getRemainingHours() {
    return this.getTheoricWeekHours() - this.getTotalWeekHours();
  }

  double getTotalWeekHours() {
    double hours = 0.0;
    for (DayHours e in data) {
      hours += e.hours;
    }
    return hours;
  }

  String getTotalWeekHoursString() {
    double hours = getTotalWeekHours();

    return this.formatHours(hours);
  }

  String formatHours(double hours) {
    int differenceInHours = hours.abs().toInt();
    int differenceInMinutes = ((hours.abs() * 60) % 60).toInt();

    return differenceInHours.toString() + "h " + differenceInMinutes.toString() + "min";
  }

  String getInitDateFormatted() {
    return _getDateFormatted(this.initDate);
  }

  String getEndDateFormatted() {
    return _getDateFormatted(this.endDate);
  }

  String _getDateFormatted(DateTime date) {
    return date == null ? "" : dateFormatter.format(date);
  }
}
