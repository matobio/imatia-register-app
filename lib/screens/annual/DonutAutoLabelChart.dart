import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../../resources/utils/models/TotalHours.dart';
import 'utils/YearModel.dart';

class DonutAutoLabelChart extends StatelessWidget {
  final YearModel pageData;

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
            this.pageData == null ? "" : this.pageData.getHoursString(this.pageData.getTotalYearRealHours()),
            style: TextStyle(fontSize: 12.0, color: Colors.amber, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  List<charts.Series<TotalHours, int>> _createSampleData() {
    List<TotalHours> data = new List();

    double realHours = this.pageData.getTotalYearRealHours();
    double theoricHours = this.pageData.getTotalYearTheoricHours();

    data.add(TotalHours(1, realHours > theoricHours ? theoricHours : realHours,
        charts.ColorUtil.fromDartColor(Colors.green), theoricHours));
    data.add(TotalHours(2, realHours > theoricHours ? 0.0 : theoricHours - realHours,
        charts.MaterialPalette.gray.shade700, theoricHours));

    return [
      new charts.Series<TotalHours, int>(
        id: 'Hours',
        domainFn: (TotalHours hours, _) => hours.index,
        measureFn: (TotalHours hours, _) => hours.hours * 100 / theoricHours,
        data: data,
        labelAccessorFn: (TotalHours hours, _) => hours.getHours(),
        colorFn: (TotalHours hours, _) => hours.color,
      )
    ];
  }
}
