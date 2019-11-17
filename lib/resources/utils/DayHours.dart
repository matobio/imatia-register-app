const String MONDAY = "L";
const String TUESDAY = "M";
const String WEDNESDAY = "Mi";
const String THURSDAY = "J";
const String FRIDAY = "V";

class DayHours {

  int weekday;
  double hours;

  DayHours(this.weekday, this.hours);

  String getHours(){
    return hours == 0 ? "" : num.parse(hours.toStringAsFixed(2)).toString();
  }

  String parseWeekday(){

    switch (this.weekday) {
      case 1:
        return MONDAY;
        break;
      case 2:
        return TUESDAY;
        break;
      case 3:
        return WEDNESDAY;
        break;
      case 4:
        return THURSDAY;
        break;
      case 5:
        return FRIDAY;
        break;
      default:
        return "";
    }
  }
}