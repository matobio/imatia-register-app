import 'package:charts_flutter/flutter.dart' as charts;

class TotalHours {
  final int index;
  final double hours;
  final charts.Color color;
  final double theoricWeekHours;

  TotalHours(this.index, this.hours, this.color, this.theoricWeekHours);

  String getHours() {
    return hours == 0 ? "" : num.parse(hours.toStringAsFixed(2)).toString();
  }
}
