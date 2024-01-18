import 'package:flutter/material.dart';

class MaxValueWidget extends StatelessWidget {
  final double? maxDecibel;

  MaxValueWidget({required this.maxDecibel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(25),
      child: Column(
        children: [
          Text(
            'Max Value Captured:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            '${maxDecibel?.toStringAsFixed(2) ?? 'N/A'} dB',
            style: TextStyle(fontSize: 18, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
