import '../../../resources/utils/models/MonthlyHours.dart';

class YearModel {
  int year;
  List<MonthlyHours> data;

  YearModel(this.year, this.data);

  double getTotalYearRealHours() {
    double hours = 0.0;
    for (MonthlyHours e in data) {
      hours += e.getRealHoursNumber();
    }
    return hours;
  }

  double getTotalYearTheoricHours() {
    double hours = 0.0;
    for (MonthlyHours e in data) {
      hours += e.getTheoricHoursNumber();
    }
    return hours;
  }

  String getHoursString(double hours) {
    int differenceInHours = hours.toInt();
    int differenceInMinutes = ((hours * 60) % 60).toInt();

    return differenceInHours.toString() + "h " + differenceInMinutes.toString() + "min";
  }
}
