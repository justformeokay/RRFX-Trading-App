import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GaugeScreen extends StatelessWidget {
  const GaugeScreen({super.key, this.recommendation, this.title});
  final String? recommendation;
  final String? title;

  double needlePointerHandler(){
    switch(recommendation){
      case "strong sell":
        return 10.0;
      case "strong buy":
        return 90.0;
      case "sell":
        return 30.0;
      case "buy":
        return 70.0;
      case "neutral":
        return 50.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SfRadialGauge(
          title: title == null ? null : GaugeTitle(
            text: title!,
            textStyle: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 100,
              ranges: <GaugeRange>[
                GaugeRange(
                    startValue: 0,
                    endValue: 20,
                    color: Colors.red,
                    label: 'Strong Sell',
                    startWidth: 10,
                    endWidth: 10),
                GaugeRange(
                    startValue: 20,
                    endValue: 40,
                    color: Colors.pink,
                    label: 'Sell',
                    startWidth: 10,
                    endWidth: 10),
                GaugeRange(
                    startValue: 40,
                    endValue: 60,
                    color: Colors.purple,
                    label: 'Neutral',
                    startWidth: 10,
                    endWidth: 10),
                GaugeRange(
                    startValue: 60,
                    endValue: 80,
                    color: Colors.greenAccent,
                    label: 'Buy',
                    startWidth: 10,
                    endWidth: 10),
                GaugeRange(
                    startValue: 80,
                    endValue: 100,
                    color: Colors.green,
                    label: 'Strong buy',
                    startWidth: 10,
                    endWidth: 10),
              ],
              pointers: <GaugePointer>[
                NeedlePointer(value: needlePointerHandler())
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Text(
                    recommendation != null ? recommendation!.toUpperCase() : "Empty",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  angle: 90,
                  positionFactor: 0.7,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}