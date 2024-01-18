import 'package:real_time_chart/real_time_chart.dart';

class RealTimeChartExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RealTimeChart(
      stream: positiveDataStream(),
      graphColor = Colors.red,
    );
  }
}

Stream<double> positiveDataStream() {
  return Stream.periodic(const Duration(milliseconds: 500), (_) {
    return Random().nextInt(300).toDouble();
  }).asBroadcastStream();
}
