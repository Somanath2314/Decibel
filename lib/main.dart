import 'dart:async';

import 'package:decibel/noise_chart.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(NoiseMeterApp());

class NoiseMeterApp extends StatefulWidget {
  @override
  _NoiseMeterAppState createState() => _NoiseMeterAppState();
}

class _NoiseMeterAppState extends State<NoiseMeterApp> {
  List<SalesData> chartData = [];

  bool _isRecording = false;
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? noiseMeter;
  double? _maxDecibel;

  List<Map<String, dynamic>> recentEntries = [
    {'Max Value': 0}
  ];

  Future<void> fetchData() async {
    var url = "https://soms-6b7dd-default-rtdb.firebaseio.com/data.json";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> entries = [];
        data.forEach((key, value) {
          entries.add({"Max Value": key, ...value});
        });
        // Get the recent 6 entries
        recentEntries = entries.take(6).toList();

        print(recentEntries.length);
      } else {
        // Handle error
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      // Handle error
      print("Error: $error");
    }
  }

  void deleteAllData() async {
    var url = "https://soms-6b7dd-default-rtdb.firebaseio.com/data.json";

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        // Database contents deleted successfully
        print("All data deleted successfully.");
      } else {
        // Handle error
        print("Failed to delete data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      // Handle error
      print("Error: $error");
    }
    recentEntries = [
      {'Max Value': 0}
    ];
    setState(() {});
  }

  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void onData(NoiseReading noiseReading) {
    _latestReading = noiseReading;

    if (_latestReading?.maxDecibel != null) {
      _maxDecibel = _latestReading?.maxDecibel;

      // Add the new data point to the chartData list
      chartData.add(SalesData(DateTime.now(), _maxDecibel!));

      // Limit the number of data points to display
      if (chartData.length > 25) {
        chartData.removeAt(0);
      }

      // Update the chart
      setState(() {});
    }
  }

  void onError(Object error) {
    print(error);
    stop();
  }

  /// Check if microphone permission is granted.
  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  /// Request the microphone permission.
  Future<void> requestPermission() async =>
      await Permission.microphone.request();

  /// Start noise sampling.
  Future<void> start() async {
    // Create a noise meter, if not already done.
    noiseMeter ??= NoiseMeter();

    // Check permission to use the microphone.
    if (!(await checkPermission())) await requestPermission();

    // Listen to the noise stream.
    _noiseSubscription = noiseMeter?.noise.listen(onData, onError: onError);
    setState(() => _isRecording = true);
  }

  /// Stop sampling.
  void onRecent() async {
    await fetchData();
    setState(() {});
  }

  void stop() async {
    var url = "https://soms-6b7dd-default-rtdb.firebaseio.com/" + "data.json";
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({"Max Value": _maxDecibel!.toStringAsFixed(2)}),
      );
    } catch (error) {
      throw error;
    }
    _noiseSubscription?.cancel();
    setState(() => _isRecording = false);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Container(
                    margin: EdgeInsets.all(25),
                    child: Column(children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: Text(_isRecording ? "Mic: ON" : "Mic: OFF",
                            style: const TextStyle(
                                fontSize: 25, color: Colors.blue)),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text(
                          'Noise: ${_latestReading?.meanDecibel.toStringAsFixed(2)} dB',
                        ),
                      ),
                      Text(
                        'Max: ${_latestReading?.maxDecibel.toStringAsFixed(2)} dB',
                      ),
                    ])),
                // NoiseChart(chartData: _chartData),
                ChartWidget(chartData),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: onRecent, child: Text("Recent Data")),
                    ElevatedButton(
                        onPressed: deleteAllData, child: Text("Delete Data")),
                  ],
                ),
                Row(
                  children: recentEntries.map((entry) {
                    // Extract the 'marks' value from each map
                    final marks = entry['Max Value'];

                    // Return a Text widget with the 'marks' value
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(marks.toString()),
                    );
                  }).toList(),
                ),
              ])),
          floatingActionButton: FloatingActionButton(
            backgroundColor: _isRecording ? Colors.red : Colors.green,
            onPressed: _isRecording ? stop : start,
            child:
                _isRecording ? const Icon(Icons.stop) : const Icon(Icons.mic),
          ),
        ),
      );
}
