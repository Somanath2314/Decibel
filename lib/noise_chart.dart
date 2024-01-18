import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartWidget extends StatelessWidget {
  final List<SalesData> chartData;

  ChartWidget(this.chartData);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: DateTimeAxis(
            // interval: 100, // Set a smaller interval hereb
            majorGridLines: MajorGridLines(width: 0), // Hide grid lines
            majorTickLines: MajorTickLines(size: 0), // Hide tick lines
            // labelStyle: TextStyle(fontSize: 0), // Hide labels
            title: AxisTitle(text: 'Time'),
            intervalType: DateTimeIntervalType.auto),
        primaryYAxis: NumericAxis(
          // majorGridLines: MajorGridLines(width: 0), // Hide vertical grid lines
          majorTickLines: MajorTickLines(size: 0),
        ),
        series: <CartesianSeries>[
          LineSeries<SalesData, DateTime>(
            dataSource: chartData,
            xValueMapper: (SalesData sales, _) => sales.year,
            yValueMapper: (SalesData sales, _) => sales.sales,
          ),
        ],
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final DateTime year;
  final double sales;
}
