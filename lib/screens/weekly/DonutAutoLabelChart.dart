import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'utils/WeeklyModel.dart';
import '../../resources/utils/models/TotalHours.dart';

class DonutAutoLabelChart extends StatelessWidget {
  final WeeklyModel pageData;

  DonutAutoLabelChart(this.pageData);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        charts.PieChart(
          _createSampleData(),
          animate: true,
          defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 20,
          ),
        ),
        Center(
          child: Text(
            this.pageData == null ? "" : this.pageData.getTotalWeekHoursString(),
            style: TextStyle(fontSize: 15.0, color: Colors.amber, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  List<charts.Series<TotalHours, int>> _createSampleData() {
    List<TotalHours> data = [];

    double realHours = pageData == null ? 0.0 : this.pageData.getTotalWeekHours();
    double theoricHours = pageData.getTheoricWeekHours();

    data.add(TotalHours(1, realHours > theoricHours ? theoricHours : realHours,
        charts.ColorUtil.fromDartColor(Colors.green), theoricHours));
    data.add(TotalHours(2, realHours > theoricHours ? 0.0 : theoricHours - realHours,
        charts.MaterialPalette.gray.shade700, theoricHours));

    return [
      new charts.Series<TotalHours, int>(
        id: 'Hours',
        domainFn: (TotalHours hours, _) => hours.index,
        measureFn: (TotalHours hours, _) => hours.hours * 100 / hours.theoricWeekHours,
        data: data,
        labelAccessorFn: (TotalHours hours, _) => hours.getHours(),
        colorFn: (TotalHours hours, _) => hours.color,
      )
    ];
  }
}
