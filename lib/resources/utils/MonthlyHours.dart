import 'DateTimeUtils.dart';

class MonthlyHours {
  int year;
  int month;
  String theoricHours;
  String realHours;

  MonthlyHours(this.year, this.month, this.theoricHours, this.realHours);

  String getMonthString() {
    return getMonthAsString(this.month);
  }

  String getTheoricHours() {
    return this.theoricHours;
  }

  double getRealHoursNumber() {
    return _getHoursNumber(this.realHours);
  }

  double getTheoricHoursNumber() {
    return _getHoursNumber(this.theoricHours);
  }

  double _getHoursNumber(String totalHours) {
    if (totalHours.isEmpty) {
      return 0;
    }
    int hours = int.parse(totalHours.split("h")[0]);
    int minutes =
        int.parse(totalHours.split("h")[1].replaceAll("min", "").trim());
    return hours + minutes / 60.0;
  }

  String getRealHours() {
    return this.realHours;
  }

  String getMonthAndYear() {
    String month = getMonthAsString(this.month);
    return month + " " + this.year.toString();
  }

  String getDifference() {
    String diff = "";

    int realHours = 0;
    int theoricHours = 0;
    int realMinutes = 0;
    int theoricMinutes = 0;
    try {
      realHours = int.parse(this.realHours.split("h")[0]);
      theoricHours = int.parse(this.theoricHours.split("h")[0]);
      realMinutes =
          int.parse(this.realHours.split("h")[1].replaceAll("min", "").trim());
      theoricMinutes = int.parse(
          this.theoricHours.split("h")[1].replaceAll("min", "").trim());
    } catch (Exception) {}

    double difference = (realHours * 60.0 + realMinutes) -
        (theoricHours * 60.0 + theoricMinutes);
    diff = difference > 0 ? "+" : "-";

    int differenceInHours = difference ~/ 60;
    int differenceInMinutes = (difference.abs() % 60).toInt();

    diff = diff +
        differenceInHours.toString().replaceAll("-", "") +
        "h " +
        differenceInMinutes.toString() +
        "min";

    return diff;
  }
}
